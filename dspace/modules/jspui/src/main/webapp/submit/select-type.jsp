<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%@page import="org.dspace.app.util.Util"%>
<%@page import="org.dspace.submit.step.PrivacyStatementsStep"%>
<%@page import="org.dspace.submit.AbstractProcessingStep"%>
<%@page import="org.dspace.content.MetadataValue"%>
<%@page import="java.util.Map" %>
<%@page import="java.util.List" %>
<%@page import="java.util.Iterator" %>
<%@page import="org.apache.commons.lang.StringUtils" %>

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

<%
String selected_type = "";
List<MetadataValue> types = (List<MetadataValue>) request.getAttribute("existing_type_selection");

if( types != null )
{
    if( types.size() == 1 )
    {
        for (MetadataValue type : types)
        {
            if (!StringUtils.isEmpty(type.getValue()))
            {
                selected_type = type.getValue();
            }
        }
    } else {
        selected_type = "";
    }
} else {
    selected_type = "";
}
%>

<script type="text/javascript">

    $(document).ready(function() {

        existing_type_selection = "<%= selected_type %>";

        /* Dynamic Sizing of Select Boxes */
        optionsizes = new Array();

        $('#type-selection select').each( function() {
            optionsizes.push( $(this).children().length );
        });
      
        optionsize = Math.max.apply(Math, optionsizes);
        if( optionsize > 10 ) optionsize = 10;

        $('#type-selection select').attr('size', optionsize);

        /* Allow only one choice over several select boxes */
        var last_valid_selection = null;

        if( existing_type_selection.length > 0 )
        {
            $('#type-selection select').val( existing_type_selection );
        }
        
        $('#type-selection select').on('change', function()
        {
            $('#type-selection select').not(this).val("");

            if( $('#type-selection select option:selected').length > 1 )
            {
                //console.log( $('#type-selection select option:selected').filter(":last").val() );
                last_valid_selection = $('#type-selection select option:selected').filter(":last").val();
                $(this).children().removeAttr("selected");
                $(this).val(last_valid_selection);
            }
            else
            {
                last_valid_selection = $(this).val();
            }
        });      
    });
    
</script>


<%
    request.setAttribute("LanguageSwitch", "hide");

    // Obtain DSpace context
    Context context = UIUtil.obtainContext(request);

	//get submission information object
    SubmissionInfo subInfo = SubmissionController.getSubmissionInfo(context, request);

    Map<String, List<String>> valuePairs = (Map<String, List<String>>) request.getAttribute("type_selection_pairs");
%>

<dspace:layout style="submission"
               locbar="off"
               navbar="off"
               titlekey="jsp.submit.progressbar.type-selection"
               nocache="true">

    <form id="type-selection" action="<%= request.getContextPath() %>/submit" method="post" onkeydown="return disableEnterKey(event);" class="form-horizontal">

        <jsp:include page="/submit/progressbar.jsp"/>

        <h1>
            <fmt:message key="jsp.submit.type-selection.title" />
        </h1>
	
        <p>
            <fmt:message key="jsp.submit.type-selection.info1"/>
        </p>
        
        <% if (request.getAttribute("no_type_selected") != null) { %>
            <div class="alert alert-warning">
                <fmt:message key="jsp.submit.type-selection.no_type_selected"/>
            </div>
        <% } %>
        <% if (request.getAttribute("invalid_type_count") != null) { %>
            <div class="alert alert-warning">
                <fmt:message key="jsp.submit.type-selection.invalid_type_count"/>
            </div>
        <% } %>        
        
        <div class="row">
            
            <%
            for (String name : valuePairs.keySet())
            {
            %>
                <div class="col-md-6">
                    <h2>          
                        <% 
                        // as we cannot use quotes inside the fmt:message tag, we have to prepare a string with the key prefix.
                        String msg_key_prefix = "jsp.submit.type-selection."; 
                        %>
                        <fmt:message key="<%= msg_key_prefix.concat(name) %>" />
                    </h2>

                    <select class="form-control" multiple="multiple" name="dc_type">
                        <%
                        Iterator<String> valuesIter = valuePairs.get(name).iterator();
                        while(valuesIter.hasNext())
                        {
                            // We have a list of value pairs.
                            // As we stored pairs the number of elements in the 
                            // list must be even. See DCInputsReader for further
                            // information.
                            String storage_value = valuesIter.next();
                            String display_value = valuesIter.next();
                            %>
                            <option value="<%=storage_value%>"><%=display_value%></option>
                            <%
                        }
                        %>
                    </select>
                </div>            
            <%
            }
            %>            
        </div>
        <%-- Hidden fields needed for SubmissionController servlet to know which step is next--%>
        <%= SubmissionController.getSubmissionParameters(context, request) %>
        <br/>        
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
