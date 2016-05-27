/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.text.filter;

import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.apache.commons.lang3.StringUtils;

/**
 * Pad numbers with leading zeros. DSpace creates sort strings and sorts these 
 * alphabetically. This Filter pads numbers with leading 0 so that all numbers
 * have a length of 8 digits. This will prevent that g.e. 2 and 20 are sorted
 * next to each other and before 3.
 * 
 * @author Pascal-Nicolas Becker (p dot becker at tu hyphen berlin dot de)
 */
public class PadNumbers implements TextFilter
{
    final static int paddinglength = 8;
    @Override
    public String filter(String str) {
        String[] tokens = StringUtils.split(str);
        String result = "";
        Pattern pattern = Pattern.compile("^([0-9]+).*");
        for (String token : tokens) {
            Matcher matcher = pattern.matcher(token);
            if (result.length() > 0)
            {
                result += " ";
            }
            if (!matcher.matches())
            {
                result += token;
                continue;
            }
            int length = paddinglength - matcher.group(1).length();
            for (int i=0; i < length; i++)
            {
                result += "0";
            }
            result += token;
        }
        return result;
    }

    @Override
    public String filter(String str, String lang) {
        return this.filter(str);
    }
    
}
