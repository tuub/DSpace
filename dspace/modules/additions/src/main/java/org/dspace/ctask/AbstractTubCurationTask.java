package org.dspace.ctask;

import org.dspace.content.DSpaceObject;
import org.dspace.curate.AbstractCurationTask;
import org.dspace.curate.Curator;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by pbroman on 24.04.17.
 */
public abstract class AbstractTubCurationTask extends AbstractCurationTask
{

    protected List<String> errors = new ArrayList<>();

    /**
     * Perform the curation task upon passed DSO.
     *
     * @param dso the DSpace object
     * @throws IOException if IO error
     */
    @Override
    public int perform(DSpaceObject dso) throws IOException
    {
        distribute(dso);
        if (errors.size() > 0)
        {
            StringBuilder errorBuilder = new StringBuilder();
            for (String error : errors)
            {
                report(error);
                errorBuilder.append(error);
                errorBuilder.append("\n");
            }
            setResult(errorBuilder.toString());
            return Curator.CURATE_ERROR;
        }
        return Curator.CURATE_SUCCESS;
    }

}
