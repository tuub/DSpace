/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.text.filter;

import com.ibm.icu.lang.UCharacter;

/**
 * Replaces special chars with spaces. Every non character or digit is 
 * interpreted as special char. Detects unicode characters as German umlauts or
 * Cyrillic letters as characters.
 * 
 * @author Pascal-Nicolas Becker (p dot becker at tu hyphen berlin dot de)
 */
public class ReplaceSpecialCharsWithSpaces
implements TextFilter
{

    @Override
    public String filter(String str) {
        StringBuilder result = new StringBuilder();
        
        for (int i = 0; i < str.length() ; i++)
        {
            if (UCharacter.isLetterOrDigit(UCharacter.codePointAt(str, i)))
            {
                result.append(str.charAt(i));
            } else {
                result.append(" ");
            }
        }
        return result.toString();
    }

    @Override
    public String filter(String str, String lang) {
        return this.filter(str);
    }
    
}
