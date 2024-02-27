let cllorg = (
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
| project ScaleGroupId
| take 1
);
union 
cluster("https://crmanacus.kusto.windows.net").database("CRMAnalytics").FeatureControlSettings,
cluster("https://crmanaweu.kusto.windows.net").database("CRMAnalytics").FeatureControlSettings
| where ScopeId in (cllorg)
| summarize ModifiedOn=max(ModifiedOn) by Name, Enabled, id, CreatedOn, ['FCB Scope']
| project Name, Enabled, id, CreatedOn, ModifiedOn, ['FCB Scope']
