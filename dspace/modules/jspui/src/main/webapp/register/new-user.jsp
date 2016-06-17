<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Register with DSpace form
  -
  - Form where new users enter their email address to get a token to access
  - the personal info page.
  -
  - Attributes to pass in:
  -     retry  - if set, this is a retry after the user entered an invalid email
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="org.dspace.app.webui.servlet.RegisterServlet" %>

<%
    boolean retry = (request.getAttribute("retry") != null);
    boolean acceptPrivacyPolicy = (request.getAttribute("acceptPrivacyPolicy") != null);
%>

<dspace:layout style="submission" titlekey="jsp.register.new-user.title">
    <%-- <h1>User Registration</h1> --%>
    <h1><fmt:message key="jsp.register.new-user.title"/></h1>

    <% if (retry) { %>
        <%-- <p><strong>The e-mail address you entered was invalid.</strong>  Please try again.</strong></p> --%>
        <p class="alert alert-warning">
            <fmt:message key="jsp.register.new-user.info1"/>
        </p>
    <% } %>
    <% if (acceptPrivacyPolicy) { %>
        <p class="alert alert-warning">
            <fmt:message key="jsp.register.new-user.missing-privacy-policy"/>
        </p>
    <% } %>

    <div class="panel panel-default">
        <div class="panel-heading">
            Register
        </div>
        <div class="panel-body">
            <form class="form-horizontal" action="<%= request.getContextPath() %>/register" method="post">
                <p>
                    <fmt:message key="jsp.register.new-user.info2"/>
                </p>
                <p>
                    <fmt:message key="jsp.register.new-user.info3"/>
                </p>
                <input type="hidden" name="step" value="<%= RegisterServlet.ENTER_EMAIL_PAGE %>"/>

                <div class="form-group">
                    <div class="col-md-12">
                        <input class="form-control" type="text" name="email" id="temail" tabindex="1" placeholder="<fmt:message key="jsp.register.new-user.email.field"/>">
                    </div>
                </div>
                <div class="form-group">
                    <div class="col-md-3">
                        <input class="btn btn-success col-md-4" type="submit" name="submit" value="<fmt:message key="jsp.register.new-user.register.button"/>"/>
                    </div>
                    <div class="col-md-6 pull-right">
                        &nbsp;
                    </div>
                </div>
            </form>
        </div>
    </div>
    <!--<dspace:include page="/components/contact-info.jsp" />-->

</dspace:layout>
