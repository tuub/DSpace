<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Show the user possible duplicates we have found and ask the user if he wants to continue his/her submission
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
           prefix="fmt" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>

<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.app.webui.servlet.SubmissionController" %>
<%@ page import="org.dspace.app.util.SubmissionInfo" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="java.util.List" %>
<%@ page import="org.dspace.content.Item" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.dspace.authorize.service.AuthorizeService" %>
<%@ page import="org.dspace.authorize.factory.AuthorizeServiceFactory" %>
<%@ page import="org.dspace.workflow.factory.WorkflowServiceFactory" %>
<%@ page import="org.dspace.workflow.WorkflowItemService" %>
<%@ page import="org.dspace.content.service.ItemService" %>
<%@ page import="org.dspace.content.factory.ContentServiceFactory" %>
<%@ page import="org.dspace.submit.step.DuplicateDetectionStep" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%

    request.setAttribute("LanguageSwitch", "hide");

    // Obtain DSpace context
    Context context = UIUtil.obtainContext(request);

    // initialize authorize service
    AuthorizeService authorizeService = AuthorizeServiceFactory.getInstance().getAuthorizeService();

    // initialize itemService
    ItemService itemService = ContentServiceFactory.getInstance().getItemService();

    // initialize workflowItemService
    WorkflowItemService workflowItemService = WorkflowServiceFactory.getInstance().getWorkflowItemService();

    //get submission information object
    SubmissionInfo subInfo = SubmissionController.getSubmissionInfo(context, request);

    String inserted_metadata_value = request.getParameter("metadata_field_value");

    List<Item> duplicates = (List<Item>) request.getAttribute("duplicates");
    if (duplicates == null)
    {
        duplicates = new ArrayList<Item>(0);
    }

    // check whether we are
    boolean isAnysItemAdmin = false;
    for (Item item : duplicates)
    {
        if (authorizeService.isAdmin(context, item))
        {
            isAnysItemAdmin = true;
        }
    }
%>

<dspace:layout style="submission"
               locbar="off"
               navbar="default"
               titlekey="jsp.submit.duplicate-detection.title"
               nocache="true">

        <jsp:include page="/submit/progressbar.jsp"/>

        <h1><fmt:message key="jsp.submit.duplicate-detection.title" /></h1>
        <div class="help-block">
            <%
                // print different messages, depending if we found one or multiple items that are similar to the value entered:
                if (duplicates.size() == 1) { %>
                <p><fmt:message key="jsp.submit.duplicate-detection.info3"/><%= inserted_metadata_value %><fmt:message key="jsp.submit.duplicate-detection.info4"/></p>
            <% } else { %>
                <p><fmt:message key="jsp.submit.duplicate-detection.info5"/><%= inserted_metadata_value %><fmt:message key="jsp.submit.duplicate-detection.info6"/></p>
            <% } %>
        </div>

        <ul>
            <%
                for (Item item : duplicates)
                {
                    %>
                        <li><dspace:reference-item item="<%= item %>" /></li>
                    <%
                }
            %>
        </ul>

        <div class="col-md-8 pull-right btn-group">
            <%
                // we need two forms here. To remove or safe the submission, we have to send the information, that we are
                // canceling the submission process. To continue we must not send this information.
                // To avoid a line break between the three buttons, we need to change the css property display for both forms.

                // show the buttons "save it, I'll decide later" and "Remove the submission"
            %>
            <form action="<%= request.getContextPath() %>/submit" method="post" onkeydown="return disableEnterKey(event);" style="display: inline-block;">
                    <%-- Hidden fields needed for SubmissionController servlet to know which step is next--%>
                    <%= SubmissionController.getSubmissionParameters(context, request) %>
                    <input type="hidden" name="cancellation" value="true" />
                    <input class="btn btn-danger" type="submit" name="submit_remove" value="<fmt:message key="jsp.submit.duplicate-detection.remove.button"/>" />
                    <input class="btn btn-default" type="submit" name="submit_keep" value="<fmt:message key="jsp.submit.duplicate-detection.save.button"/>" />
            </form>

            <% // Are your sure the repository doesn't contain your item yet? "This is not a duplicate, continue" %>
            <form action="<%= request.getContextPath() %>/submit" method="post" onkeydown="return disableEnterKey(event);" style="display: inline-block;">
                <%-- Hidden fields needed for SubmissionController servlet to know which step is next--%>
                <%= SubmissionController.getSubmissionParameters(context, request) %>
                <input class="btn btn-success" type="submit" name="<%= DuplicateDetectionStep.IGNORE_DUPLICATES_BUTTON%>" value="<fmt:message key="jsp.submit.duplicate-detection.ignore-duplicates.button"/>" />
            </form>
        </div>

</dspace:layout>
