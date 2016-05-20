/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.identifier.doi;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URISyntaxException;
import java.net.URL;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import org.apache.commons.lang.NotImplementedException;
import org.apache.http.client.utils.URIBuilder;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.DSpaceObject;
import org.dspace.content.crosswalk.CrosswalkException;
import org.dspace.content.crosswalk.DisseminationCrosswalk;
import org.dspace.content.crosswalk.ParameterizedDisseminationCrosswalk;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.DSpaceObjectService;
import org.dspace.core.Context;
import org.dspace.core.factory.CoreServiceFactory;
import org.dspace.handle.service.HandleService;
import org.dspace.identifier.DOI;
import org.dspace.services.ConfigurationService;
import org.jdom.Content;
import org.jdom.Element;
import org.jdom.Text;
import org.jdom.output.Format;
import org.jdom.output.XMLOutputter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Required;

/**
 *
 * @author Pascal-Nicolas Becker
 */
public class SerializedDataCiteConnector
implements DOIConnector
{

    private static final Logger log = LoggerFactory.getLogger(SerializedDataCiteConnector.class);
    
    // Configuration property names
    static final String CFG_USER = "identifier.doi.user";
    static final String CFG_PASSWORD = "identifier.doi.password";
    private static final String CFG_PREFIX
            = "identifier.doi.prefix";
    private static final String CFG_PUBLISHER
            = "crosswalk.dissemination.DataCite.publisher";
    private static final String CFG_DATAMANAGER
            = "crosswalk.dissemination.DataCite.dataManager";
    private static final String CFG_HOSTINGINSTITUTION
            = "crosswalk.dissemination.DataCite.hostingInstitution";
    
    /**
     * Stores the scheme used to connect to the DataCite server. It will be set
     * by spring dependency injection.
     */
    protected String SCHEME;
    /**
     * Stores the hostname of the DataCite server. Set by spring dependency
     * injection.
     */
    protected String HOST;
    
    /**
     * Path on the DataCite server used to generate DOIs. Set by spring
     * dependency injection.
     */
    protected String DOI_PATH;
    /**
     * Path on the DataCite server used to register metadata. Set by spring
     * dependency injection.
     */
    protected String METADATA_PATH;
    /**
     * Name of crosswalk to convert metadata into DataCite Metadata Scheme. Set 
     * by spring dependency injection.
     */
    protected String CROSSWALK_NAME;
    
    /** 
     * DisseminationCrosswalk to map local metadata into DataCite metadata.
     * The name of the crosswalk is set by spring dependency injection using
     * {@link setDisseminationCrosswalk(String) setDisseminationCrosswalk} which
     * instantiates the crosswalk.
     */
    protected ParameterizedDisseminationCrosswalk xwalk;
    
    protected ConfigurationService configurationService;
    
    protected String USERNAME;
    protected String PASSWORD;
    
    @Autowired
    protected HandleService handleService;
    
    protected String outputDirectory;
    protected String filenamePrefix;

    public SerializedDataCiteConnector()
    {
        this.xwalk = null;
        this.USERNAME = null;
        this.PASSWORD = null;
        this.filenamePrefix = "doi_command-";
    }
    
    /**
     * Used to set the scheme to connect the DataCite server. Used by spring
     * dependency injection.
     * @param DATACITE_SCHEME Probably https or http.
     */
    @Required
    public void setDATACITE_SCHEME(String DATACITE_SCHEME)
    {
        this.SCHEME = DATACITE_SCHEME;
    }

    /**
     * Set the hostname of the DataCite server. Used by spring dependency
     * injection.
     * @param DATACITE_HOST Hostname to connect to register DOIs (f.e. test.datacite.org).
     */
    @Required
    public void setDATACITE_HOST(String DATACITE_HOST)
    {
        this.HOST = DATACITE_HOST;
    }
    
    /**
     * Set the path on the DataCite server to register DOIs. Used by spring
     * dependency injection.
     * @param DATACITE_DOI_PATH Path to register DOIs, f.e. /doi.
     */
    @Required
    public void setDATACITE_DOI_PATH(String DATACITE_DOI_PATH)
    {
        if (!DATACITE_DOI_PATH.startsWith("/"))
        {
            DATACITE_DOI_PATH = "/" + DATACITE_DOI_PATH;
        }
        if (!DATACITE_DOI_PATH.endsWith("/"))
        {
            DATACITE_DOI_PATH = DATACITE_DOI_PATH + "/";
        }
        
        this.DOI_PATH = DATACITE_DOI_PATH;
    }
    
    /**
     * Set the path to register metadata on DataCite server. Used by spring
     * dependency injection.
     * @param DATACITE_METADATA_PATH Path to register metadata, f.e. /mds.
     */
    @Required
    public void setDATACITE_METADATA_PATH(String DATACITE_METADATA_PATH)
    {
        if (!DATACITE_METADATA_PATH.startsWith("/"))
        {
            DATACITE_METADATA_PATH = "/" + DATACITE_METADATA_PATH;
        }
        if (!DATACITE_METADATA_PATH.endsWith("/"))
        {
            DATACITE_METADATA_PATH = DATACITE_METADATA_PATH + "/";
        }
        
        this.METADATA_PATH = DATACITE_METADATA_PATH;
    }
    
    
    @Autowired
    @Required
    public void setConfigurationService(ConfigurationService configurationService)
    {
        this.configurationService = configurationService;
    }
    
    /**
     * Set the name of the dissemination crosswalk used to convert the metadata
     * into DataCite Metadata Schema. Used by spring dependency injection.
     * @param CROSSWALK_NAME The name of the dissemination crosswalk to use. This
     *                       crosswalk must be configured in dspace.cfg.
     */
    @Required
    public void setDisseminationCrosswalkName(String CROSSWALK_NAME) {
        this.CROSSWALK_NAME = CROSSWALK_NAME;
    }
    
    protected void prepareXwalk()
    {
        if (null != this.xwalk)
            return;
        
        this.xwalk = (ParameterizedDisseminationCrosswalk) CoreServiceFactory.getInstance().getPluginService().getNamedPlugin(
                DisseminationCrosswalk.class, this.CROSSWALK_NAME);
        
        if (this.xwalk == null)
        {
            throw new RuntimeException("Can't find crosswalk '"
                    + CROSSWALK_NAME + "'!");
        }
    }
    
    protected String getUsername()
    {
        if (null == this.USERNAME)
        {
            this.USERNAME = this.configurationService.getProperty(DataCiteConnector.CFG_USER);
            if (null == this.USERNAME)
            {
                throw new RuntimeException("Unable to load username from "
                        + "configuration. Cannot find property " +
                        DataCiteConnector.CFG_USER + ".");
            }
        }
        return this.USERNAME;
    }
    
    protected String getPassword()
    {
        if (null == this.PASSWORD)
        {
            this.PASSWORD = this.configurationService.getProperty(DataCiteConnector.CFG_PASSWORD);
            if (null == this.PASSWORD)
            {
                throw new RuntimeException("Unable to load password from "
                        + "configuration. Cannot find property " +
                        DataCiteConnector.CFG_PASSWORD + ".");
            }
        }
        return this.PASSWORD;
    }
    
    @Required
    public void setOutputDirectory(String OUTPUT_DIRECTORY)
    {
        this.outputDirectory = OUTPUT_DIRECTORY;
    }
    
    public void setFilenamePrefix(String FILENAME_PREFIX)
    {
        if (null == FILENAME_PREFIX)
        {
            this.filenamePrefix = "";
        }
        else
        {
            this.filenamePrefix = FILENAME_PREFIX;
        }
    }
    
    @Override
    public boolean isDOIReserved(Context context, String doi)
            throws DOIIdentifierException
    {
        throw new NotImplementedException();
    }
    
    @Override
    public boolean isDOIRegistered(Context context, String doi)
            throws DOIIdentifierException
    {
        throw new NotImplementedException();
    }
    
    @Override
    public void deleteDOI(Context context, String doi)
            throws DOIIdentifierException
    {
        URIBuilder uribuilder = new URIBuilder();
        uribuilder.setScheme(SCHEME).setHost(HOST).setPath(METADATA_PATH
                + doi.substring(DOI.SCHEME.length()));
        
        Element command = null;
        try {
             command = this.serializeCommand(doi, "DELETE", uribuilder.build().toURL(), null, true, null);
        } catch (URISyntaxException ex) {
            // TODO
        } catch (MalformedURLException ex) {
            // TODO
        }
        
        this.saveCommand(command);
    }

    @Override
    public void reserveDOI(Context context, DSpaceObject dso, String doi)
            throws DOIIdentifierException
    {
        this.prepareXwalk();

        DSpaceObjectService<DSpaceObject> dSpaceObjectService = ContentServiceFactory.getInstance().getDSpaceObjectService(dso);

        if (!this.xwalk.canDisseminate(dso))
        {
            log.error("Crosswalk " + this.CROSSWALK_NAME 
                    + " cannot disseminate DSO with type " + dso.getType() 
                    + " and ID " + dso.getID() + ". Giving up reserving the DOI "
                    + doi + ".");
            throw new DOIIdentifierException("Cannot disseminate "
                    + dSpaceObjectService.getTypeText(dso) + "/" + dso.getID()
                    + " using crosswalk " + this.CROSSWALK_NAME + ".",
                    DOIIdentifierException.CONVERSION_ERROR);
        }

        // Set the transform's parameters.
        // XXX Should the actual list be configurable?
        Map<String, String> parameters = new HashMap<>();
        if (configurationService.hasProperty(CFG_PREFIX))
            parameters.put("prefix",
                    configurationService.getProperty(CFG_PREFIX));
        if (configurationService.hasProperty(CFG_PUBLISHER))
            parameters.put("publisher",
                    configurationService.getProperty(CFG_PUBLISHER));
        if (configurationService.hasProperty(CFG_DATAMANAGER))
            parameters.put("datamanager",
                    configurationService.getProperty(CFG_DATAMANAGER));
        if (configurationService.hasProperty(CFG_HOSTINGINSTITUTION))
            parameters.put("hostinginstitution",
                    configurationService.getProperty(CFG_HOSTINGINSTITUTION));

        Element root = null;
        try
        {
            root = xwalk.disseminateElement(context, dso, parameters);
        }
        catch (AuthorizeException ae)
        {
            log.error("Caught an AuthorizeException while disseminating DSO "
                    + "with type " + dso.getType() + " and ID " + dso.getID()
                    + ". Giving up to reserve DOI " + doi + ".", ae);
            throw new DOIIdentifierException("AuthorizeException occured while "
                    + "converting " + dSpaceObjectService.getTypeText(dso) + "/" + dso.getID()
                    + " using crosswalk " + this.CROSSWALK_NAME + ".", ae,
                    DOIIdentifierException.CONVERSION_ERROR);
        }
        catch (CrosswalkException ce)
        {
            log.error("Caught an CrosswalkException while reserving a DOI ("
                    + doi + ") for DSO with type " + dso.getType() + " and ID " 
                    + dso.getID() + ". Won't reserve the doi.", ce);
            throw new DOIIdentifierException("CrosswalkException occured while "
                    + "converting " + dSpaceObjectService.getTypeText(dso) + "/" + dso.getID()
                    + " using crosswalk " + this.CROSSWALK_NAME + ".", ce,
                    DOIIdentifierException.CONVERSION_ERROR);
        }
        catch (IOException | SQLException ex)
        {
            throw new RuntimeException(ex);
        }
        
        String metadataDOI = extractDOI(root);
        if (null == metadataDOI)
        {
            // The DOI will be saved as metadata of dso after successful
            // registration. To register a doi it has to be part of the metadata
            // sent to DataCite. So we add it to the XML we'll send to DataCite
            // and we'll add it to the DSO after successful registration.
            root = addDOI(doi, root);
        }
        else if (!metadataDOI.equals(doi.substring(DOI.SCHEME.length())))
        {
            // FIXME: that's not an error. If at all, it is worth logging it.
            throw new DOIIdentifierException("DSO with type "
                    + dSpaceObjectService.getTypeText(dso) + " and id " 
                    + dso.getID() + " already has DOI " + metadataDOI
                    + ". Won't reserve DOI " + doi + " for it.");
        }
        
        URIBuilder uribuilder = new URIBuilder();
        uribuilder.setScheme(SCHEME).setHost(HOST).setPath(METADATA_PATH);
        
        Element command = null;
        try {
            command = serializeCommand(doi, "POST", uribuilder.build().toURL(), "application/xml", true, root);
        }
        catch (MalformedURLException ex)
        {
            // TODO
        }
        catch (URISyntaxException ex)
        {
            // TODO
        }
        this.saveCommand(command);
    }
    
    @Override
    public void registerDOI(Context context, DSpaceObject dso, String doi)
            throws DOIIdentifierException
    {
        URIBuilder uribuilder = new URIBuilder();
        uribuilder.setScheme(SCHEME).setHost(HOST).setPath(DOI_PATH);
        
        Element command = null;
        try {
            String content = "doi=" + doi.substring(DOI.SCHEME.length()) + "\n"
                    + "url=" + handleService.resolveToURL(context, dso.getHandle()) + "\n";
            command = serializeCommand(doi, "POST", uribuilder.build().toURL(), "text/plain", true, new Text(content));
        }
        catch (SQLException ex)
        {
            // TODO
        }
        catch (MalformedURLException ex)
        {
            // TODO
        }
        catch (URISyntaxException ex)
        {
            // TODO
        }
        this.saveCommand(command);
    }
    
    @Override
    public void updateMetadata(Context context, DSpaceObject dso, String doi) 
            throws DOIIdentifierException
    { 
        // We can use reserveDOI to update metadata. Datacite API uses the same
        // request for reservartion as for updating metadata.
        this.reserveDOI(context, dso, doi);
    }

    protected Element serializeCommand(String doi, String method, URL url, 
            String contentType, boolean credentials, Content content)
    {
        long millis = System.currentTimeMillis();

        Element command = new Element("command");
        
        Element commandTimestamp = new Element("timestamp");
        commandTimestamp.addContent(Long.toString(millis));
        command.addContent(commandTimestamp);
        
        Element commandDoi = new Element("doi");
        commandDoi.addContent(doi);
        command.addContent(commandDoi);
        
        Element commandUrl = new Element("url");
        commandUrl.addContent(url.toExternalForm());
        command.addContent(commandUrl);
        
        Element commandContentType = new Element("contentType");
        if (null != contentType)
        {
            commandContentType.addContent(contentType);
        }
        command.addContent(commandContentType);
        
        Element commandMethod = new Element("method");
        commandMethod.addContent(method);
        command.addContent(commandMethod);
        
        Element commandUsername = new Element("username");
        if (credentials)
        {
            commandUsername.addContent(this.getUsername());
        }
        command.addContent(commandUsername);
        
        Element commandPassword = new Element("password");
        if (credentials)
        {
            commandPassword.addContent(this.getPassword());
        }
        command.addContent(commandPassword);
        
        Element commandContent = new Element("content");
        if (null != content)
        {
            commandContent.addContent(content);
        }
        command.addContent(commandContent);
        
        return command;
    }
    
    protected void saveCommand(Element command)
    {
        // we expect the XML here, we created before.
        // Won't caught NullpointerException oder NumberFormatException, as we
        // couldn't handle them well and don't expect them to apear.
        Element commandTimestamp = command.getChild("timestamp");
        long millis = Long.parseLong(commandTimestamp.getTextTrim());
        
        Format format = Format.getPrettyFormat();
        format.setEncoding("UTF-8");
        XMLOutputter xout = new XMLOutputter(format);
        
        FileOutputStream fout = null;
        BufferedOutputStream out = null;
                
        try {
            File file = createFile(millis);
            fout = new FileOutputStream(file);
            out = new BufferedOutputStream(fout);
            xout.output(command, out);
        }
        catch (FileNotFoundException ex)
        {
            throw new RuntimeException(ex);
        }
        catch (IOException ex)
        {
            throw new RuntimeException(ex);
        }
        finally
        {
            try {
                if (out != null)
                {
                    out.close();
                }
            } catch (IOException ex) {
                // nothing to do.
            }
            try {
                if (fout != null)
                {
                    fout.close();
                }
            } catch (IOException ex) {
                // nothing to do.
            }
        }
    }
    
    protected File createFile(long millis)
            throws IOException
    {
        SimpleDateFormat df = new SimpleDateFormat("YYYYMMdd_HHmm-ssSS");
        String date = df.format(new Date(millis));        
        
        File file = new File(outputDirectory + File.separator
                + this.filenamePrefix + date + ".xml");
        for (int i = 1 ; i < 10; ++i)
        {
            if (file.createNewFile())
            {
                return file;
            }
            file = new File(outputDirectory + File.separator + date 
                    + "_" + Integer.toString(i) + ".xml");
        }
        
        throw new RuntimeException("Cannot create a file. "
                + "Did we produced more then ten commands in one millisecond?");
    }
    
    protected String extractDOI(Element root) {
        Element doi = root.getChild("identifier", root.getNamespace());
        return (null == doi) ? null : doi.getTextTrim();
    }

    protected Element addDOI(String doi, Element root) {
        if (null != extractDOI(root))
        {
            return root;
        }
        Element identifier = new Element("identifier", "http://datacite.org/schema/kernel-3");
        identifier.setAttribute("identifierType", "DOI");
        identifier.addContent(doi.substring(DOI.SCHEME.length()));
        return root.addContent(0, identifier);
    }
}
