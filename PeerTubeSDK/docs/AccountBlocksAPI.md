# AccountBlocksAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1BlocklistStatusGet**](AccountBlocksAPI.md#apiv1blockliststatusget) | **GET** /api/v1/blocklist/status | Get block status of accounts/hosts
[**apiV1ServerBlocklistAccountsAccountNameDelete**](AccountBlocksAPI.md#apiv1serverblocklistaccountsaccountnamedelete) | **DELETE** /api/v1/server/blocklist/accounts/{accountName} | Unblock an account by its handle
[**apiV1ServerBlocklistAccountsGet**](AccountBlocksAPI.md#apiv1serverblocklistaccountsget) | **GET** /api/v1/server/blocklist/accounts | List account blocks
[**apiV1ServerBlocklistAccountsPost**](AccountBlocksAPI.md#apiv1serverblocklistaccountspost) | **POST** /api/v1/server/blocklist/accounts | Block an account


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
AccountBlocksAPI.apiV1BlocklistStatusGet(accounts: accounts, hosts: hosts) { (response, error) in
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

# **apiV1ServerBlocklistAccountsAccountNameDelete**
```swift
    open class func apiV1ServerBlocklistAccountsAccountNameDelete(accountName: String, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Unblock an account by its handle

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let accountName = "accountName_example" // String | account to unblock, in the form `username@domain`

// Unblock an account by its handle
AccountBlocksAPI.apiV1ServerBlocklistAccountsAccountNameDelete(accountName: accountName) { (response, error) in
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
 **accountName** | **String** | account to unblock, in the form &#x60;username@domain&#x60; | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1ServerBlocklistAccountsGet**
```swift
    open class func apiV1ServerBlocklistAccountsGet(start: Int? = nil, count: Int? = nil, sort: String? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

List account blocks

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let sort = "sort_example" // String | Sort column (optional)

// List account blocks
AccountBlocksAPI.apiV1ServerBlocklistAccountsGet(start: start, count: count, sort: sort) { (response, error) in
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

# **apiV1ServerBlocklistAccountsPost**
```swift
    open class func apiV1ServerBlocklistAccountsPost(apiV1ServerBlocklistAccountsPostRequest: ApiV1ServerBlocklistAccountsPostRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Block an account

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let apiV1ServerBlocklistAccountsPostRequest = _api_v1_server_blocklist_accounts_post_request(accountName: "accountName_example") // ApiV1ServerBlocklistAccountsPostRequest |  (optional)

// Block an account
AccountBlocksAPI.apiV1ServerBlocklistAccountsPost(apiV1ServerBlocklistAccountsPostRequest: apiV1ServerBlocklistAccountsPostRequest) { (response, error) in
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
 **apiV1ServerBlocklistAccountsPostRequest** | [**ApiV1ServerBlocklistAccountsPostRequest**](ApiV1ServerBlocklistAccountsPostRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

