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
import java.util.List;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import org.dspace.app.util.SubmissionInfo;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Bitstream;
import org.dspace.content.BitstreamFormat;
import org.dspace.content.Bundle;
import org.dspace.content.Item;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.BitstreamFormatService;
import org.dspace.content.service.BitstreamService;
import org.dspace.content.service.BundleService;
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
public class PrivacyStatementsStep extends AbstractProcessingStep
{
    /***************************************************************************
     * STATUS / ERROR FLAGS (returned by doProcessing() if an error occurs or
     * additional user interaction may be required)
     * 
     * (Do NOT use status of 0, since it corresponds to STATUS_COMPLETE flag
     * defined in the JSPStepManager class)
     **************************************************************************/
    // user did not answered the statemtents
    public static final int STATUS_UNACCEPTED_PRIVACY_STATEMENTS = 1;
    
    public static final String BUNDLE_NAME = "PRIVACYSTATEMENT";
    public static final String BITSTREAM_NAME = "privacy_statements.txt";
    
    private static final BitstreamFormatService bitstreamFormatService = ContentServiceFactory.getInstance().getBitstreamFormatService();

    /** The fully qualified pathname of file containing the privacy statements. */
    private static String configFilePath = ConfigurationManager.getProperty("dspace.dir")
            + File.separator + "config" + File.separator + "privacy-statements.cfg";
    
    private static String[] statements = null;
    
    private final static Logger log = Logger.getLogger(PrivacyStatementsStep.class);
    
    public PrivacyStatementsStep()
    {
        loadPrivacyStatements();
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
        // check if user aggreed to all privacy statements
        String[] checked_statements = request.getParameterValues("privacy_statements");
        for (int i = 0; i < statements.length; i++)
        {
            if (!ArrayUtils.contains(checked_statements, "privacy_statement_"+i))
            {
                return STATUS_UNACCEPTED_PRIVACY_STATEMENTS;
            }
        }

        // We should remove all Privacy Statements that were stored before
        // (in case the privacy statements were updated meanwhile)
        // to do so, we store a list of bundle UUIDs, create a new Bundle with 
        // the same name, create the new bitstream and remove the old bundles.
        Item item = subInfo.getSubmissionItem().getItem();
        List<Bundle> bundles = itemService.getBundles(item, BUNDLE_NAME);
        List<UUID> bundleUUIDs = new ArrayList(bundles.size());
        for (Bundle bundle : bundles)
        {
            bundleUUIDs.add(bundle.getID());
        }

        StringBuilder statementsText = new StringBuilder();
        for (String statement : statements)
        {
            statementsText.append(statement + "\n\n");
        }
        byte[] statementsBytes = statementsText.toString().getBytes();
        ByteArrayInputStream bais = new ByteArrayInputStream(statementsBytes);
        Bitstream b = bitstreamService.create(context, bundleService.create(context, item, BUNDLE_NAME), bais);
        // Now set the format and name of the bitstream
        b.setName(context, BITSTREAM_NAME);
        b.setSource(context, "Written by org.dspace.submit.step.PrivacyStatementsStep.");
        // Use the License format
        BitstreamFormat bf = bitstreamFormatService.findByShortDescription(context, "License");
        b.setFormat(context, bf);
        bitstreamService.update(context, b);
        
        // remove the old bundles
        for (UUID uuid : bundleUUIDs)
        {
            bundleService.delete(context, bundleService.find(context, uuid));
        }

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
    
    public static String[] loadPrivacyStatements()
    {
        if (statements == null)
        {
            // open config file
            File configFile = new File(configFilePath);
            BufferedReader reader = null;
            try {
                reader = new BufferedReader(new FileReader(configFile));
            } catch (FileNotFoundException ex) {
                log.error("Cannot read configuration (" 
                        + configFile.getAbsolutePath() + "): " + ex.getMessage(), ex);
                throw new RuntimeException("Cannot read config File.", ex);
            }
            
            ArrayList<String> lines = new ArrayList<String>();
            try {
                String line;
                while ((line = reader.readLine()) != null)
                {
                    line = StringUtils.trim(line);
                    if (StringUtils.startsWith(line, "#")
                            || StringUtils.startsWith(line, "/*"))
                    {
                        continue;
                    }
                    lines.add(line);
                }
            } catch (IOException ex)
            {
                // TODO
            }
            ArrayList<String> statementsList = new ArrayList<String>(lines.size());
            for (int i = 0; i < lines.size(); i++)
            {
                String line = lines.get(i);
                if (line.equals("")) continue;
                
                while ((i+1) < lines.size() && !"".equals(lines.get(i+1)))
                {
                    ++i;
                    line = line + "\n" + lines.get(i);
                }
                if (!line.equals(""))
                {
                    statementsList.add(line);
                }
            }
            statements = statementsList.toArray(new String[0]);
        }
        // do not return a reference to our array
        return statements.clone();
    }
}
