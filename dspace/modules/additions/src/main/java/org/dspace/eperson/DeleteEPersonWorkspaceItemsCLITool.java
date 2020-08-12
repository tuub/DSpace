package org.dspace.eperson;

import org.apache.commons.cli.*;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Item;
import org.dspace.content.MetadataSchema;
import org.dspace.content.MetadataValue;
import org.dspace.content.WorkspaceItem;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.ItemService;
import org.dspace.content.service.WorkspaceItemService;
import org.dspace.core.Context;
import org.dspace.eperson.factory.EPersonServiceFactory;
import org.dspace.eperson.service.EPersonService;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Commandline tool for deleting the workspaceItems of a specific EPerson.
 *
 * @author Marsa Haoua
 */
public class DeleteEPersonWorkspaceItemsCLITool
{

    private static final Option VERB_LIST = new Option("L", "list", false, "List WorkspaceItems of an existing EPerson\n\n");
    private static final Option VERB_DELETE_WORKSPACEITEMS = new Option("D", "deleteWorkspaceItems", false, "Delete WorkspaceItems of an existing EPerson\n\n");

    private static final Option OPT_EMAIL = new Option("m", "email", true, "The user's email address, empty for none");
    private static final Option OPT_NETID = new Option("n", "netid", true, "Network ID associated with the person, empty for none");

    private static final EPersonService ePersonService = EPersonServiceFactory.getInstance().getEPersonService();
    private static final ItemService itemService = ContentServiceFactory.getInstance().getItemService();
    private static final WorkspaceItemService workspaceItemService = ContentServiceFactory.getInstance().getWorkspaceItemService();

    private static final String HEADER = "Delete or list EPerson WorkspaceItems\n\n";
    private static final String CMD_LINE_SYNTAX = "delete-eperson-workspaceitems";

    public static void main(String[] args) throws ParseException
    {
        final OptionGroup VERBS = new OptionGroup();
        VERBS.addOption(VERB_LIST);
        VERBS.addOption(VERB_DELETE_WORKSPACEITEMS);

        final Options globalOptions = new Options();
        globalOptions.addOptionGroup(VERBS);
        globalOptions.addOption("h", "help", false, "Explain deleting WorkspaceItems of an existing EPerson options");

        DefaultParser parser = new DefaultParser();
        CommandLine command = parser.parse(globalOptions, args, true);

        Context context = new Context();

        // Disable authorization since this only runs from the local commandline.
        context.turnOffAuthorisationSystem();

        if (command.hasOption(VERB_LIST.getOpt()))
        {
            cmdListEPersonWorkspaceItems(context, args);
        }
        else if (command.hasOption(VERB_DELETE_WORKSPACEITEMS.getOpt())){
            cmdDeleteWorkspaceItems(context, args);
        }
        else if (command.hasOption('h'))
        {
            HelpFormatter formatter = new HelpFormatter();
            formatter.printHelp(CMD_LINE_SYNTAX, HEADER, globalOptions, "\n", true);
        }
        else
        {
            System.err.println("Unknown operation.\n");
            HelpFormatter formatter = new HelpFormatter();
            formatter.printHelp(CMD_LINE_SYNTAX, HEADER, globalOptions, "\n", true);
            context.abort();
            System.exit(1);
        }

        if (context.isValid())
        {
            try
            {
                context.complete();
            }
            catch (SQLException ex)
            {
                System.err.println(ex.getMessage());
            }
        }
    }

    /** Command to list WorkspaceItems of an existing EPerson. */
    private static void cmdListEPersonWorkspaceItems(Context context, String[] args)
    {
        EPerson eperson = getEPersonFromGivenArguments(context, args, VERB_LIST);
        if (null == eperson)
        {
            System.err.println("No such EPerson");
            System.exit(1);
        }

        // List all unfinished/rejected WorkspaceItems of the retrieved EPerson
        try
        {
            List<WorkspaceItem> ePersonWorkspaceItems = workspaceItemService.findByEPerson(context, eperson);
            System.out.printf("The EPerson with the ID: %s\t email: %s/ netid: %s\t lastName: %s, firstName: %s has %d workspaceItems:\n\n",
                    eperson.getID().toString(),
                    eperson.getEmail(),
                    eperson.getNetid(),
                    eperson.getLastName(), eperson.getFirstName(), ePersonWorkspaceItems.size());

            for (WorkspaceItem workspaceItem: ePersonWorkspaceItems)
            {
                Item item = workspaceItem.getItem();
                String type = item.getItemService()
                    .getMetadataFirstValue(item, MetadataSchema.DC_SCHEMA, "type", null, Item.ANY);
                String title = item.getName();
                String submitter = item.getSubmitter().getEmail();
                String collection = workspaceItem.getCollection().getName();

                System.out.printf("- WorkspaceItem with the type: %s\t title: %s\t submitter: %s\t from the collection: %s\t %s",  type, title, submitter, collection, "has been: ");

                List<MetadataValue> provenanceDescriptionMetadataValues = itemService.getMetadata(workspaceItem.getItem(), MetadataSchema.DC_SCHEMA, "description", "provenance", "en");
                List<String> rejectionReasons = new ArrayList<>();

                for(MetadataValue metadataValue: provenanceDescriptionMetadataValues)
                {
                    String provenanceDescription = metadataValue.getValue();
                    if(provenanceDescription.contains("Rejected by"))
                    {
                        rejectionReasons.add(metadataValue.getValue());
                    }
                }
                if(rejectionReasons.size() > 0)
                {
                    System.out.println("\n\t".concat(String.join("\n\t", rejectionReasons)));
                }
                else
                {
                    System.out.printf("not rejected\n", String.valueOf(workspaceItem.getID()));
                }
            }
        }
        catch (SQLException ex)
        {
            System.err.println(ex.getMessage());
        }
    }

    /** Command to delete WorkspaceItems of an existing EPerson. */
    private static void cmdDeleteWorkspaceItems(Context context, String[] args)
    {
        EPerson eperson = getEPersonFromGivenArguments(context, args, VERB_DELETE_WORKSPACEITEMS);
        if (null == eperson)
        {
            System.err.println("No such EPerson");
            System.exit(1);
        }

        try
        {
                // Delete all unfinished/rejected WorkspaceItems of the retrieved EPerson
                List<WorkspaceItem> ePersonWorkspaceItems = workspaceItemService.findByEPerson(context, eperson);
                for(WorkspaceItem workspaceItem: ePersonWorkspaceItems)
                {
                    try
                    {
                        context.turnOffAuthorisationSystem();
                        workspaceItemService.deleteAll(context, workspaceItem);
                    }
                    finally
                    {
                        context.restoreAuthSystemState();
                    }
                }
                context.complete();
                System.out.printf("Deleted %s workspaceItems of EPerson with the ID: %s\t email: %s/ netid: %s\t lastName: %s, firstName: %s.\n",
                    ePersonWorkspaceItems.size(), eperson.getID().toString(), eperson.getEmail(), eperson.getNetid(), eperson.getLastName(), eperson.getFirstName());
        }
        catch (SQLException ex)
        {
            System.err.println(ex.getMessage());
        }
        catch (AuthorizeException ex)
        {
            System.err.println(ex.getMessage());
        }
        catch (IOException ex)
        {
            System.err.println(ex.getMessage());
        }
    }

    /** Helper method to retrieve an existing EPerson based on the given arguments. */
    private static EPerson getEPersonFromGivenArguments(Context context, String[] args, Option option)
    {
        Options options = new Options();

        options.addOption(option);

        final OptionGroup identityOptions = new OptionGroup();
        identityOptions.addOption(OPT_EMAIL);
        identityOptions.addOption(OPT_NETID);

        options.addOptionGroup(identityOptions);

        options.addOption("h", "help", false, "explain ".concat(option.getDescription()).concat(" options"));

        DefaultParser parser = new DefaultParser();
        CommandLine command = null;
        try
        {
            command = parser.parse(options, args);
        }
        catch (ParseException e)
        {
            System.err.println(e.getMessage());
        }

        if (command.hasOption('h'))
        {
            HelpFormatter formatter = new HelpFormatter();
            formatter.printHelp(CMD_LINE_SYNTAX, option.getDescription(), options, "\n", true);
            System.exit(0);
        }

        // Find EPerson by netid or email
        EPerson eperson = null;
        try {
            if (command.hasOption(OPT_NETID.getOpt()))
            {
                eperson = ePersonService.findByNetid(context, command.getOptionValue(OPT_NETID.getOpt()));
            }
            else if (command.hasOption(OPT_EMAIL.getOpt()))
            {
                eperson = ePersonService.findByEmail(context, command.getOptionValue(OPT_EMAIL.getOpt()));
            }
            else
            {
                System.err.println("You must specify the EPerson's email address or netid.");
                HelpFormatter formatter = new HelpFormatter();
                formatter.printHelp(CMD_LINE_SYNTAX, option.getDescription(), options, "\n", true);
                System.exit(1);
            }
        }
        catch (SQLException e)
        {
            System.err.append(e.getMessage());
        }
        return eperson;
    }
}
