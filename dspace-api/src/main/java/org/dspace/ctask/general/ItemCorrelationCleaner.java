/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.ctask.general;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;

import org.apache.commons.lang3.StringUtils;

import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Collection;
import org.dspace.content.Community;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.content.MetadataValue;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.curate.AbstractCurationTask;
import org.dspace.curate.Curator;
import org.dspace.curate.Distributive;
import org.dspace.identifier.DOI;
import org.dspace.identifier.IdentifierException;
import org.dspace.identifier.doi.DOIIdentifierException;
import org.dspace.identifier.factory.IdentifierServiceFactory;
import org.dspace.identifier.service.DOIService;
import org.dspace.identifier.service.IdentifierService;

/**
 *
 * @author Marsa Haoua
 */
@Distributive
public class ItemCorrelationCleaner extends AbstractCurationTask 
{
    private final transient DOIService doiService
            = IdentifierServiceFactory.getInstance().getDOIService();
    private final transient IdentifierService identifierService
            = IdentifierServiceFactory.getInstance().getIdentifierService();
    
    private String doiPrefix = new String();
    static final String CFG_NAMESPACE_SEPARATOR = "identifier.doi.namespaceseparator";
    static final String CFG_PREFIX = "identifier.doi.prefix";
    static final char SLASH = '/';

    private final List<String> results = new ArrayList<>();

    @Override
    public void init(Curator curator, String taskId) throws IOException 
    {
        super.init(curator, taskId);

        try 
        {
            doiPrefix = loadDOIPrefix();
        } 
        catch (RuntimeException e) 
        {
            results.add("Configuration error: " + e);
            setResult(results.toString());
            report(results.toString());
        }
    }

    @Override
    public int perform(DSpaceObject dso) throws IOException 
    {
        results.clear();
        results.add("\nStatus of single Handle within: " 
                    + dso.getHandle() + "\n----------------");
        distribute(dso);
        String result = StringUtils.join(results, "\n");
        setResult(result);
        report(result);
        return Curator.CURATE_SUCCESS;
    }

    /*
     * The original distribute method calls the performItem method only
     * on archived Items. But for this scenario all items of a collection 
     * including withdrawn items need to be performed as well.
     * 
     * @param dso
     * @throws IOException 
     */
    @Override
    protected void distribute(DSpaceObject dso) throws IOException 
    {
        try 
        {
            //perform task on this current object
            performObject(dso);

            //next, we'll try to distribute to all child objects, based on container type
            int type = dso.getType();
            if (Constants.COLLECTION == type) 
            {
                // Get all archived or withdrawn items
                Iterator<Item> iter = itemService.findAllByCollection(Curator.curationContext(), (Collection)dso);
                while (iter.hasNext()) 
                {
                    performObject(iter.next());
                }
            }
            else if (Constants.COMMUNITY == type) 
            {
                Community comm = (Community) dso;
                for (Community subcomm : comm.getSubcommunities()) 
                {
                    distribute(subcomm);
                }
                
                for (Collection coll : comm.getCollections()) 
                {
                    distribute(coll);
                }
            } 
            else if (Constants.SITE == type) 
            {
                List<Community> topComm = communityService.findAllTop(Curator.curationContext());
                for (Community comm : topComm) 
                {
                    distribute(comm);
                }
            }
        } 
        catch (SQLException sqlE) 
        {
            throw new IOException(sqlE.getMessage(), sqlE);
        }
    }

    @Override
    protected void performItem(Item item) throws SQLException, IOException 
    {
        String schema = "dc";
        String element = "relation";
        String issupplementToQualifier = "issupplementto";
        String issupplementedByQualifier = "issupplementedby";

        try 
        {
            Context context = Curator.curationContext();
            int status = perform(context, item, schema, element, issupplementedByQualifier, issupplementToQualifier);
            results.add("Handle: " + item.getHandle() + "\t\t Status: " + status);
            return;
        } 
        catch (SQLException e) 
        {
            setResult(e.getMessage());
            results.add("Handle: " + item.getHandle() + "\t\t Status: " + Curator.CURATE_ERROR);
        }
        results.add("Handle: " + item.getHandle() + "\t\t Status: " + Curator.CURATE_SKIP);
    }

    /*
     * Helper method which performs the metadata lookup for a given Item in both direction: 
     * - Item as a supplemented by
     * - Item as a issupplement to
     *
     * @param context
     * @param item
     * @param schema
     * @param element
     * @param issupplementedByQualifier
            the qualifier "issupplementedby" as string
     * @param issupplementToQualifier
            the qualifier "issupplementto" as string
     * @return 
            the status of the task 
     */
    private int perform(Context context, Item item, String schema, String element,
            String issupplementedByQualifier, String issupplementToQualifier) 
    {
        int issupplementedBy = findAndCorrectCorrelation(context, item, schema, element,
                issupplementedByQualifier, issupplementToQualifier);
        
        int issupplementTo = findAndCorrectCorrelation(context, item, schema, element,
                issupplementToQualifier, issupplementedByQualifier);

        if (issupplementedBy == Curator.CURATE_ERROR
                || issupplementTo == Curator.CURATE_ERROR) 
        {
            return Curator.CURATE_ERROR;
        } 
        else if (issupplementedBy == Curator.CURATE_SUCCESS
                || issupplementTo == Curator.CURATE_SUCCESS) 
        {
            return Curator.CURATE_SUCCESS;
        } 
        else 
        {
            return Curator.CURATE_SKIP;
        }
    }

    /*
     * Verify whether references between items are bidirectional and 
     * that a link isn't referencing a withdrawn Item by:
     * 
     *  1 - Retrieving MetadataValues from the given Item based on the schema,
     *      element and issupplementedByOrTOQualifier values
     * 
     *  2 - Checking the validity of the values of the Item's MetadataValues 
     * 
     *  3 - Correcting the references
     * 
     * @param context
     * @param item
     * @param schema
     * @param element
     * @param issupplementedByOrTOQualifier
     * @param againstIssupplementedByOrToQualifier
     * @return 
     */
    private int findAndCorrectCorrelation(Context context, Item item, String schema, String element,
            String issupplementedByOrTOQualifier, String againstIssupplementedByOrToQualifier) 
    {
        try 
        {
            List<MetadataValue> itemMetadataValues = itemService.getMetadata(item,
                    schema, element, issupplementedByOrTOQualifier, Item.ANY);

            String doiToSet = identifierService.lookup(context, item, DOI.class);

            if (null != doiToSet) 
            {
                doiToSet = doiService.DOIToExternalForm(doiToSet);

                if (!item.isWithdrawn() && doiToSet.startsWith(doiPrefix)) // son doi est ok
                {
                    for (MetadataValue metadataValue : itemMetadataValues) 
                    {
                        try 
                        {
                            // Retrieve the Item by the DOI
                            String doi = doiService.formatIdentifier(metadataValue.getValue());
                            DOI doiRow = doiService.findByDoi(context, doi.substring(DOI.SCHEME.length()));
                            doi = doiService.DOIToExternalForm(doi);

                            if (null != doiRow && doi.startsWith(doiPrefix)) 
                            {
                                Item itemTo = (Item) doiRow.getDSpaceObject();
                                
                                if (null != itemTo) 
                                {
                                    // Check if the references of the item retrieved from the DOI are set properly,
                                    // by checking the values of the appropriate MetadataValues
                                    List<MetadataValue> itemToMetadataValues
                                            = itemService.getMetadata(itemTo, schema,
                                                    element, againstIssupplementedByOrToQualifier, Item.ANY);

                                    List<String> issupplementedToStringValues
                                            = getMetadataStringValue(itemToMetadataValues);
                                    
                                    if (!issupplementedToStringValues.contains(doiToSet)) 
                                    {
                                        // Remove the metadata from Item. 
                                        // Only the withdrawn Item should have the reference 
                                        if (itemTo.isWithdrawn()) 
                                        { 
                                            itemService.removeMetadataValues(context, item, 
                                                        Collections.singletonList(metadataValue));
                                            itemService.update(context, item);
                                        }
                                        // Update the metadata value
                                        itemService.addMetadata(context, itemTo,
                                                    schema, element, againstIssupplementedByOrToQualifier,
                                                    null, doiToSet);
                                        itemService.update(context, itemTo);
                                    }
                                }
                            }
                            else 
                            {
                                // DO NOTHING! 
                                // The Item may reference another Item beyond the repository
                            }
                        } 
                        catch (DOIIdentifierException | SQLException | AuthorizeException e) 
                        {
                            setResult(e.getMessage());
                            return Curator.CURATE_ERROR;
                        }
                    }
                    return Curator.CURATE_SUCCESS;
                }
            }
        } 
        catch (IdentifierException e) 
        {
            setResult(e.getMessage());
            return Curator.CURATE_ERROR;
        }
        return Curator.CURATE_SKIP;
    }
    
    /*
     * Retrieve and Return a list values out of the given MetadataValue list.
     * 
     * @param metadataValues
     *          List of MetadataValue
     * @return 
     *          List of values from the given list
     */
    private List<String> getMetadataStringValue(List<MetadataValue> metadataValues) 
    {
        List<String> values = new ArrayList<>();
        for (MetadataValue value : metadataValues) 
        {
            values.add(value.getValue());
        }
        return values;
    }

    /*
     * Load the prefix of DOI from the configuration file.
     * 
     * @return 
     *      Prefix of the DOI
     */
    private String loadDOIPrefix() 
    {
        String namespaceSeparator = configurationService.getProperty(CFG_NAMESPACE_SEPARATOR, "");
        String prefix = configurationService.getProperty(CFG_PREFIX);

        if (null == prefix) 
        {
            throw new RuntimeException("Unable to load DOI prefix!"
                    + " Cannot find property: "
                    + CFG_PREFIX + ".");
        }
        return DOI.RESOLVER + String.valueOf(SLASH) + prefix
                + String.valueOf(SLASH) + namespaceSeparator;
    }
}
