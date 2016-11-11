<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Navigation bar for admin pages
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="java.util.LinkedList" %>
<%@ page import="java.util.List" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>

<%@ page import="org.dspace.browse.BrowseInfo" %>
<%@ page import="org.dspace.sort.SortOption" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.eperson.EPerson" %>
<%@page import="org.apache.commons.lang.StringUtils"%>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

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
        currentPage = currentPage.substring(0, c);
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

%>

<div class="container" style="background-color: #fff; margin: 0; width: 100%; border-bottom: 1px #c50e1f solid;">
    <div class="topbar container">
        <!-- LOGIN / USER -->
        <% if (user != null) { %>
            <% if (false) { %>
                <a href="<%= request.getContextPath() %>/mydspace">
                    <fmt:message key="jsp.layout.navbar-default.loggedin">
                        <fmt:param><%= navbarUserName %></fmt:param>
                    </fmt:message>
                </a>
                ( <a href="<%= request.getContextPath() %>/logout"><fmt:message key="jsp.layout.navbar-default.logout"/></a>
                <a class="no-link" href="<%= request.getContextPath() %>/logout" title="<fmt:message key="jsp.layout.navbar-default.logout"/>">
                    <span class="glyphicon glyphicon-power-off"></span></a> )
            <% } %>
            <a class="no-link" href="<%= request.getContextPath() %>/logout" title="<fmt:message key="jsp.layout.navbar-default.logout"/>"><i class="glyphicon glyphicon-power-off"></i><span class="hidden-xs"> <fmt:message key="jsp.layout.navbar-default.logout"/></span></a>
            &nbsp;|&nbsp;
            <a class="no-link" href="<%= request.getContextPath() %>/subscribe" title="<fmt:message key="jsp.layout.navbar-default.receive"/>"><i class="glyphicon glyphicon-flash"></i><span class="hidden-xs"> <fmt:message key="jsp.layout.navbar-default.receive"/></span></a>
            &nbsp;|&nbsp;
            <a class="no-link" href="<%= request.getContextPath() %>/profile" title="<fmt:message key="jsp.layout.navbar-default.edit"/>"><i class="glyphicon glyphicon-user"></i><span class="hidden-xs"> <fmt:message key="jsp.layout.navbar-default.edit"/></span></a>
        <% } else { %>
            <a class="no-link" href="<%= request.getContextPath() %>/mydspace" title="<fmt:message key="jsp.layout.navbar-default.sign"/>"><i class="glyphicon glyphicon-user"></i><span class="hidden-xs"> <fmt:message key="jsp.layout.navbar-default.sign"/></span></a>
        <% } %>
        &nbsp;|&nbsp;
        <a class="no-link" href="<%= request.getContextPath() %>/feedback" id="feedback" target="_blank" class="tooltipstered" title="<fmt:message key="jsp.layout.footer-default.feedback"/>"><i class="glyphicon glyphicon-comment"></i><span class="hidden-xs"> <fmt:message key="jsp.layout.footer-default.feedback"/></span></a>
    </div>
</div>


<nav class="navbar navbar-default navbar-collapse" id="main-navbar">
    <div class="container">
        <a href="<%= request.getContextPath() %>/" class="navbar-brand navbar-right">
            <img src="<%= request.getContextPath() %>/image/logo-do.png" alt="DepositOnce" class="thumb" title="DepositOnce" style="height: 38px; padding-top: 6px;" />
        </a>
        <div class="navbar-header">
            <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>
            <a href="http://www.tu-berlin.de" target="_blank" class="navbar-brand navbar-right">
                <img src="<%= request.getContextPath() %>/image/logo-tu.png" alt="TU Berlin" class="thumb" title="TU Berlin" style="height: 45px;" />
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
                <li class="text-center dropdown">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                        <i class="glyphicon glyphicon-book" aria-hidden="true"></i>
                        <fmt:message key="jsp.layout.navbar-admin.contents"/>
                        <b class="caret"></b>
                    </a>
                    <ul class="dropdown-menu">
                        <li>
                            <a href="<%= request.getContextPath() %>/tools/edit-communities">
                                <fmt:message key="jsp.layout.navbar-admin.communities-collections"/>
                            </a>
                        </li>
                        <li class="divider"></li>
                        <li><a href="<%= request.getContextPath() %>/tools/edit-item"><fmt:message key="jsp.layout.navbar-admin.items"/></a></li>
                        <li><a href="<%= request.getContextPath() %>/dspace-admin/workflow"><fmt:message key="jsp.layout.navbar-admin.workflow"/></a></li>
                        <li><a href="<%= request.getContextPath() %>/dspace-admin/supervise"><fmt:message key="jsp.layout.navbar-admin.supervisors"/></a></li>
                        <li><a href="<%= request.getContextPath() %>/dspace-admin/curate"><fmt:message key="jsp.layout.navbar-admin.curate"/></a></li>
                        <li><a href="<%= request.getContextPath() %>/dspace-admin/withdrawn"><fmt:message key="jsp.layout.navbar-admin.withdrawn"/></a></li>
                        <li><a href="<%= request.getContextPath() %>/dspace-admin/privateitems"><fmt:message key="jsp.layout.navbar-admin.privateitems"/></a></li>
                        <li><a href="<%= request.getContextPath() %>/dspace-admin/metadataimport"><fmt:message key="jsp.layout.navbar-admin.metadataimport"/></a></li>
                        <li><a href="<%= request.getContextPath() %>/dspace-admin/batchimport"><fmt:message key="jsp.layout.navbar-admin.batchimport"/></a></li>
                    </ul>
                </li>
                <li class="text-center dropdown">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                        <i class="glyphicon glyphicon-lock" aria-hidden="true"></i>
                        <fmt:message key="jsp.layout.navbar-admin.accesscontrol"/> <b class="caret"></b>
                    </a>
                    <ul class="dropdown-menu">
                        <li>
                            <a href="<%= request.getContextPath() %>/dspace-admin/edit-epeople">
                            <fmt:message key="jsp.layout.navbar-admin.epeople"/></a>
                        </li>
                        <li>
                            <a href="<%= request.getContextPath() %>/tools/group-edit"><fmt:message key="jsp.layout.navbar-admin.groups"/></a>
                        </li>
                        <li>
                            <a href="<%= request.getContextPath() %>/tools/authorize"><fmt:message key="jsp.layout.navbar-admin.authorization"/></a>
                        </li>
                        <li>
                            <a href="<%= request.getContextPath() %>/tools/reset-accounts"><fmt:message key="jsp.layout.navbar-admin.reset-accounts"/></a>
                        </li>
                    </ul>
                </li>
                <li class="text-center <%= currentPage.endsWith("/statistics")? "active" : "" %>"">
                    <a href="<%= request.getContextPath() %>/statistics">
                        <i class="glyphicon glyphicon-bar-chart" aria-hidden="true"></i>
                        <fmt:message key="jsp.layout.navbar-admin.statistics"/>
                    </a>
                </li>
                <li class="text-center dropdown">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                        <i class="glyphicon glyphicon-cog" aria-hidden="true"></i>
                        <fmt:message key="jsp.layout.navbar-admin.settings"/> <b class="caret"></b>
                    </a>
                    <ul class="dropdown-menu">
                        <li>
                            <a href="<%= request.getContextPath() %>/dspace-admin/metadata-schema-registry">
                                <fmt:message key="jsp.layout.navbar-admin.metadataregistry"/>
                            </a>
                        </li>
                        <li>
                            <a href="<%= request.getContextPath() %>/dspace-admin/format-registry">
                                <fmt:message key="jsp.layout.navbar-admin.formatregistry"/>
                            </a>
                        </li>
                        <li class="divider"></li>
                        <li>
                            <a href="<%= request.getContextPath() %>/dspace-admin/news-edit">
                                <fmt:message key="jsp.layout.navbar-admin.editnews"/>
                            </a>
                        </li>
                        <li class="divider"></li>
                        <li>
                            <a href="<%= request.getContextPath() %>/dspace-admin/license-edit">
                            <fmt:message key="jsp.layout.navbar-admin.editlicense"/></a>
                        </li>
                    </ul>
                </li>
                <li class="text-center <%= ( currentPage.endsWith( "/help" ) ? "active" : "" ) %>">
                    <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.site-admin\") %>">
                        <fmt:message key="jsp.layout.navbar-admin.help"/>
                    </dspace:popup>
                </li>
             </ul>
        </div><!--/.nav-collapse -->
    </div>
</nav>
