package org.dspace.ctask;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.dspace.authorize.AuthorizeException;
import org.dspace.authorize.ResourcePolicy;
import org.dspace.authorize.factory.AuthorizeServiceFactory;
import org.dspace.authorize.service.ResourcePolicyService;
import org.dspace.content.Bitstream;
import org.dspace.content.Bundle;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.ItemService;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.curate.AbstractCurationTask;
import org.dspace.curate.Curator;
import org.dspace.curate.Distributive;
import org.dspace.eperson.Group;
import org.dspace.eperson.factory.EPersonServiceFactory;
import org.dspace.eperson.service.GroupService;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * A curator task setting the access level for OpenAire.
 */
@Distributive
public class DnbAccessRights extends AbstractTubCurationTask
{

    private final static String FREE = "free";
    private final static String DOMAIN = "domain";
    private final static String EMBARGOED = "embargoed";
    private final static String UNKNOWN = "unknown";

    private final static List<String> PUBLICATION_SUBTYPES
            = Arrays.asList("Article", "Book Part", "Conference Object");

    private final static List<String> PUBLICATION_TYPES
            = Arrays.asList("Book", "Conference Proceedings", "Doctoral Thesis", "Habilitation", "Bachelor Thesis",
            "Master Thesis", "Other", "Periodical Part", "Preprint", "Report", "Research Paper");

    //private AuthorizeService authorizeService;
    private ItemService itemService;


    private final ResourcePolicyService resourcePolicyService
            = AuthorizeServiceFactory.getInstance().getResourcePolicyService();

    private final GroupService groupService
            = EPersonServiceFactory.getInstance().getGroupService();

    @Override
    public void init(Curator curator, String taskId) throws IOException
    {
        super.init(curator, taskId);
        //authorizeService = AuthorizeServiceFactory.getInstance().getAuthorizeService();
        itemService = ContentServiceFactory.getInstance().getItemService();
    }


    /**
     * Performs the curation task on an item. <br>
     * Sets the access rights field ro 'free', 'domain', 'embargoed' or 'unknown'
     * Only operates on items where the field is empty or set with one of the above values!
     * If the field is set with another value (as 'blocked'), it is left as was.
     * Otherwise the following logic is used:
     * If an item is in embargo, the field is set to 'embargoed'.
     * If the item is not in embargo and the field is empty or set to 'embargoed', a logic is used to calculate,
     * if it shall be set to 'free' or 'domain'.
     *
     * @param item the DSpace Item
     * @throws SQLException
     * @throws IOException
     */
    @Override
    protected void performItem(Item item) throws SQLException, IOException
    {
        try
        {
            String accessRights
                    = itemService.getMetadataFirstValue(item, "tub", "accessrights", "dnb", Item.ANY);

            report("Item " + item.getHandle() + " has access rights " + accessRights);

            if (accessRights == null)
            {
                if (isInEmbargo(Curator.curationContext(), item))
                {
                    setAccessRights(item, EMBARGOED);
                }
                else
                {
                    setAccessRights(item, calculateAccessRights(item));
                }
            }
            else if ((FREE.equals(accessRights) || DOMAIN.equals(accessRights) || UNKNOWN.equals(accessRights))
                    && isInEmbargo(Curator.curationContext(), item))
            {
                setAccessRights(item, EMBARGOED);
            }
            else if (EMBARGOED.equals(accessRights) && !isInEmbargo(Curator.curationContext(), item))
            {
                setAccessRights(item, calculateAccessRights(item));
            }
        }
        catch (AuthorizeException e)
        {
            String message = "Couldn't update item with handle " + item.getHandle() + ": " + e;
            errors.add(message);
        }
    }

    /**
     * Calculates the access rights for the item.
     *
     * CAREFUL! This logic is NOT exhaustive! This method should ONLY be called when tub.accessrights.dnb
     * is empty or embargoed. There has to remain a possibility to manually set this value to free or domain.
     *
     * The following logic tries to estimate the rights as good as we can. If an item is under creative commons the
     * decision is easy. We try to estimate the status of all other documents following their document type.
     * This was specified by TU Universitätsverlag and OA-Team. See DEPONCE-30.
     *
     * @param item
     * @return either "free", "domain" or "unknown"
     */
    private String calculateAccessRights(Item item)
    {
        String dcRightsUri
                = itemService.getMetadataFirstValue(item, "dc", "rights", "uri", Item.ANY);

        String dcPublisherName
                = itemService.getMetadataFirstValue(item, "dc", "publisher", "name", Item.ANY);

        String dcType
                = itemService.getMetadataFirstValue(item, "dc", "type", null, Item.ANY);

        if (StringUtils.contains(dcRightsUri, "creativecommons.org")
                || StringUtils.equals(dcPublisherName, "Universitätsverlag der TU Berlin")
                || PUBLICATION_TYPES.contains(dcType))
        {
            return FREE;
        }

        if (PUBLICATION_SUBTYPES.contains(dcType)
                && !StringUtils.contains(dcRightsUri, "creativecommons.org"))
        {
            return DOMAIN;
        }

        return UNKNOWN;
    }


    /**
     * Sets the access rights field of the given item to the given value.
     *
     * @param item
     * @param value
     * @throws SQLException
     * @throws AuthorizeException
     */
    private void setAccessRights(Item item, String value) throws SQLException, AuthorizeException
    {
        itemService.setMetadataSingleValue(
                Curator.curationContext(),
                item,
                "tub",
                "accessrights",
                "dnb",
                Item.ANY,
                value);
        itemService.update(Curator.curationContext(), item);
        String message = "DNB Access rights for item with handle " + item.getHandle() + " changed to " + value;
        report(message);
        setResult(message);
    }

    /**
     * Checks if the item of any ORIGINAL bitstream in the item is embargoed,
     * i.e. if user Anonymous is not allowed to read it.
     *
     * @param context
     * @param item
     * @return true, if there is an embargo, otherwise false.
     * @throws SQLException
     */
    private boolean isInEmbargo(Context context, Item item) throws SQLException
    {
        if (dspaceObjectInEmbargo(context, item))
        {
            return true;
        }
        for (Bitstream bitstream : getOriginalBitstreams(item))
        {

            if (dspaceObjectInEmbargo(context, bitstream))
            {
                return true;
            }
        }
        return false;
    }

    private boolean dspaceObjectInEmbargo(Context context, DSpaceObject dSpaceObject) throws SQLException
    {
        List<ResourcePolicy> policies = resourcePolicyService.find(
                context,
                dSpaceObject,
                groupService.findByName(context, Group.ANONYMOUS),
                Constants.READ);
        // There should be only one policy for this group, action and bitstream.
        // If there is a start date, this is the read start date a.k.a. the embargo end date
        for (ResourcePolicy policy : policies)
        {
            if (!resourcePolicyService.isDateValid(policy))
            {
                return true;
            }
        }
        return false;
    }

    /**
     * Retrieves all ORIGINAL bitstream objects in an item.
     * @param item the item object
     * @return a list with the bitstreams-
     */
    private List<Bitstream> getOriginalBitstreams(Item item)
    {
        List<Bitstream> bitstreams = new ArrayList<>();

        for (Bundle bundle : item.getBundles())
        {
            if ("ORIGINAL".equals(bundle.getName()))
            {
                bitstreams.addAll(bundle.getBitstreams());
            }
        }
        return bitstreams;
    }



}
