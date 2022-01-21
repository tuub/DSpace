import { WorkspaceitemSectionFormObject } from './workspaceitem-section-form.model';
import { WorkspaceitemSectionLicenseObject } from './workspaceitem-section-license.model';
import { WorkspaceitemSectionUploadObject } from './workspaceitem-section-upload.model';
import { WorkspaceitemSectionCcLicenseObject } from './workspaceitem-section-cc-license.model';
import {WorkspaceitemSectionIdentifiersObject} from './workspaceitem-section-identifiers.model';

/**
 * An interface to represent submission's section object.
 * A map of section keys to an ordered list of WorkspaceitemSectionDataType objects.
 */
export class WorkspaceitemSectionsObject {
  [name: string]: WorkspaceitemSectionDataType;
}

/**
 * Export a type alias of all sections
 */
export type WorkspaceitemSectionDataType
  = WorkspaceitemSectionUploadObject
  | WorkspaceitemSectionFormObject
  | WorkspaceitemSectionLicenseObject
  | WorkspaceitemSectionCcLicenseObject
  | WorkspaceitemSectionIdentifiersObject
  | string;
