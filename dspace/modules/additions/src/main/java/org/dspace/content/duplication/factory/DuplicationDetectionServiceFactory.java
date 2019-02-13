/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.content.duplication.factory;

import org.dspace.content.duplication.service.DuplicationDetectionService;
import org.dspace.services.factory.DSpaceServicesFactory;

/**
 * Abstract factory to get the DuplicationDetectionService.
 *
 * @author Pascal-Nicolas Becker (pascal at the dash library dash code dot de)
 */
public abstract class DuplicationDetectionServiceFactory
{

    public abstract DuplicationDetectionService getDuplicationDetectionService();

    public static DuplicationDetectionServiceFactory getInstance()
    {
        return DSpaceServicesFactory.getInstance().getServiceManager().getServiceByName("duplicationDetectionServiceFactory", DuplicationDetectionServiceFactory.class);
    }
}
