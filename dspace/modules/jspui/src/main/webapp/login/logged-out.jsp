<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Displays a message indicating the user has logged out
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<dspace:layout locbar="nolink" titlekey="jsp.login.logged-out.title">
    <%-- <h1>Logged Out</h1> --%>
    
    <div class="col-md-6 col-md-offset-3 text-center">
        <div class="panel panel-default">
            <div class="panel-heading">
                <fmt:message key="jsp.login.logged-out.title"/>
            </div>
            <div class="panel-body">
                <p>
                    <fmt:message key="jsp.login.logged-out.thank"/>
                </p>
                <p>
                    <fmt:message key="jsp.login.logged-out.auto-redirect"/>
                </p>
            </div>

    
    
    <script>
        window.setTimeout(function() {
            location.href = "<%= request.getContextPath() %>/";
            }, 3000);
    </script>

</dspace:layout>
