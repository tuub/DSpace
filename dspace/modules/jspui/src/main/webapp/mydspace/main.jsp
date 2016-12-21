<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Main My DSpace page
  -
  -
  - Attributes:
  -    mydspace.user:    current user (EPerson)
  -    workspace.items:  List<WorkspaceItem> array for this user
  -    workflow.items:   List<WorkflowItem> array of submissions from this user in
  -                      workflow system
  -    workflow.owned:   List<WorkflowItem> array of tasks owned
  -    workflow.pooled   List<WorkflowItem> array of pooled tasks
  --%>

<%@page import="org.apache.commons.lang3.StringUtils"%>
<%@page import="org.dspace.content.MetadataValue"%>
<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page  import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>

<%@ page import="org.dspace.app.webui.servlet.MyDSpaceServlet" %>
<%@ page import="org.dspace.content.WorkspaceItem" %>
<%@ page import="org.dspace.core.Utils" %>
<%@ page import="org.dspace.eperson.EPerson" %>
<%@ page import="org.dspace.eperson.Group"   %>
<%@ page import="org.dspace.content.Item"   %>
<%@ page import="org.dspace.content.MetadataSchema"   %>
<%@ page import="org.dspace.app.util.CollectionDropDown" %>
<%@ page import="org.dspace.workflowbasic.BasicWorkflowItem" %>
<%@ page import="java.util.List" %>
<%@ page import="org.dspace.app.itemimport.BatchUpload"%>
<%@ page import="org.dspace.workflowbasic.service.BasicWorkflowService" %>

<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.core.Context" %>


<%
    EPerson user = (EPerson) request.getAttribute("mydspace.user");

    List<WorkspaceItem> workspaceItems =
        (List<WorkspaceItem>) request.getAttribute("workspace.items");

    List<BasicWorkflowItem> workflowItems =
        (List<BasicWorkflowItem>) request.getAttribute("workflow.items");

    List<BasicWorkflowItem> owned =
        (List<BasicWorkflowItem>) request.getAttribute("workflow.owned");

    List<BasicWorkflowItem> pooled =
        (List<BasicWorkflowItem>) request.getAttribute("workflow.pooled");

    List<Group> groupMemberships =
        (List<Group>) request.getAttribute("group.memberships");

    List<WorkspaceItem> supervisedItems =
        (List<WorkspaceItem>) request.getAttribute("supervised.items");

    List<String> exportsAvailable = (List<String>)request.getAttribute("export.archives");

    List<BatchUpload> importsAvailable = (List<BatchUpload>)request.getAttribute("import.uploads");

    // Is the logged in user an admin
    Boolean displayMembership = (Boolean)request.getAttribute("display.groupmemberships");
    boolean displayGroupMembership = (displayMembership == null ? false : displayMembership.booleanValue());

    Context context = UIUtil.obtainContext(request);
%>

<dspace:layout style="submission" titlekey="jsp.mydspace" nocache="true">
    <div class="panel panel-default">
        <div class="panel-heading">
                    <fmt:message key="jsp.mydspace"/>: <%= Utils.addEntities(user.getFullName()) %>
                    <span class="pull-right"><dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.index\") + \"#mydspace\"%>"><fmt:message key="jsp.help"/></dspace:popup></span>
        </div>

        <div class="panel-body">
            <form action="<%= request.getContextPath() %>/mydspace" method="post">
                <input type="hidden" name="step" value="<%= MyDSpaceServlet.MAIN_PAGE %>" />
                <input class="btn btn-success" type="submit" name="submit_new" value="<fmt:message key="jsp.mydspace.main.start.button"/>" />
                <input class="btn btn-info" type="submit" name="submit_own" value="<fmt:message key="jsp.mydspace.main.view.button"/>" />
            </form>


            <%-- Task list:  Only display if the user has any tasks --%>
            <% if (owned.size() > 0) { %>
                <h3><fmt:message key="jsp.mydspace.main.heading2"/></h3>
                <p class="submitFormHelp">
                    <%-- Below are the current tasks that you have chosen to do. --%>
                    <fmt:message key="jsp.mydspace.main.text1"/>
                </p>
                <table class="table with-filter" align="center" summary="Table listing owned tasks">
                    <tr>
                        <th><fmt:message key="jsp.mydspace.main.task"/></th>
                        <th><fmt:message key="jsp.mydspace.main.type"/></th>
                        <th><fmt:message key="jsp.mydspace.main.item"/></th>
                        <th><fmt:message key="jsp.mydspace.main.subto"/></th>
                        <th><fmt:message key="jsp.mydspace.main.subby"/></th>
                        <th>&nbsp;</th>
                    </tr>
                    <% for (int i = 0; i < owned.size(); i++) { %>
                        <%
                        Item item = owned.get(i).getItem();
                        String title = item.getName();
                        if (StringUtils.isBlank(title)) {
                            title = LocaleSupport.getLocalizedMessage(pageContext,"jsp.general.untitled");
                        }
                        String type = item.getItemService()
                                .getMetadataFirstValue(item, MetadataSchema.DC_SCHEMA, "type", null, Item.ANY);
                        if (StringUtils.isBlank(type)) {
                            type = LocaleSupport.getLocalizedMessage(pageContext,"jsp.general.untyped");
                        }
                        EPerson submitter = item.getSubmitter();
                        %>
                        <tr>
                            <td>
                                <%
                                switch (owned.get(i).getState())
                                {
                                    //There was once some code...
                                    case BasicWorkflowService.WFSTATE_STEP1: %><fmt:message key="jsp.mydspace.main.sub1"/><% break;
                                    case BasicWorkflowService.WFSTATE_STEP2: %><fmt:message key="jsp.mydspace.main.sub2"/><% break;
                                    case BasicWorkflowService.WFSTATE_STEP3: %><fmt:message key="jsp.mydspace.main.sub3"/><% break;
                                }
                                %>
                            </td>
                            <td><%= Utils.addEntities(type) %></td>
                            <td><%= Utils.addEntities(title) %></td>
                            <td><%= CollectionDropDown.collectionPath(context, owned.get(i).getCollection()) %></td>
                            <td><a href="mailto:<%= submitter.getEmail() %>"><%= Utils.addEntities(submitter.getFullName()) %></a></td>
                            <td>
                                 <form action="<%= request.getContextPath() %>/mydspace" method="post">
                                    <input type="hidden" name="step" value="<%= MyDSpaceServlet.MAIN_PAGE %>" />
                                    <input type="hidden" name="workflow_id" value="<%= owned.get(i).getID() %>" />
                                    <input class="btn btn-primary" type="submit" name="submit_perform" value="<fmt:message key="jsp.mydspace.main.perform.button"/>" />
                                    <input class="btn btn-default" type="submit" name="submit_return" value="<fmt:message key="jsp.mydspace.main.return.button"/>" />
                                 </form>
                            </td>
                        </tr>
                    <% } %>
                </table>
            <% } %>

            <% if (pooled.size() > 0) { %>
                <h3><fmt:message key="jsp.mydspace.main.heading3"/></h3>
                <p class="submitFormHelp">
                    <%--Below are tasks in the task pool that have been assigned to you. --%>
                    <fmt:message key="jsp.mydspace.main.text2"/>
                </p>
                <table class="table with-filter" align="center" summary="Table listing the tasks in the pool">
                    <tr>
                        <th><fmt:message key="jsp.mydspace.main.task"/></th>
                        <th><fmt:message key="jsp.mydspace.main.type"/></th>
                        <th><fmt:message key="jsp.mydspace.main.item"/></th>
                        <th><fmt:message key="jsp.mydspace.main.subto"/></th>
                        <th><fmt:message key="jsp.mydspace.main.subby"/></th>
                        <th>&nbsp;</th>
                </tr>
                <% for (int i = 0; i < pooled.size(); i++) { %>
                    <%
                    Item item = pooled.get(i).getItem();
                    String title = item.getName();
                    String type = item.getItemService()
                        .getMetadataFirstValue(item, MetadataSchema.DC_SCHEMA, "type", null, Item.ANY);
                    if (StringUtils.isBlank(title)) {
                        title = LocaleSupport.getLocalizedMessage(pageContext,"jsp.general.untitled");
                    }
                    EPerson submitter = item.getSubmitter();
                    %>
                    <tr>
                        <td>
                            <%
                            switch (pooled.get(i).getState()) {
                                case BasicWorkflowService.WFSTATE_STEP1POOL: %><fmt:message key="jsp.mydspace.main.sub1"/><% break;
                                case BasicWorkflowService.WFSTATE_STEP2POOL: %><fmt:message key="jsp.mydspace.main.sub2"/><% break;
                                case BasicWorkflowService.WFSTATE_STEP3POOL: %><fmt:message key="jsp.mydspace.main.sub3"/><% break;
                            }
                            %>
                        </td>
                        <td><%= Utils.addEntities(type) %></td>
                        <td><%= Utils.addEntities(title) %></td>
                        <td><%= CollectionDropDown.collectionPath(context, pooled.get(i).getCollection()) %></td>
                        <td><a href="mailto:<%= submitter.getEmail() %>"><%= Utils.addEntities(submitter.getFullName()) %></a></td>
                        <td>
                            <form action="<%= request.getContextPath() %>/mydspace" method="post">
                                <input type="hidden" name="step" value="<%= MyDSpaceServlet.MAIN_PAGE %>" />
                                <input type="hidden" name="workflow_id" value="<%= pooled.get(i).getID() %>" />
                                <input class="btn btn-default" type="submit" name="submit_claim" value="<fmt:message key="jsp.mydspace.main.take.button"/>" />
                            </form>
                        </td>
                    </tr>
                <% } %>
            </table>
        <% } %>

        <% if (workspaceItems.size() > 0 || supervisedItems.size() > 0) { %>
            <h3><fmt:message key="jsp.mydspace.main.heading4"/></h3>
            <p><fmt:message key="jsp.mydspace.main.text4" /></p>
            <table class="table with-filter" align="center" summary="Table listing unfinished submissions">
                <tr>
                    <th>&nbsp;</th>
                    <th><fmt:message key="jsp.mydspace.main.type"/></th>
                    <th><fmt:message key="jsp.mydspace.main.title"/></th>
                    <th><fmt:message key="jsp.mydspace.main.subby"/></th>
                    <th><fmt:message key="jsp.mydspace.main.subto"/></th>
                    <th>&nbsp;</th>
                </tr>
                <% if (supervisedItems.size() > 0 && workspaceItems.size() > 0) { %>
                    <tr>
                        <th colspan="5">
                            <fmt:message key="jsp.mydspace.main.authoring" />
                        </th>
                    </tr>
                <% } %>
                <%  for (int i = 0; i < workspaceItems.size(); i++) { %>
                    <%
                    Item item = workspaceItems.get(i).getItem();
                    String title = item.getName();
                    String type = item.getItemService()
                            .getMetadataFirstValue(item, MetadataSchema.DC_SCHEMA, "type", null, Item.ANY);
                    if (StringUtils.isBlank(title)) {
                        title = LocaleSupport.getLocalizedMessage(pageContext,"jsp.general.untitled");
                    }
                    if (StringUtils.isBlank(type)) {
                        type = LocaleSupport.getLocalizedMessage(pageContext,"jsp.general.untyped");
                    }
                    EPerson submitter = item.getSubmitter();
                    %>
                    <tr>
                        <td>
                            <form action="<%= request.getContextPath() %>/workspace" method="post">
                                <input type="hidden" name="workspace_id" value="<%= workspaceItems.get(i).getID() %>"/>
                                <input class="btn btn-default" type="submit" name="submit_open" value="<fmt:message key="jsp.mydspace.general.open" />"/>
                            </form>
                        </td>
                        <td><%= Utils.addEntities(type) %></td>
                        <td><%= Utils.addEntities(title) %></td>
                        <td><a href="mailto:<%= submitter.getEmail() %>"><%= Utils.addEntities(submitter.getFullName()) %></a></td>
                        <td><%= CollectionDropDown.collectionPath(context, workspaceItems.get(i).getCollection()) %></td>
                        <td>
                            <form action="<%= request.getContextPath() %>/mydspace" method="post">
                                <input type="hidden" name="step" value="<%= MyDSpaceServlet.MAIN_PAGE %>"/>
                                <input type="hidden" name="workspace_id" value="<%= workspaceItems.get(i).getID() %>"/>
                                <input class="btn btn-danger" type="submit" name="submit_delete" value="<fmt:message key="jsp.mydspace.general.remove" />"/>
                            </form>
                        </td>
                    </tr>
                <% } %>

                <% if (supervisedItems.size() > 0) { %>
                    <tr>
                        <th colspan="5">
                            <fmt:message key="jsp.mydspace.main.supervising" />
                        </th>
                    </tr>
                <% } %>

                <% for (int i = 0; i < supervisedItems.size(); i++) { %>
                    <%
                    Item item = supervisedItems.get(i).getItem();
                    String title = item.getName();
                    if (StringUtils.isBlank(title)) {
                        title = LocaleSupport.getLocalizedMessage(pageContext,"jsp.general.untitled");
                    }
                    String type = item.getItemService()
                            .getMetadataFirstValue(item, MetadataSchema.DC_SCHEMA, "type", null, Item.ANY);
                    if (StringUtils.isBlank(type)) {
                        type = LocaleSupport.getLocalizedMessage(pageContext,"jsp.general.untyped");
                    }
                    EPerson submitter = supervisedItems.get(i).getItem().getSubmitter();
                    %>
                    <tr>
                        <td>
                            <form action="<%= request.getContextPath() %>/workspace" method="post">
                                <input type="hidden" name="workspace_id" value="<%= supervisedItems.get(i).getID() %>"/>
                                <input class="btn btn-default" type="submit" name="submit_open" value="<fmt:message key="jsp.mydspace.general.open" />"/>
                            </form>
                        </td>
                        <td>
                            <a href="mailto:<%= submitter.getEmail() %>"><%= Utils.addEntities(submitter.getFullName()) %></a>
                        </td>
                        <td><%= Utils.addEntities(type) %></td>
                        <td><%= Utils.addEntities(title) %></td>
                        <td><%= CollectionDropDown.collectionPath(context, supervisedItems.get(i).getCollection()) %></td>
                        <td>
                            <form action="<%= request.getContextPath() %>/mydspace" method="post">
                                <input type="hidden" name="step" value="<%= MyDSpaceServlet.MAIN_PAGE %>"/>
                                <input type="hidden" name="workspace_id" value="<%= supervisedItems.get(i).getID() %>"/>
                                <input class="btn btn-default" type="submit" name="submit_delete" value="<fmt:message key="jsp.mydspace.general.remove" />"/>
                            </form>
                        </td>
                    </tr>
                <% } %>
            </table>
        <% } %>

        <% if (workflowItems.size() > 0) { %>
            <h3><fmt:message key="jsp.mydspace.main.heading5"/></h3>
            <table class="table with-filter" align="center" summary="Table listing submissions in workflow process">
                <tr>
                    <th><fmt:message key="jsp.mydspace.main.type"/></th>
                    <th><fmt:message key="jsp.mydspace.main.title"/></th>
                    <th><fmt:message key="jsp.mydspace.main.subto"/></th>
                </tr>
                <% for (int i = 0; i < workflowItems.size(); i++) { %>
                    <%
                    Item item = workflowItems.get(i).getItem();
                    String title = item.getName();
                    if (StringUtils.isBlank(title)) {
                        title = LocaleSupport.getLocalizedMessage(pageContext,"jsp.general.untitled");
                    }
                    String type = item.getItemService()
                            .getMetadataFirstValue(item, MetadataSchema.DC_SCHEMA, "type", null, Item.ANY);
                    if (StringUtils.isBlank(type)) {
                        type = LocaleSupport.getLocalizedMessage(pageContext,"jsp.general.untyped");
                    }
                    %>
                    <tr>
                        <td><%= Utils.addEntities(type) %></td>
                        <td><%= Utils.addEntities(title) %></td>
                        <td>
                           <form action="<%= request.getContextPath() %>/mydspace" method="post">
                               <%= CollectionDropDown.collectionPath(context, workflowItems.get(i).getCollection()) %>
                               <input type="hidden" name="step" value="<%= MyDSpaceServlet.MAIN_PAGE %>" />
                               <input type="hidden" name="workflow_id" value="<%= workflowItems.get(i).getID() %>" />
                           </form>
                        </td>
                    </tr>
                <% } %>
            </table>
        <% } %>

        <% if(displayGroupMembership && groupMemberships.size()>0) { %>
            <h3><fmt:message key="jsp.mydspace.main.heading6"/></h3>
            <ul>
                <% for(int i=0; i<groupMemberships.size(); i++) { %>
                    <li><%=groupMemberships.get(i).getName()%></li>
                <% } %>
            </ul>
        <% } %>

        <% if(exportsAvailable!=null && exportsAvailable.size()>0) { %>
            <h3><fmt:message key="jsp.mydspace.main.heading7"/></h3>
            <ol class="exportArchives">
                <% for(String fileName:exportsAvailable) { %>
                    <li>
                        <a href="<%=request.getContextPath()+"/exportdownload/"+fileName%>" title="<fmt:message key="jsp.mydspace.main.export.archive.title"><fmt:param><%= fileName %></fmt:param></fmt:message>"><%=fileName%></a>
                    </li>
                <% } %>
            </ol>
        <% } %>

        <% if(importsAvailable!=null && importsAvailable.size()>0) { %>
            <h3><fmt:message key="jsp.mydspace.main.heading8"/></h3>
            <ul class="exportArchives" style="list-style-type: none;">
                <%
                int i=0;
                %>
                <% for(BatchUpload batchUpload : importsAvailable) { %>
                    <li style="padding-top:5px; margin-top:10px">
                        <div style="float:left">
                            <b><%= batchUpload.getDateFormatted() %></b>
                        </div>
                        <% if (batchUpload.isSuccessful()) { %>
                            <div style= "float:left">
                                &nbsp;&nbsp;-->
                                <span style="color:green"><fmt:message key="jsp.dspace-admin.batchimport.success"/></span>
                            </div>
                        <% } else { %>
                            <div style= "float:left;">
                                &nbsp;&nbsp;-->
                                <span style="color:red"><fmt:message key="jsp.dspace-admin.batchimport.failure"/></span>
                            </div>
                        <% } %>
                        <div style="float:left; padding-left:20px">
                            <a id="a2_<%= i%>" style="display:none; font-size:12px" href="javascript:showMoreClicked(<%= i%>);"><i>(<fmt:message key="jsp.dspace-admin.batchimport.hide"/>)</i></a>
                            <a id="a1_<%= i%>" style="font-size:12px" href="javascript:showMoreClicked(<%= i%>);"><i>(<fmt:message key="jsp.dspace-admin.batchimport.show"/>)</i></a>
                        </div>
                        <br/>
                        <div id="moreinfo_<%= i%>" style="clear:both; display:none; margin-top:15px; padding:10px; border:1px solid; border-radius:4px; border-color:#bbb">
                            <div>
                                <fmt:message key="jsp.dspace-admin.batchimport.itemstobeimported"/>: <b><%= batchUpload.getTotalItems() %></b>
                            </div>
                            <div style="float:left">
                                <fmt:message key="jsp.dspace-admin.batchimport.itemsimported"/>: <b><%= batchUpload.getItemsImported() %></b>
                            </div>
                            <div style="float:left; padding-left:20px">
                                <a id="a4_<%= i%>" style="display:none; font-size:12px" href="javascript:showItemsClicked(<%= i%>);"><i>(<fmt:message key="jsp.dspace-admin.batchimport.hideitems"/>)</i></a>
                                <a id="a3_<%= i%>" style="font-size:12px" href="javascript:showItemsClicked(<%= i%>);"><i>(<fmt:message key="jsp.dspace-admin.batchimport.showitems"/>)</i></a>
                            </div>
                            <br/>
                            <div id="iteminfo_<%= i%>" style="clear:both; display:none; border:1px solid; background-color:#eeeeee; margin:30px 20px">
                                <% for(String handle : batchUpload.getHandlesImported()) { %>
                                    <div style="padding-left:10px"><a href="<%= request.getContextPath() %>/handle/<%= handle %>"><%= handle %></a></div>
                                <% } %>
                            </div>
                            <div style="margin-top:10px">
                                <form action="<%= request.getContextPath() %>/mydspace" method="post">
                                    <input type="hidden" name="step" value="7">
                                    <input type="hidden" name="uploadid" value="<%= batchUpload.getDir().getName() %>">
                                    <input class="btn btn-info" type="submit" name="submit_mapfile" value="<fmt:message key="jsp.dspace-admin.batchimport.downloadmapfile"/>">
                                    <% if (!batchUpload.isSuccessful()){ %>
                                        <input class="btn btn-warning" type="submit" name="submit_resume" value="<fmt:message key="jsp.dspace-admin.batchimport.resume"/>">
                                    <% } %>
                                    <input class="btn btn-danger" type="submit" name="submit_delete" value="<fmt:message key="jsp.dspace-admin.batchimport.deleteitems"/>">
                                </form>
                            <div>
                            <% if (!batchUpload.getErrorMsgHTML().equals("")) { %>
                                <div style="margin-top:20px; padding-left:20px; background-color:#eee">
                                    <div style="padding-top:10px; font-weight:bold">
                                        <fmt:message key="jsp.dspace-admin.batchimport.errormsg"/>
                                    </div>
                                    <div style="padding-top:20px">
                                        <%= batchUpload.getErrorMsgHTML() %>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                        <br/>
                        <%
                        i++;
                        %>
                    <% } %>
                </li>
            </ul>
        <% } %>

        <script>
            function showMoreClicked(index){
                $('#moreinfo_'+index).toggle( "slow", function() {
                    // Animation complete.
                  });
                $('#a1_'+index).toggle();
                $('#a2_'+index).toggle();
            }

            function showItemsClicked(index){
                $('#iteminfo_'+index).toggle( "slow", function() {
                    // Animation complete.
                  });
                $('#a3_'+index).toggle();
                $('#a4_'+index).toggle();
            }
        </script>
    </div>
</div>
</dspace:layout>
