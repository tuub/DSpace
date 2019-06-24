<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  request the title of the submission to perfom a search for previously archived duplicates. If a title was filled out
  by a previous task, show this title to the use so he/she may edit it.
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
           prefix="fmt" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>

<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.app.webui.servlet.SubmissionController" %>
<%@ page import="org.dspace.app.util.SubmissionInfo" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.dspace.submit.AbstractProcessingStep" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%
    request.setAttribute("LanguageSwitch", "hide");

    // Obtain DSpace context
    Context context = UIUtil.obtainContext(request);

    //get submission information object
    SubmissionInfo subInfo = SubmissionController.getSubmissionInfo(context, request);

    String title = StringUtils.trim((String) request.getAttribute("item_title"));
    if (StringUtils.isEmpty(title))
    {
        title = "";
    }

    String errormessage = StringUtils.trim((String) request.getAttribute("errormessage"));

    Boolean doNotProceed = (Boolean)request.getAttribute("doNotProceed");
    boolean stopProceeding = (doNotProceed == null ? false : doNotProceed.booleanValue());
%>

<dspace:layout style="submission"
               locbar="off"
               navbar="default"
               titlekey="jsp.submit.duplicate-detection.title"
               nocache="true">

    <form action="<%= request.getContextPath() %>/submit" method="post" onkeydown="return disableEnterKey(event);">

        <jsp:include page="/submit/progressbar.jsp"/>

        <h1><fmt:message key="jsp.submit.duplicate-detection.title" /></h1>
        <div class="help-block">
            <% if (StringUtils.isEmpty(title)) {%>
                <fmt:message key="jsp.submit.duplicate-detection.info1"/>
            <% } else { %>
                <fmt:message key="jsp.submit.duplicate-detection.info2"/>
            <% } %>
        </div>
        <% if (!StringUtils.isEmpty(errormessage)) { %>
            <div class="alert alert-warning"><fmt:message key="<%= errormessage%>" /></div>
        <% } %>
        <% if (!stopProceeding) {%>
            <div class="row"><label class="col-md-2 label-required"><fmt:message key="jsp.submit.duplicate-detection.field-label" /></label><div class="col-md-10"><div class="row col-md-12"><div class="col-md-10"><input class="form-control" type="text" name="metadata_field_value" id="matadata_field_value" size="50" value="<%= title %>"/></div></div></div></div><br/>
        <% } %>


        <%-- Hidden fields needed for SubmissionController servlet to know which step is next--%>
        <%= SubmissionController.getSubmissionParameters(context, request) %>

        <%  //if not first step, show "Previous" button
            if(!SubmissionController.isFirstStep(request, subInfo))
            { %>
        <div class="col-md-6 pull-right btn-group">
            <input class="btn btn-default col-md-4" type="submit" name="<%=AbstractProcessingStep.PREVIOUS_BUTTON%>" value="<fmt:message key="jsp.submit.general.previous"/>" />
            <input class="btn btn-default col-md-4" type="submit" name="<%=AbstractProcessingStep.CANCEL_BUTTON%>" value="<fmt:message key="jsp.submit.general.cancel-or-save.button"/>" />
            <input class="btn btn-primary col-md-4" type="submit" name="<%=AbstractProcessingStep.NEXT_BUTTON%>" value="<fmt:message key="jsp.submit.general.next"/>" />

                    <%  } else { %>
            <div class="col-md-4 pull-right btn-group">
                <input class="btn btn-default col-md-6" type="submit" name="<%=AbstractProcessingStep.CANCEL_BUTTON%>" value="<fmt:message key="jsp.submit.general.cancel-or-save.button"/>" />
                <input class="btn btn-primary col-md-6" type="submit" name="<%=AbstractProcessingStep.NEXT_BUTTON%>" value="<fmt:message key="jsp.submit.general.next"/>" />
                <%  }  %>
            </div>
    </form>
</dspace:layout>
