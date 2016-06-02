/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.dspace.app.webui.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Iterator;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Item;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.ItemService;
import org.dspace.core.Context;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 *Servlet for handling requests within a Opus3 and opus4 items.
 * The ID is extracted from the URL, e.g: code>/opus/frontdoorphp? source_id=733/code>.
 * If there is an appropriate Handle to the opusID, 
 * the response is forwarded to the appropriate Handle site. The Handle page is shown.
 * 
 * @author Marsa Haoua
 */
public class OpusMigrationServlet extends DSpaceServlet 
{

    private static final String OPUS4_URI_PATTERN = "[/]frontdoor[/](index[/]){2}docId[/][1-9][0-9]*";
    private static final String OPUS3_URI_PATTERN = "[/]frontdoor\\.php";
    private final Logger log = LoggerFactory.getLogger(OpusMigrationServlet.class);

    //schema
    private static final String OPUS_SCHEMA = "tub";
    private static final String OPUS_ELEMENT = "identifier";
    private static final String OPUS3_QUALIFIER = "opus3";
    private static final String OPUS4_QUALIFIER = "opus4";
    private static final String SERVLET_PATH = "handle";
    
    private final transient ItemService itemService = ContentServiceFactory.getInstance().getItemService();

    @Override
    protected void doDSPost(Context context, HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException, AuthorizeException 
    {
        processRequest(context, request, response);
    }

    @Override
    protected void doDSGet(Context context, HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, SQLException, AuthorizeException 
    {
        processRequest(context, request, response);
    }

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param context DSpace context object
     * @param request HTTP servlet request
     * @param response HTTP servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(Context context, HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException 
    {
        String uri = request.getPathInfo();
        String contextPath = request.getContextPath();
        String scheme = request.getScheme();
        String serverName = request.getServerName();
        int serverPort = request.getServerPort();
        String opusItemID = null;
        String qualifier = null;
        String url = null;

        //We are dealing with opus4
        if (uri == null)
        {
            JSPManager.showInvalidIDError(request, response, opusItemID, -1);
            return;
        }
        else if (uri.matches(OPUS4_URI_PATTERN)) 
        {
            String splittedURI[] = uri.split("/");
            opusItemID = splittedURI[splittedURI.length - 1];
            qualifier = OPUS4_QUALIFIER;

        } //else with opus3
        else if(uri.matches(OPUS3_URI_PATTERN)) 
        {
            String query = request.getQueryString();
            String splittedQuery[] = query.split("=");
            opusItemID = splittedQuery[splittedQuery.length - 1];
            qualifier = OPUS3_QUALIFIER;
        }
        else 
        { 
            JSPManager.showInvalidIDError(request, response, opusItemID, -1);
            return;
        }
        if (null != opusItemID && null != qualifier) 
        {
            Iterator<Item> itemIterator = null;
            try 
            {
                itemIterator = itemService.findByMetadataField(context, OPUS_SCHEMA, OPUS_ELEMENT, qualifier, opusItemID);
               
                if(!itemIterator.hasNext())
                {
                    JSPManager.showInvalidIDError(request, response, opusItemID, -1);
                    return;
                }
                else
                {
                    Item opusItem = itemIterator.next();
                    if(itemIterator.hasNext())
                    {
                        throw new IllegalArgumentException("This opus item with the ID = " + opusItemID 
                                                    + " is refering to multiple DSpace items");
                    }
                    String handle = opusItem.getHandle();
                    url = scheme.concat("://").concat(serverName).concat(":")
                                .concat(String.valueOf(serverPort)).concat(contextPath)
                                .concat("/").concat(SERVLET_PATH).concat("/").concat(handle);
                     
                    response.setStatus(HttpServletResponse.SC_MOVED_PERMANENTLY);
                    response.setHeader("Location", url);
                    response.flushBuffer();
                }
            } 
            catch (SQLException ex) 
            {
                log.error(ex.getMessage());
            } 
            catch (AuthorizeException ex) 
            {
                log.error(ex.getMessage());
            }

        }
    }
    
}
