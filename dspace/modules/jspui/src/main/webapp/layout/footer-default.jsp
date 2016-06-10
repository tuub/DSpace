<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Footer for home page
  --%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="java.net.URLEncoder" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.content.DCDate" %>

<%
String sidebar = (String) request.getAttribute("dspace.layout.sidebar");
int copyrightYear = DCDate.getCurrent().getYear();
%>

        <% if (sidebar != null) { %>
                </div>
                <div class="col-md-3">
                    <%= sidebar %>
                </div>
            </div>
        <% } %>
    </div>
</main>

<%-- Page footer --%>
<footer class="footer">
    <div class="container">
        <div class="text-center">
            <fmt:message key="jsp.layout.footer-default.text">
                <fmt:param><%= copyrightYear %></fmt:param>
            </fmt:message>
        </div>
        <div class="text-center">
            <fmt:message key="jsp.layout.footer-default.links" />
        </div>
    </div>
</footer>
</body>
</html>
