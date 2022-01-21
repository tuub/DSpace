/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.rest.submit.step;

import java.util.ArrayList;
import java.util.List;
import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.dspace.app.rest.model.patch.Operation;
import org.dspace.app.rest.model.step.DataIdentifiers;
import org.dspace.app.rest.submit.AbstractProcessingStep;
import org.dspace.app.rest.submit.SubmissionService;
import org.dspace.app.rest.utils.ContextUtil;
import org.dspace.app.util.SubmissionStepConfig;
import org.dspace.content.InProgressSubmission;
import org.dspace.content.Item;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.handle.factory.HandleServiceFactory;
import org.dspace.identifier.DOI;
import org.dspace.identifier.Handle;
import org.dspace.identifier.IdentifierException;
import org.dspace.identifier.doi.DOIIdentifierNotApplicableException;
import org.dspace.identifier.factory.IdentifierServiceFactory;
import org.dspace.identifier.service.IdentifierService;
import org.dspace.services.factory.DSpaceServicesFactory;
import org.dspace.services.model.Request;

/**
 * Submission processing step to mint / reserve identifiers (if applicable) and return
 * identifier data for use in the 'identifiers' submission section component in dspace-angular.
 *
 * This method can be extended to allow (if authorised) an operation to be sent which will
 * override an item filter and force reservation of an identifier.
 *
 * @author Kim Shepherd
 * @author Marsa Haoua
 */
public class ShowIdentifiersStep extends AbstractProcessingStep {

    private static final Logger log = LogManager.getLogger(ShowIdentifiersStep.class);

    /**
     * Override DataProcessing.getData, return data identifiers from getIdentifierData()
     *
     * @param submissionService The submission service
     * @param obj               The workspace or workflow item
     * @param config            The submission step configuration
     * @return                  A simple DataIdentifiers bean containing doi, handle and list of other identifiers
     */
    @Override
    public DataIdentifiers getData(SubmissionService submissionService, InProgressSubmission obj,
                                   SubmissionStepConfig config) throws Exception {
        // We effectively do some 'pre-processing' here, though there should be no need to implement
        // ListenerProcessingStep. We'll retrieve the identifiers first, if the the item do not have
        // any identifier, we'll just attempt a mint/reserve here. It'll either succeed, fail, or skip
        // due to filter. We'll do so if and only if the user have the proper access to mint/reserve
        // identifiers. Otherwise this will cause an AuthorizeException for the WRITE action as this
        // method is called for all in progress submission items and a submitter user can not
        // mint/reserve identifiers for a workflow item, in this case we just return the identifiers
        // data that already exist or have been minted/reserved for the workspace item.
        DataIdentifiers dataIdentifiers = getIdentifierData(obj);
        if (dataIdentifiers.hasNoIdentifiers() && authorizeService.authorizeActionBoolean(getContext(), obj.getItem(), Constants.WRITE)) {
            try {
                reserveIdentifier(getContext(), obj);
                dataIdentifiers = getIdentifierData(obj);
            } catch (IdentifierException e) {
                // Something really went wrong! Log message and rethrow
                log.error("Identifier exception encountered when reserving item: " + e.getLocalizedMessage());
                throw new Exception(e);
            }
        }
        return dataIdentifiers;
    }

    /**
     * Get data about existing identifiers for this in-progress submission item - this method doesn't require
     * submissionService or step config, so can be more easily called from doPatchProcessing as well
     *
     * @param obj   The workspace or workflow item
     * @return      A simple DataIdentifiers bean containing doi, handle and list of other identifiers
     */
    private DataIdentifiers getIdentifierData(InProgressSubmission obj) {
        log.debug("getIdentifierData() called");
        Context context = getContext();
        DataIdentifiers result = new DataIdentifiers();
        // Load identifier service
        IdentifierService identifierService =
            IdentifierServiceFactory.getInstance().getIdentifierService();
        // Attempt to look up handle and DOI identifiers for this item
        String handle = identifierService.lookup(context, obj.getItem(), Handle.class);
        String doi = identifierService.lookup(context, obj.getItem(), DOI.class);

        // Look up all identifiers and if they're not the DOI or handle, add them to the 'other' list
        List<String> otherIdentifiers = new ArrayList<>();
        for (String identifier : identifierService.lookup(context, obj.getItem())) {
            if (!StringUtils.equals(doi, identifier) && !StringUtils.equals(handle, identifier)) {
                otherIdentifiers.add(identifier);
            }
        }

        // If we got a DOI, format it to its external form
        if (StringUtils.isNotEmpty(doi)) {
            try {
                doi = IdentifierServiceFactory.getInstance().getDOIService().DOIToExternalForm(doi);
            } catch (IdentifierException e) {
                log.error("Error formatting DOI: " + doi);
            }
        }
        // If we got a handle, format it to its canonical form
        if (StringUtils.isNotEmpty(handle)) {
            handle = HandleServiceFactory.getInstance().getHandleService().getCanonicalForm(handle);
        }

        // Populate bean with data and return
        result.setDoi(doi);
        result.setHandle(handle);
        result.setOtherIdentifiers(otherIdentifiers);
        log.debug(result);

        return result;
    }

    /**
     * Mint / reserve an identifier for later registration ( by the DOI organiser for the DOI identifiers for example)
     * This method allows the filter to determine whether the item should actually get
     * an identifier or not
     * @param context   DSpace context
     * @param obj       The workspace or workflow item
     * @throws Exception
     */
    private void reserveIdentifier(Context context, InProgressSubmission obj) throws Exception {
        Item item = obj.getItem();
        log.debug("reserveIdentifier called for item " + obj.getItem().getID());
        if (item == null) {
            log.error("Null item passed to reserve identifier action");
        }
        try {
            // Try an ordinary reservation, obeying the filter if configured
            IdentifierServiceFactory.getInstance().getIdentifierService().reserve(context, item);
        } catch (DOIIdentifierNotApplicableException e) {
            // This is a non-fatal error - it just means the filter has been applied and this item should
            // not receive a DOI
            assert item != null;
            log.info("DOI reservation skipped (filtered) for item: " + item.getID());
        }
    }

    /**
     * Utility method to get DSpace context from the HTTP request
     * @return  DSpace context
     */
    private Context getContext() {
        Context context = null;
        Request currentRequest = DSpaceServicesFactory.getInstance().getRequestService().getCurrentRequest();
        if (currentRequest != null) {
            HttpServletRequest request = currentRequest.getHttpServletRequest();
            context = ContextUtil.obtainContext(request);
        } else {
            context = new Context();
        }

        return context;
    }

    /**
     * This step is currently just for displaying identifiers and does not take additional patch operations
     * @param context
     *            the DSpace context
     * @param currentRequest
     *            the http request
     * @param source
     *            the in progress submission
     * @param op
     *            the json patch operation
     * @param stepConf
     * @throws Exception
     */
    @Override
    public void doPatchProcessing(Context context, HttpServletRequest currentRequest, InProgressSubmission source,
                                  Operation op, SubmissionStepConfig stepConf) throws Exception {
        log.warn("Not implemented");
    }
}