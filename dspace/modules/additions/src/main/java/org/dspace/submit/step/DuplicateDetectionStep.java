/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.submit.step;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

import javax.persistence.Basic;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.swing.text.AbstractDocument;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.dspace.app.util.SubmissionInfo;
import org.dspace.app.util.Util;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Item;
import org.dspace.content.MetadataField;
import org.dspace.content.MetadataSchema;
import org.dspace.content.duplication.factory.DuplicationDetectionServiceFactory;
import org.dspace.content.duplication.service.DuplicationDetectionService;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.ItemService;
import org.dspace.content.service.MetadataFieldService;
import org.dspace.content.service.WorkspaceItemService;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.core.I18nUtil;
import org.dspace.services.ConfigurationService;
import org.dspace.submit.AbstractProcessingStep;
import org.dspace.utils.DSpace;
import org.dspace.workflow.WorkflowItem;
import org.dspace.workflow.WorkflowItemService;
import org.dspace.workflow.WorkflowService;
import org.dspace.workflow.factory.WorkflowServiceFactory;
import org.dspace.workflowbasic.BasicWorkflowItem;
import org.dspace.workflowbasic.service.BasicWorkflowService;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * This submission step requires the user to enter the title of the submission and looks for possible duplicates
 * already archived. The duplication detection is done by making a fuzzy search for the title.
 *
 * @author Pascal-Nicolas Becker (pascal at the dash library dash code dot de)
 */
public class DuplicateDetectionStep extends AbstractProcessingStep
{
    /***************************************************************************
     * STATUS / ERROR FLAGS (returned by doProcessing() if an error occurs or
     * additional user interaction may be required)
     *
     * (Do NOT use status of 0, since it corresponds to STATUS_COMPLETE flag
     * defined in the JSPStepManager class)
     **************************************************************************/
    // Mark that the form was send without adding a title.
    public static final int STATUS_NO_TITLE_ERROR = 1;
    // Mark that an internal error occured.  Details will be put into the logfile.
    public static final int STATUS_UNEXPECTED_ERROR = 2;
    // Mark that we found possible duplicates and stored them in the request attribute "duplicates".
    public static final int STATUS_DUPLICATES_DETECTED = 3;
    // We will send STATUS_COMPLETE if no duplicates where found or the user explicitly ignored possible duplicates.

    // We need to define a button the user may press to ignore possible duplicates (see the buttons defined in the
    // AbstractProcessingStep).
    public static final String IGNORE_DUPLICATES_BUTTON = "submit_ignore_duplicates";

    protected DuplicationDetectionService duplicationDetectionService = DuplicationDetectionServiceFactory.getInstance().getDuplicationDetectionService();
    protected WorkspaceItemService workspaceItemService = ContentServiceFactory.getInstance().getWorkspaceItemService();
    protected WorkflowItemService workflowItemService = WorkflowServiceFactory.getInstance().getWorkflowItemService();
    protected WorkflowService workflowService = WorkflowServiceFactory.getInstance().getWorkflowService();

    private static final Logger log = Logger.getLogger(DuplicateDetectionStep.class);

    /**
     * Adds the title to the item and checks for possible duplicate items within the repository.
     *
     * @param context
     *            current DSpace context
     * @param request
     *            current servlet request object
     * @param response
     *            current servlet response object
     * @param subInfo
     *            submission info object
     * @return Status or error flag which will be processed by
     *         doPostProcessing() below! (if STATUS_COMPLETE or 0 is returned,
     *         no errors occurred!)
     */
    @Override
    public int doProcessing(Context context, HttpServletRequest request,
                            HttpServletResponse response, SubmissionInfo subInfo)
            throws ServletException, IOException, SQLException,
            AuthorizeException
    {
        // get the submit button pressed by the user.
        String buttonPressed = Util.getSubmitButton(request, CANCEL_BUTTON);

        // if we showed possible duplicates and the user decided to ignore them, the step is completed
        if (buttonPressed.equals(IGNORE_DUPLICATES_BUTTON))
        {
            return STATUS_COMPLETE;
        }

        // get the title and item from the request.
        String title = request.getParameter("metadata_field_value");
        Item item = subInfo.getSubmissionItem().getItem();
        MetadataField field = duplicationDetectionService.getMetadataField(context);

        // check if we got one title, not more, not less.
        if (StringUtils.isEmpty(title))
        {
            return STATUS_NO_TITLE_ERROR;
        }
        if (item == null)
        {
            log.warn("Duplicate Detection Step called, but no item supplied.");
            return STATUS_UNEXPECTED_ERROR;
        }
        if (field == null)
        {
            log.warn("Unable to load title field. Field configured to store the title does not seem to exist in the database.");
            return STATUS_UNEXPECTED_ERROR;
        }

        // store the title value in the item.
        // overwrite any other title value, in case the title was loaded from another source (BibTeX, DataCite, WoS, ...)
        // and updated by the user
        itemService.clearMetadata(context, item, field.getMetadataSchema().getName(), field.getElement(),
                                  field.getQualifier(), Item.ANY);
        itemService.addMetadata(context, item, field.getMetadataSchema().getName(), field.getElement(),
                                field.getQualifier(), I18nUtil.getDefaultLocale().toString(),
                                StringUtils.trim(title));
        itemService.update(context, item);

        List<Item> duplicates = duplicationDetectionService.detectDuplicateReadableItems(context, field, item);
        if (duplicates.isEmpty())
        {
            log.debug("List of possible duplicates is empty");
            return STATUS_COMPLETE;
        }

        request.setAttribute("duplicates", duplicates);
        return STATUS_DUPLICATES_DETECTED;
    }


    /**
     * Retrieves the number of pages that this "step" extends over. This method
     * is used to build the progress bar.
     * <P>
     * This method may just return 1 for most steps (since most steps consist of
     * a single page). But, it should return a number greater than 1 for any
     * "step" which spans across a number of HTML pages. For example, the
     * configurable "Describe" step (configured using input-forms.xml) overrides
     * this method to return the number of pages that are defined by its
     * configuration file.
     * <P>
     * Steps which are non-interactive (i.e. they do not display an interface to
     * the user) should return a value of 1, so that they are only processed
     * once!
     *
     *
     * @param request
     *            The HTTP Request
     * @param subInfo
     *            The current submission information object
     *
     * @return the number of pages in this step
     */
    @Override
    public int getNumberOfPages(HttpServletRequest request,
                                SubmissionInfo subInfo) throws ServletException
    {
        /*
         * This method reports how many "pages" to put in
         * the Progress Bar for this Step.
         *
         * Most steps should just return 1 (which means the Step only appears
         * once in the Progress Bar).
         *
         * If this Step should be shown as multiple "Pages" in the Progress Bar,
         * then return a value higher than 1. For example, return 2 in order to
         * have this Step appear twice in a row within the Progress Bar.
         *
         * If you return 0, this Step will not appear in the Progress Bar at
         * ALL! Therefore it is important for non-interactive steps to return 0.
         */

        // in most cases, you'll want to just return 1
        return 1;
    }
}
