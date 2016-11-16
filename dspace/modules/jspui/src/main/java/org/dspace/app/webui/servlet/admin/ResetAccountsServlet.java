/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.dspace.app.webui.servlet.admin;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.commons.lang.RandomStringUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.dspace.app.util.Util;
import org.dspace.authorize.AuthorizeException;
import org.dspace.core.Context;
import org.dspace.app.webui.servlet.DSpaceServlet;
import org.dspace.content.WorkspaceItem;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.WorkspaceItemService;
import org.dspace.eperson.EPerson;
import org.dspace.eperson.factory.EPersonServiceFactory;
import org.dspace.eperson.service.EPersonService;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.content.Item;
import org.dspace.content.service.ItemService;
import org.dspace.eperson.Group;
import org.dspace.eperson.service.GroupService;
import org.dspace.services.ConfigurationService;
import org.dspace.services.factory.DSpaceServicesFactory;
import org.dspace.workflow.WorkflowItem;
import org.dspace.workflow.WorkflowItemService;
import org.dspace.workflow.factory.WorkflowServiceFactory;


 /**
 * This servlet reset an Account which is read from a configuration file. 
 * Some admin, which are configured in admins.cfg can reset some accounts via UI.
 * They just select an account in a dropdown list and reseted it. If the
 * selected account has some unfinished submissions, this will be shown to the
 * admin. In this case the admin can proceed or cancel the account reseting
 * process. 
 * Reseting account process:
 * 1 - delete all unfinished submissions 
 * 2 - set some user profile(read from coniguration file) to null 
 * 3 - generate and assign that account a new Password 
 * 4 - display the new password to the admin
 *
 * @author Marsa Haoua
 * @author Pascal-Nicolas Becker
 * 
 */
public class ResetAccountsServlet extends DSpaceServlet
{
    private final transient EPersonService personService
             = EPersonServiceFactory.getInstance().getEPersonService();
    private final transient GroupService groupService
             = EPersonServiceFactory.getInstance().getGroupService();
    private final transient WorkspaceItemService workspaceItemService
             = ContentServiceFactory.getInstance().getWorkspaceItemService();
    private final transient WorkflowItemService workflowItemService 
            = WorkflowServiceFactory.getInstance().getWorkflowItemService();
    private final transient ItemService itemService
            = ContentServiceFactory.getInstance().getItemService();
    private final transient ConfigurationService configurationService
             = DSpaceServicesFactory.getInstance().getConfigurationService();
    
    /* List of dummies accounts*/
    private static List<String> resetableAccounts = new ArrayList<String>();
    
    //Profile
    private static List<String> profile = new ArrayList<String>();
    
    /* List of admin accounts*/
    private static List<String> adminAccounts = new ArrayList<String>();
    
    /*Submissions account*/
    private static String submissionEmail = null;
    
    // defaults for profile
    private static String firstname = "firstname";
    private static String lastname = "lastname";
    private static String phone = "";
    
    /*Password length */
    private static final int PASSWORD_LENGTH = 8;
    
    /** Logger */
    private static Logger log = Logger.getLogger(ResetAccountsServlet.class);
    
    protected void doDSGet(Context context, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
        
        doDSPost(context, request, response);
    }

    protected void doDSPost(Context context, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {   
        try 
        {
            initElements(context);
        } 
        catch (UnsupportedEncodingException ex) 
        {
            log.error("Couldn't decode the values from configuration files: " + ex);
        }
        
        if(adminAccounts == null 
                || !adminAccounts.contains(context.getCurrentUser().getEmail()))
        {
            throw new AuthorizeException("You are not authorized to reset user accounts.");
        }

        String button = Util.getSubmitButton(request, "submit");
        // An email was selected
        if (button.equals("submit_reset")) 
        {
            //get the selected email
            String email = request.getParameter("email");
            
            if (StringUtils.isEmpty(email)) 
            {
                this.showAccountsPage(request, response, 
                        "Please select the account you wish to reset.");
                return;
            }
            if (!resetableAccounts.contains(email))
            {
                log.error("The selected account (" + email + ") is  not configured to be reseatble!");
                this.showAccountsPage(request, response, 
                        "The account you selected is not configured to be resetable. Please contact the administrator in case of any doubt.");
                return;
            }
            
            // check unfinished submission
            EPerson eperson = personService.findByEmail(context, email);
                
            if (eperson == null) 
            {
                log.error("Cannot reset account '" + email +"' as the EPerson does not exist.");
                this.showAccountsPage(request, response, 
                        "There is no account with the selected email address. Please contact the administrator.");
                return;
            }
            
            List<WorkspaceItem> unfinishedItems = workspaceItemService.findByEPerson(context,eperson);
            if (!unfinishedItems.isEmpty()) 
            {
                //warning     
                request.setAttribute("workspace.items", unfinishedItems);
                request.setAttribute("eperson", eperson);
                JSPManager.showJSP(request, response, "/tools/reset-accounts-unfinished-submissions.jsp");
                return;
            }
            //There are no unfinished items
            else 
            {
                try {
                    resetAccount(context, eperson, request, response);
                } catch (IllegalStateException ex) {
                    String message = ex.getMessage();
                    if (StringUtils.isNotBlank(message))
                    {
                        this.showAccountsPage(request, response, message);
                    } else {
                        this.showAccountsPage(request, response,
                                "An error occured, please contact the Administrator.");
                    }
                    return; // return after catching the exception, even if this code block is moved once.
                }
                return;
            }
        }
        else if (button.equals("submit_reset_continue")) 
        {
            // Despite unfinished submissions the account should be reseted
            String eperson_email = request.getParameter("eperson_email");
            EPerson eperson = personService.findByEmail(context, eperson_email);
            deleteUnfinishedSubmissions(context, eperson, request, response);
            
            try {
                resetAccount(context, eperson, request, response);
            } catch (IllegalStateException ex) {
                String message = ex.getMessage();
                if (!StringUtils.isNotBlank(message))
                {
                    this.showAccountsPage(request, response, message);
                } else {
                    this.showAccountsPage(request, response,
                            "An error occured, please contact the Administrator.");
                }
                return; // return after catching the exception, even if this code block is moved once.
            }
            
            return;
        }
        
        showAccountsPage(request, response, null);
    }
    
     /**
     * Reset an account wich have unfinished submissions
     *
     * @param context
     *            DSpace context
     * @param request
     *            the HTTP request containing posted info
     * @param response
     *            the HTTP response
     * 
     * @throws AuthorizeException
     * @throws IOException
     * @throws ResetAccountsServletException
     * @throws SQLException
     * @throws ServletException
     * 
     */
    private void deleteUnfinishedSubmissions(Context context, EPerson eperson, 
            HttpServletRequest request, HttpServletResponse response)
            throws IOException,
            SQLException, AuthorizeException, ServletException
    {
        //delete all unfinished submissions
        Iterator<WorkspaceItem> unfinishedItems = workspaceItemService.findByEPerson(context, eperson).iterator();
        while(unfinishedItems.hasNext())
        {
            try {
                context.turnOffAuthorisationSystem();
                workspaceItemService.deleteAll(context, unfinishedItems.next());
            } finally {
                context.restoreAuthSystemState();
            }
        }   
    }
    
    /**
     * Reset an account. 
     * It change the submitter of aöö item submitteb by this account,
     * set the profile to null at least 
     * set a new password and display it to the admin
     *
     * @param context
     *            DSpace context
     * @param request
     *            the HTTP request containing posted info
     * @param response
     *            the HTTP response
     * 
     * @throws AuthorizeException
     * @throws IOException
     * @throws ResetAccountsServletException
     * @throws SQLException
     * @throws ServletException
     * 
     */
    private void resetAccount(Context context, EPerson eperson,
            HttpServletRequest request, HttpServletResponse response) 
            throws SQLException, ServletException, AuthorizeException, 
                    IOException 
    {
        if (context.getCurrentUser() == null
                || context.getCurrentUser().getEmail() == null
                || !adminAccounts.contains(context.getCurrentUser().getEmail())
                || eperson == null
                || eperson.getEmail() == null
                || !resetableAccounts.contains(eperson.getEmail()))
        {
            throw new AuthorizeException("You're not allowed to reset accounts.");
        }
        
        changeSubmitter(context, eperson);

        //reset profile
        resetEPersonProfile(context, eperson);
        
        //generate new password
        String password = RandomStringUtils.random(PASSWORD_LENGTH, true, true);
        
        try
        {
            context.turnOffAuthorisationSystem();
            personService.setPassword(eperson, password);
            personService.update(context, eperson);
        } finally {
            context.restoreAuthSystemState();
        }
        
        context.complete();
        
        //display password
        request.setAttribute("newPassword", password);
        request.setAttribute("eperson-mail", eperson.getEmail());
        JSPManager.showJSP(request, response, "/tools/reset-accounts-success.jsp");
    }

     /**
     * All items which were submitted by a specific Eperson are overwrote
     * with a submitter read in a configuration file submissions-account.cfg.
     * 
     * @param context
     *            DSpace context
     * @param eperson
     *            the original items submitter EPerson  
     * 
     * @throws AuthorizeException
     * @throws SQLException
     * 
     */
    private void changeSubmitter(Context context, EPerson eperson) 
                        throws SQLException, AuthorizeException 
    {
        //Change the submitter of all accepted submissions of the selected EPerson
        Iterator<Item> submittedItems = itemService.findBySubmitter(context, eperson);
        List<WorkflowItem> workflowItems = workflowItemService.findBySubmitter(context, eperson);
        
        // we have checked that before, but as we switch off the authorization
        // system with the next command, check this again, to be sure
        // this method was not called with wron preconditions.
        if (context.getCurrentUser() == null
                || context.getCurrentUser().getEmail() == null
                || !adminAccounts.contains(context.getCurrentUser().getEmail())
                || eperson == null
                || eperson.getEmail() == null
                || !resetableAccounts.contains(eperson.getEmail()))
        {
            throw new AuthorizeException("You're not allowed to reset accounts.");
        }
        try
        {
            context.turnOffAuthorisationSystem();

            //Get the configured eperson submitter 
            EPerson newSubmitter = personService.findByEmail(context, submissionEmail);

            //Case there is no eperson for this email, we generate one
            if(newSubmitter == null)
            {
                log.error("The EPerson ("+ submissionEmail +")submissions should be assigned to "
                        + "during the reset of accounts, does not exist.");
                throw new IllegalStateException("The account submissions should be assigned to "
                        + "does not exist. Please contact the administrator.");
            }

            //Set new submitter
            while(submittedItems.hasNext())
            {
                Item item = submittedItems.next();
                item.setSubmitter(newSubmitter);
                itemService.update(context, item);
            }
            for (WorkflowItem wi : workflowItems)
            {
                Item item = wi.getItem();
                if (item != null)
                {
                    item.setSubmitter(newSubmitter);
                    itemService.update(context, item);
                }
            }
        } finally {
            context.restoreAuthSystemState();
        }
    }
    
     /**
     * Some profile read in a configuration file user-profile.cfg of a specific Eperson are set to null
     * 
     * @param context
     *            DSpace context
     * @param eperson
     *            the EPerson  
     * 
     * @throws ResetAccountsServletException
     * @throws SQLException
     * 
     */
    private void resetEPersonProfile(Context context, EPerson eperson) 
                        throws AuthorizeException, SQLException
    {
        if (eperson == null)
        {
            throw new IllegalArgumentException("EPerson must not be null.");
        }
        
        eperson.setFirstName(context, firstname);
        eperson.setLastName(context, lastname);
        personService.setMetadataSingleValue(context, eperson, "eperson" , "phone", null, null, phone);

        // we have checked that before, but as we switch off the authorization
        // system with the next command, check this again, to be sure
        // this method was not called with wrong preconditions.
        if (context.getCurrentUser() == null
                || context.getCurrentUser().getEmail() == null
                || !adminAccounts.contains(context.getCurrentUser().getEmail())
                || eperson == null
                || eperson.getEmail() == null
                || !resetableAccounts.contains(eperson.getEmail()))
        {
            throw new AuthorizeException("You're not allowed to reset this account.");
        }
        try
        {
            context.turnOffAuthorisationSystem();
            personService.update(context, eperson);
        } finally {
            context.restoreAuthSystemState();
        }
    }
   
    /**
     * Initialize all needed configured information
     * 
     * @throws UnsupportedEncodingException 
     */
    private void initElements(Context context)
            throws UnsupportedEncodingException, SQLException
    {
        adminAccounts.clear();
        adminAccounts.addAll(Arrays.asList(configurationService.getArrayProperty("reset-accounts.admin.emails")));
        if (adminAccounts == null || adminAccounts.isEmpty())
        {
            log.warn("Unable to load users allowed to reset accounts.");
            adminAccounts = new ArrayList<String>();
        }

        List<EPerson> admins = groupService.allMembers(context, groupService.findByName(context, Group.ADMIN));
        if (admins != null)
        {
            for (EPerson admin : admins)
            {
                if (!StringUtils.isEmpty(admin.getEmail()))
                {
                    adminAccounts.add(admin.getEmail());
                }
            }
        }
        
        resetableAccounts.clear();
        resetableAccounts.addAll(Arrays.asList(configurationService.getArrayProperty("reset-accounts.dummy.accounts")));
        if (resetableAccounts.isEmpty())
        {
            log.warn("Unable to load resetable accounts.");
        }
        
        submissionEmail = configurationService.getProperty("reset-accounts.submission.account").trim();
        if (StringUtils.isEmpty(submissionEmail))
        {
            log.warn("The account sumissions should be assinged to if an account is reseted is not configured.");
        }
        
        firstname = configurationService.getProperty("reset-accounts.profile.firstname").trim();
        if (firstname == null)
        {
            firstname = "firstname";
        }
        lastname = configurationService.getProperty("reset-accounts.profile.lastname").trim();
        if (lastname == null)
        {
            lastname = "lastname";
        }
        phone = configurationService.getProperty("reset-accounts.profile.phone").trim();
        if (phone == null)
        {
            phone = "";
        }
    }
    
    /**
     * Display the reset account page
     * 
     * @param request
     *            the HTTP request containing posted info
     * @param response
     *            the HTTP response
     * @param page
     *          the jsp file path
     * 
     * @throws ServletException
     * @throws IOException
     * @throws SQLException
     * @throws AuthorizeException 
     */
    private void showAccountsPage(HttpServletRequest request, HttpServletResponse response,
            String message) throws ServletException, IOException, 
                                SQLException, AuthorizeException
    {
        request.setAttribute("errormsg", message);
        request.setAttribute("accounts", resetableAccounts.toArray(new String[resetableAccounts.size()]));
        JSPManager.showJSP(request, response, "/tools/reset-accounts.jsp");
    }
}
