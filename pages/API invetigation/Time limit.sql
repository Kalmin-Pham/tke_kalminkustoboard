let cllgetorginfo = (
['Retrieve org id']
);
union 
cluster("https://crmanacus.kusto.windows.net").database("CRMAnalytics").ThrottlingUsage,
cluster("https://crmanaweu.kusto.windows.net").database("CRMAnalytics").ThrottlingUsage
| where TIMESTAMP between (_startTime .. _endTime)
| where organizationId in (cllgetorginfo)
| where throttleType == 'TimeUsage'
| where endpointType == 'OData' // OData, SdkService, SandboxListener 
| summarize 
    Time_limit = max(passed)/60000.0, 
    Time_throttled = max(toint(throttled)),
    Time_threshold = max(threshold)/60000.0 
    by bin(TIMESTAMP, totimespan(interval))
