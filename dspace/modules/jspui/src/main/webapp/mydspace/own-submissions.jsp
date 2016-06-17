<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Show user's previous (accepted) submissions
  -
  - Attributes to pass in:
  -    user     - the e-person who's submissions these are (EPerson)
  -    items    - the submissions themselves (Item[])
  -    handles  - Corresponding Handles (String[])
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page  import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.content.Item" %>
<%@ page import="org.dspace.eperson.EPerson" %>
<%@ page import="java.util.List" %>
<%@ page import="org.dspace.core.Utils" %>

<%
    EPerson eperson = (EPerson) request.getAttribute("user");
    List<Item> items = (List<Item>) request.getAttribute("items");
%>

<dspace:layout style="submission" locbar="link"
               parentlink="/mydspace"
               parenttitlekey="jsp.mydspace"
               titlekey="jsp.mydspace">

    <a class="btn btn-default" href="<%= request.getContextPath() %>/mydspace"><fmt:message key="jsp.mydspace.general.backto-mydspace"/></a>
    <br/><br/>

    <div class="panel panel-default">
        <div class="panel-heading">
            <%-- Your Submissions --%>
            <fmt:message key="jsp.mydspace.own-submissions.title"/>: <fmt:message key="jsp.mydspace"/>
        </div>
        <div class="panel-body">
            <% if (items.size() == 0) { %>
                <p>
                    <fmt:message key="jsp.mydspace.own-submissions.text1"/>
                </p>
            <% } else { %>
                <p>
                    <fmt:message key="jsp.mydspace.own-submissions.text2"/>
                </p>
                <% if (items.size() == 1) { %>
                    <p>
                        <fmt:message key="jsp.mydspace.own-submissions.text3"/>
                    </p>
                <% } else { %>
                    <p>
                        <fmt:message key="jsp.mydspace.own-submissions.text4">
                            <fmt:param><%= items.size() %></fmt:param>
                        </fmt:message>
                    </p>
                <% } %>
                <dspace:itemlist items="<%= items %>" />
            <% } %>
        </div>
    </div>

</dspace:layout>
