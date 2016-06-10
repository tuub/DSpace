<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%@page import="org.dspace.app.util.Util"%>
<%@page import="org.dspace.submit.step.PrivacyStatementsStep"%>
<%@page import="org.dspace.submit.AbstractProcessingStep"%>
<%--
  - Show questions regarding privacy issues in metadata.
  -
  - Attributes to pass in:
  - privacyQuestions - The privacy statements to acknowledge
  - privacyQuestionsRejected - Parameter if alls privacy statements were acknowldeged.
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>

<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.app.webui.servlet.SubmissionController" %>
<%@ page import="org.dspace.app.util.SubmissionInfo" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.app.util.Util" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<style type="text/css">
    .privacy-statement label {
        font-weight: normal !important;
    }

	.privacy-statement h1,
    .privacy-statement h2,
    .privacy-statement h3,
    .privacy-statement h4,
    .privacy-statement h5,
    .privacy-statement h6
    {
        margin-top: 0px;
        margin-bottom: 0px;
    }
</style>

<%
    request.setAttribute("LanguageSwitch", "hide");

    // Obtain DSpace context
    Context context = UIUtil.obtainContext(request);

	//get submission information object
    SubmissionInfo subInfo = SubmissionController.getSubmissionInfo(context, request);

    String license = (String) request.getAttribute("license");
%>

<dspace:layout style="submission"
			   locbar="off"
               navbar="default"
               titlekey="jsp.submit.progressbar.privacy-statements"
               nocache="true">

    <form action="<%= request.getContextPath() %>/submit" method="post" onkeydown="return disableEnterKey(event);" class="form-horizontal">

        <jsp:include page="/submit/progressbar.jsp"/>

        <h1>
            <fmt:message key="jsp.submit.privacy-statements.title" />
            <span class="pull-right"><dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.index\") +\"#license\"%>"><fmt:message key="jsp.morehelp"/></dspace:popup></span>
        </h1>

        <p>
            <fmt:message key="jsp.submit.privacy-statements.info1"/>
        </p>

        <% if (request.getAttribute("privacy_statements_rejected") != null) { %>
            <div class="alert alert-warning">
                <fmt:message key="jsp.submit.privacy-statements.error"/>
            </div>
        <% } %>

        <%
        String[] statements = PrivacyStatementsStep.loadPrivacyStatements();
        %>
        <% for (int i=0; i<statements.length ; i++) { %>
            <div class="checkbox-inline privacy-statement">
                <label>
                    <input type="checkbox" name="privacy_statements" value="privacy_statement_<%=i%>" autocomplete="on" />
                    <%= statements[i] %>
                </label>
            </div>
            <br/>
        <% } %>

        <%-- Hidden fields needed for SubmissionController servlet to know which step is next--%>
        <%= SubmissionController.getSubmissionParameters(context, request) %>

        <div class="row">
            <div class="col-md-12">
                <div class="text-center">
                    <!-- If not first step, show "Previous" button -->
                    <% if(!SubmissionController.isFirstStep(request, subInfo)) { %>
                        <input class="btn btn-default col-md-4" type="submit" name="<%=PrivacyStatementsStep.PREVIOUS_BUTTON%>" value="<fmt:message key="jsp.submit.general.previous"/>" />
                        <input class="btn btn-danger col-md-4" type="submit" name="<%=AbstractProcessingStep.CANCEL_BUTTON%>" value="<fmt:message key="jsp.submit.select-collection.cancel"/>" />
                        <input class="btn btn-success col-md-4" type="submit" name="<%=AbstractProcessingStep.NEXT_BUTTON%>" value="<fmt:message key="jsp.submit.general.next"/>" />
                    <% } else { %>
                        <input class="btn btn-danger col-md-4" type="submit" name="<%=AbstractProcessingStep.CANCEL_BUTTON%>" value="<fmt:message key="jsp.submit.select-collection.cancel"/>" />
                        <input class="btn btn-success col-md-4" type="submit" name="<%=AbstractProcessingStep.NEXT_BUTTON%>" value="<fmt:message key="jsp.submit.general.next"/>" />
                    <% } %>
                </div>
            </div>
        </div>
    </form>
</dspace:layout>
