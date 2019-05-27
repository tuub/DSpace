<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Feedback form JSP
  -
  - Attributes:
  -    feedback.problem  - if present, report that all fields weren't filled out
  -    authenticated.email - email of authenticated user, if any
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%
    boolean problem = (request.getParameter("feedback.problem") != null);
    String email = request.getParameter("email");

    if (email == null || email.equals(""))
    {
        email = (String) request.getAttribute("authenticated.email");
    }

    if (email == null)
    {
        email = "";
    }

    String feedback = request.getParameter("feedback");
    if (feedback == null)
    {
        feedback = "";
    }

    String fromPage = request.getParameter("fromPage");
    if (fromPage == null)
    {
        fromPage = "";
    }
%>



<%
if (problem)
{
%>
    <p><strong><fmt:message key="jsp.feedback.form.text2"/></strong></p>
<%
}
%>

<script>
    $(document).on('click', '#close', function() {
        $('.tooltipster-base').hide();
    });
</script>

<form action="<%= request.getContextPath() %>/feedback" method="post" class="form-ajax-feedback form-horizontal">

    <div class="form-group">
        <!--<label class="col-md-5 control-label" for="temail"><fmt:message key="jsp.feedback.form.email"/></label>-->
        <div class="col-md-12">
            <input type="text" class="form-control" name="email" id="temail" size="30" placeholder="<fmt:message key="jsp.feedback.form.email"/>" value="<%=StringEscapeUtils.escapeHtml(email)%>" />
        </div>
    </div>
    <div class="form-group">
        <!--<label class="col-md-5 control-label" for="temail"><fmt:message key="jsp.feedback.form.comment"/></label>-->
        <div class="col-md-12">
            <textarea name="feedback" id="tfeedback" class="form-control" rows="6" cols="30" placeholder="<fmt:message key="jsp.feedback.form.comment"/>" ><%=StringEscapeUtils.escapeHtml(feedback)%></textarea>
        </div>
    </div>
    <div class="form-group">
        <div class="col-md-12">
            <input type="hidden" name="donotfeedme" value="" />
            <input type="submit" name="submit" class="btn btn-default" value="<fmt:message key="jsp.feedback.form.send"/>" />
            <input type="button" id="close" name="close" class="btn btn-link pull-right" value="<fmt:message key="jsp.feedback.form.close"/>" />
        </div>
    </div>

</form>
