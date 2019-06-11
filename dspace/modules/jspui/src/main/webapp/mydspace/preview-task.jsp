<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Preview task page
  -
  -   workflow.item:  The workflow item for the task they're performing
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="org.dspace.app.util.CollectionDropDown" %>
<%@ page import="org.dspace.app.webui.servlet.MyDSpaceServlet" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.content.Collection" %>
<%@ page import="org.dspace.content.Item" %>
<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.eperson.EPerson" %>
<%@ page import="org.dspace.identifier.DOI" %>
<%@ page import="org.dspace.identifier.service.IdentifierService" %>
<%@ page import="org.dspace.identifier.factory.IdentifierServiceFactory" %>
<%@ page import="org.dspace.services.factory.DSpaceServicesFactory" %>
<%@ page import="org.dspace.workflowbasic.BasicWorkflowItem" %>
<%@ page import="org.dspace.workflowbasic.service.BasicWorkflowService" %>

<%@ page import="org.apache.commons.lang.StringUtils" %>


<%
    BasicWorkflowItem workflowItem =
        (BasicWorkflowItem) request.getAttribute("workflow.item");

    Collection collection = workflowItem.getCollection();
    Item item = workflowItem.getItem();

    Context context = UIUtil.obtainContext(request);
    boolean claimed = false;
    
    IdentifierService identifierService = IdentifierServiceFactory.getInstance().getIdentifierService();
    String doi = null;
    try
    {
        doi = identifierService.lookup(context, item, DOI.class);
        if (!StringUtils.isEmpty(doi))
        { 
            doi = IdentifierServiceFactory.getInstance().getDOIService().DOIToExternalForm(doi);   
        }
    }
    catch (Exception ex)
    {
            // nothing to do here
    }
%>

<dspace:layout style="submission"
			   locbar="link"
               parentlink="/mydspace"
               parenttitlekey="jsp.mydspace"
               titlekey="jsp.mydspace.preview-task.title"
               nocache="true">

	<h1><fmt:message key="jsp.mydspace.preview-task.title"/></h1>
    
<%
    String key = new String();
    if (workflowItem.getState() == BasicWorkflowService.WFSTATE_STEP1POOL)
    {
        key = "jsp.mydspace.preview-task.text1";
    }
    else if(workflowItem.getState() == BasicWorkflowService.WFSTATE_STEP2POOL)
    {
        key = "jsp.mydspace.preview-task.text3";
    }
    else if(workflowItem.getState() == BasicWorkflowService.WFSTATE_STEP3POOL)
    {
        key = "jsp.mydspace.preview-task.text4";
    }
    else if(workflowItem.getState() == BasicWorkflowService.WFSTATE_STEP1
            || workflowItem.getState() == BasicWorkflowService.WFSTATE_STEP2
            || workflowItem.getState() == BasicWorkflowService.WFSTATE_STEP3)
    {
        claimed = true;
        key="jsp.mydspace.preview-task.text5";
    }
%>
 <p>
    <fmt:message key="<%= key %>">
    <fmt:param><%= CollectionDropDown.collectionPath(context, collection) %></fmt:param>
    </fmt:message>
</p>

<% if (!StringUtils.isEmpty(doi)) { %>
    <table class="table table-striped table-bordered" style="margin: 0 auto; width: 100%;">
        <colgroup>
            <col class="col-md-4 text-left">
            <col class="col-md-4 text-left">
        </colgroup>
        <tr class="odd">
            <td>
                <fmt:message key="jsp.mydspace.preview-task.show.DOI"/>
            </td>
            <td>
                <%= doi %>
            </td>
        </tr>
    </table>
    <br/>
<% } %>
    
    <dspace:item item="<%= item %>" />

    <form action="<%= request.getContextPath() %>/mydspace" method="post">
        <input type="hidden" name="workflow_id" value="<%= workflowItem.getID() %>"/>
        <input type="hidden" name="step" value="<%= MyDSpaceServlet.PREVIEW_TASK_PAGE %>"/>
	<input class="btn btn-default col-md-2" type="submit" name="submit_cancel" value="<fmt:message key="jsp.mydspace.general.cancel"/>" />
<%
        // the duplicate detection may link to the preview task page even if the task is claimed by another commiter
        // show the "accept task"-button only if the item was not claimed yet.
        if (!claimed)
        {
%>       
            <input class="btn btn-primary col-md-2 pull-right" type="submit" name="submit_start" value="<fmt:message key="jsp.mydspace.preview-task.accept.button"/>" />
<%
        }
%>
    </form>
</dspace:layout>
