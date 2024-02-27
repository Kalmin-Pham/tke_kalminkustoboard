let cllgetorginfo = (
['Retrieve org id']
);
union 
cluster("https://crmanacus.kusto.windows.net").database("CRMAnalytics").ThrottlingUsage,
cluster("https://crmanaweu.kusto.windows.net").database("CRMAnalytics").ThrottlingUsage
| where TIMESTAMP between (_startTime .. _endTime)
| where organizationId in (cllgetorginfo)
| where throttleType == 'Concurrency'
| where endpointType == 'OData' // OData, SdkService, SandboxListener 
| summarize 
    Concurency_limit = max(passed),
    Concurency_throttled = max(toint(throttled)),
    Concurency_threshold = max(threshold)
    by bin(TIMESTAMP, totimespan(interval))
