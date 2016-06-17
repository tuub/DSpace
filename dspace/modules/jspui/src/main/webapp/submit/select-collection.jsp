<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - UI page for selection of collection.
  -
  - Required attributes:
  -    collections - Array of collection objects to show in the drop-down.
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>

<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.app.webui.servlet.SubmissionController" %>
<%@ page import="org.dspace.submit.AbstractProcessingStep" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.content.Collection" %>
<%@ page import="java.util.List" %>

<!-- Added -->
<%@ page import="org.dspace.content.Community" %>
<%@ page import="java.util.ArrayList" %>

<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.TreeMap" %>
<%@ page import="java.util.UUID" %>

<%@ page import="org.dspace.content.Collection" %>
<%@ page import="org.dspace.app.util.CollectionDropDown" %>

<!-- Added -->

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%
    request.setAttribute("LanguageSwitch", "hide");

    //get collections to choose from
    List<Collection> collections =
        (List<Collection>) request.getAttribute("collections");

    //check if we need to display the "no collection selected" error
    Boolean noCollection = (Boolean) request.getAttribute("no.collection");

    // Obtain DSpace context
    Context context = UIUtil.obtainContext(request);

    /*
    public String getFullCommunityPath() throws SQLException
    {
        return getFullCommunityPath( ConfigurationManager.getProperty("webui.collection.display.fullpath.separator") );
    }

    public String getFullCommunityPath( String separator )
        throws SQLException
    {
        String path = getMetadata("name");

        if( ConfigurationManager.getBooleanProperty("webui.collection.display.fullpath") )
        {
            int startlevel = Integer.parseInt( ConfigurationManager.getProperty("webui.collection.display.fullpath.startlevel") );
            Community collectionCommunities[] = getCommunities();
            ArrayList<String> communityArrayList = new ArrayList();

            //ConfigurationManager.getBooleanProperty("webui.collection.display.fullpath.startlevel")


            //if( StringUtils.isBlank( separator ) ) {
            //    separator = ConfigurationManager.getProperty("webui.collection.display.fullpath.separator");
            //}

            for(int i=0; (i<=startlevel && i < collectionCommunities.length); i++)
            {
                communityArrayList.add( 0, collectionCommunities[i].getMetadata("name") );
            }


            //for( Community parentCommunity : getCommunities() )
            //{
            //    communityArrayList.add( 0, parentCommunity.getMetadata("name") );
            //}

            path = StringUtils.join( communityArrayList, separator );
            path = path.concat( separator ).concat( getMetadata("name") );
        }

        return path;
    }
    */

%>

<dspace:layout style="submission" locbar="off"
               titlekey="jsp.submit.select-collection.title"
               nocache="true">

    <h1>
        <fmt:message key="jsp.submit.select-collection.heading"/>
        <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.index\") + \"#choosecollection\"%>">
            <fmt:message key="jsp.morehelp"/>
        </dspace:popup>
    </h1>

    <% if (collections.size() > 0) { %>
        <p><fmt:message key="jsp.submit.select-collection.info1"/></p>

        <form action="<%= request.getContextPath() %>/submit" method="post" onkeydown="return disableEnterKey(event);">
            <!-- If no collection was selected, display an error -->
            <% if((noCollection != null) && (noCollection.booleanValue()==true)) { %>
                <div class="alert alert-warning"><fmt:message key="jsp.submit.select-collection.no-collection"/></div>
            <% } %>

            <div class="input-group">
                <label for="tcollection" class="input-group-addon">
                    <fmt:message key="jsp.submit.select-collection.collection"/>
                </label>
                <select class="form-control selectpicker" name="collection" id="tcollection" data-live-search="true">
                    <option value="-1" selected="true" disabled="disabled"><fmt:message key="jsp.submit.select-collection.choose"/></option>

                    <%
                    TreeMap<String,Integer> communityStringTreeMap = new TreeMap();

                    for (int i = 0; i < collections.size(); i++)
                    {
                        //communityStringTreeMap.put( collections.get(i).getFullCommunityPath(), collections.get(i).getID() );
                        //communityStringTreeMap.put( collections.get(i).getName(), collections.get(i).getID() );
                        /*
                        List<Community> parentCommunities = collections.get(i).getCommunities();
                        for (int k = 0; k < parentCommunities.size(); k++)
                        {
                            out.println(parentCommunities.get(k).getName());
                        }
                        */
                    }

                    for(Map.Entry<String,Integer> entry : communityStringTreeMap.entrySet()) {
                        String mykey = entry.getKey();
                        Integer myvalue = entry.getValue();
                    %>
                        <option value="<%= myvalue %>"><%= mykey %></option>
                    <%
                    }
                    %>
                </select>
            </div>
            <br/>

            <%-- Hidden fields needed for SubmissionController servlet to know which step is next--%>
            <%= SubmissionController.getSubmissionParameters(context, request) %>
            <div class="row">
                <div class="col-md-4 pull-right btn-group">
                    <input class="btn btn-default col-md-6" type="submit" name="<%=AbstractProcessingStep.CANCEL_BUTTON%>" value="<fmt:message key="jsp.submit.select-collection.cancel"/>" />
                    <input class="btn btn-primary col-md-6" type="submit" name="<%=AbstractProcessingStep.NEXT_BUTTON%>" value="<fmt:message key="jsp.submit.general.next"/>" />
                </div>
            </div>
        </form>
    <% } else { %>
        <p class="alert alert-warning"><fmt:message key="jsp.submit.select-collection.none-authorized"/></p>
    <% } %>
</dspace:layout>
