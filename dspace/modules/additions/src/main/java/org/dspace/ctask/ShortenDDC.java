package org.dspace.ctask;

import org.apache.commons.lang3.StringUtils;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Item;
import org.dspace.content.MetadataValue;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.ItemService;
import org.dspace.curate.Curator;
import org.dspace.curate.Distributive;

import java.io.IOException;
import java.sql.SQLException;
import java.util.LinkedList;
import java.util.List;

/**
 * A curation task shortening complex ddc values.
 */
@Distributive
public class ShortenDDC extends AbstractTubCurationTask
{

    private ItemService itemService;

    @Override
    public void init(Curator curator, String taskId) throws IOException
    {
        super.init(curator, taskId);
        itemService = ContentServiceFactory.getInstance().getItemService();
    }


    /**
     * Performs the curation task on an item. <br>
     *
     * Shortens a complex DDC metadata value to the last segment.
     *
     * @param item the DSpace Item
     * @throws SQLException
     * @throws IOException
     */
    @Override
    protected void performItem(Item item) throws SQLException, IOException
    {
        try {
            List<MetadataValue> ddcList
                    = itemService.getMetadata(item, "dc", "subject", "ddc", Item.ANY);

            boolean update = false;

            for (MetadataValue ddc : ddcList)
            {
                String ddcValue = ddc.getValue();
                if (StringUtils.startsWith(ddcValue, "DDC::")) {
                    String newValue = ddcValue.substring(ddcValue.lastIndexOf(':') + 1);
                    itemService.addMetadata(
                            Curator.curationContext(),
                            item,
                            "dc",
                            "subject",
                            "ddc",
                            "de",
                            newValue);

                    List metadataValueList = new LinkedList();
                    metadataValueList.add(ddc);
                    itemService.removeMetadataValues(
                            Curator.curationContext(),
                            item,
                            metadataValueList);

                    report("DDC value changed from \"" + ddcValue + "\" to \"" + newValue + "\"");
                    update = true;
                }
            }

            if (update)
            {
                itemService.update(Curator.curationContext(), item);
            }
        }
        catch (AuthorizeException e)
        {
            String message = "Couldn't update item with handle " + item.getHandle() + ": " + e;
            errors.add(message);
        }
    }

}
