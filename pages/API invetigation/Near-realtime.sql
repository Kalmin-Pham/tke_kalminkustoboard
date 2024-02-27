let cllgetorginfo = (
['Retrieve org id']
);
union 
cluster("https://crmanacus.kusto.windows.net").database("CRMAnalytics").WebRequestStatistics,
cluster("https://crmanaweu.kusto.windows.net").database("CRMAnalytics").WebRequestStatistics
| where TIMESTAMP between (_startTime .. _endTime)
| where OrganizationId in (cllgetorginfo)
| where Request has requeststring or isempty(requeststring) 
| where SystemUserId contains agentid or isempty(agentid)
| where UserAgent contains agentname or isempty(agentname)
| where * contains reqid or isempty(reqid)
| extend Type=substring(HttpStatus,0,3)
| project TIMESTAMP, ActivityId, HttpMethod, requestId, Request, HttpStatus, ExecutionTime, UserAgent, SystemUserId, ClientRequestId, ClientSessionId, AADObjectId, Type
| order by TIMESTAMP desc
| take 200
