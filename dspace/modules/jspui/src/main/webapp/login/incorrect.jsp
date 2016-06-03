<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Display message indicating password is incorrect, and allow a retry
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>


<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>


<dspace:layout style="submission" navbar="default"
               locbar="nolink"
               titlekey="jsp.login.incorrect.title">

    <div class="container col-md-6 col-md-offset-3">        
        <div class="panel panel-default">
            <div class="panel-heading">
                <fmt:message key="jsp.login.password.heading"/>
                <span class="pull-right">
                    <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.index\") + \"#login\"%>"><fmt:message key="jsp.help"/></dspace:popup>
                </span>
            </div>
            <div class="panel panel-body">        
                <p class="alert alert-warning">
                    <strong>
                        <fmt:message key="jsp.login.incorrect.text">
                            <fmt:param><%= request.getContextPath() %>/forgot</fmt:param>
                        </fmt:message>
                    </strong>
                </p>
            </div>                
            <dspace:include page="/components/login-form.jsp" />
        </div>
    </div>

</dspace:layout>
