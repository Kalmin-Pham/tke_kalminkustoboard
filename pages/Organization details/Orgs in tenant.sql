let clltenant = (
union 
cluster("https://crmanacus.kusto.windows.net").database("CRMAnalytics").OrganizationDetails,
cluster("https://crmanaweu.kusto.windows.net").database("CRMAnalytics").OrganizationDetails
| where TIMESTAMP between (_startTime.._endTime)
| where OrgId == orgid or isempty(orgid)
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
| where BAPEnvironmentId == envid or isempty(envid)
| project TenantId
| take 1
);
union 
cluster("https://crmanacus.kusto.windows.net").database("CRMAnalytics").OrganizationDetails,
cluster("https://crmanaweu.kusto.windows.net").database("CRMAnalytics").OrganizationDetails
| where TIMESTAMP between (_startTime.._endTime)
| where TenantId in (clltenant)
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
| summarize DisabledOn=max(DisabledOn), ExpiryDate=max(ExpiryDate) by Geo, DomainName, URL, OrgId, BAPEnvironmentId, UniqueName, SecurityGroupGUID, FriendlyName, Type, OrgStatus, IsMultiGeo, IsCDS, StateChangeReason
| project Geo, DomainName, URL, OrgId, OrgType = case(Type == 0, "Production", Type == 4, "Production", Type == 11, "Email Trial", Type == 5, "Sandbox", Type == 6, "Sandbox", Type == 10, "Support instance", Type == 12, "Default", Type == 13, "Developer", Type == 14, "Trial", Type == 15, "Teams", "NA"
), EnvironmentID = BAPEnvironmentId, UniqueName, SecurityGroupGUID, FriendlyName, Status = case(OrgStatus == 1, "Enabled", OrgStatus == 0, "Disabled", OrgStatus == 2, "Pending", OrgStatus == 3, "Failed", "Maintenance"), IsMultiGeo, IsCDS, StateChangeReason, DisabledDate=iff(DisabledOn>ExpiryDate,DisabledOn,ExpiryDate)
