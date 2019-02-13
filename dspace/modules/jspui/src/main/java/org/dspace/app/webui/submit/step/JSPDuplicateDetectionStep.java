/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.webui.submit.step;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.dspace.app.util.SubmissionInfo;
import org.dspace.app.webui.submit.JSPStep;
import org.dspace.app.webui.submit.JSPStepManager;
import org.dspace.app.webui.util.UIUtil;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Item;
import org.dspace.content.MetadataField;
import org.dspace.content.duplication.factory.DuplicationDetectionServiceFactory;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.ItemService;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Context;
import org.dspace.submit.AbstractProcessingStep;
import org.dspace.submit.step.DuplicateDetectionStep;
import org.dspace.submit.step.SampleStep;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * This is the JSP binding class for the duplicate detection step.
 *
 * @author Pascal-Nicolas Becker (pascal at the dash library dash code dot de)
 */
public class JSPDuplicateDetectionStep extends JSPStep
{
    protected static final transient ItemService itemService = ContentServiceFactory.getInstance().getItemService();

    /** JSP which asks the user to give us the title */
    private static final String REQUEST_TITLE_JSP = "/submit/request-title.jsp";
    /** JSP which displays possible duplicates and asks how to proceed */
    private static final String REVIEW_DUPLICATES_JSP = "/submit/handle-duplicates.jsp";

    /**
     * Do any pre-processing to determine which JSP (if any) is used to generate
     * the UI for this step. This method should include the gathering and
     * validating of all data required by the JSP. In addition, if the JSP
     * requires any variable to passed to it on the Request, this method should
     * set those variables.
     * <P>
     * If this step requires user interaction, then this method must call the
     * JSP to display, using the "showJSP()" method of the JSPStepManager class.
     * <P>
     * If this step doesn't require user interaction OR you are solely using
     * Manakin for your user interface, then this method may be left EMPTY,
     * since all step processing should occur in the doProcessing() method.
     *
     * @param context
     *            current DSpace context
     * @param request
     *            current servlet request object
     * @param response
     *            current servlet response object
     * @param subInfo
     *            submission info object
     */
    public void doPreProcessing(Context context, HttpServletRequest request,
                                HttpServletResponse response, SubmissionInfo subInfo)
            throws ServletException, IOException, SQLException,
            AuthorizeException
    {
        // load the metadatafield we're using to store the title
        MetadataField field = DuplicationDetectionServiceFactory.getInstance().getDuplicationDetectionService().getMetadataField(context);
        if (field == null)
        {
            throw new RuntimeException("The duplicate detection step is configured to use a field that does not exist.");
        }
        if (field.getMetadataSchema() == null)
        {
            throw new IllegalStateException("field does not belong to any schema");
        }

        // load the item we are working on
        Item item = subInfo.getSubmissionItem().getItem();
        if (item == null)
        {
            throw new IllegalStateException("The duplicate detection step was called, but the submission item does not exist.");
        }

        // check if a title was filled in in any previous step. Store it in the request to present it to the user.
        String title = itemService.getMetadataFirstValue(item, field.getMetadataSchema().getName(), field.getElement(),
                                                         field.getQualifier(), Item.ANY);
        request.setAttribute("item_title", title);

        // show the JSP that asks for the title.
        JSPStepManager.showJSP(request, response, subInfo, REQUEST_TITLE_JSP);
    }

    /**
     * Do any post-processing after the step's backend processing occurred (in
     * the doProcessing() method).
     * <P>
     * It is this method's job to determine whether processing completed
     * successfully, or display another JSP informing the users of any potential
     * problems/errors.
     * <P>
     * If this step doesn't require user interaction OR you are solely using
     * Manakin for your user interface, then this method may be left EMPTY,
     * since all step processing should occur in the doProcessing() method.
     *
     * @param context
     *            current DSpace context
     * @param request
     *            current servlet request object
     * @param response
     *            current servlet response object
     * @param subInfo
     *            submission info object
     * @param status
     *            any status/errors reported by doProcessing() method
     */
    public void doPostProcessing(Context context, HttpServletRequest request,
                                 HttpServletResponse response, SubmissionInfo subInfo, int status)
            throws ServletException, IOException, SQLException,
            AuthorizeException
    {
        // doPostProcessing is called after DuplicatDetectionStep.doProcessing run. Check the status and handle it.
        if (status == DuplicateDetectionStep.STATUS_NO_TITLE_ERROR)
        {
            // we did not get any title. Show the request title page again and add an error message
            request.setAttribute("errormessage", "jsp.submit.duplicate-detection.noTitle");
            JSPStepManager.showJSP(request, response, subInfo, REQUEST_TITLE_JSP);
        } else if (status == DuplicateDetectionStep.STATUS_UNEXPECTED_ERROR)
        {
            // either the metadata field was not found or we did not got any item with the submissionInfo.
            // details will be logged by the DuplicationDetecitonService. Show a common error message and ask to enter
            // the title again (show request-title.jsp).
            request.setAttribute("errormessage", "jsp.submit.duplicate-detection.unexpectedError");
            request.setAttribute("doNotProceed", Boolean.TRUE);
            JSPStepManager.showJSP(request, response, subInfo, REQUEST_TITLE_JSP);
        } else if (status == DuplicateDetectionStep.STATUS_DUPLICATES_DETECTED)
        {
            // We found duplicates. The list of duplicates is added by the DuplicationDetectionStep.
            // List of duplicates is set by the DuplicateDetectionStep as request attribute
            JSPStepManager.showJSP(request, response, subInfo, REVIEW_DUPLICATES_JSP);
        }
    }

    /**
     * Retrieves the number of pages that this "step" extends over. This method
     * is used by the SubmissionController to build the progress bar.
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
     * @param subInfo The current submission information object
     *
     * @return the number of pages in this step
     * @throws ServletException Won't occur, is just present as the implemented interface contains it.
     */
    public int getNumberOfPages(HttpServletRequest request,
                                SubmissionInfo subInfo) throws ServletException
    {
        /*
         * This method tells the SubmissionController how many "pages" to put in
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

    /**
     * Return the URL path (e.g. /submit/review-metadata.jsp) of the JSP
     * which will review the information that was gathered in this Step.
     * <P>
     * This Review JSP is loaded by the 'Verify' Step, in order to dynamically
     * generate a submission verification page consisting of the information
     * gathered in all the enabled submission steps.
     *
     * @param context
     *            current DSpace context
     * @param request
     *            current servlet request object
     * @param response
     *            current servlet response object
     * @param subInfo
     *            submission info object
     */
    public String getReviewJSP(Context context, HttpServletRequest request,
                               HttpServletResponse response, SubmissionInfo subInfo)
    {
        return NO_JSP;
    }

}
