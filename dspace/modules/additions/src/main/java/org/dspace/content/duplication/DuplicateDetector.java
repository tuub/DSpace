/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.content.duplication;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.cli.PosixParser;
import org.apache.log4j.Logger;
import org.dspace.content.Item;
import org.dspace.content.MetadataField;
import org.dspace.content.WorkspaceItem;
import org.dspace.content.duplication.factory.DuplicationDetectionServiceFactory;
import org.dspace.content.duplication.service.DuplicationDetectionService;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.ItemService;
import org.dspace.content.service.MetadataFieldService;
import org.dspace.content.service.WorkspaceItemService;
import org.dspace.core.Context;
import org.dspace.utils.DSpace;
import org.dspace.workflow.WorkflowItem;
import org.dspace.workflowbasic.factory.BasicWorkflowServiceFactory;
import org.dspace.workflowbasic.service.BasicWorkflowItemService;
import org.springframework.util.StringUtils;

import java.sql.SQLException;
import java.util.Iterator;


/**
 * The DuplicateDetector is a simple command line tool, to find items using a fuzzy search on a given metadata field.
 *
 * @author Pascal-Nicolas Becker (pascal at the dash library dash code dot de)
 */
public class DuplicateDetector
{
    private static final Logger log = Logger.getLogger(DuplicateDetector.class);

    private final DuplicationDetectionService duplicationDetectionService;
    private final MetadataFieldService metadataFieldService;
    private final WorkspaceItemService workspaceItemService;
    private final BasicWorkflowItemService workflowItemService;
    private final ItemService itemService;

    public DuplicateDetector()
    {
        duplicationDetectionService = DuplicationDetectionServiceFactory.getInstance().getDuplicationDetectionService();
        metadataFieldService = ContentServiceFactory.getInstance().getMetadataFieldService();
        workflowItemService = BasicWorkflowServiceFactory.getInstance().getBasicWorkflowItemService();
        workspaceItemService = ContentServiceFactory.getInstance().getWorkspaceItemService();
        itemService = ContentServiceFactory.getInstance().getItemService();
    }

    /**
     * Initialize the Duplicate Detector and trigger parsing and running the command
     * @param args Command Line arguments
     */
    public static void main(String args[])
    {
        log.debug("Starting Duplicate Detector");

        DSpace dspace = new DSpace();

        // get a context
        Context context = new Context();
        context.setMode(Context.Mode.READ_ONLY);
        // turn off Auth
        context.turnOffAuthorisationSystem();

        DuplicateDetector detector = new DuplicateDetector();
        detector.runCLI(context, args, detector);

        context.restoreAuthSystemState();
        context.abort();
    }

    /**
     * Parse the command line and actually run the command
     *
     * @param args Command Line arguments
     * @param context DSpace context
     * @param detector Initialized Detector class
     */
    public void runCLI(Context context, String args[], DuplicateDetector detector)
    {
        // initialize options
        Options options = new Options();
        options.addOption(Option.builder("f")
                                .longOpt("field")
                                .hasArg(true)
                                .numberOfArgs(1)
                                .argName("metadata-field")
                                .desc("metadata field to compare, e.g. dc.creator.author")
                                .required(true)
                                .type(String.class)
                                .build());
        options.addOption(Option.builder("d")
                                .longOpt("maximum-distance")
                                .hasArg(true)
                                .numberOfArgs(1)
                                .argName("maximum edit distance")
                                .desc("maximum edit distance")
                                .required(false)
                                .type(Integer.class)
                                .build());
        options.addOption(Option.builder("s")
                                .longOpt("sample")
                                .argName("sample value")
                                .numberOfArgs(1)
                                .desc("the value your looking for duplicates")
                                .required(true)
                                .type(String.class)
                                .build());
        // initialize parser
        CommandLineParser parser = new PosixParser();
        CommandLine line = null;
        HelpFormatter helpformater = new HelpFormatter();
        //parse
        try
        {
            line = parser.parse(options, args);
        }
        catch (ParseException ex)
        {
            log.fatal(ex);
            System.exit(1);
        }

        String[] fieldname = StringUtils.split(line.getOptionValue("field"), ".");
        String sample = line.getOptionValue("sample");
        int maxDistance = Integer.parseInt(line.getOptionValue("maximum-distance", "3"));
        System.out.println("Looking for sample '" + sample + "'.");
        System.out.println("Maximum edit distance set to " + Integer.toString(maxDistance) + ".");

        if (fieldname.length < 2)
        {
            System.err.println("Fieldname must contain at least schema and element, speratated by a dot.");
            context.abort();
            System.exit(1);
        }
        if (fieldname.length > 3)
        {
            System.err.println("Fieldname must not contain more than schema, element and qualifier, separated by a dot.");
            context.abort();
            System.exit(1);
        }

        MetadataField metadataField = null;
        try
        {
            if (fieldname.length == 2)
            {
                metadataField = metadataFieldService.findByElement(context, fieldname[0], fieldname[1], null);
            }
            if (fieldname.length == 3)
            {
                metadataField = metadataFieldService.findByElement(context, fieldname[0], fieldname[1], fieldname[2]);
            }
        } catch (SQLException ex) {
            System.err.println("SQLException caught while looking for fields: " + ex.getMessage());
            log.fatal(ex);
            context.abort();
            System.exit(1);
        }
        System.out.println("Loooking for field " + metadataField.toString() + " (" + metadataField.getID() + ").");

        Iterator<Item> itemIter = null;
        try
        {
            itemIter = duplicationDetectionService.detectDuplicateItems(context, metadataField, sample, maxDistance);
        } catch (SQLException ex) {
            System.out.println("SQLException caught while looking for duplicates: " + ex.getMessage());
            log.fatal(ex);
            System.exit(1);
        }
        StringBuilder itemDescription = new StringBuilder();

        int i=0;
        for(; itemIter.hasNext(); i++)
        {
            Item item = itemIter.next();
            WorkflowItem wfi = null;
            WorkspaceItem wsi = null;
            try
            {
                wfi = workflowItemService.findByItem(context, item);
                wsi = workspaceItemService.findByItem(context, item);
            } catch (Exception ex) {
                System.err.println("Caught " + ex.getClass().getCanonicalName() + " while looking for work*Items: " + ex.getMessage());
            }

            String itemValue = itemService.getMetadata(item, line.getOptionValue("field"));
            if (wfi != null)
            {
                itemDescription.append("WorkflowItem ");
            } else if (wsi != null) {
                itemDescription.append("WorkspaceItem ");
            } else if (item.isWithdrawn()) {
                itemDescription.append("Withdrawn Item ");
            } else if (!item.isDiscoverable()) {
                itemDescription.append("Private Item ");
            } else {
                itemDescription.append("Strange Item ");
            }
            itemDescription.append(item.getID().toString());

            itemDescription.append(" : ");

            if (itemValue != null)
            {
                itemDescription.append(itemValue);
            } else {
                itemDescription.append("null");
            }
            itemDescription.append(".\n");
        }

        System.out.println("Fount " + Integer.toString(i) + " items:\n");
        System.out.println(itemDescription.toString());
    }

}
