<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Default navigation bar
--%>

<%@page import="org.apache.commons.lang.StringUtils"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="/WEB-INF/dspace-tags.tld" prefix="dspace" %>

<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale"%>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.core.I18nUtil" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.content.Collection" %>
<%@ page import="org.dspace.content.Community" %>
<%@ page import="org.dspace.eperson.EPerson" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.browse.BrowseIndex" %>
<%@ page import="org.dspace.browse.BrowseInfo" %>
<%@ page import="java.util.Map" %>
<%
    // Is anyone logged in?
    EPerson user = (EPerson) request.getAttribute("dspace.current.user");

    // Is the logged in user an admin
    Boolean admin = (Boolean)request.getAttribute("is.admin");
    boolean isAdmin = (admin == null ? false : admin.booleanValue());

    // Is the logged in user a community admin
    Boolean communityAdmin = (Boolean)request.getAttribute("is.communityAdmin");
    boolean isCommunityAdmin = (communityAdmin == null ? false : communityAdmin.booleanValue());

    // Is the logged in user a collection admin
    Boolean collectionAdmin = (Boolean)request.getAttribute("is.collectionAdmin");
    boolean isCollectionAdmin = (collectionAdmin == null ? false : collectionAdmin.booleanValue());

    // Get the current page, minus query string
    String currentPage = UIUtil.getOriginalURL(request);
    int c = currentPage.indexOf( '?' );
    if( c > -1 )
    {
        currentPage = currentPage.substring( 0, c );
    }

    // E-mail may have to be truncated
    String navbarEmail = null;

    String navbarUserName = "";
    if (null != user)
    {
        navbarUserName = user.getEmail();
        navbarEmail = user.getEmail();

        if( user.getFullName() != null )
        {
            navbarUserName = user.getFullName();
        }
    }

    // get the browse indices

    BrowseIndex[] bis = BrowseIndex.getBrowseIndices();
    BrowseInfo binfo = (BrowseInfo) request.getAttribute("browse.info");
    String browseCurrent = "";
    if (binfo != null)
    {
        BrowseIndex bix = binfo.getBrowseIndex();
        // Only highlight the current browse, only if it is a metadata index,
        // or the selected sort option is the default for the index
        if (bix.isMetadataIndex() || bix.getSortOption() == binfo.getSortOption())
        {
            if (bix.getName() != null)
                browseCurrent = bix.getName();
        }
    }
 // get the locale languages
    Locale[] supportedLocales = I18nUtil.getSupportedLocales();
    Locale sessionLocale = UIUtil.getSessionLocale(request);
%>

<div class="container" style="background-color: #fff; margin: 0; width: 100%; border-bottom: 1px #c50e1f solid;">
    <div class="topbar container">
        <!-- LOGIN / USER -->
        <% if (user != null) { %>
            <a href="<%= request.getContextPath() %>/mydspace">
                <fmt:message key="jsp.layout.navbar-default.loggedin">
                    <fmt:param><%= navbarUserName %></fmt:param>
                </fmt:message>
            </a>
            ( <a href="<%= request.getContextPath() %>/logout"><fmt:message key="jsp.layout.navbar-default.logout"/></a>
            <a class="no-link" href="<%= request.getContextPath() %>/logout" title="<fmt:message key="jsp.layout.navbar-default.logout"/>">
                <span class="glyphicon glyphicon-power-off"></span></a> )
            &nbsp;|&nbsp;
            <a href="<%= request.getContextPath() %>/subscribe"><fmt:message key="jsp.layout.navbar-default.receive"/></a>
            &nbsp;|&nbsp;
            <a href="<%= request.getContextPath() %>/profile"><fmt:message key="jsp.layout.navbar-default.edit"/></a>
        <% } else { %>
            <span class="glyphicon glyphicon-user"></span>
            <a href="<%= request.getContextPath() %>/mydspace"><fmt:message key="jsp.layout.navbar-default.sign"/></a>
        <% } %>
        &nbsp;|&nbsp;
        <span class="glyphicon glyphicon-comment"></span>
        <a href="<%= request.getContextPath() %>/feedback" id="feedback" target="_blank" class="tooltipstered">
            <fmt:message key="jsp.layout.footer-default.feedback"/>
        </a>       
    </div>
</div>


<nav class="navbar navbar-default navbar-collapse" id="main-navbar">
    <div class="container">
        <a href="<%= request.getContextPath() %>/" class="navbar-brand navbar-right">
            <img src="<%= request.getContextPath() %>/image/logo-do.png" alt="DepositOnce" class="header-logo" title="DepositOnce" style="height: 38px; padding-top: 6px;" />
        </a>
        <div class="navbar-header">
            <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>
            <a href="http://www.tu-berlin.de" target="_blank" class="navbar-brand navbar-right">
                <img src="<%= request.getContextPath() %>/image/logo-tu.png" alt="TU Berlin" class="header-logo" title="TU Berlin" style="height: 45px;" />
            </a>
        </div>
        <div id="navbar" class="navbar-collapse collapse">
            <ul class="nav navbar-nav navbar-right">
                <!-- HOME -->
                <li class="text-center <%= currentPage.endsWith("/home.jsp")? "active" : "" %>">
                    <a href="<%= request.getContextPath() %>/">
                        <i class="glyphicon glyphicon-home" aria-hidden="true"></i>
                        <fmt:message key="jsp.layout.navbar-default.home"/>
                    </a>
                </li>
                <!-- SEARCH -->
                <li class="text-center <%= currentPage.endsWith("search") ? "active" : "" %>">
                    <a href="<%= request.getContextPath() %>/simple-search">
                        <i class="glyphicon glyphicon-search" aria-hidden="true"></i>
                        <fmt:message key="jsp.layout.navbar-default.search"/>
                    </a>
                </li>
                <li class="text-center dropdown <%= currentPage.endsWith("/browse") || currentPage.endsWith("/community-list") || currentPage.endsWith("/recent.jsp") ? "active" : "" %>">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                        <i class="glyphicon glyphicon-list" aria-hidden="true"></i><fmt:message key="jsp.layout.navbar-default.browse"/>
                        <b class="caret"></b>
                    </a>
                    <ul class="dropdown-menu">
                        <li>
                            <a href="<%= request.getContextPath() %>/community-list">
                                <fmt:message key="jsp.layout.navbar-default.communities-collections"/>
                            </a>
                        </li>
                        <li>
                            <a href="<%= request.getContextPath() %>/recent">
                                <fmt:message key="jsp.layout.navbar-default.recent-submissions"/>
                            </a>
                        </li>
                        <li class="divider"></li>
                        <li class="dropdown-header">
                            <fmt:message key="jsp.layout.navbar-default.browseitemsby"/>
                        </li>
                        <%-- Insert the dynamic browse indices here --%>
                        <% for (int i = 0; i < bis.length; i++) {
                            BrowseIndex bix = bis[i];
                            String key = "browse.menu." + bix.getName();
                            %>
                            <li>
                                <a href="<%= request.getContextPath() %>/browse?type=<%= bix.getName() %>">
                                    <fmt:message key="<%= key %>"/>
                                </a>
                            </li>
                        <% } %>
                        <%-- End of dynamic browse indices --%>
                        <% if (ConfigurationManager.getBooleanProperty("webui.controlledvocabulary.enable")) { %>
                            <li class="divider"></li>
                            <li>
                                <a href="<%= request.getContextPath() %>/subject-search">
                                    <fmt:message key="jsp.layout.navbar-default.subjectsearch"/>
                                </a>
                            </li>
                        <% } %>
                    </ul>
                </li>
                <!-- PUBLISH -->
                <li class="text-center <%= currentPage.endsWith("/submit")? "active" : "" %>">
                    <a href="<%= request.getContextPath() %>/submit">
                        <i class="glyphicon glyphicon-upload" aria-hidden="true"></i><fmt:message key="jsp.layout.navbar-default.publish"/>
                    </a>
                </li>
                <!-- MY DEPOSITS -->
                <li class="text-center <%= currentPage.endsWith("/mydspace")? "active" : "" %>"">
                    <a href="<%= request.getContextPath() %>/mydspace">
                        <i class="glyphicon glyphicon-file-text" aria-hidden="true"></i><fmt:message key="jsp.layout.navbar-default.users"/>
                    </a>
                </li>
                <!-- LANGUAGE -->
                <% if (supportedLocales != null && supportedLocales.length > 1) { %>
                    <li class="text-center dropdown">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                            <fmt:message key="jsp.layout.navbar-default.language"/><b class="caret"></b>
                        </a>
                        <ul class="dropdown-menu">
                            <% for (int i = supportedLocales.length-1; i >= 0; i--) { %>
                                <li>
                                    <a onclick="javascript:document.repost.locale.value='<%=supportedLocales[i].toString()%>'; document.repost.submit();" href="<%= request.getContextPath() %>?locale=<%=supportedLocales[i].toString()%>">
                                        <%= supportedLocales[i].getDisplayLanguage(supportedLocales[i])%>
                                    </a>
                                </li>
                            <% } %>
                        </ul>
                    </li>
                <% } %>
                <!-- ADMINISTER -->
                <% if (isAdmin) { %>
                    <li class="text-center">
                        <a href="<%= request.getContextPath() %>/dspace-admin">
                            <i class="glyphicon glyphicon-wrench" aria-hidden="true"></i><fmt:message key="jsp.administer"/>
                        </a>
                    </li>
                <% } else if (isCommunityAdmin || isCollectionAdmin) { %>
                    <li class="text-center">
                        <a href="<%= request.getContextPath() %>/tools">
                            <i class="glyphicon glyphicon-wrench" aria-hidden="true"></i><fmt:message key="jsp.administer"/>
                        </a>
                    </li>
                <% } %>
            </ul>
        </div><!--/.nav-collapse -->
    </div>
</nav>
