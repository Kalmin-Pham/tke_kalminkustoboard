let cllgetorginfo = (
['Retrieve org id']
);
union 
cluster("https://crmanacus.kusto.windows.net").database("CRMAnalytics").ThrottlingUsage,
cluster("https://crmanaweu.kusto.windows.net").database("CRMAnalytics").ThrottlingUsage
| where TIMESTAMP between (_startTime .. _endTime)
| where organizationId in (cllgetorginfo)
| where throttleType == 'ApiBurst'
| where endpointType == 'OData' // OData, SdkService, SandboxListener 
| summarize 
    Burst_pass = max(attempted),
    Burst_throttled = max(toint(throttled)),
    Burst_threshold = max(threshold)
    by bin(TIMESTAMP, totimespan(interval))
