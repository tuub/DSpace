/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */

package org.dspace.content.duplication.factory;

import org.dspace.content.duplication.service.DuplicationDetectionService;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * Factory implementation to get the DuplicationDetectionService.
 *
 * @author Pascal-Nicolas Becker (pascal at the dash library dash code dot de)

 */
public class DuplicationDetectionServiceFactoryImpl extends DuplicationDetectionServiceFactory
{
    @Autowired(required=true)
    private DuplicationDetectionService duplicationDetectionService;

    public DuplicationDetectionService getDuplicationDetectionService() { return duplicationDetectionService; }
}
