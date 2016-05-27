/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.sort;

import org.apache.log4j.Logger;
import org.dspace.text.filter.ConvertRomanNumerals;
import org.dspace.text.filter.DecomposeDiactritics;
import org.dspace.text.filter.LowerCaseAndTrim;
import org.dspace.text.filter.MoveYearsForward;
import org.dspace.text.filter.PadNumbers;
import org.dspace.text.filter.ReplaceSpecialCharsWithSpaces;
import org.dspace.text.filter.StandardInitialArticleWord;
import org.dspace.text.filter.TextFilter;
import org.dspace.text.filter.TrimAndMergeMultipleSpaces;

/**
 *
 * @author Pascal-Nicolas Becker (p dot becker at tu hyphen berlin dot de)
 */
public class OrderFormatSeriesNumberHeuristic 
implements OrderFormatDelegate
{
    	
    // Initialised in subclass in an object initializer
    protected TextFilter[] filters;
        
    {
        filters = new TextFilter[] {
            // new DecomposeDiactritics(),
            new ReplaceSpecialCharsWithSpaces(),
            new TrimAndMergeMultipleSpaces(),
            new MoveYearsForward(),
            new ConvertRomanNumerals(),
            new PadNumbers(),
            new LowerCaseAndTrim()
        };
    }
    
    private static final Logger log = Logger.getLogger(OrderFormatSeriesNumberHeuristic.class);


    /**
     * Prepare the appropriate sort string for the given value in the
     * given language.  Language should be supplied with the ISO-6390-1
     * or ISO-639-2 standards.  For example "en" or "eng".
     * 
     * @param	value	the string value
     * @param	language	the language to interpret in
     */
    public String makeSortString(String value, String language)
    {
        String origValue = value;
        if (filters == null)
        {
            // Log an error if the class is not configured correctly
            log.error("No filters defined for " + this.getClass().getName());
        }
        else
        {
            // Normalize language into a two or three character code
            if (language != null)
            {
                if (language.length() > 2 && language.charAt(2) == '_')
                {
                    language = language.substring(0, 2);
                }

                if (language.length() > 3)
                {
                    language = language.substring(0, 3);
                }
            }

            // Iterate through filters, applying each in turn
            for (int idx = 0; idx < filters.length; idx++)
            {
                String debug = filters[idx].getClass().getName() + ".filter(" + value + ")=";
                if (language != null)
                {
                    value = filters[idx].filter(value, language);
                }
                    else
                {
                    value = filters[idx].filter(value);
                }
                log.debug(debug + value);
            }
        }
        log.debug("will sort '" + origValue + "' as if it where '" + value + "'.");
        return value;
    }
}
