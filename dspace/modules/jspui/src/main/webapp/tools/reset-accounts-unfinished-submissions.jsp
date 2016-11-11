<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page  import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>

<%@ page import="org.dspace.app.webui.servlet.MyDSpaceServlet" %>
<%@ page import="org.dspace.content.Item" %>
<%@ page import="org.dspace.content.WorkspaceItem" %>
<%@ page import="org.dspace.core.Utils" %>
<%@ page import="org.dspace.eperson.EPerson" %>
<%@ page import="java.util.List" %>

<%--
  -  Show Eperson unfinnished submissions
  -
  - Attributes:
  -    
--%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
           prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%

    request.setAttribute("LanguageSwitch", "hide");

    // Is the logged in user an admin or community admin or cllection admin
    Boolean admin = (Boolean) request.getAttribute("is.admin");
    boolean isAdmin = (admin == null ? false : admin.booleanValue());

    Boolean communityAdmin = (Boolean) request.getAttribute("is.communityAdmin");
    boolean isCommunityAdmin = (communityAdmin == null ? false : communityAdmin.booleanValue());

    Boolean collectionAdmin = (Boolean) request.getAttribute("is.collectionAdmin");
    boolean isCollectionAdmin = (collectionAdmin == null ? false : collectionAdmin.booleanValue());

    String naviAdmin = "admin";

    if (!isAdmin && (isCommunityAdmin || isCollectionAdmin)) {
        naviAdmin = "community-or-collection-admin";
    }

    //Epeson unfinnished items
    List<WorkspaceItem> workspaceItems
            = (List<WorkspaceItem>) request.getAttribute("workspace.items");
    
    EPerson eperson = (EPerson)request.getAttribute("eperson");

    String row = "even";
%>

<dspace:layout titlekey="jsp.tools.reset.email.title"
navbar="<%= naviAdmin%>"
               locbar="link"
               parenttitlekey="jsp.administer"
               parentlink="/dspace-admin"
               nocache="true">



    <!-- Display workspace items if any -->
    <% if (!workspaceItems.isEmtpy()) { %>
    <div class="panel panel-warning">
        <div class="panel-heading">
            <fmt:message key="jsp.tools.reset.email.unfinished.submissions"/>
        </div>

        <table class="table" align="center" summary="Table listing unfinished submissions">
            <tr>
                <th id="t10" class="oddRowEvenCol"><fmt:message key="jsp.mydspace.main.subby"/></th>
                <th id="t11" class="oddRowOddCol"><fmt:message key="jsp.mydspace.main.elem1"/></th>
                <th id="t12" class="oddRowEvenCol"><fmt:message key="jsp.mydspace.main.elem2"/></th>
                <th id="t13" class="oddRowOddCol"><fmt:message key="metadata.dc.type"/></th>
            </tr>
            <tr>
                <th colspan="5">
                    <%-- Authoring --%>
                    <fmt:message key="jsp.mydspace.main.authoring" />
                </th>
            </tr>

            <% for (WorkspaceItem wsi : workspaceItems) {
                    String title = itemService.getMetadataFirstValue(wsi.getItem(), "dc", "title", null, Item.ANY);
                    if (title == null)
                    {
                        title = LocaleSupport.getLocalizedMessage(pageContext, "jsp.general.untitled");
                    }
                    EPerson submitter = wsi.getItem().getSubmitter();
            %>
            <tr>
                <td headers="t10" class="<%= row%>RowEvenCol"><%= Utils.addEntities(submitter.getFullName())%></td>
                <td headers="t11" class="<%= row%>RowOddCol"><%= Utils.addEntities(title)%></td>
                <td headers="t12" class="<%= row%>RowEvenCol"><%= wsi.getCollection().getMetadata("name")%></td>
                <td headers="t13" class="<%= row%>RowOddCol"><%
                String type = itemService.getMetadataFirstValue(wsi.getItem(), "dc", "type", null, Item.ANY);
                if (type != null)
                {
                    out.print(type);
                } else {
                    out.print("&nbsp;");
                }
                %></td>
            </tr>
            <% }%>
        </table>       
    </div>
    <% }%>
    <form action="<%=request.getContextPath()%>/tools/reset-accounts" method="post">
        <input type="hidden" name="eperson_email" value="<%= eperson.getEmail() %>"/>

        <div class="input-group">
            <input class="btn btn-primary" type="submit" name="submit_reset_continue" value="<fmt:message key="jsp.dspace-admin.general.delete"/>" />
            <input class="btn btn-default" type="submit" name="submit_cancel" value="<fmt:message key="jsp.dspace-admin.general.cancel"/>" />
        </div>

    </form>
</dspace:layout>
