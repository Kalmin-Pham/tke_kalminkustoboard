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
| summarize Avg_Queuing_Time = avg(QueuingTime), Avg_SDK_Time = avg(SdkTotalMs), Avg_SQL_Time = avg(SqlTotalMs), Avg_SQLConnection_Time = avg(SqlConnectionOpenTotalMs), Avg_Execution_Time = avg(ExecutionTime), RequestCount = count() by bin(TIMESTAMP, 15m)
| order by TIMESTAMP desc
| render timechart 