/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.webui.jsptag;

import org.apache.commons.lang.StringUtils;
import org.dspace.app.webui.servlet.MyDSpaceServlet;
import org.dspace.app.webui.util.UIUtil;
import org.dspace.content.Item;
import org.dspace.content.MetadataValue;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.ItemService;
import org.dspace.core.Context;
import org.dspace.workflow.WorkflowItemService;
import org.dspace.workflow.factory.WorkflowServiceFactory;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.jstl.fmt.LocaleSupport;
import javax.servlet.jsp.tagext.TagSupport;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * This tag references an item by giving a short citation and linking to either the itemview, the edit item form or
 * the workflow task preview. Please ensure the user is able to access the item and - depending on the items's state -
 * the item edit form or the workflow task preview.
 *
 * @author Pascal-Nicolas Becker (pascal at the dash library dash code dot de)
 */
public class ReferenceItemTag extends TagSupport
{
    public ReferenceItemTag() { super(); }

    private final transient ItemService itemService = ContentServiceFactory.getInstance().getItemService();
    private final transient WorkflowItemService workflowItemService =
            WorkflowServiceFactory.getInstance().getWorkflowItemService();

    private transient Item item;
    public Item getItem() { return item; }
    public void setItem(Item item) { this.item = item; }

    /**
     * Gather all metadata needed for the citation and create the button / link to open the referenced item.
     * @return SKIP_BODY
     * @throws JspException if an error occurs while processing this tag
     */
    @Override
    public int doStartTag() throws JspException
    {
        // show the duplicates, following the following non-formal citation style:
        // Name for first author/editor; name of last author/editor, Publication year. Title : Subtitle [document type]. Place of publication: Publisher.
        // Link to itemview or edit step.

        if (this.item == null)
        {
            throw new JspException("ReferenceItemTag was called, but no item set. Please use the item attribute.");
        }

        HttpServletRequest request = (HttpServletRequest) pageContext.getRequest();
        Context context;
        try
        {
            context = UIUtil.obtainContext(request);
        } catch (SQLException ex) {
            throw new JspException(ex);
        }

        // assemble the contributor names from the author and editor fields.
        List<MetadataValue> author = itemService.getMetadata(this.item, "dc", "contributor", "author", Item.ANY);
        List<MetadataValue> editor = itemService.getMetadata(this.item, "dc", "contributor", "editor", Item.ANY);
        String contributor = "";
        // take the first author if available
        if (author != null && author.size() > 0)
        {
            contributor += author.get(0).getValue();
            // take the last author, if we have more than one.
            if (author.size() > 1)
            {
                contributor += "; " + author.get(author.size()-1).getValue();
            } else {
                // add the first editor, if there is only one author but an editor with a different name
                if (editor != null
                        && editor.size() > 0
                        && ! StringUtils.equals(author.get(0).getValue(), editor.get(0).getValue()))
                {
                    contributor += "; " + editor.get(0).getValue();
                }
            }
        } else {
            // use editor information if we have no author
            if (editor != null && editor.size() > 0)
            {
                contributor = editor.get(0).getValue();
                // add the last editor, if we have more than one.
                if (editor.size() > 1)
                {
                    contributor += "; " + editor.get(editor.size()-1).getValue();
                }
            }
        }

        // get the publication year
        String year = itemService.getMetadataFirstValue(this.item, "dc", "date", "issued", Item.ANY);
        if (!StringUtils.isEmpty(year) && year.contains("-"))
        {
            // ensure we only have the year
            year = year.substring(0, year.indexOf("-"));
        }

        // get the first title. We assume the title is already in the format "title : subtitle".
        String title = itemService.getMetadataFirstValue(this.item, "dc", "title", null, Item.ANY);

        // get the document type
        String docType = itemService.getMetadataFirstValue(this.item, "dc", "type", null, Item.ANY);

        // get the publisher's place
        String place = itemService.getMetadataFirstValue(this.item, "local", "publisher", "place", Item.ANY);

        // get the publisher
        String publisher = itemService.getMetadataFirstValue(this.item, "dc", "publisher", null, Item.ANY);

        // do we have to link to the "get task page"?
        int workflowId = -1;
        try {
            if (workflowItemService.findByItem(context, item) != null)
            {
                workflowId = workflowItemService.findByItem(context, item).getID();
            }
        } catch (SQLException ex) {
            throw new JspException(ex);
        }

        // assemble the citation string
        // the following if-else-clauses could probably be written much shorter, but we want to keep them
        // understandable. Furthermore the addition of dots and commas is not easy, as the fields before and
        // after must not be empty to include them.
        StringBuilder citation = new StringBuilder();
        citation.append(contributor);
        if (citation.length() > 0 && !StringUtils.isEmpty(year))
        {
            citation.append(", ").append(year);
        }
        else if (!StringUtils.isEmpty(year))
        {
            citation.append(year);
        }
        if (citation.length() > 0)
        {
            citation.append(".\n");
        }

        if (!StringUtils.isEmpty(title))
        {
            citation.append("<strong>").append(title).append("</strong>");
        }
        if (!StringUtils.isEmpty(docType))
        {
            if (!StringUtils.isEmpty(title))
            {
                // add a space if we had a title and have a docType
                citation.append(" ");
            }
            citation.append("[").append(docType).append("]");
        }
        // add a dot if we had title and/or docType
        if (!StringUtils.isEmpty(title) || !StringUtils.isEmpty(docType))
        {
            citation.append(".\n");
        }

        if (!StringUtils.isEmpty(place))
        {
            citation.append(place);
            if (!StringUtils.isEmpty(publisher))
            {
                citation.append(": ");
            }
        }
        if (!StringUtils.isEmpty(publisher))
        {
            citation.append(publisher);
        }
        if (! StringUtils.isEmpty(place) || !StringUtils.isEmpty(publisher))
        {
            citation.append(".\n");
        }

        // check if the item is withdrawn => add "link" to open the editor
        if (item.isWithdrawn())
        {
            citation.append("<form method=\"get\" action=\"" + request.getContextPath()
                                    + "/tools/edit-item\" style=\"display: inline-block;\" target=\"_blank\" >\n");
            citation.append("<input type=\"hidden\" name=\"item_id\" value=\"" + item.getID() + "\" />\n");
            citation.append("<input type=\"submit\" value=\""
                                + LocaleSupport.getLocalizedMessage(pageContext, "org.dspace.app.webui.jsptag.ReferenceItemTag.open.withdrawn")
                                + "\" class=\"btn btn-link\"/></form>\n");

        } else if (workflowId > 0) {
            // item is still in workflow
            citation.append("<form action=\"" + request.getContextPath()
                                + "/mydspace\" method=\"post\" style=\"display: inline-block;\" target=\"_blank\">\n");
            citation.append("<input type=\"hidden\" name=\"step\" value=\"" + MyDSpaceServlet.MAIN_PAGE + "\" />\n");
            citation.append("<input type=\"hidden\" name=\"workflow_id\" value=\"" + Integer.toString(workflowId) + "\" />\n");
            citation.append("<input class=\"btn btn-link\" type=\"submit\" name=\"submit_claim\" value=\""
                                + LocaleSupport.getLocalizedMessage(pageContext, "org.dspace.app.webui.jsptag.ReferenceItemTag.open.workflowitem")
                                + "\" />\n");
            citation.append("</form>\n");
        } else {
            citation.append("<a href=\"" + request.getContextPath() + "/handle/" + item.getHandle() + "\" "
                                + "class=\"btn btn-link\" target=\"_blank\">"
                                + LocaleSupport.getLocalizedMessage(pageContext, "org.dspace.app.webui.jsptag.ReferenceItemTag.open.item")
                                + "</a>\n");
        }

        try
        {
            // write the citation to the jsp.
            pageContext.getOut().println(citation.toString());
        } catch (IOException ex) {
            throw new JspException(ex);
        }

        return SKIP_BODY;
    }

}
