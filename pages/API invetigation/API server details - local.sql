let formatnumber = (input:int){
let number = tostring(input);
let lennum1 = strlen(number);
let lennum = toint(lennum1);
case(
lennum > 3 and lennum < 7, strcat(substring(number,0,lennum-3),',',substring(number,lennum-3,3)), //xxx,xxx
lennum > 6 and lennum < 10, strcat(substring(number,0,lennum-6),',',substring(number,lennum-6,3),',',substring(number,lennum-3,3)), //xxx,xxx,xxx
lennum > 9 and lennum < 13, strcat(substring(number,0,lennum-9),',',substring(number,lennum-9,3),',',substring(number,lennum-6,3),',',substring(number,lennum-3,3)), //xxx,xxx,xxx,xxx
lennum > 12 and lennum < 16, strcat(substring(number,0,lennum-12),',',substring(number,lennum-12,3),',',substring(number,lennum-9,3),',',substring(number,lennum-6,3),',',substring(number,lennum-3,3)), //xxx,xxx,xxx,xxx,xxx
lennum > 15 and lennum < 19, strcat(substring(number,0,lennum-15),',',substring(number,lennum-15,3),',',substring(number,lennum-12,3),',',substring(number,lennum-9,3),',',substring(number,lennum-6,3),',',substring(number,lennum-3,3)), //xxx,xxx,xxx,xxx,xxx,xxx
number)
};
let cllgetorginfo = (
['Retrieve org id']
);
let GetTierByServerCount = (serverCount:int) {toint(toreal(serverCount)/toreal(2));}; 
let OrgDetails =  
union 
cluster("https://crmanacus.kusto.windows.net").database("CRMAnalytics").OrganizationDetails,
cluster("https://crmanaweu.kusto.windows.net").database("CRMAnalytics").OrganizationDetails
| where TIMESTAMP between (_startTime .. _endTime)
| where OrgId in (cllgetorginfo)
| top 1 by TIMESTAMP 
| project OrganizationId = OrgId, CurrentAPIUnits = TenantAPIUnits,  Domain = DomainName, ExpectedServerCount = GetServerCountByApiUnits(TenantAPIUnits); 
let WebStats =  
union 
cluster("https://crmanacus.kusto.windows.net").database("CRMAnalytics").WebRequestStatistics,
cluster("https://crmanaweu.kusto.windows.net").database("CRMAnalytics").WebRequestStatistics
| where TIMESTAMP between (_startTime .. _endTime)
| where OrganizationId in (cllgetorginfo)
| where Headers contains 'x-ms-routing-max-server-count' 
| top 1 by TIMESTAMP 
| extend CurrentServerCount = toint(todynamic(Headers)['x-ms-routing-max-server-count']) 
| project OrganizationId, CurrentServerCount, CurrentWebTier = GetTierByServerCount(CurrentServerCount); 
OrgDetails | join WebStats on OrganizationId 
| extend SROverideExists = iff(CurrentServerCount > ExpectedServerCount, true, false) 
// | project CurrentAPIUnits, CurrentServerCount, CurrentWebTier, ScaleGroupType
| project Details = strcat(
'**Allocated API Units**: ', formatnumber(toint(CurrentAPIUnits)), 
'\n\n**API Server Count**: ', CurrentServerCount,
'\n\n**API Web Tier**: ', CurrentWebTier)
