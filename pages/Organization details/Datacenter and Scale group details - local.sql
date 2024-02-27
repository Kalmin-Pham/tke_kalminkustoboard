//Retrieve org Info
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
| extend AzureRegion = case(DCName == "BN1","eastus",DCName == "BY2","westus", DCName == "AMS","westeurope",DCName == "DB3", "northeurope", DCName == "HKN","eastasia", DCName == "SG1","southeastasia", DCName == "CPQ","brazilsouth", DCName=="SN1","southcentralus", DCName == "MEL","australiasoutheast", DCName=="SYD","australiaeast", DCName == "TYO","japaneast", DCName=="OSA","japanwest", DCName == "MAA","southindia", DCName=="PNQ","centralindia", DCName == "YTO","canadacentral", DCName=="YQB","canadaeast", DCName == "CWL","ukwest", DCName=="LON","uksouth", DCName == "FRC","francecentral", DCName=="FRS","francesouth", DCName == "UAN","uaenorth", DCName=="UAC","uaecentral", DCName == "SAN","southafricanorth", DCName=="SAW","southafricawest", DCName == "GEC","germanywestcentral", DCName=="GEN","germanynorth", DCName == "ZRH","switzerlandnorth", DCName=="GVA","switzerlandwest", DCName == "CKR","koreacentral", DCName=="SKR","koreasouth", DCName == "ENO","norwayeast", DCName=="WNO","norwaywest", DCName == "TP1","eastus", DCName=="TP2","westus", "Undefined"), ScaleGroupId
| take 1
);
let clltenant2 = (
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
| project ScaleGroupId
| take 1
);
let que1 = (
union 
cluster("https://crmanacus.kusto.windows.net").database("CRMAnalytics").IslandDetails
| where ScaleGroupId in (clltenant2)
| extend merge=1
| project IslandName, IslandNumber, KustoCluster, merge, ScaleGroupId
| take 1
);
let que2 = (
union 
cluster("https://crmanacus.kusto.windows.net").database("CRMAnalytics").ScalegroupDetails,
cluster("https://crmanaweu.kusto.windows.net").database("CRMAnalytics").ScalegroupDetails
| where TIMESTAMP between (_startTime.._endTime)
| where Id in (clltenant2)
| extend merge=1
| order by ScaleGroup, ScaleGroupType, TargetEdition, TierGroupName, AzureRegion, Geo
| project ScaleGroup, ScaleGroupType, TargetEdition, TierGroupName, AzureRegion, Geo, Datacenter, merge
// | take 1
);
que1
| join kind=inner que2 on merge
| project IslandName, IslandNumber, KustoCluster, ScaleGroup, ScaleGroupType, TargetEdition, TierGroupName, AzureRegion, Geo, Datacenter, ScaleGroupId
| take 1
| project Details = strcat(
'**Geo**: ', Geo, 
'\n\n**Datacenter**: ', Datacenter, 
'\n\n**Azure Region**: ', AzureRegion,
'\n\n**Scale Group**: ', ScaleGroup,
'\n\n**Scale Group Type / Target type**: ', strcat(ScaleGroupType, ' / ', TargetEdition),
'\n\n**Scale Group Id**: ', ScaleGroupId,
'\n\n**Island Name / Tier Group Name**: ', strcat(IslandName, ' / ', TierGroupName),
'\n\n**Island Number**: ', IslandNumber,
'\n\n**Kusto Cluster**: ', KustoCluster)


//main script
// let clltenant = (
// union 
// cluster("https://crmanacus.kusto.windows.net").database("CRMAnalytics").OrganizationDetails,
// cluster("https://crmanaweu.kusto.windows.net").database("CRMAnalytics").OrganizationDetails
// | where OrgId == orgid or isempty(orgid)
// | where DomainName == domainname or isempty(domainname)
// | where Geo == geo or isempty(geo)
// | where BAPEnvironmentId == envid or isempty(envid)
// | project AzureRegion = case(DCName == "BN1","eastus",DCName == "BY2","westus", DCName == "AMS","westeurope",DCName == "DB3", "northeurope", DCName == "HKN","eastasia", DCName == "SG1","southeastasia", DCName == "CPQ","brazilsouth", DCName=="SN1","southcentralus", DCName == "MEL","australiasoutheast", DCName=="SYD","australiaeast", DCName == "TYO","japaneast", DCName=="OSA","japanwest", DCName == "MAA","southindia", DCName=="PNQ","centralindia", DCName == "YTO","canadacentral", DCName=="YQB","canadaeast", DCName == "CWL","ukwest", DCName=="LON","uksouth", DCName == "FRC","francecentral", DCName=="FRS","francesouth", DCName == "UAN","uaenorth", DCName=="UAC","uaecentral", DCName == "SAN","southafricanorth", DCName=="SAW","southafricawest", DCName == "GEC","germanywestcentral", DCName=="GEN","germanynorth", DCName == "ZRH","switzerlandnorth", DCName=="GVA","switzerlandwest", DCName == "CKR","koreacentral", DCName=="SKR","koreasouth", DCName == "ENO","norwayeast", DCName=="WNO","norwaywest", DCName == "TP1","eastus", DCName=="TP2","westus", "Undefined"), ScaleGroupId
// | take 1
// );
// let clltenant2 = (
// union 
// cluster("https://crmanacus.kusto.windows.net").database("CRMAnalytics").OrganizationDetails,
// cluster("https://crmanaweu.kusto.windows.net").database("CRMAnalytics").OrganizationDetails
// | where OrgId == orgid or isempty(orgid)
// | where DomainName == domainname or isempty(domainname)
// | where Geo == geo or isempty(geo)
// | project ScaleGroupId
// | take 1
// );
// let que1 = (
// union 
// cluster("https://crmanacus.kusto.windows.net").database("CRMAnalytics").IslandDetails
// | where ScaleGroupId in (clltenant2)
// | extend merge=1
// | project IslandName, IslandNumber, KustoCluster, merge
// | take 1
// );
// let que2 = (
// union 
// cluster("https://crmanacus.kusto.windows.net").database("CRMAnalytics").ScalegroupDetails,
// cluster("https://crmanaweu.kusto.windows.net").database("CRMAnalytics").ScalegroupDetails
// | where Id in (clltenant2)
// | extend merge=1
// | order by ScaleGroup, ScaleGroupType, TargetEdition, TierGroupName, AzureRegion, Geo
// | project ScaleGroup, ScaleGroupType, TargetEdition, TierGroupName, AzureRegion, Geo, Datacenter, merge
// | take 1
// );
// que1
// | join kind=inner que2 on merge
// | project IslandName, IslandNumber, KustoCluster, ScaleGroup, ScaleGroupType, TargetEdition, TierGroupName, AzureRegion, Geo, Datacenter
