<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>

<%--
  - Display hierarchical list of communities and collections
  -
  - Attributes to be passed in:
  -    communities         - array of communities
  -    collections.map  - Map where a keys is a community IDs (Integers) and
  -                      the value is the array of collections in that community
  -    subcommunities.map  - Map where a keys is a community IDs (Integers) and
  -                      the value is the array of subcommunities in that community
  -    admin_button - Boolean, show admin 'Create Top-Level Community' button
  --%>

<%@page import="java.util.List"%>
<%@page import="org.dspace.content.service.CollectionService"%>
<%@page import="org.dspace.content.factory.ContentServiceFactory"%>
<%@page import="org.dspace.content.service.CommunityService"%>
<%@page import="org.dspace.content.Bitstream"%>
<%@page import="org.apache.commons.lang.StringUtils"%>
<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ page import="org.dspace.app.webui.servlet.admin.EditCommunitiesServlet" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.browse.ItemCountException" %>
<%@ page import="org.dspace.browse.ItemCounter" %>
<%@ page import="org.dspace.content.Collection" %>
<%@ page import="org.dspace.content.Community" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.Map" %>

<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.google.gson.*" %>
<%@ page import="com.google.gson.GsonBuilder" %>
<%@ page import="com.google.gson.JsonElement" %>
<%@ page import="com.google.gson.JsonObject" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%
    List<Community> communities = (List<Community>) request.getAttribute("communities");
    Map collectionMap = (Map) request.getAttribute("collections.map");
    Map subcommunityMap = (Map) request.getAttribute("subcommunities.map");
    Boolean admin_b = (Boolean)request.getAttribute("admin_button");
    boolean admin_button = (admin_b == null ? false : admin_b.booleanValue());
    ItemCounter ic = new ItemCounter(UIUtil.obtainContext(request));
%>

<%!

    JsonArray makeCommunitiesToJsonArray(HttpServletRequest request,List<Community> communities, Map collectionMap, Map subcommunityMap, ItemCounter ic)
    throws ItemCountException
    {
        JsonArray jsonCommunitiesArray = new JsonArray();
        for(int i=0; i< communities.size(); i++)
        {
            JsonObject communityJson = new JsonObject();
            JsonObject jsonCommunityUrl = new JsonObject();
            communityJson.addProperty("text", communities.get(i).getName());
            if(ConfigurationManager.getBooleanProperty("webui.strengths.show"))
            {
                communityJson.addProperty("count", ic.getCount(communities.get(i)));
            } else {
                communityJson.addProperty("count", -1);
            }

            jsonCommunityUrl.addProperty("href", request.getContextPath() + "/handle/" + communities.get(i).getHandle());
            communityJson.add("a_attr", jsonCommunityUrl);

            communityJson.add("children", buildSubCommunitiesJsonArray(request,communities.get(i),collectionMap, subcommunityMap, ic));
            jsonCommunitiesArray.add(communityJson);
        }
        return jsonCommunitiesArray;
    }

    JsonArray buildSubCommunitiesJsonArray(HttpServletRequest request,Community c, Map collectionMap, Map subcommunityMap, ItemCounter ic)
    throws ItemCountException
    {
        List<Community> communities = (List<Community>) subcommunityMap.get(c.getID().toString());
        List<Collection> collections = (List<Collection>) collectionMap.get(c.getID().toString());
        JsonArray output = new JsonArray();

        if (communities != null && communities.size() > 0)
        {
            for(Community comm : communities)
            {
                JsonObject community = new JsonObject();
                JsonObject community_url = new JsonObject();

                /* Community Universitätsbibliothek */
                community_url.addProperty("href", request.getContextPath() + "/handle/" + comm.getHandle());
                String linkText = comm.getName();
                if(ConfigurationManager.getBooleanProperty("webui.strengths.show"))
                {
                    linkText += " (" + ic.getCount(comm) + ")";
                }
                community.addProperty("text", linkText);

                community.add("a_attr", community_url);
                /*commJson.addProperty("url", request.getContextPath() + "/handle/" + comm.getHandle());*/

                community.add("children",buildSubCommunitiesJsonArray(request, comm, collectionMap, subcommunityMap, ic));
                output.add(community);
            }
        }
        if (collections != null && collections.size() > 0)
        {
            for(Collection coll : collections)
            {
                JsonObject collection = new JsonObject();
                JsonObject collection_url = new JsonObject();

                collection_url.addProperty("href", request.getContextPath() + "/handle/" + coll.getHandle());

                String linkText = coll.getName();
                linkText = linkText.replaceAll("^[A-Za-z0-9äöüÄÖÜß,\\s\\-]+\\s{1}-\\s+", "").trim();

                if(ConfigurationManager.getBooleanProperty("webui.strengths.show"))
                {
                    linkText += " (" + ic.getCount(coll) + ")";
                }
                collection.addProperty("text", linkText);

                collection.add("a_attr", collection_url);
                output.add(collection);
            }
        }
        return output;//communityJson;
    }


    CommunityService comServ = ContentServiceFactory.getInstance().getCommunityService();
    CollectionService colServ = ContentServiceFactory.getInstance().getCollectionService();


%>

<dspace:layout titlekey="jsp.community-list.title">

    <script type='text/javascript' src='<%= request.getContextPath() %>/static/js/vendor/jstree3/jstree.js'></script>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/js/vendor/jstree3/themes/proton/style.css" type="text/css" />

<script>
$(document).ready(function() {
    var communityData = <% out.println(makeCommunitiesToJsonArray( request, communities,  collectionMap,  subcommunityMap, ic).toString()); %>;
    $('#communityTree').jstree({
        'core' : {
            'themes': {
                'name': 'proton',
                'responsive': true
            },
            'data' : communityData
        }
    }).bind("loaded.jstree", function (e, data) {
        /* Open nodes on load (until x'th level) */
        var depth = 3;
        data.instance.get_container().find('li').each(function(i) {
            if(data.instance.get_path($(this)).length<=depth){
                data.instance.open_node($(this));
            }
        });
    });

     // expand all
    $("#expandTree").click(function () {
        $("#communityTree").jstree("open_all");
    });

    // collapse all
    $("#collapseTree").click(function () {
        $("#communityTree").jstree("close_all");
        $("#communityTree").jstree("select_node", "#node_0", true);
    });

    $('#communityTree').bind("select_node.jstree", function(e, data) {
        //console.log( data.node.a_attr.href );
        if( data.node.a_attr.href == '#' ) {
            //$(this).find('a').css('cursor', 'default');
            $(this).find('a').css('cursor', 'default');
            e.preventDefault();
        } else {
            window.location.href = data.node.a_attr.href;
        }
    });

});
</script>

<% if (admin_button) { %>
    <dspace:sidebar>
        <div class="panel panel-warning">
            <div class="panel-heading">
                <fmt:message key="jsp.admintools"/>
                <span class="pull-right">
                    <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.site-admin\")%>">
                        <fmt:message key="jsp.adminhelp"/>
                    </dspace:popup>
                </span>
            </div>
            <div class="panel-body">
                <form method="post" action="<%=request.getContextPath()%>/dspace-admin/edit-communities">
                    <input type="hidden" name="action" value="<%=EditCommunitiesServlet.START_CREATE_COMMUNITY%>" />
                    <input class="btn btn-default" type="submit" name="submit" value="<fmt:message key="jsp.community-list.create.button"/>" />
                </form>
            </div>
        </div>
    </dspace:sidebar>
<% } %>

<div id="collection-list">

    <h1><fmt:message key="jsp.community-list.title"/></h1>
    <p><fmt:message key="jsp.community-list.text1"/></p>


    <button class="btn btn-default" id="expandTree">Expand</button>
    <button class="btn btn-default" id="collapseTree">Collapse</button>
    <br/><br/>
    <div id="communityTree"></div>

</div>

</dspace:layout>
