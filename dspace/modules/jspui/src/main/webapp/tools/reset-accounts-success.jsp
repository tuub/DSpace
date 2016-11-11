<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page  import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>

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
    
    String password = (String) request.getAttribute("newPassword");                
    String email = (String)request.getAttribute("eperson-mail");
%>

<dspace:layout titlekey="jsp.tools.reset.email.title"
navbar="<%= naviAdmin%>"
               locbar="link"
               parenttitlekey="jsp.administer"
               parentlink="/dspace-admin"
               nocache="true">

    <h1><fmt:message key="jsp.dspace-admin.eperson-main.ResetPassword.head" /></h1>

    
    <p>
    <h4><%= email %>  <fmt:message key="jsp.tools.reset.email.new.password" /> <%= password %></h4>
       
    <p align="center">
        <a href="<%= request.getContextPath()%>/tools/reset-accounts"><fmt:message key="jsp.tools.reset.email.back" /></a>
    </p>

</dspace:layout>
