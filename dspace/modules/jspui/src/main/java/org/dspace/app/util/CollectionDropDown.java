/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.util;

import org.apache.commons.lang3.StringUtils;
import org.dspace.content.Collection;
import org.dspace.content.Community;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.CommunityService;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Context;
import org.dspace.services.ConfigurationService;
import org.dspace.services.factory.DSpaceServicesFactory;

import java.sql.SQLException;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;
import java.util.Objects;

/**
 * Utility class for lists of collections.
 */

public class CollectionDropDown {

	/** The configuration service. */
	private static final ConfigurationService configurationService
			= DSpaceServicesFactory.getInstance().getConfigurationService();

	/** The configuration service. */
	private static final CommunityService communityService
			= ContentServiceFactory.getInstance().getCommunityService();

    /**
     * Get full path starting from a top-level community via subcommunities down to a collection.
     * The full path will not be truncated.
     * 
     * @param col 
     *            Get full path for this collection
     * @return Full path to the collection
     * @throws SQLException if database error
     */
    public static String collectionPath(Context context, Collection col) throws SQLException
    {
        return CollectionDropDown.collectionPath(context, col, 0);
    }
    
    /**
     * Get full path starting from a top-level community via subcommunities down to a collection.
     * The full path will be truncated to the specified number of characters and prepended with an ellipsis.
     * If maxchars is not specified, the levels configuration will be used (local addition).
     *
     * @param collection
     *            Get full path for this collection
     * @param maxchars 
     *            Truncate the full path to maxchar characters. 0 means do not truncate.
     * @return Full path to the collection (truncated)
     * @throws SQLException if database error
     */
    public static String collectionPath(Context context, Collection collection, int maxchars) throws SQLException
    {

		String separator = configurationService.getProperty("webui.collection.display.fullpath.separator");
		if (StringUtils.isBlank(separator)) {
			 separator = " > ";
		}

		String path = collection.getName();

		if (configurationService.getBooleanProperty("webui.collection.display.fullpath")) {

            /*
             * Local addition: use configured level depth instead of char truncation (if no char truncation specified).
             */
			int levels = configurationService.getIntProperty("webui.collection.display.fullpath.levels",
                    Integer.MAX_VALUE);

			if (maxchars > 0) {
				levels = Integer.MAX_VALUE;
			}

			List<Community> collectionCommunities = communityService.getAllParents(context, collection);

			LinkedList<String> communityList = new LinkedList();

			if (collectionCommunities.size() > 0)
			{
				for (int i = 0; i < collectionCommunities.size() && i < levels; i++) {
					communityList.addFirst(collectionCommunities.get(i).getName());
				}
			}

			communityList.add(collection.getName());
			path = StringUtils.join(communityList, separator);

			if (maxchars > 0) {
				int len = path.length();
				if (len > maxchars)
				{
					path = path.substring(len - (maxchars - 1), len);
					path = "\u2026" + path; // prepend with an ellipsis (cut from left)
				}

			}
		}
		return path;

    }

	/**
	 * Annotates an array of collections with their respective full paths (@see #collectionPath() method in this class).
	 * @param collections An array of collections to annotate with their hierarchical paths.
	 *                       The array and all its entries must be non-null.
	 * @return A sorted array of collection path entries (essentially collection/path pairs).
	 * @throws SQLException In case there are problems annotating a collection with its path.
	 */
	public static CollectionPathEntry[] annotateWithPaths(Context context, List<Collection> collections)
            throws SQLException
	{
		CollectionPathEntry[] result = new CollectionPathEntry[collections.size()];
		for (int i = 0; i < collections.size(); i++)
		{
			Collection collection = collections.get(i);
			CollectionPathEntry entry = new CollectionPathEntry(collection, collectionPath(context, collection));
			result[i] = entry;
		}
		Arrays.sort(result);
		return result;
	}

	/**
	 * A helper class to hold (collection, full path) pairs. Instances of the helper class are sortable:
	 * two instances will be compared first on their full path and if those are equal,
	 * the comparison will fall back to comparing collection IDs.
	 */
	public static class CollectionPathEntry implements Comparable<CollectionPathEntry>
	{
		public Collection collection;
		public String path;

		public CollectionPathEntry(Collection collection, String path)
		{
			this.collection = collection;
			this.path = path;
		}

		@Override
		public int compareTo(CollectionPathEntry other)
		{
			if (!this.path.equals(other.path))
			{
				return this.path.compareTo(other.path);
			}
			return this.collection.getID().compareTo(other.collection.getID());
		}

		@Override
		public boolean equals(Object o)
		{
			return o != null && o instanceof CollectionPathEntry && this.compareTo((CollectionPathEntry) o) == 0;
		}

		@Override
		public int hashCode()
		{
			return Objects.hash(path, collection.getID());
		}
	}
}
