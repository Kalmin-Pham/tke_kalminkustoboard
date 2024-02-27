//Retrieve org Info
let cllorg =(['Retrieve org id']);
let que1 = (
union 
cluster("https://crmanacus.kusto.windows.net").database("CRMAnalytics").OrganizationDetails,
cluster("https://crmanaweu.kusto.windows.net").database("CRMAnalytics").OrganizationDetails
| where TIMESTAMP between (_startTime.._endTime)
| where OrgId == orgid or isempty(orgid)
| where BAPEnvironmentId == envid or isempty(envid)
| extend URL = case(
Geo=='NA', strcat('https://', DomainName, '.crm.dynamics.com'),
Geo=='LATAM', strcat('https://', DomainName, '.crm2.dynamics.com'),
Geo=='CAN', strcat('https://', DomainName, '.crm3.dynamics.com'),
Geo=='EMEA', strcat('https://', DomainName, '.crm4.dynamics.com'),
Geo=='APAC', strcat('https://', DomainName, '.crm5.dynamics.com'),
Geo=='OCE', strcat('https://', DomainName, '.crm6.dynamics.com'),
Geo=='JPN', strcat('https://', DomainName, '.crm7.dynamics.com'),
Geo=='IND', strcat('https://', DomainName, '.crm8.dynamics.com'),
Geo=='TIP', strcat('https://', DomainName,'.crm10.dynamics.com'),
Geo=='GBR', strcat('https://', DomainName, '.crm11.dynamics.com'),
Geo=='FRA', strcat('https://', DomainName, '.crm12.dynamics.com'),
Geo=='ZAF', strcat('https://', DomainName, '.crm14.dynamics.com'),
Geo=='GER', strcat('https://', DomainName, '.crm16.dynamics.com'),
Geo=='CHE', strcat('https://', DomainName, '.crm17.dynamics.com'),
Geo=='NOR', strcat('https://', DomainName, '.crm19.dynamics.com'),
Geo=='SGP', strcat('https://', DomainName, '.crm20.dynamics.com'),
Geo=='KOR', strcat('https://', DomainName, '.crm21.dynamics.com'),
Geo=='AUP', 'Deleted or Test cluster', 'Undefined'
)
| where DomainName == domainname or URL startswith domainname or URL startswith substring(domainname, 0, indexof(domainname, ".com") + 4) or isempty(domainname)
| extend Version = strcat(tostring(MajorVersion),'.',tostring(MinorVersion),'.',tostring(BuildNumber),'.',tostring(Revision))
| extend OrgType = case(Type == 0, "Production", Type == 4, "Production", Type == 5, "Sandbox", Type == 6, "Sandbox", Type == 10, "Support instance", Type == 12, "Default", Type == 13, "Developer", Type == 14, "Trial", Type == 15, "Teams", "NA"
)
| extend Status = case(OrgStatus == 1, "Enabled", OrgStatus == 0, "Disabled", OrgStatus == 2, "Pending", OrgStatus == 3, "Failed", "Maintenance")
| extend merge=1
| project IsMultiGeo, IsCDS,UserCount, SqlServerName,DatabaseName , Version, FnoUrl,BackupRetentionInDays, merge
| take 1
);
let que2 =  (
union
cluster("https://crmanacus.kusto.windows.net").database("CRMAnalytics").OrganizationProperties,
cluster("https://crmanaweu.kusto.windows.net").database("CRMAnalytics").OrganizationProperties
| where TIMESTAMP between (_startTime.._endTime)
| where OrganizationID  in (cllorg) or isempty(orgid)
| extend merge=1
| project AdminOnlyMode,merge
| take 1
);
que1
| join kind=inner que2 on merge
| project Details = strcat(
'**MultiGeo enabled**: ', iff(IsMultiGeo=='true','Yes','No'), 
'\n\n**CDS Org**: ', iff(IsCDS=='true','Yes','No'), 
'\n\n**Admin only mode**: ', case(AdminOnlyMode=='0','Off;    **Background jobs**: On', AdminOnlyMode=='1','On;    **Background jobs**: On', AdminOnlyMode=='2','Off;    **Background jobs**: Off','On;    **Background jobs**: Off'),
'\n\n**User Count**: ', UserCount,
'\n\n**SQL Server Name**: ', SqlServerName,
'\n\n**Database Name**: ', DatabaseName,
'\n\n**Version**: ',Version,
'\n\n**FnO Url**: ', FnoUrl,
'\n\n**Max autobackup duration**: ', BackupRetentionInDays, ' days')
