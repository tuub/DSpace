/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.content.duplication;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.dspace.authorize.service.AuthorizeService;
import org.dspace.content.Item;
import org.dspace.content.MetadataField;
import org.dspace.content.MetadataSchema;
import org.dspace.content.dao.ItemDAO;
import org.dspace.content.duplication.service.DuplicationDetectionService;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.ItemService;
import org.dspace.content.service.MetadataFieldService;
import org.dspace.content.service.WorkspaceItemService;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.services.ConfigurationService;
import org.dspace.utils.DSpace;
import org.dspace.versioning.VersionHistory;
import org.dspace.versioning.factory.VersionServiceFactory;
import org.dspace.versioning.service.VersionHistoryService;
import org.dspace.workflow.WorkflowItem;
import org.dspace.workflow.WorkflowItemService;
import org.dspace.workflowbasic.BasicWorkflowItem;
import org.dspace.workflowbasic.service.BasicWorkflowService;
import org.springframework.beans.factory.annotation.Autowired;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * Service to detect duplicate Items by a fuzzy search over their title.
 *
 * @author Pascal-Nicolas Becker (pascal at the dash library dash code dot de)
 */
public class DuplicationDetectionServiceImpl implements DuplicationDetectionService
{

    private Logger log = Logger.getLogger(DuplicationDetectionServiceImpl.class);
    @Autowired(required = true)
    protected transient ItemDAO itemDAO;
    @Autowired(required = true)
    protected transient ItemService itemService;
    @Autowired(required = true)
    protected transient WorkspaceItemService workspaceItemService;
    @Autowired(required = true)
    protected transient AuthorizeService authorizeService;
    @Autowired(required = true)
    protected transient WorkflowItemService workflowItemService;
    @Autowired(required = true)
    protected transient ConfigurationService configurationService;
    @Autowired(required = true)
    protected transient MetadataFieldService metadataFieldService;




    protected DuplicationDetectionServiceImpl() {};

    @Override
    public List<Item> detectDuplicateReadableItems(Context context, Item item)
            throws SQLException
    {
        return this.detectDuplicateReadableItems(context, this.getMetadataField(context), item);
    }

    @Override
    public List<Item> detectDuplicateReadableItems(Context context, MetadataField field, Item item)
            throws SQLException
    {
        int maxDistance = (new DSpace()).getConfigurationService()
                                        .getIntProperty("duplication.detection.edit-distance", 8);
        return this.detectDuplicateReadableItems(context, field, item, maxDistance);
    }

    @Override
    public List<Item> detectDuplicateReadableItems(Context context,
                                                       MetadataField field,
                                                       Item item,
                                                       int maxDistance)
            throws SQLException
    {
        // for performance reasons and caching it is helpful to run the following code in a read-only context,
        // especially as we're going to loop through multiple items.
        // To ensure calling methods don't get problems, we have to ensure to reinstate the previous context mode, when
        // we are done here. We'll use a try-final-block for that.
        Context.Mode previousMode = context.getCurrentMode();
        try
        {
            context.setMode(Context.Mode.READ_ONLY);

            // to prevent runtime problems in the user interface, we limit the list of possible duplicates.
            // The maximum number of possible duplicates can be configured and will be set to 10 by default. If the
            // configuration value is less than 1 all possible duplicates will be listed.
            int maximumDuplicates = configurationService.getIntProperty("duplication.detection.maximum-duplicates", 10);

            String value = itemService.getMetadataFirstValue(item,field.getMetadataSchema().getName(), field.getElement(),
                                                             field.getQualifier(), Item.ANY);
            // get possible duplicates
            Iterator<Item> duplicateIterator = this.detectDuplicateItems(context, field, value);

            // check which duplicates should be presented to the current user and store those in a list
            List<Item> duplicates = new ArrayList<>(maximumDuplicates < 1 ? 50 : maximumDuplicates);
            while(duplicateIterator.hasNext() && (maximumDuplicates < 1 || duplicates.size() <= maximumDuplicates))
            {
                Item candidate = duplicateIterator.next();
                log.debug("Found possible duplicate " + candidate.getID() + ", list currently contains "
                                  + Integer.toString(duplicates.size()) + " items.");

                // ignore the item that is currently being processed
                if (candidate.equals(item)) {
                    log.debug("Current candidate is the workspace item currently being processed => ignoring it.");
                    continue;
                }

                // ignore all versions of the same item
                VersionHistoryService versionHistoryService = null;
                try {
                    versionHistoryService = VersionServiceFactory.getInstance().getVersionHistoryService();
                } catch (Exception ex) {
                    // just to be sure, in case someone rips of the versioning service as he/she thinks that is the way
                    // to deactivate it (yes, there is a configuration property, at least for JSPUI).
                }

                if (versionHistoryService != null)
                {
                    // if our item and the duplicate candidate share the same versionHistory, they are two different
                    // versions of the same item.
                    VersionHistory versionHistory = versionHistoryService.findByItem(context, item);
                    VersionHistory candiateVersionHistory = versionHistoryService.findByItem(context, candidate);
                    // if the versionHistory is null, either versioning is switched off or the item doesn't have
                    // multiple versions
                    if (versionHistory != null
                            && candiateVersionHistory != null
                            && versionHistory.equals(candiateVersionHistory))
                    {
                        continue;
                    }
                }

                // ignore workspace items as we cannot assume the submission will be finished and the deposit license granted
                if (workspaceItemService.findByItem(context, candidate) != null)
                {
                    log.debug("Current candidate is a workspace item => ignoring it.");
                    // this item won't be added to the results list and won't be processed further => uncache it.
                    context.uncacheEntity(candidate);
                    continue;
                }

                // add item if current user may administrate it
                if (authorizeService.isAdmin(context, candidate))
                {
                    log.debug("Current candidate can be administrated by current user => taking it into account.");
                    duplicates.add(candidate);
                    continue;
                }

                // add WorkflowItem if user may review it
                // JSPUI can use the basic workflow service only
                WorkflowItem wfi = workflowItemService.findByItem(context, candidate);
                if (wfi != null && wfi instanceof BasicWorkflowItem)
                {
                    BasicWorkflowItem bfi = (BasicWorkflowItem) wfi;
                    int state = bfi.getState();
                    if ((state == BasicWorkflowService.WFSTATE_STEP1POOL || state == BasicWorkflowService.WFSTATE_STEP1) && authorizeService.authorizeActionBoolean(context, context.getCurrentUser(), bfi.getCollection(), Constants.WORKFLOW_STEP_1, true)
                            || (state == BasicWorkflowService.WFSTATE_STEP2POOL || state == BasicWorkflowService.WFSTATE_STEP2) && authorizeService.authorizeActionBoolean(context, context.getCurrentUser(), bfi.getCollection(), Constants.WORKFLOW_STEP_2, true)
                            || (state == BasicWorkflowService.WFSTATE_STEP3POOL || state == BasicWorkflowService.WFSTATE_STEP3) && authorizeService.authorizeActionBoolean(context, context.getCurrentUser(), bfi.getCollection(), Constants.WORKFLOW_STEP_3, true))
                    {
                        log.debug("Current candiadte is a workflow Itme the current user is able to review => taking it into account.");
                        duplicates.add(candidate);
                        continue;
                    }
                    log.debug("Current candidate is a workflow item the current user may not review => ignoring it.");
                    context.uncacheEntity(candidate);
                    continue;
                }

                // ignore xmlworkflowitems
                if (wfi  != null)
                {
                    log.debug("Current candidate is a xmlworkflow item => ignoring it.");
                    context.uncacheEntity(candidate);
                    continue;
                }

                // we already checked, that we cannot administrate the item -> skip it if it is withdrawn.
                if (candidate.isWithdrawn())
                {
                    log.debug("Current item is withdrawn and we cannot administrate it -> ignore it.");
                    context.uncacheEntity(candidate);
                    continue;
                }

                // it seems we have a normal item here. Add it if the user is allowed to see it.
                if (authorizeService.authorizeActionBoolean(context, candidate, Constants.READ))
                {
                    log.debug("Current candidate seems to be an acceptable item => taking it into account.");
                    duplicates.add(candidate);
                } else {
                    // uncache all items we won't further process
                    log.debug("Current candidate seems to be an item the current user is not allowed to see => ignoring it.");
                    context.uncacheEntity(candidate);
                }
            }

            log.debug("Returning a list of possible duplicates containing " + Integer.toString(duplicates.size()) + " items.");
            return duplicates;
        } finally {
            // restore the previous context mode
            context.setMode(previousMode);
        }
    }

    @Override
    public Iterator<Item> detectDuplicateItems(Context context, String value)
            throws SQLException
    {
        return this.detectDuplicateItems(context, this.getMetadataField(context), value);
    }

    @Override
    public Iterator<Item> detectDuplicateItems(Context context, MetadataField field, String value)
            throws SQLException
    {
        int maxDistance = configurationService.getIntProperty("duplication.detection.edit-distance", 8);
        return this.detectDuplicateItems(context, field, value, maxDistance);
    }

    @Override
    public Iterator<Item> detectDuplicateItems(Context context, MetadataField field, String value, int maxDistance)
            throws SQLException
    {
        return itemDAO.detectDuplicateItems(context, field, value, maxDistance);
    }

    @Override
    public MetadataField getMetadataField(Context context)
            throws SQLException
    {
        // Load the metadata field in which we shall store the title. If the default is changed within the configuration
        // a syntax of <schema>.<element>.<qualifier> will be used. We need to parse that first.
        String schema = MetadataSchema.DC_SCHEMA;
        String element = "title";
        String qualifier = null;

        String fieldProperty = configurationService.getProperty("duplication.detection.field");
        if (StringUtils.isEmpty(fieldProperty))
        {
            fieldProperty = MetadataSchema.DC_SCHEMA.concat(".title");
        }
        String[] fieldDefinition = fieldProperty.split(".");

        if (fieldDefinition.length >= 1 && !StringUtils.isEmpty(fieldDefinition[0]))
        {
            schema = fieldDefinition[0];
        }
        if (fieldDefinition.length >= 2 && !StringUtils.isEmpty(fieldDefinition[1]))
        {
            element = fieldDefinition[1];
        }
        if (fieldDefinition.length >= 3 && !StringUtils.isEmpty(fieldDefinition[2]))
        {
            qualifier = fieldDefinition[3];
        }

        // Don't cache the metadatafield to not have to restart the servlet container when the configuration is changed.
        return metadataFieldService.findByElement(context, schema, element, qualifier);
    }
}
