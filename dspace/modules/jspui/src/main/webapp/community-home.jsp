<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Community home JSP
  -
  - Attributes required:
  -    community             - Community to render home page for
  -    collections           - array of Collections in this community
  -    subcommunities        - array of Sub-communities in this community
  -    last.submitted.titles - String[] of titles of recently submitted items
  -    last.submitted.urls   - String[] of URLs of recently submitted items
  -    admin_button - Boolean, show admin 'edit' button
  --%>

<%@page import="org.dspace.content.service.CollectionService"%>
<%@page import="org.dspace.content.factory.ContentServiceFactory"%>
<%@page import="org.dspace.content.service.CommunityService"%>
<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.dspace.app.webui.components.RecentSubmissions" %>

<%@ page import="org.dspace.app.webui.servlet.admin.EditCommunitiesServlet" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.browse.BrowseIndex" %>
<%@ page import="org.dspace.browse.ItemCounter" %>
<%@ page import="org.dspace.content.*" %>
<%@ page import="org.dspace.core.Utils" %>
<%@ page import="org.dspace.services.ConfigurationService" %>
<%@ page import="org.dspace.services.factory.DSpaceServicesFactory" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.content.MetadataSchema" %>
<%@ page import="java.util.ArrayList" %>


<%
    // Retrieve attributes
    Community community = (Community) request.getAttribute( "community" );
    List<Collection> collections =
        (List<Collection>) request.getAttribute("collections");
    List<Community> subcommunities =
        (List<Community>) request.getAttribute("subcommunities");

    RecentSubmissions rs = (RecentSubmissions) request.getAttribute("recently.submitted");

    Boolean editor_b = (Boolean)request.getAttribute("editor_button");
    boolean editor_button = (editor_b == null ? false : editor_b.booleanValue());
    Boolean add_b = (Boolean)request.getAttribute("add_button");
    boolean add_button = (add_b == null ? false : add_b.booleanValue());
    Boolean remove_b = (Boolean)request.getAttribute("remove_button");
    boolean remove_button = (remove_b == null ? false : remove_b.booleanValue());

    // get the browse indices
    BrowseIndex[] bis = BrowseIndex.getBrowseIndices();
    CommunityService comServ = ContentServiceFactory.getInstance().getCommunityService();
    CollectionService colServ = ContentServiceFactory.getInstance().getCollectionService();
    // Put the metadata values into guaranteed non-null variables
    String name = comServ.getMetadata(community, "name");
    String intro = comServ.getMetadata(community, "introductory_text");
    String copyright = comServ.getMetadata(community, "copyright_text");
    String sidebar = comServ.getMetadata(community, "side_bar_text");
    Bitstream logo = community.getLogo();

    ConfigurationService configurationService = DSpaceServicesFactory.getInstance().getConfigurationService();

    boolean feedEnabled = configurationService.getBooleanProperty("webui.feed.enable");
    String feedData = "NONE";
    if (feedEnabled)
    {
        // FeedData is expected to be a comma separated list
        String[] formats = configurationService.getArrayProperty("webui.feed.formats");
        String allFormats = StringUtils.join(formats, ",");
        feedData = "comm:" + allFormats;
    }

    ItemCounter ic = new ItemCounter(UIUtil.obtainContext(request));

    List<Item> items = rs.getRecentSubmissions();
    boolean first = true;
%>

<%@page import="org.dspace.app.webui.servlet.MyDSpaceServlet"%>
<dspace:layout locbar="commLink" title="<%= name %>" feedData="<%= feedData %>">
    <div class="well">
        <div class="row">
            <div class="col-md-8">
                <h2>
                    <%= name %>
                    <a class="statisticsLink btn btn-xs btn-default" href="<%= request.getContextPath() %>/handle/<%= community.getHandle() %>/statistics">
                        <i class="glyphicon glyphicon-bar-chart" aria-hidden="true"></i><fmt:message key="jsp.community-home.display-statistics"/>
                    </a>
                </h2>
                <% if(configurationService.getBooleanProperty("webui.strengths.show")) { %>
                    <%= ic.getCount(community) %> <fmt:message key="jsp.layout.navbar-admin.items"/>
                <% } %>
            </div>
            <%  if (logo != null) { %>
                <div class="col-md-4">
                    <img class="img-responsive" alt="Logo" src="<%= request.getContextPath() %>/retrieve/<%= logo.getID() %>" />
                </div>
            <% } %>
        </div>
        <% if (StringUtils.isNotBlank(intro)) { %>
            <%= intro %>
        <% } %>
    </div>
    <p class="copyrightText">
        <%= copyright %>
    </p>
    <!-- RECENT SUBMISSIONS TO THIS COMMUNITY -->
    <div class="row">
        <div class="col-md-12">
            <div class="panel panel-default">
                <div class="panel-heading text-center">
                    <fmt:message key="jsp.community-home.recentsub"/>
                </div>
                <div class="panel-body">
                    <% for (int i = 0; i < items.size(); i++) { %>
                        <%
                        Item item = items.get(i);
                        /* Get title */
                        String title = item.getName();
                        String displayTitle = "Untitled";
                        if (StringUtils.isNotBlank(title)) {
                            displayTitle = Utils.addEntities(title);
                        }
                        /* Get authors */
                        List<MetadataValue> authors = item.getItemService()
                                .getMetadata(item, MetadataSchema.DC_SCHEMA, "contributor", "author", Item.ANY);
                        List<String> authorList = new ArrayList();
                        for( int j=0 ; j < authors.size(); j++ )
                        {
                            authorList.add(authors.get(j).getValue());
                        }
                        /* Get publication date */
                        String publicationDate = item.getItemService()
                                .getMetadataFirstValue(item, MetadataSchema.DC_SCHEMA, "date", "issued", Item.ANY);
                        /* Get abstract */
                        String description = item.getItemService()
                                .getMetadataFirstValue(item, MetadataSchema.DC_SCHEMA, "description", "abstract", Item.ANY);
                        %>
                        <a href="<%= request.getContextPath() %>/handle/<%= item.getHandle() %>">
                            <strong><%= StringUtils.abbreviate(displayTitle, 400) %></strong>
                        </a>
                        <p>
                            <i><%= StringUtils.join(authorList, " ; ") %></i> (<%= publicationDate %>)
                        </p>
                        <p>
                            <%= StringUtils.abbreviate(description, 400) %>
                        </p>
                        <%
                            first = false;
                        %>
                    <% } %>
                </div>
                <div class="panel-footer">
                    <% if(feedEnabled) { %>
                        <%
                            String[] fmts = feedData.substring(5).split(",");
                            String icon = null;
                            int width = 0;
                        %>
                        <% for (int j = 0; j < fmts.length; j++) { %>
                            <%
                            if ("rss_1.0".equals(fmts[j])) {
                                icon = "rss1.gif";
                                width = 80;
                            } else if ("rss_2.0".equals(fmts[j])) {
                                icon = "rss2.gif";
                                width = 80;
                            } else {
                                icon = "rss.gif";
                                width = 36;
                            }
                            %>
                            <a href="<%= request.getContextPath() %>/feed/<%= fmts[j] %>/<%= community.getHandle() %>">
                                <img src="<%= request.getContextPath() %>/image/<%= icon %>" alt="RSS Feed" width="<%= width %>" height="15" style="margin: 3px 0 3px" />
                            </a>
                        <% } %>
                    <% } %>
                </div>
            </div>
        </div>

        <!-- COMMUNITY STATISTICS -->
        <div id="statistics"></div>
        <!-- /COMMUNITY STATISTICS -->

        <div class="col-md-2">

        </div>
    </div>
    <!-- /RECENT SUBMISSIONS TO THIS COMMUNITY -->


    <div class="row">
        <%@ include file="discovery/static-tagcloud-facet.jsp" %>
    </div>


    <dspace:sidebar>

        <% if(editor_button || add_button) { %>

            <div class="col-md-12">

                <div class="panel panel-default facets">
                    <div class="panel-heading">
                        <fmt:message key="jsp.admintools"/>
                        <span class="pull-right">
                            <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.site-admin\")%>"><fmt:message key="jsp.adminhelp"/></dspace:popup>
                        </span>
                    </div>
                    <div class="panel-body">
                        <ul class="list-group">
                            <% if(editor_button) { %>
                                <li class="list-group-item">
                                    <form method="post" action="<%=request.getContextPath()%>/tools/edit-communities">
                                        <input type="hidden" name="community_id" value="<%= community.getID() %>" />
                                        <input type="hidden" name="action" value="<%=EditCommunitiesServlet.START_EDIT_COMMUNITY%>" />
                                        <%--<input type="submit" value="Edit..." />--%>
                                        <input class="btn btn-link" type="submit" value="<fmt:message key="jsp.general.edit.button"/>" />
                                    </form>
                                </li>
                            <% } %>
                            <% if(add_button) { %>
                                <li class="list-group-item">
                                    <form method="post" action="<%=request.getContextPath()%>/tools/collection-wizard">
                                        <input type="hidden" name="community_id" value="<%= community.getID() %>" />
                                        <input class="btn btn-link" type="submit" value="<fmt:message key="jsp.community-home.create1.button"/>" />
                                    </form>
                                </li>
                                <li class="list-group-item">
                                    <form method="post" action="<%=request.getContextPath()%>/tools/edit-communities">
                                        <input type="hidden" name="action" value="<%= EditCommunitiesServlet.START_CREATE_COMMUNITY%>" />
                                        <input type="hidden" name="parent_community_id" value="<%= community.getID() %>" />
                                        <%--<input type="submit" name="submit" value="Create Sub-community" />--%>
                                        <input class="btn btn-link" type="submit" name="submit" value="<fmt:message key="jsp.community-home.create2.button"/>" />
                                    </form>
                                </li>
                            <% } %>
                            <% if( editor_button ) { %>
                                <li class="list-group-item">
                                    <form method="post" action="<%=request.getContextPath()%>/mydspace">
                                        <input type="hidden" name="community_id" value="<%= community.getID() %>" />
                                        <input type="hidden" name="step" value="<%= MyDSpaceServlet.REQUEST_EXPORT_ARCHIVE %>" />
                                        <input class="btn btn-link" type="submit" value="<fmt:message key="jsp.mydspace.request.export.community"/>" />
                                    </form>
                                </li>
                                <li class="list-group-item">
                                    <form method="post" action="<%=request.getContextPath()%>/mydspace">
                                        <input type="hidden" name="community_id" value="<%= community.getID() %>" />
                                        <input type="hidden" name="step" value="<%= MyDSpaceServlet.REQUEST_MIGRATE_ARCHIVE %>" />
                                        <input class="btn btn-link" type="submit" value="<fmt:message key="jsp.mydspace.request.export.migratecommunity"/>" />
                                    </form>
                                </li>
                                <li class="list-group-item">
                                    <form method="post" action="<%=request.getContextPath()%>/tools/metadataexport">
                                        <input type="hidden" name="handle" value="<%= community.getHandle() %>" />
                                        <input class="btn btn-link" type="submit" value="<fmt:message key="jsp.general.metadataexport.button"/>" />
                                    </form>
                                </li>
                            <% } %>
                        </ul>
                    </div>
                </div>
            </div>
        <% } %>

        <% if (subcommunities.size() != 0) { %>
            <div class="col-md-12">
                <div class="panel panel-default facets">
                    <div class="panel-heading">
                        <fmt:message key="jsp.community-home.sidebar.communities"/>
                        <!--<fmt:message key="jsp.community-home.heading3"/>-->
                    </div>
                    <div class="panel-body">
                        <ul class="list-group">
                            <% for (int j = 0; j < subcommunities.size(); j++) { %>
                                <li class="list-group-item">
                                    <a href="<%= request.getContextPath() %>/handle/<%= subcommunities.get(j).getHandle() %>">
                                        <%= subcommunities.get(j).getName() %>
                                    </a>
                                    <% if (remove_button) { %>
                                        <form class="btn-toolbar" method="post" action="<%=request.getContextPath()%>/tools/edit-communities">
                                            <input type="hidden" name="parent_community_id" value="<%= community.getID() %>" />
                                            <input type="hidden" name="community_id" value="<%= subcommunities.get(j).getID() %>" />
                                            <input type="hidden" name="action" value="<%=EditCommunitiesServlet.START_DELETE_COMMUNITY%>" />
                                            <button type="submit" class="btn btn-xs btn-danger"><span class="glyphicon glyphicon-trash"></span></button>
                                        </form>
                                    <% } %>
                                </li>
                            <% } %>
                        </ul>
                    </div>
                </div>
            </div>
        <% } %>

        <% if (collections.size() != 0) { %>

            <div class="col-md-12">
                <%-- <h3>Collections in this community</h3> --%>
                <div class="panel panel-default facets">
                    <div class="panel-heading">
                        <fmt:message key="jsp.community-home.sidebar.collections"/>
                        <!--<fmt:message key="jsp.community-home.heading2"/>-->
                    </div>
                    <div class="panel-body">
                        <ul class="list-group">
                            <% for (int i = 0; i < collections.size(); i++) { %>
                                <li class="list-group-item">
                                    <a href="<%= request.getContextPath() %>/handle/<%= collections.get(i).getHandle() %>">
                                        <%= collections.get(i).getName() %>
                                    </a>
                                    <% if (remove_button) { %>
                                        <form class="btn-toolbar" method="post" action="<%=request.getContextPath()%>/tools/edit-communities">
                                            <input type="hidden" name="parent_community_id" value="<%= community.getID() %>" />
                                            <input type="hidden" name="community_id" value="<%= community.getID() %>" />
                                            <input type="hidden" name="collection_id" value="<%= collections.get(i).getID() %>" />
                                            <input type="hidden" name="action" value="<%=EditCommunitiesServlet.START_DELETE_COLLECTION%>" />
                                            <button type="submit" class="btn btn-xs btn-danger"><span class="glyphicon glyphicon-trash"></span></button>
                                        </form>
                                    <% } %>
                                </li>
                            <% } %>
                        </ul>
                    </div>
                </div>
            </div>
        <% } %>

        <%-- Browse --%>
        <div class="col-md-12">
            <div class="panel panel-default facets">
                <div class="panel-heading">
                    <fmt:message key="jsp.community-home.sidebar.browseby"/>
                    <!--<fmt:message key="jsp.general.browse"/>-->
                </div>

                <div class="panel-body">
                    <ul class="list-group">
                        <%-- Insert the dynamic list of browse options --%>
                        <% for (int i = 0; i < bis.length; i++) { %>
                            <%
                            String key = "browse.menu." + bis[i].getName();
                            %>
                            <li class="list-group-item">
                                <form method="get" action="<%= request.getContextPath() %>/handle/<%= community.getHandle() %>/browse">
                                    <input type="hidden" name="type" value="<%= bis[i].getName() %>"/>
                                    <%-- <input type="hidden" name="community" value="<%= community.getHandle() %>" /> --%>
                                    <input class="btn btn-link browse" type="submit" name="submit_browse" value="<fmt:message key="<%= key %>"/>"/>
                                </form>
                            </li>
                        <% } %>
                    </ul>
                </div>
            </div>
        </div>

        <%= sidebar %>

        <%
            int discovery_panel_cols = 12;
            int discovery_facet_cols = 12;
        %>
        <%@ include file="discovery/static-sidebar-facet.jsp" %>
  </dspace:sidebar>
</dspace:layout>
