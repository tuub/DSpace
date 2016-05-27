/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.submit.step;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.logging.Level;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.dspace.app.util.DCInputsReader;
import org.dspace.app.util.DCInputsReaderException;

import org.dspace.app.util.SubmissionInfo;
import org.dspace.app.util.Util;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Bitstream;
import org.dspace.content.BitstreamFormat;
import org.dspace.content.Bundle;
import org.dspace.content.Item;
import org.dspace.content.MetadataValue;
import org.dspace.content.WorkspaceItem;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.ItemService;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Context;
import org.dspace.submit.AbstractProcessingStep;

/**
 * Privacy Statements servlet for DSpace. Asks the user before submitting any
 * metadata whether she or he will respect privacy issues and has the permission
 * of the authors and co-authors to submit the metadata.
 * <P>
 * This class performs all the behind-the-scenes processing that
 * this particular step requires.  This class's methods is utilized 
 * by the JSP-UI
 * <P>
 * 
 * @see org.dspace.app.util.SubmissionConfig
 * @see org.dspace.app.util.SubmissionStepConfig
 * @see org.dspace.submit.AbstractProcessingStep
 * 
 * @author Pascal-Nicolas Becker
 */
public class TypeSelectionStep extends AbstractProcessingStep
{
    /***************************************************************************
     * STATUS / ERROR FLAGS (returned by doProcessing() if an error occurs or
     * additional user interaction may be required)
     * 
     * (Do NOT use status of 0, since it corresponds to STATUS_COMPLETE flag
     * defined in the JSPStepManager class)
     **************************************************************************/
    // user did not chose a type
    public static final int STATUS_NO_TYPE_SELECTED = 1;
    // user chose more than one type
    public static final int STATUS_INVALID_TYPE_COUNT = 2;
    
    private final static Logger log = Logger.getLogger(TypeSelectionStep.class);
    
    protected final static ItemService itemService = ContentServiceFactory.getInstance().getItemService();
    
    private static String[] pairValueNames = new String[] { "publication_types", "research_data_types" };
    
    public static String[] getPairValueNames()
    {
        // TODO load from configuration
        return pairValueNames.clone();
    }
    /**
     * Do any processing of the information input by the user, and/or perform
     * step processing (if no user interaction required)
     * <P>
     * It is this method's job to save any data to the underlying database, as
     * necessary, and return error messages (if any) which can then be processed
     * by the appropriate user interface (JSP-UI or XML-UI)
     * <P>
     * NOTE: If this step is a non-interactive step (i.e. requires no UI), then
     * it should perform *all* of its processing in this method!
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
    
    public int doProcessing(Context context, HttpServletRequest request,
            HttpServletResponse response, SubmissionInfo subInfo)
            throws ServletException, IOException, SQLException,
            AuthorizeException
    {
        
        // check if user chose only one type
        String[] type_selection = request.getParameterValues("dc_type");
        if( type_selection == null || type_selection.length == 0)
        {            
            return STATUS_NO_TYPE_SELECTED;
        }
        if( type_selection.length > 1)
        {            
            return STATUS_INVALID_TYPE_COUNT;
        }
        
        Item item = subInfo.getSubmissionItem().getItem();
        
        List<MetadataValue> type = itemService.getMetadataByMetadataString(item, "dc.type");
        if ( !itemService.getMetadataByMetadataString(item, "dc.type").isEmpty())
        {
            itemService.clearMetadata(context, item, "dc", "type", Item.ANY, Item.ANY);
        }
        itemService.addMetadata(context, item, "dc", "type", null, null, type_selection[0]);
        itemService.update(context, item);
        
        return STATUS_COMPLETE; // no errors!
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
     * @param request
     *            The HTTP Request
     * @param subInfo
     *            The current submission information object
     * 
     * @return the number of pages in this step
     */
    public int getNumberOfPages(HttpServletRequest request,
            SubmissionInfo subInfo) throws ServletException
    {
        // always just one page of privacy statements
        return 1;
    }
    
    
    
}
