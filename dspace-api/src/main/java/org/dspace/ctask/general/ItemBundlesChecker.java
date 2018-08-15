/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.ctask.general;


import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.dspace.content.Bundle;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.curate.AbstractCurationTask;
import org.dspace.curate.Curator;
import org.dspace.curate.Suspendable;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;


/**
 * ItemBundlesChecker is a task that checks, if an item has other Bundle names
 * than those configured in the ${module_dir}/valid-bundle-names.cfg  or the local.cfg file.
 * within these files the valid bundle names are configured
 * through the property curate.bundles.valid.bundle.names
 * i.e. so: curate.bundles.valid.bundle.names = BRANDED_PREVIEW, DISPLAY, LICENSE
 * <p>
 * Each Item that has a Bundle name that is not listen in the above property,
 * or written in lower case or mistyped is reported (dspace.log) by this task,
 * by the CURATE_FAIL status, and an explanation report
 *
 * @author Marsa Haoua
 * @author Peter Lazarev: jan 2018, improved and adapted to dspace 6
 */

@Suspendable(invoked = Curator.Invoked.INTERACTIVE)
public class ItemBundlesChecker extends AbstractCurationTask
{

    protected Logger log = Logger.getLogger(ItemBundlesChecker.class);
    protected List<String> validBundleNames;

    @Override
    public void init(Curator curator, String taskId) throws IOException
    {
        super.init(curator, taskId);
        validBundleNames = Arrays.asList(StringUtils.stripAll(configurationService
                .getArrayProperty("curate.bundles.valid.bundle.names", new String[]{})));
    }

    @Override
    public int perform(DSpaceObject dso) throws IOException
    {
        int status = Curator.CURATE_SKIP; //curate_skip for all dso's which will not turn out to be an Item below

        if (dso instanceof Item)
        {
            try
            {
                status = Curator.CURATE_SUCCESS; //optimistic assumption. it is overridden below on invalid names or errors.
                String resultString = "";

                List<Bundle> bundles = ((Item) dso).getBundles();

                if (validBundleNames.size() == 0)
                    throw new Exception("can not run ItemBundlesChecker: no list of valid bundle names"
                            + " ('curate.bundles.valid.bundle.names' property) was given in the configuration"
                            + " (usually in the file valid.bundle.names.cfg or local.cfg).");

                for (Bundle bundle : bundles)
                {
                    if (!validBundleNames.contains(bundle.getName().trim()))
                    {
                        status = Curator.CURATE_FAIL;
                        resultString += (resultString == ""? "" : ", ") + "'" + bundle.getName().trim() + "'";
                    }
                }

                if (status == Curator.CURATE_FAIL)
                {
                    resultString =  "Item: " + dso.getHandle()
                            + " has Invalid bundle name(s):" + resultString
                            + ". But only the following can be used: " + validBundleNames ;

                    report(resultString);
                    setResult(resultString);
                }
            }
            catch (Exception ex)
            {
                log.error(ex);
                status = Curator.CURATE_ERROR;
            }
        }

        return status;
    }
}
