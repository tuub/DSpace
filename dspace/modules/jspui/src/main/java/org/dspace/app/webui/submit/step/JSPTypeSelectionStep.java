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
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.log4j.Logger;
import org.apache.commons.lang.StringUtils;

import org.dspace.app.util.DCInputsReader;
import org.dspace.app.util.DCInputsReaderException;
import org.dspace.app.util.SubmissionInfo;
import org.dspace.app.util.Util;
import org.dspace.app.webui.submit.JSPStep;
import org.dspace.app.webui.submit.JSPStepManager;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.authorize.AuthorizeException;
import org.dspace.core.Context;
import org.dspace.submit.step.TypeSelectionStep;
import org.dspace.content.Item;
import org.dspace.content.MetadataValue;
import org.dspace.content.WorkspaceItem;

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
public class JSPTypeSelectionStep extends JSPStep
{
    /** JSP which displays default license information * */
    private static final String TYPE_SELECTION_JSP = "/submit/select-type.jsp";
    
    private static final Logger log = Logger.getLogger(JSPTypeSelectionStep.class);

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
        prepareJSP(request, subInfo);        
        JSPStepManager.showJSP(request, response, subInfo, TYPE_SELECTION_JSP);
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
        String buttonPressed = Util.getSubmitButton(request, TypeSelectionStep.CANCEL_BUTTON);
        if (buttonPressed.equalsIgnoreCase(TypeSelectionStep.NEXT_BUTTON)
                && status == TypeSelectionStep.STATUS_COMPLETE)
        {
            return;
        }
        
        // Error Handling
        if (buttonPressed.equalsIgnoreCase(TypeSelectionStep.NEXT_BUTTON))
        {
            if (status == TypeSelectionStep.STATUS_INVALID_TYPE_COUNT)
            {
                request.setAttribute("invalid_type_count", true);
            }
            if (status == TypeSelectionStep.STATUS_NO_TYPE_SELECTED)
            {
                request.setAttribute("no_type_selected", true);
            }
            prepareJSP(request, subInfo);
            JSPManager.showJSP(request, response, TYPE_SELECTION_JSP);
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
    
    void prepareJSP(HttpServletRequest request, SubmissionInfo subInfo)
    {
        Item item = subInfo.getSubmissionItem().getItem();
        
        List<MetadataValue> types = item.getItemService().getMetadataByMetadataString(item, "dc.type");
        if (types != null && types.size() > 0)
        {
            request.setAttribute("existing_type_selection", types);
        }

        // Load the DCInputsReader that parses the inputs-form.xml file.
        DCInputsReader dcir;
        try {
            dcir = new DCInputsReader();
        } catch (DCInputsReaderException ex) {
            throw new RuntimeException("Cannot Parse inputs-forms.xml.", ex);
        }
        // filter the value pairs we want to show
        Map<String, List<String>> valuePairs = new HashMap<String, List<String>>();
        Iterator<String> pairNameIter = dcir.getPairsNameIterator();
        while (pairNameIter.hasNext())
        {
            String name = pairNameIter.next();
            for (String val : TypeSelectionStep.getPairValueNames())
            {
                if (StringUtils.equalsIgnoreCase(val, name))
                {
                    valuePairs.put(name, dcir.getPairs(name));
                }
            }
        }
        request.setAttribute("type_selection_pairs", valuePairs);
    }
    
}
