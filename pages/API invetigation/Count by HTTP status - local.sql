let cllgetorginfo = (
['Retrieve org id']
);
union 
cluster("https://crmanacus.kusto.windows.net").database("CRMAnalytics").WebRequestStatistics,
cluster("https://crmanaweu.kusto.windows.net").database("CRMAnalytics").WebRequestStatistics
| where TIMESTAMP between (_startTime.._endTime)
| where OrganizationId in (cllgetorginfo)
| where SystemUserId contains agentid or isempty(agentid)
| where UserAgent contains agentname or isempty(agentname)
| where * contains reqid or isempty(reqid)
| where Request has requeststring or isempty(requeststring)
| extend StatusCode_Meaning = case(
HttpStatus=='100 Continue', 'The server has received the request headers, and the client should proceed to send the request body',
HttpStatus=='101 Switching Protocols', 'The server has agreed to switch protocols as requested by the client',
HttpStatus=='102 Processing', 'The server is still processing the request',
HttpStatus=='200 OK', 'The request was successful, and the server has returned the requested data',
HttpStatus=='201 Created', 'The request was successful, and a new resource was created as a result',
HttpStatus=='204 No Content', 'The server successfully processed the request but is not returning any content',
HttpStatus=='206 Partial Content', 'The server is delivering only part of the resource due to a range header sent by the client',
HttpStatus=='300 Multiple Choices', 'Indicates multiple options for the resource from which the client may choose',
HttpStatus=='301 Moved Permanently', 'Tells the client that the resource has been permanently moved to another location',
HttpStatus=='302 Found', 'Tells the client that the resource has been temporary moved to another location',
HttpStatus=='304 Not Modified', 'Indicates that the resource has not been modified since the last request',
HttpStatus=='307 Temporary Redirect', 'Tells the client that the resource has been temporary moved to another location, but it does not allow the HTTP method to change',
HttpStatus=='308 Permanent Redirect', 'The request and all future requests should be repeated using another URI',
HttpStatus=='400 Bad Request', 'Indicates that the server cannot or will not process the request due to a client error',
HttpStatus=='401 Unauthorized', 'Requires authentication. The request lacks valid authentication credentials',
HttpStatus=='403 Forbidden', 'The server understood the request, but it refuses to authorize it',
HttpStatus=='404 Not Found', 'The server cannot find the requested resource',
HttpStatus=='405 Method Not Allowed', 'The method specified in the request is not allowed for the resource identified by the request URI',
HttpStatus=='412 Precondition Failed', 'Access to the target resource of this conditional request has been denied. The condition defined by the If-Unmodified-Since or If-None-Match headers is not fulfilled.',
HttpStatus=='429', 'Too many request, the user has sent too many requests in a given amount of time and the request exceed the API limitation',
HttpStatus=='500 Internal Server Error', 'A generic error message indicating that an unexpected condition was encountered by the server',
HttpStatus=='501 Not Implemented', 'The server either does not recognize the request method or lacks the ability to fulfill the request',
HttpStatus=='503 Service Unavailable', 'The server is not ready to handle the request. Common causes are a server that is down for maintenance or is overloaded',
HttpStatus=='504 Gateway Timeout', 'The server did not receive a timely response from the upstream server or some other auxiliary server it needed to access in order to complete the request',
HttpStatus=='505 HTTP Version Not Supported', 'The server does not support the HTTP protocol version that was used in the request',
'NA')
| summarize Count=count() by HttpStatus, StatusCode_Meaning
| project HttpStatus, Count, StatusCode_Meaning
| order by Count desc 
