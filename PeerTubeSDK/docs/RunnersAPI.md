# RunnersAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1RunnersGet**](RunnersAPI.md#apiv1runnersget) | **GET** /api/v1/runners | List runners
[**apiV1RunnersRegisterPost**](RunnersAPI.md#apiv1runnersregisterpost) | **POST** /api/v1/runners/register | Register a new runner
[**apiV1RunnersRunnerIdDelete**](RunnersAPI.md#apiv1runnersrunneriddelete) | **DELETE** /api/v1/runners/{runnerId} | Delete a runner
[**apiV1RunnersUnregisterPost**](RunnersAPI.md#apiv1runnersunregisterpost) | **POST** /api/v1/runners/unregister | Unregister a runner


# **apiV1RunnersGet**
```swift
    open class func apiV1RunnersGet(start: Int? = nil, count: Int? = nil, sort: Sort_apiV1RunnersGet? = nil, completion: @escaping (_ data: ApiV1RunnersGet200Response?, _ error: Error?) -> Void)
```

List runners

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let sort = "sort_example" // String | Sort runners by criteria (optional)

// List runners
RunnersAPI.apiV1RunnersGet(start: start, count: count, sort: sort) { (response, error) in
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
 **sort** | **String** | Sort runners by criteria | [optional] 

### Return type

[**ApiV1RunnersGet200Response**](ApiV1RunnersGet200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1RunnersRegisterPost**
```swift
    open class func apiV1RunnersRegisterPost(apiV1RunnersRegisterPostRequest: ApiV1RunnersRegisterPostRequest? = nil, completion: @escaping (_ data: ApiV1RunnersRegisterPost200Response?, _ error: Error?) -> Void)
```

Register a new runner

API used by PeerTube runners

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let apiV1RunnersRegisterPostRequest = _api_v1_runners_register_post_request(registrationToken: "registrationToken_example", name: "name_example", description: "description_example") // ApiV1RunnersRegisterPostRequest |  (optional)

// Register a new runner
RunnersAPI.apiV1RunnersRegisterPost(apiV1RunnersRegisterPostRequest: apiV1RunnersRegisterPostRequest) { (response, error) in
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
 **apiV1RunnersRegisterPostRequest** | [**ApiV1RunnersRegisterPostRequest**](ApiV1RunnersRegisterPostRequest.md) |  | [optional] 

### Return type

[**ApiV1RunnersRegisterPost200Response**](ApiV1RunnersRegisterPost200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1RunnersRunnerIdDelete**
```swift
    open class func apiV1RunnersRunnerIdDelete(runnerId: Int, apiV1RunnersUnregisterPostRequest: ApiV1RunnersUnregisterPostRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete a runner

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let runnerId = 987 // Int | 
let apiV1RunnersUnregisterPostRequest = _api_v1_runners_unregister_post_request(runnerToken: "runnerToken_example") // ApiV1RunnersUnregisterPostRequest |  (optional)

// Delete a runner
RunnersAPI.apiV1RunnersRunnerIdDelete(runnerId: runnerId, apiV1RunnersUnregisterPostRequest: apiV1RunnersUnregisterPostRequest) { (response, error) in
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
 **runnerId** | **Int** |  | 
 **apiV1RunnersUnregisterPostRequest** | [**ApiV1RunnersUnregisterPostRequest**](ApiV1RunnersUnregisterPostRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1RunnersUnregisterPost**
```swift
    open class func apiV1RunnersUnregisterPost(apiV1RunnersUnregisterPostRequest: ApiV1RunnersUnregisterPostRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Unregister a runner

API used by PeerTube runners

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let apiV1RunnersUnregisterPostRequest = _api_v1_runners_unregister_post_request(runnerToken: "runnerToken_example") // ApiV1RunnersUnregisterPostRequest |  (optional)

// Unregister a runner
RunnersAPI.apiV1RunnersUnregisterPost(apiV1RunnersUnregisterPostRequest: apiV1RunnersUnregisterPostRequest) { (response, error) in
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
 **apiV1RunnersUnregisterPostRequest** | [**ApiV1RunnersUnregisterPostRequest**](ApiV1RunnersUnregisterPostRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

