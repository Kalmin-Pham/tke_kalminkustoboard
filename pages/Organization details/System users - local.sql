let clltenantid = (
['Retrieve org id']
);
union 
cluster("https://crmanacus.kusto.windows.net").database("CRMAnalytics").OrgUserLicenseInfo,
cluster("https://crmanaweu.kusto.windows.net").database("CRMAnalytics").OrgUserLicenseInfo
| where OrganizationId in (clltenantid)
| summarize max(ModifiedOn) by SystemUserId, AccessMode=case(AccessMode == 0, 'Read-Write',AccessMode == 1, 'Administrative',AccessMode == 2, 'Read',AccessMode == 3, 'Support User',AccessMode == 4, 'Non-interactive', 'Delegated Admin'), AzureActiveDirectoryObjectId, IsActiveDirectoryUser, CreatedOn
| project SystemUserId, AccessMode=case(AccessMode == 0, 'Read-Write',AccessMode == 1, 'Administrative',AccessMode == 2, 'Read',AccessMode == 3, 'Support User',AccessMode == 4, 'Non-interactive', 'Delegated Admin'), AzureActiveDirectoryObjectId, IsActiveDirectoryUser, CreatedOn
