/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.text.filter;

import org.apache.commons.lang3.StringUtils;

/**
 *
 * @author Pascal-Nicolas Becker (p dot becker at tu hyphen berlin dot de)
 */
public class MoveYearsForward
implements TextFilter
{
    public static final int start = 1900;
    public static final int end  = 2100;

    @Override
    public String filter(String str) {
        String[] tokens = StringUtils.split(str);
        String prefix = "";
        String suffix = "";
        for (int i = tokens.length -1 ; i >= 0; i--) {
            Integer number = null;
            try
            {
                number = Integer.valueOf(tokens[i]);
            } catch (NumberFormatException ex) {
                // token is not a number
                if (suffix.length() > 0) tokens[i] += " ";
                suffix = tokens[i] + suffix;
                continue;
            }
            if (start <= number && number <= end)
            {
                // we regard the number to be a year and move it forward.
                if (prefix.length() > 0) tokens[i] += " ";
                prefix = tokens[i] + prefix;
            } else {
                // we do not modify the place of the number
                if (suffix.length() > 0) tokens[i] += " ";
                suffix = tokens[i] + suffix;
            }
        }
        if (prefix.length() > 0 && suffix.length() > 0)
        {
            return prefix + " " + suffix;
        }
        return prefix + suffix;
    }

    @Override
    public String filter(String str, String lang) {
        return this.filter(str);
    }
    
}
