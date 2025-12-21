# LogsAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getInstanceAuditLogs**](LogsAPI.md#getinstanceauditlogs) | **GET** /api/v1/server/audit-logs | Get instance audit logs
[**getInstanceLogs**](LogsAPI.md#getinstancelogs) | **GET** /api/v1/server/logs | Get instance logs
[**sendClientLog**](LogsAPI.md#sendclientlog) | **POST** /api/v1/server/logs/client | Send client log


# **getInstanceAuditLogs**
```swift
    open class func getInstanceAuditLogs(completion: @escaping (_ data: [String]?, _ error: Error?) -> Void)
```

Get instance audit logs

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// Get instance audit logs
LogsAPI.getInstanceAuditLogs() { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

**[String]**

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getInstanceLogs**
```swift
    open class func getInstanceLogs(completion: @escaping (_ data: [String]?, _ error: Error?) -> Void)
```

Get instance logs

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// Get instance logs
LogsAPI.getInstanceLogs() { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

**[String]**

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sendClientLog**
```swift
    open class func sendClientLog(sendClientLog: SendClientLog? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Send client log

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let sendClientLog = SendClientLog(message: "message_example", url: "url_example", level: "level_example", stackTrace: "stackTrace_example", userAgent: "userAgent_example", meta: "meta_example") // SendClientLog |  (optional)

// Send client log
LogsAPI.sendClientLog(sendClientLog: sendClientLog) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sendClientLog** | [**SendClientLog**](SendClientLog.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

