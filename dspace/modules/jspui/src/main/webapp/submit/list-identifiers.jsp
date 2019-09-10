<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  list identifiers minted by the MintIdentifierStep. Listing persistent identifiers enables submitters to add proposals
  on how to cite the submission.
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
           prefix="fmt" %>

<%@ page import="org.dspace.app.util.SubmissionInfo" %>
<%@ page import="org.dspace.app.webui.servlet.SubmissionController" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.services.factory.DSpaceServicesFactory" %>
<%@ page import="org.dspace.submit.AbstractProcessingStep" %>

<%@ page import="org.apache.commons.lang.StringUtils" %>

<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%
    request.setAttribute("LanguageSwitch", "hide");

    // Obtain DSpace context
    Context context = UIUtil.obtainContext(request);

    //get submission information object
    SubmissionInfo subInfo = SubmissionController.getSubmissionInfo(context, request);

    String errormessage = StringUtils.trim((String) request.getAttribute("errormessage"));
    String doi = StringUtils.trim((String) request.getAttribute("doi"));
    String handle = StringUtils.trim((String) request.getAttribute("handle"));
    List<String> otherIdentifiers = (List<String>) request.getAttribute("other_identifiers");

    String showIdentifiers = DSpaceServicesFactory.getInstance().getConfigurationService().getProperty("webui.submission.list-identifiers");
    
    if (StringUtils.isEmpty(showIdentifiers))
    {
        showIdentifiers = "all";
    }
    
    boolean showDOIs = false;
    boolean showHandles = false;
    boolean showOtherIdentifiers = false;
    
    if (StringUtils.containsIgnoreCase(showIdentifiers, "all"))
    {
        showDOIs = true;
        showHandles = true;
        showOtherIdentifiers = true;
    } 
    else 
    {
        if (StringUtils.containsIgnoreCase(showIdentifiers, "doi"))
        {
            showDOIs = true;
        }
        if (StringUtils.containsIgnoreCase(showIdentifiers, "handle"))
        {
            showHandles = true;
        }
        if (StringUtils.containsIgnoreCase(showIdentifiers, "other"))
        {
            showOtherIdentifiers = true;
        }
    }


    // store if we listed any identifiers
    boolean identifierListed = false;
%>

<dspace:layout style="submission"
               locbar="off"
               navbar="default"
               titlekey="jsp.submit.list-identifiers.title"
               nocache="true">

    <form action="<%= request.getContextPath() %>/submit" method="post" onkeydown="return disableEnterKey(event);">

        <jsp:include page="/submit/progressbar.jsp"/>

        <h1><fmt:message key="jsp.submit.list-identifiers.title" /></h1>
        <% if (!StringUtils.isEmpty(errormessage)) { %>
            <div class="alert alert-warning"><fmt:message key="<%= errormessage%>" /></div>
        <% } %>

        <br/>

        <table class="table table-striped table-bordered" style="margin: 0 auto; width: 50%;">
            <colgroup>
                <col class="col-md-2 text-left">
                <col class="col-md-8 text-left">
                <col class="col-md-2 text-left">
            </colgroup>
            <% if (showDOIs) { %>
                <tr class="odd">
                    <td>
                        <fmt:message key="jsp.submit.list-identifiers.doi"/>
                    </td>
                    <td>
                        <% if (StringUtils.isEmpty(doi)) {%>
                            <fmt:message key="jsp.submit.list-identifiers.no_doi_found"/>
                        <% } else { %>
                            <% identifierListed = true; %>
                            <%= doi %>
                        <% } %>
                    </td>
                    <td>
                        <button class="copy-button" onclick="return false;" data-clipboard-text="<%= doi %>"
                                title="Copy DOI to clipboard">Copy</button>
                    </td>
                </tr>
            <% } %>

            <% if (showHandles) { %>
                <tr>
                    <td>
                        <fmt:message key="jsp.submit.list-identifiers.handle"/>
                    </td>
                    <td>
                        <% if (StringUtils.isEmpty(handle)) {%>
                            <fmt:message key="jsp.submit.list-identifiers.no_handle_found"/>
                        <% } else { %>
                            <% identifierListed = true; %>
                            <%= handle %>
                        <% } %>
                    </td>
                    <td>
                        <button class="copy-button" onclick="return false;" data-clipboard-text="<%= handle %>"
                                title="Copy Handle to clipboard">Copy</button>
                    </td>
                </tr>
            <% } %>

            <%-- We show other identifiers if configured and available.
                 We do not show any warning if there are no other identifiers.
                 This enables us to show all identifiers by default. --%>
            <% if (showOtherIdentifiers && otherIdentifiers != null && !otherIdentifiers.isEmpty()) {%>
                <% identifierListed = true; %>
                <tr>
                    <td>
                        <fmt:message key="jsp.submit.list-identifiers.other_identifiers"/>
                    </td>
                    <td>
                        <%
                            Iterator<String> identifiers = otherIdentifiers.iterator();
                            while (identifiers.hasNext())
                            {
                                out.print(identifiers.next());
                                if (identifiers.hasNext())
                                {
                                    out.println("<br/>");
                                }
                            }
                        %>
                    </td>
                    <td>
                        &nbsp;
                    </td>
                </tr>
            <% } %>
        </table>

        <br/><br/>

        <div class="row">
            <% if (!identifierListed) { %>
                <div class="alert alert-danger"><fmt:message key="jsp.submit.list-identifiers.no_identifiers_found"/></div>
            <% } else { %>
                <div class="alert alert-info">
                    <strong><fmt:message key="jsp.submit.list-identifiers.info"/></strong>
                    <p><fmt:message key="jsp.submit.list-identifiers.info2"/></p>
                </div>
            <% } %>
        </div>

        <%-- Hidden fields needed for SubmissionController servlet to know which step is next--%>
        <%= SubmissionController.getSubmissionParameters(context, request) %>

        <br/>
        <div class="row">
            <div class="col-md-12">
                <div class="text-center">
                    <!-- If not first step, show "Previous" button -->
                    <% if(!SubmissionController.isFirstStep(request, subInfo)) { %>
                        <input class="btn btn-default col-md-4" type="submit" name="<%=AbstractProcessingStep.PREVIOUS_BUTTON%>" value="<fmt:message key="jsp.submit.general.previous"/>" />
                        <input class="btn btn-danger col-md-4" type="submit" name="<%=AbstractProcessingStep.CANCEL_BUTTON%>" value="<fmt:message key="jsp.submit.general.cancel-or-save.button"/>" />
                        <input class="btn btn-success col-md-4" type="submit" name="<%=AbstractProcessingStep.NEXT_BUTTON%>" value="<fmt:message key="jsp.submit.general.next"/>" />
                    <% } else { %>
                        <input class="btn btn-danger col-md-4" type="submit" name="<%=AbstractProcessingStep.CANCEL_BUTTON%>" value="<fmt:message key="jsp.submit.general.cancel-or-save.button"/>" />
                        <input class="btn btn-success col-md-4" type="submit" name="<%=AbstractProcessingStep.NEXT_BUTTON%>" value="<fmt:message key="jsp.submit.general.next"/>" />
                    <% } %>
                </div>
            </div>
        </div>
    </form>
</dspace:layout>