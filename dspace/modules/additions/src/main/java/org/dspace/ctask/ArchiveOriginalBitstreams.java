/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.ctask;

import org.apache.commons.codec.digest.DigestUtils;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.time.DateUtils;
import org.dspace.authorize.AuthorizeException;
import org.dspace.authorize.ResourcePolicy;
import org.dspace.authorize.factory.AuthorizeServiceFactory;
import org.dspace.authorize.service.AuthorizeService;
import org.dspace.authorize.service.ResourcePolicyService;
import org.dspace.content.Bitstream;
import org.dspace.content.Bundle;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.BitstreamService;
import org.dspace.content.service.BundleService;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.curate.AbstractCurationTask;
import org.dspace.curate.Curator;
import org.dspace.curate.Distributive;
import org.apache.commons.collections.CollectionUtils;
import org.dspace.eperson.Group;
import org.dspace.eperson.factory.EPersonServiceFactory;
import org.dspace.eperson.service.GroupService;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.Charset;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;

/**
 * A curator task creating zip archives in BagIt format for items with more than one ORIGINAL bitstream.
 */
@Distributive
public class ArchiveOriginalBitstreams extends AbstractTubCurationTask
{

    private final static String ARCHIVE_BUNDLE_NAME = "ARCHIVE";
    private final static String BAGIT_ARCHIVE_NAME = "container";
    private final static String BAGIT_ARCHIVE_FILE_NAME = BAGIT_ARCHIVE_NAME + ".zip";
    private final static String BAGIT_BASE_DIR = BAGIT_ARCHIVE_NAME + "/";
    private final static String BAGIT_PAYLOAD_DIR = "data/";
    private final static String BAGIT_MANIFEST_FILE_NAME = "manifest-md5.txt";
    private final static String BAGIT_DECLARATION_FILE_NAME = "bagit.txt";
    private final static String BAGIT_DECLARATION_CONTENT = "BagIt-Version: 0.97\nTag-File-Character-Encoding: UTF-8";

    private final static List<String> PUBLICATION_TYPES
            = Arrays.asList("Book", "Conference Proceedings", "Doctoral Thesis", "Habilitation", "Master Thesis",
            "Other", "Periodical Part", "Preprint", "Report", "Research Paper", "Article", "Book Part",
            "Conference Object");

    private BitstreamService bitstreamService;
    private BundleService bundleService;
    private ResourcePolicyService resourcePolicyService;
    private AuthorizeService authorizeService;
    private GroupService groupService;
    private Group groupAnonymous;

    @Override
    public void init(Curator curator, String taskId) throws IOException
    {
        super.init(curator, taskId);
        bitstreamService = ContentServiceFactory.getInstance().getBitstreamService();
        bundleService = ContentServiceFactory.getInstance().getBundleService();
        resourcePolicyService = AuthorizeServiceFactory.getInstance().getResourcePolicyService();
        authorizeService = AuthorizeServiceFactory.getInstance().getAuthorizeService();
        groupService = EPersonServiceFactory.getInstance().getGroupService();
    }

    /**
     * Performs the archive curation task on an item. <br>
     * If there are at most one bitstream and no old archive, no action is performed.<br>
     * Otherwise, if there is an old archive, it is checked whether all checksums match. If they do not,
     * the old archive is removed.
     * @param item the DSpace Item
     * @throws SQLException
     * @throws IOException
     */
    @Override
    protected void performItem(Item item) throws SQLException, IOException
    {
        // Do not operate on Items, that are still in the submission workflow
        if (itemService.isInProgressSubmission(Curator.curationContext(), item))
        {
            return;
        }

        // Create archive only for publication types (no research data)
        String dcType = itemService.getMetadataFirstValue(item, "dc", "type", null, Item.ANY);

        List<Bitstream> originalBitstreams = getOriginalBitstreams(item);
        List<Bundle> archiveBundles = itemService.getBundles(item, ARCHIVE_BUNDLE_NAME);

        if (groupAnonymous == null)
        {
            groupAnonymous = groupService.findByName(Curator.curationContext(), Group.ANONYMOUS);
        }

        try {

            // If there is maximum one original bitstream, and no old archive, don't do anything.
            if (originalBitstreams.size() < 2 && CollectionUtils.isEmpty(archiveBundles))
            {
                report("Item " + item.getID() + " has maximum one bitstream, " +
                        "and there is no old archive, this item will not be procesed.");
                return;
            }

            if (CollectionUtils.isEmpty(archiveBundles))
            {
                // If no archive present and it is not a publication, don't do anything
                if (!PUBLICATION_TYPES.contains(dcType))
                {
                    return;
                }
                // No archive bundle but several bitstreams, create new archive
                Bundle archiveBundle = bundleService.create(Curator.curationContext(), item, ARCHIVE_BUNDLE_NAME);
                String createMessage = createArchiveBitstream(archiveBundle, originalBitstreams);
                itemService.updateLastModified(Curator.curationContext(), item);

                String message = "The item with handle " + item.getHandle() + " has " + originalBitstreams.size()
                        + " bitstreams, new zip archive created. ";
                if (createMessage != null)
                {
                    message += createMessage;
                }
                report(message);
                setResult(message);

            }
            else
            {
                // Old archive bundle present, check if the checksums match
                Bundle archiveBundle = archiveBundles.get(0);
                if (!archiveChecksumsMatch(originalBitstreams, archiveBundle))
                {
                    Bitstream archiveBitstream = bitstreamService.getBitstreamByName(
                            item, ARCHIVE_BUNDLE_NAME, BAGIT_ARCHIVE_FILE_NAME);
                    bundleService.removeBitstream(Curator.curationContext(), archiveBundle, archiveBitstream);

                    // Create a new archive only if there is more than one bitstream
                    if (originalBitstreams.size() > 1) {
                        String createMessage = createArchiveBitstream(archiveBundle, originalBitstreams);
                        itemService.updateLastModified(Curator.curationContext(), item);
                        String message = "Checksums don't match; zip archive replaced for item with handle " + item.getHandle();
                        if (createMessage != null)
                        {
                            message += "; " + createMessage;
                        }
                        report(message);
                        setResult(message);
                    }
                }
                else
                {
                    report("All checksums match for item with handle " + item.getHandle());
                }

                // Check if the embargo end date matches the max embargo end date of the bitstreams
                Date maxEmbargoEndDate = getMaxEmbargoEndDate(originalBitstreams);
                Date archiveEmbargoEndDate = getMaxEmbargoEndDate(archiveBundle.getBitstreams());

                if (maxEmbargoEndDate !=  null
                        && (archiveEmbargoEndDate == null
                            || !DateUtils.isSameDay(maxEmbargoEndDate, archiveEmbargoEndDate)))
                {
                    String message = "A bitstream has a later embargo end date as the archive, "
                            + "changing it in the archive to " + maxEmbargoEndDate;
                    report(message);
                    setResult(message);

                    Bitstream archiveBitstream = bitstreamService.getBitstreamByName(
                            item, ARCHIVE_BUNDLE_NAME, BAGIT_ARCHIVE_FILE_NAME);
                    List<ResourcePolicy> resourcePolicies = resourcePolicyService.find(
                            Curator.curationContext(),
                            archiveBitstream,
                            groupAnonymous,
                            Constants.READ);
                    for (ResourcePolicy resourcePolicy : resourcePolicies)
                    {
                        authorizeService.createOrModifyPolicy(
                                resourcePolicy,
                                Curator.curationContext(),
                                null,
                                groupAnonymous,
                                null,
                                maxEmbargoEndDate,
                                Constants.READ,
                                null,
                                archiveBitstream);
                    }
                }
                else
                {
                    report("Embargo end date matches for item with handle " + item.getHandle());
                }
            }

            if (archiveBundles.size() > 1)
            {
                report("There is more than one " + ARCHIVE_BUNDLE_NAME + " bundle present in item " + item.getID()
                        + ", this should never be the case!");
            }

        } catch (AuthorizeException e) {
            errors.add("Error creating or modifying embargo end date: " + e);
        }
    }

    /**
     * Creates a bitstream with a zip archive of all original bitstreams.
     * @param archiveBundle the archive bundle
     * @param originalBitstreams a list of original bitstreams.
     * @throws SQLException
     * @throws IOException
     * @throws AuthorizeException
     */
    private String createArchiveBitstream(Bundle archiveBundle, List<Bitstream> originalBitstreams)
            throws SQLException, IOException, AuthorizeException
    {
        String returnMessage = null;

        Context context = Curator.curationContext();
        File archiveFile = createBagitZipArchive(context, originalBitstreams);
        Bitstream archiveBitstream = bitstreamService.create(
                Curator.curationContext(),
                archiveBundle,
                new FileInputStream(archiveFile));

        archiveBitstream.setName(context, BAGIT_ARCHIVE_FILE_NAME);

        /*
         * Set the embargo end date for the archive to the last embargo end date of all the bitstreams.
         */
        Date maxEmbargoDate = getMaxEmbargoEndDate(originalBitstreams);

        if (maxEmbargoDate != null)
        {
            returnMessage = "Setting embargo for archive to " + maxEmbargoDate;
            report(returnMessage);
            authorizeService.createOrModifyPolicy(
                    null,
                    context,
                    null,
                    groupAnonymous,
                    null,
                    maxEmbargoDate,
                    Constants.READ,
                    null,
                    archiveBitstream);
        }
        return returnMessage;
    }

    /**
     * Gets the maximum embargo end date of all bitstreams in the list.
     * @param originalBitstreams
     * @return the max embargo end date or null if no embargo set.
     * @throws SQLException
     */
    private Date getMaxEmbargoEndDate(List<Bitstream> originalBitstreams)
            throws SQLException
    {
        Date maxEmbargoDate = null;
        for (Bitstream bitstream : originalBitstreams)
        {
            List<ResourcePolicy> resourcePolicies = resourcePolicyService.find(
                    Curator.curationContext(),
                    bitstream,
                    groupAnonymous,
                    Constants.READ);
            for (ResourcePolicy resourcePolicy : resourcePolicies)
            {
                if (resourcePolicy.getStartDate() != null)
                {
                    report(" - Bitstream embargo found: " + resourcePolicy.getStartDate());
                    if (maxEmbargoDate == null || maxEmbargoDate.before(resourcePolicy.getStartDate()))
                    {
                        maxEmbargoDate = resourcePolicy.getStartDate();
                    }
                }
            }
        }
        return maxEmbargoDate;
    }

    /**
     * Retrieves all ORIGINAL bitstream objects in an item.
     * @param item the item object
     * @return a list with the bitstreams-
     */
    private List<Bitstream> getOriginalBitstreams(Item item)
    {
        List<Bitstream> bitstreams = new ArrayList<>();

        for (Bundle bundle : item.getBundles())
        {
            if ("ORIGINAL".equals(bundle.getName()))
            {
                bitstreams.addAll(bundle.getBitstreams());
            }
        }
        return bitstreams;
    }

    /**
     * Checks if the checksums of the ORIGINAL bitstream are the same as those for the files in the archive BagIt zip.
     *
     * @param originalBitstreams the ORIGINAL bitstreams
     * @param archiveBundle the archive bundle
     * @return true, if all ORIGINAL bitstreams are present in the archive and all the checksums match.
     *
     * @throws SQLException
     * @throws IOException
     * @throws AuthorizeException
     */
    private boolean archiveChecksumsMatch(List<Bitstream> originalBitstreams, Bundle archiveBundle)
            throws SQLException, IOException, AuthorizeException
    {

        List<Bitstream> archiveBitstreams = archiveBundle.getBitstreams();

        // This shouldn't happen, but when it does, a new archive must be generated.
        if (CollectionUtils.isEmpty(archiveBitstreams))
        {
            return false;
        }
        InputStream archiveInputStream = bitstreamService.retrieve(Curator.curationContext(), archiveBitstreams.get(0));

        ZipInputStream zipInputStream = new ZipInputStream(archiveInputStream);
        String manifestContent = getManifestContent(zipInputStream, BAGIT_BASE_DIR + BAGIT_MANIFEST_FILE_NAME);
        Map<String, String> checksumMap = getChecksumMap(manifestContent);

        if (originalBitstreams.size() != checksumMap.size())
        {
            return false;
        }

        for (Bitstream bitstream : originalBitstreams)
        {
            if (!StringUtils.equals(checksumMap.get(BAGIT_PAYLOAD_DIR + getMd5FileName(bitstream.getName())), bitstream.getChecksum()))
            {
                return false;
            }
        }

        return true;
    }

    /**
     * Gets the contents of the manifest file of a BagIt zip-file.
     *
     * @param zipInputStream the input stream of the zip file
     * @param manifestFileName the name of the manifest file
     * @return a string with the manifest content
     * @throws IOException if the zip stream cannot de read
     */
    private String getManifestContent(ZipInputStream zipInputStream, String manifestFileName)
            throws IOException
    {
        String content = null;
        ZipEntry zipEntry;

        while ((zipEntry = zipInputStream.getNextEntry()) != null)
        {
            if (StringUtils.equals(manifestFileName, zipEntry.getName()))
            {
                content = IOUtils.toString(zipInputStream, Charset.forName("UTF-8"));
            }
        }
        return content;
    }

    /**
     * Creates a map with file names as keys and checksums as values from the content of a BagIt manifest file.
     * @param manifestContent the content of the manifest file as string.
     * @return a map with the result.
     */
    private Map<String, String> getChecksumMap(String manifestContent)
    {
        Map<String, String> checksumMap = new HashMap<>();
        if (manifestContent != null)
        {
            String[] rows = manifestContent.split("\\n");
            for (String row : rows)
            {
                String[] valueKey = row.split(" ", 2);
                if (valueKey.length == 2)
                {
                    checksumMap.put(valueKey[1], valueKey[0]);
                }
            }
        }
        return checksumMap;
    }


    /**
     * Creates a zip archive according to BagIt specifications.
     *
     * @param context the curator context
     * @param bitstreamList a list of bitstreams for the archive
     * @return the generated zip file
     * @throws SQLException
     * @throws IOException
     * @throws AuthorizeException
     */
    private File createBagitZipArchive(Context context, List<Bitstream> bitstreamList)
            throws SQLException, IOException, AuthorizeException
    {

        if (bitstreamList == null || bitstreamList.size() == 0)
        {
            return null;
        }

        String tempFileName = bitstreamList.get(0).getChecksum();
        File tempZipFile = File.createTempFile(tempFileName, ".zip");

        Set<String> fileNamesInZip = new HashSet();

        try {

            FileOutputStream fileOutputStream = new FileOutputStream(tempZipFile);
            ZipOutputStream zipOutputStream = new ZipOutputStream(fileOutputStream, Charset.forName("UTF-8"));

            StringBuffer checksums = new StringBuffer();

            for (Bitstream bitstream : bitstreamList)
            {
                String fileName = getMd5FileName(bitstream.getName());
                // You can't have several files with the same name in a zip
                if (fileNamesInZip.contains(fileName))
                {
                    continue;
                } else
                {
                    fileNamesInZip.add(fileName);
                }


                addZipEntry(zipOutputStream, fileName, bitstreamService.retrieve(context, bitstream));

                // For the BagIt checksum file
                checksums.append(bitstream.getChecksum());
                checksums.append(" ");
                checksums.append(BAGIT_PAYLOAD_DIR + fileName);
                checksums.append("\n");

            }

            //Write manifest file to zip
            ZipEntry zipEntry = new ZipEntry(BAGIT_BASE_DIR + BAGIT_MANIFEST_FILE_NAME);
            zipOutputStream.putNextEntry(zipEntry);
            zipOutputStream.write(checksums.toString().getBytes());

            //Write begit declation file to zip
            zipEntry = new ZipEntry(BAGIT_BASE_DIR + BAGIT_DECLARATION_FILE_NAME);
            zipOutputStream.putNextEntry(zipEntry);
            zipOutputStream.write(BAGIT_DECLARATION_CONTENT.getBytes());

            zipOutputStream.close();
            fileOutputStream.close();

        } catch (IOException e) {
            errors.add("Error creating zip archive: " + e);
            throw e;
        }

        return tempZipFile;
    }

    /**
     * Adds a zip entry to a zipOutputStream using an inputStream.
     *
     * @param zipOutputStream
     * @param fileName
     * @param inputStream
     * @throws IOException
     */
    void addZipEntry(ZipOutputStream zipOutputStream, String fileName, InputStream inputStream)
            throws IOException
    {
        ZipEntry zipEntry = new ZipEntry(BAGIT_BASE_DIR + BAGIT_PAYLOAD_DIR + fileName);
        zipOutputStream.putNextEntry(zipEntry);

        int length;
        byte[] buffer = new byte[2048];
        while ((length = inputStream.read(buffer, 0, buffer.length)) > 0)
        {
            zipOutputStream.write(buffer, 0, length);
        }
        zipOutputStream.closeEntry();
        inputStream.close();

    }

    /**
     * Creates a md5 string from the filename and appends the extension (if any).
     *
     * @param fileName the name of the file
     * @return a string with the me5 filename
     */
    String getMd5FileName(String fileName)
    {
        String extension = FilenameUtils.getExtension(fileName);
        if (StringUtils.isNotEmpty(extension))
        {
            extension = "." + extension;
        }
        return DigestUtils.md5Hex(fileName) + extension;
    }



}
