let cllgetorginfo = (
['Retrieve org id']
);
union 
cluster("https://crmanacus.kusto.windows.net").database("CRMAnalytics").WebRequestStatistics,
cluster("https://crmanaweu.kusto.windows.net").database("CRMAnalytics").WebRequestStatistics
| where TIMESTAMP between (_startTime .. _endTime)
| where OrganizationId in (cllgetorginfo)
| where SystemUserId contains agentid or isempty(agentid)
| where UserAgent contains agentname or isempty(agentname)
| where Request contains requeststring or isempty(requeststring)
| extend Type=substring(HttpStatus,0,3)
| top 50 by ExecutionTime
| project TIMESTAMP, ActivityId, HttpMethod, requestId, Request, HttpStatus, ExecutionTime, UserAgent, SystemUserId, ClientRequestId, ClientSessionId, AADObjectId, Type
