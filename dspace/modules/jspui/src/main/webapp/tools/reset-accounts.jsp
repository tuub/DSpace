<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  -  Reset dummies account
  -
  - Attributes:
  -    
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>

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
    
    String errormsg = (String) request.getAttribute("errormsg");
    String[] accounts = (String[]) request.getAttribute("accounts");
%>

<dspace:layout titlekey="jsp.tools.reset.email.title"
navbar="<%= naviAdmin%>"
               locbar="link"
               parenttitlekey="jsp.administer"
               parentlink="/dspace-admin"
               nocache="true">
<%
    if (!StringUtils.isBlank(errormsg))
    {
%>
        <p class="text-warning"><%= errormsg %></p>
<%
    }
%>

<%
    if (accounts == null || accounts.length < 1)
    {
%>
        <p class="text-warning">No accounts where configured to be resetable. Please contact the administartor.</p>
<%
    } else {
%>
        <form action="<%=request.getContextPath()%>/tools/reset-accounts" method="post">

            <div class="input-group">
                <label class="input-group-addon"><fmt:message key="jsp.tools.reset.email.tag"/>:</label>

                <select class="form-control" name="email" id="account">
                    <optgroup label="Please select an account:">
                        <% for (String account : accounts) {%>
                            <option><%= account %></option>
                        <% } %>
                    </optgroup>
                </select>
            </div>

            <div class="input-group">
                <input class="btn btn-default" type="submit" name="submit_reset" value="<fmt:message key="jsp.tools.reset.account.button"/>" />
                <input class="btn btn-default" type="submit" name="submit_cancel" value="<fmt:message key="jsp.dspace-admin.general.cancel"/>" />
            </div>
        </form>
<%
    } // else
%>

</dspace:layout>
