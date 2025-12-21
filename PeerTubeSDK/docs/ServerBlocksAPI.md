# ServerBlocksAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1BlocklistStatusGet**](ServerBlocksAPI.md#apiv1blockliststatusget) | **GET** /api/v1/blocklist/status | Get block status of accounts/hosts
[**apiV1ServerBlocklistServersGet**](ServerBlocksAPI.md#apiv1serverblocklistserversget) | **GET** /api/v1/server/blocklist/servers | List server blocks
[**apiV1ServerBlocklistServersHostDelete**](ServerBlocksAPI.md#apiv1serverblocklistservershostdelete) | **DELETE** /api/v1/server/blocklist/servers/{host} | Unblock a server by its domain
[**apiV1ServerBlocklistServersPost**](ServerBlocksAPI.md#apiv1serverblocklistserverspost) | **POST** /api/v1/server/blocklist/servers | Block a server


# **apiV1BlocklistStatusGet**
```swift
    open class func apiV1BlocklistStatusGet(accounts: [String]? = nil, hosts: [String]? = nil, completion: @escaping (_ data: BlockStatus?, _ error: Error?) -> Void)
```

Get block status of accounts/hosts

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let accounts = ["inner_example"] // [String] | Check if these accounts are blocked (optional)
let hosts = ["inner_example"] // [String] | Check if these hosts are blocked (optional)

// Get block status of accounts/hosts
ServerBlocksAPI.apiV1BlocklistStatusGet(accounts: accounts, hosts: hosts) { (response, error) in
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
 **accounts** | [**[String]**](String.md) | Check if these accounts are blocked | [optional] 
 **hosts** | [**[String]**](String.md) | Check if these hosts are blocked | [optional] 

### Return type

[**BlockStatus**](BlockStatus.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1ServerBlocklistServersGet**
```swift
    open class func apiV1ServerBlocklistServersGet(start: Int? = nil, count: Int? = nil, sort: String? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

List server blocks

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let sort = "sort_example" // String | Sort column (optional)

// List server blocks
ServerBlocksAPI.apiV1ServerBlocklistServersGet(start: start, count: count, sort: sort) { (response, error) in
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
 **start** | **Int** | Offset used to paginate results | [optional] 
 **count** | **Int** | Number of items to return | [optional] [default to 15]
 **sort** | **String** | Sort column | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1ServerBlocklistServersHostDelete**
```swift
    open class func apiV1ServerBlocklistServersHostDelete(host: String, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Unblock a server by its domain

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let host = "host_example" // String | server domain to unblock

// Unblock a server by its domain
ServerBlocksAPI.apiV1ServerBlocklistServersHostDelete(host: host) { (response, error) in
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
 **host** | **String** | server domain to unblock | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1ServerBlocklistServersPost**
```swift
    open class func apiV1ServerBlocklistServersPost(apiV1ServerBlocklistServersPostRequest: ApiV1ServerBlocklistServersPostRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Block a server

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let apiV1ServerBlocklistServersPostRequest = _api_v1_server_blocklist_servers_post_request(host: "host_example") // ApiV1ServerBlocklistServersPostRequest |  (optional)

// Block a server
ServerBlocksAPI.apiV1ServerBlocklistServersPost(apiV1ServerBlocklistServersPostRequest: apiV1ServerBlocklistServersPostRequest) { (response, error) in
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
 **apiV1ServerBlocklistServersPostRequest** | [**ApiV1ServerBlocklistServersPostRequest**](ApiV1ServerBlocklistServersPostRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

