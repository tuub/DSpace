/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.content.duplication.service;

import org.dspace.content.Item;
import org.dspace.content.MetadataField;
import org.dspace.core.Context;

import java.sql.SQLException;
import java.util.Iterator;
import java.util.List;

/**
 * Service to detect duplicate Items by a fuzzy search over their title.
 *
 * @author Pascal-Nicolas Becker (pascal at the dash library dash code dot de)
 */
public interface DuplicationDetectionService
{
    /**
     * Shortcut to call {@link #detectDuplicateReadableItems(Context, MetadataField, Item)} using the metadatafield
     * configured by {@code duplication.detection.field} in dspace.cfg.
     * @param context DSpace's context object
     * @param item The item for which we search for duplicates.
     * @return An empty list or a list of items the user is allowed to see that are possible duplicates of the item provided.
     * @throws SQLException If the database does funky things.
     */
    public List<Item> detectDuplicateReadableItems(Context context, Item item)
            throws SQLException;

    /**
     * Shortcut to call {@link #detectDuplicateReadableItems(Context, MetadataField, Item, int)} using the edit distance
     * configured by {@code duplication.detection.edit-distance} in dspace.cfg.
     * @param context DSpace's context object
     * @param field The metadata field we should compare
     * @param item The item for which we search for duplicates.
     * @return An empty list or a list of items the user is allowed to see that are possible duplicates of the item provided.
     * @throws SQLException If the database does funky things.
     */
    public List<Item> detectDuplicateReadableItems(Context context, MetadataField field, Item item)
            throws SQLException;

    /**
     * Find all items the user is granted read permission whose value in the specified metadata field is nearby the
     * value in the metadatafield of the item provided. This method uses
     * {@link #detectDuplicateItems(Context, MetadataField, String)} to detect possible duplicates and then filters all
     * workspace items, all workflow items the current user is not allowed to review and all items the user is not
     * allowed to read. If an item is withdrawn and the user is not Administrator of the collection the item belongs to
     * the item won't be part of the list.
     * For perfomance reasons by default only 10 possible duplicates will be added to the list. This value can be
     * configured by the property {@code duplication.detection.maximum-duplicates}. Set
     * {@code duplication.detection.maximum-duplicates} to a value below 1 to include all possible items in the list.
     * Have in mind that this may yield to timeouts and severe performance problems as all items will be loaded.
     * @param context DSpace's context object
     * @param field The metadata field we should compare
     * @param item The item for which we search for duplicates.
     * @param maxDistance The maximum edit distance used by the levenshtein algorithm while performing the search.
     * @return An empty list or a list of items the user is allowed to see that are possible duplicates of the item provided.
     * @throws SQLException If the database does funky things.
     */
    public List<Item> detectDuplicateReadableItems(Context context, MetadataField field, Item item, int maxDistance)
            throws SQLException;

    /**
     * Shortcut to call {@link #detectDuplicateItems(Context, MetadataField, String)} using the metadatafield
     * configured by {@code duplication.detection.field} in dspace.cfg.
     * @param context DSpace's context object
     * @param value The pattern to which the edit distance is calculated by the search.
     * @return An Item iterator that contains items whose metadata field value has an edit distance to the search
     *         pattern less or equal the provided maximum distance.
     * @throws SQLException If the database does funky things.
     */
    public Iterator<Item> detectDuplicateItems(Context context, String value)
            throws SQLException;

    /**
     * Shortcut to call {@link #detectDuplicateItems(Context, MetadataField, String, int)} using the edit distance
     * configured by {@code duplication.detection.edit-distance} in dspace.cfg.
     * @param context DSpace's context object
     * @param field The metadatafield used by the search.
     * @param value The pattern to which the edit distance is calculated by the search.
     * @return An Item iterator that contains items whose metadata field value has an edit distance to the search
     *         pattern less or equal the provided maximum distance.
     * @throws SQLException If the database does funky things.
     */
    public Iterator<Item> detectDuplicateItems(Context context, MetadataField field, String value)
            throws SQLException;

    /**
     * Find all items whose value in the specified metadata field is nearby the provided value.
     * This method does a fuzzy search using the levenshtein algorithm. The maximum edit distance can be provided by the
     * appropriate algorithm. The returned list may contain any kind of items even items the current user may not be
     * granted read access. See {@link #detectDuplicateReadableItems(Context, MetadataField, Item)} for a method
     * returning only items the user is able to see or review.
     * @param context DSpace's context object
     * @param field The metadata field used by the search.
     * @param value The pattern to which the edit distance is calculated by the search.
     * @param maxDistance The maximum edit distance used by the levenshtein algorithm while performing the search.
     * @return An Item iterator that contains items whose metadata field value has an edit distance to the search
     *         pattern less or equal the provided maximum distance.
     * @throws SQLException If the database does funky things.
     */
    public Iterator<Item> detectDuplicateItems(Context context, MetadataField field, String value, int maxDistance)
            throws SQLException;

    /**
     * Load the metadatafield the duplication service is configured to use.
     * @param context DSpace context object
     * @return The metadatafield used by this step or null if the configured metadatafield could not be found.
     * @throws SQLException If the database does funky things.
     */
    public MetadataField getMetadataField(Context context)
            throws SQLException;
}
