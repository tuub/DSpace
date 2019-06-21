<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Home page JSP
  -
  - Attributes:
  -    communities - Community[] all communities in DSpace
  -    recent.submissions - RecetSubmissions
  --%>

<%@page import="org.dspace.core.factory.CoreServiceFactory"%>
<%@page import="org.dspace.core.service.NewsService"%>
<%@page import="org.dspace.content.service.CommunityService"%>
<%@page import="org.dspace.content.factory.ContentServiceFactory"%>
<%@page import="org.dspace.content.service.ItemService"%>
<%@page import="org.dspace.core.Utils"%>
<%@page import="org.dspace.content.Bitstream"%>
<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="java.io.File" %>
<%@ page import="java.util.Enumeration"%>
<%@ page import="java.util.Locale"%>
<%@ page import="java.util.List"%>
<%@ page import="javax.servlet.jsp.jstl.core.*" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.dspace.core.I18nUtil" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.app.webui.components.RecentSubmissions" %>
<%@ page import="org.dspace.content.Community" %>
<%@ page import="org.dspace.browse.ItemCounter" %>
<%@ page import="org.dspace.content.Item" %>
<%@ page import="org.dspace.content.MetadataValue" %>
<%@ page import="org.dspace.services.ConfigurationService" %>
<%@ page import="org.dspace.services.factory.DSpaceServicesFactory" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>

<%
    List<Community> communities = (List<Community>) request.getAttribute("communities");

    Locale[] supportedLocales = I18nUtil.getSupportedLocales();
    Locale sessionLocale = UIUtil.getSessionLocale(request);
    Config.set(request.getSession(), Config.FMT_LOCALE, sessionLocale);
    NewsService newsService = CoreServiceFactory.getInstance().getNewsService();
    String topNews = newsService.readNewsFile(LocaleSupport.getLocalizedMessage(pageContext, "news-top.html"));
    String sideNews = newsService.readNewsFile(LocaleSupport.getLocalizedMessage(pageContext, "news-side.html"));

    ConfigurationService configurationService = DSpaceServicesFactory.getInstance().getConfigurationService();
    
    boolean feedEnabled = configurationService.getBooleanProperty("webui.feed.enable");
    String feedData = "NONE";
    if (feedEnabled)
    {
        // FeedData is expected to be a comma separated list
        String[] formats = configurationService.getArrayProperty("webui.feed.formats");
        String allFormats = StringUtils.join(formats, ",");
        feedData = "ALL:" + allFormats;
    }
    
    ItemCounter ic = new ItemCounter(UIUtil.obtainContext(request));

    RecentSubmissions submissions = (RecentSubmissions) request.getAttribute("recent.submissions");
    ItemService itemService = ContentServiceFactory.getInstance().getItemService();
    CommunityService communityService = ContentServiceFactory.getInstance().getCommunityService();
%>

<dspace:layout locbar="nolink" titlekey="jsp.collection-home.recentsub" feedData="<%= feedData %>">

<% if (supportedLocales != null && supportedLocales.length > 1) { %>
    <form method="get" name="repost" action="">
        <input type ="hidden" name ="locale"/>
    </form>
    <% for (int i = supportedLocales.length-1; i >= 0; i--) { %>
        <a class ="langChangeOn" onclick="javascript:document.repost.locale.value='<%=supportedLocales[i].toString()%>'; document.repost.submit();">
            <%= supportedLocales[i].getDisplayLanguage(supportedLocales[i])%>
        </a> &nbsp;
    <% } %>
<% } %>

<h1>
    <fmt:message key="jsp.collection-home.recentsub"/>
</h1>

<div class="row">
    <div class="col-md-12">
        <div class="panel panel-default">        
            <div class="panel-heading text-center">
                <fmt:message key="jsp.collection-home.recentsub"/>
            </div>
            <div class="panel-body">
                <% if (submissions != null && submissions.count() > 0) { %>
                    <% for (Item item : submissions.getRecentSubmissions()) { %>
                        <%
                        String displayTitle = itemService.getMetadataFirstValue(item, "dc", "title", null, Item.ANY);
                        if (displayTitle == null) {
                            displayTitle = "Untitled";
                        }
                        
                        String displayAbstract = itemService.getMetadataFirstValue(item, "dc", "description", "abstract", Item.ANY);
                        if (displayAbstract == null) {
                            displayAbstract = "";
                        }
                        
                        String displayDate = itemService.getMetadataFirstValue(item, "dc", "date", "issued", Item.ANY);
                        if (displayDate == null) {
                            displayDate = "";
                        } else {
                            displayDate = displayDate.substring(0,4);
                        }

                        String displayType = itemService.getMetadataFirstValue(item, "dc", "type", null, Item.ANY);
                        if (displayType == null) {
                            displayType = "Untyped";
                        }

                        // Get the author(s)
                        List<MetadataValue> authors = itemService.getMetadata(item, "dc", "contributor", "author", Item.ANY);
                        String displayAuthor = "";
                        for (MetadataValue author : authors) {   
                            if (displayAuthor.length() != 0) {
                                displayAuthor = displayAuthor + "; ";
                            }
                            displayAuthor += author.getValue();
                        }
                        %>

                        <a href="<%= request.getContextPath() %>/handle/<%=item.getHandle() %>"> 
                            <strong><%= Utils.addEntities(StringUtils.abbreviate(displayTitle, 400)) %></strong>
                        </a>
                
                        <p>
                            <i><%= Utils.addEntities(StringUtils.abbreviate(displayAuthor, 500)) %></i>
                            <br/>
                            <%= Utils.addEntities(StringUtils.abbreviate(displayDate, 500)) %>,
                            <%= Utils.addEntities(StringUtils.abbreviate(displayType, 500)) %>
                        </p>
                    <% } %>
                <% } %>
		    </div>
            <% if(feedEnabled) { %>
                <div class="panel-footer">
                    <%
                    String[] fmts = feedData.substring(feedData.indexOf(':')+1).split(",");
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
                        <a href="<%= request.getContextPath() %>/feed/<%= fmts[j] %>/site">
                            <img src="<%= request.getContextPath() %>/image/<%= icon %>" alt="RSS Feed" width="<%= width %>" height="15" vspace="3" border="0" />
                        </a>
                    <% } %>
                </div>
            <% } %>
        </div>
    </div>

    
</dspace:layout>