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
import org.apache.log4j.Logger;

import org.dspace.app.util.SubmissionInfo;
import org.dspace.app.util.Util;
import org.dspace.app.webui.servlet.SubmissionController;
import org.dspace.app.webui.submit.JSPStep;
import org.dspace.app.webui.submit.JSPStepManager;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.app.webui.util.UIUtil;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.WorkspaceItem;
import org.dspace.core.Context;
import org.dspace.core.LogManager;
import org.dspace.submit.step.PrivacyStatementsStep;

/**
 * Privacy Statements servlet for DSpace JSP-UI. Handles privacy statements every
 * users to must acknowledge before metadata and files can be submitted.
 * <P>
 * This JSPStep class works with the SubmissionController servlet
 * for the JSP-UI
 *
 * The following methods are called in this order:
 * <ul>
 * <li>Call doPreProcessing() method</li>
 * <li>If showJSP() was specified from doPreProcessing(), then the JSP
 * specified will be displayed</li>
 * <li>If showJSP() was not specified from doPreProcessing(), then the
 * doProcessing() method is called and the step completes immediately</li>
 * <li>Call doProcessing() method on appropriate AbstractProcessingStep after
 * the user returns from the JSP, in order to process the user input</li>
 * <li>Call doPostProcessing() method to determine if more user interaction is
 * required, and if further JSPs need to be called.</li>
 * <li>If there are more "pages" in this step then, the process begins again
 * (for the new page).</li>
 * <li>Once all pages are complete, control is forwarded back to the
 * SubmissionController, and the next step is called.</li>
 * </ul>
 *
 * @see org.dspace.app.webui.servlet.SubmissionController
 * @see org.dspace.app.webui.submit.JSPStep
 * @see org.dspace.submit.step.PrivacyStatementsStep
 *
 * @author Tim Donohue
 * @version $Revision$
 */
public class JSPPrivacyStatementsStep extends JSPStep
{
    /** JSP which displays default license information * */
    private static final String PRIVACY_SATEMENTS_JSP = "/submit/privacy_statements.jsp";
    
    private static final Logger log = Logger.getLogger(JSPPrivacyStatementsStep.class);

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
        JSPStepManager.showJSP(request, response, subInfo, PRIVACY_SATEMENTS_JSP);
    }

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
     * @param status
     *            any status/errors reported by doProcessing() method
     */
    public void doPostProcessing(Context context, HttpServletRequest request,
            HttpServletResponse response, SubmissionInfo subInfo, int status)
            throws ServletException, IOException, SQLException,
            AuthorizeException
    {
        String buttonPressed = Util.getSubmitButton(request, PrivacyStatementsStep.CANCEL_BUTTON);
        if (buttonPressed.equalsIgnoreCase(PrivacyStatementsStep.NEXT_BUTTON)
                && status != PrivacyStatementsStep.STATUS_COMPLETE)
        {
            request.setAttribute("privacy_statements_rejected", true);
            JSPManager.showJSP(request, response, PRIVACY_SATEMENTS_JSP);
        }
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
        return NO_JSP; //signing off on license does not require reviewing
    }
}
