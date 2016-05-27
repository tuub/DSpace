/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.text.filter;

/**
 * Removes leading and trailing whitespaces and merges consecutive multiple 
 * whitespaces to a single space.
 * 
 * @author Pascal-Nicolas Becker (p dot becker at tu hyphen berlin dot de)
 */
public class TrimAndMergeMultipleSpaces implements TextFilter
{

    @Override
    public String filter(String str) {
        return str.trim().replaceAll("\\s+", " ");
    }

    @Override
    public String filter(String str, String lang) {
        return this.filter(str);
    }
    
}
