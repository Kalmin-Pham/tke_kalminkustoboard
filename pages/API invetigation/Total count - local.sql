let formatnumber = (input:long){
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
let que1 = (
union 
cluster("https://crmanacus.kusto.windows.net").database("CRMAnalytics").WebRequestStatistics,
cluster("https://crmanaweu.kusto.windows.net").database("CRMAnalytics").WebRequestStatistics
| where TIMESTAMP between (_startTime.._endTime)
| where OrganizationId in (cllgetorginfo)
| where SystemUserId contains agentid or isempty(agentid)
| where UserAgent contains agentname or isempty(agentname)
| where Request has requeststring or isempty(requeststring)
| where * contains reqid or isempty(reqid)
| summarize TotalCount=count(), Success = countif(HttpStatus startswith '2' or HttpStatus startswith '3'), Redirection = countif(HttpStatus startswith '3'), Failure = countif(HttpStatus startswith '4' or HttpStatus startswith '5'), ClientError = countif(HttpStatus startswith '4'), ServerError = countif(HttpStatus startswith '5')
| project TotalCount,Success,Redirection,Failure,ClientError,ServerError,merge=1
);
let que2 = (
union 
cluster("https://crmanacus.kusto.windows.net").database("CRMAnalytics").ThrottlingUsage,
cluster("https://crmanaweu.kusto.windows.net").database("CRMAnalytics").ThrottlingUsage
| where TIMESTAMP between (_startTime .. _endTime)
| where organizationId in (cllgetorginfo)
| where userId contains agentid or isempty(agentid)
| where throttled == 1 and enabled == 1
| summarize Throttled_call = count()
| project Throttled_call, merge=1
);
que2
| join kind=inner que1 on merge
| project Details = strcat(
'**Total requests**: ', formatnumber(TotalCount), 
'\n\n**Success requests**: ', formatnumber(Success),
'\n\n**Redirection requests**: ', formatnumber(Redirection),
'\n\n**Failures**: ', formatnumber(Failure),
'\n\n**Client Error**: ', formatnumber(ClientError),
'\n\n**Server Error**: ', formatnumber(ServerError),
'\n\n**Throttled requests**: ', formatnumber(Throttled_call)
)
