/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.text.filter;

import java.text.ParseException;
import org.apache.commons.lang3.StringUtils;

/**
 *
 * Parses a string for Roman numerals and converts them to Arabic ones.
 * 
 * @author Pascal-Nicolas Becker (p dot becker at tu hyphen berlin dot de)
 */
public class ConvertRomanNumerals 
implements TextFilter
{

    @Override
    public String filter(String str) {
        String[] tokens = StringUtils.split(str);
        String result = "";
        for (String token : tokens)
        {
            if (token.matches("^[iIvVxXlLcCdDmM]+$"))
            {
                try
                {
                    token = Integer.toString(detectRomanNumerals(token));
                } catch (ParseException ex) {
                    // nothing to do
                }
            }
            if (result.length() > 0)
            {
                result += " ";
            }
            result += token;
        }
        return result;
    }

    @Override
    public String filter(String str, String lang) {
        return this.filter(str);
    }
    
    public static int detectRomanNumerals(String number) throws ParseException
    {
        number = number.trim().toLowerCase();
        int lookbehind = 0;
        int result = 0;
        for (int i = number.length() -1; i >= 0; i--)
        {
            int token = convertRomanNumeral(number.charAt(i));
            if (token == -1)
            {
                throw new ParseException("Character " + number.charAt(i) 
                        + " is not allowed in roman numerals.", i);
            }
            if (lookbehind > token)
            {
                result -= token;
            } else {
                result += token;
            }
            lookbehind = token;
        }
        return result;
    }
    
    private static int convertRomanNumeral(char c)
    {
        switch (c)
        {
            case 'I' :
            case 'i' :
                return 1;
            case 'V' :
            case 'v' :
                return 5;
            case 'X' :
            case 'x' :
                return 10;
            case 'L' :
            case 'l' :
                return 50;
            case 'C' :
            case 'c' :
                return 100;
            case 'D' :
            case 'd' :
                return 500;
            case 'M' :
            case 'm' :
                return 1000;
            default :
                return -1;
        }
    }
    
}
