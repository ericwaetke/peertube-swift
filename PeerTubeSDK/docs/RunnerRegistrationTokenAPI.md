# RunnerRegistrationTokenAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1RunnersRegistrationTokensGeneratePost**](RunnerRegistrationTokenAPI.md#apiv1runnersregistrationtokensgeneratepost) | **POST** /api/v1/runners/registration-tokens/generate | Generate registration token
[**apiV1RunnersRegistrationTokensGet**](RunnerRegistrationTokenAPI.md#apiv1runnersregistrationtokensget) | **GET** /api/v1/runners/registration-tokens | List registration tokens
[**apiV1RunnersRegistrationTokensRegistrationTokenIdDelete**](RunnerRegistrationTokenAPI.md#apiv1runnersregistrationtokensregistrationtokeniddelete) | **DELETE** /api/v1/runners/registration-tokens/{registrationTokenId} | Remove registration token


# **apiV1RunnersRegistrationTokensGeneratePost**
```swift
    open class func apiV1RunnersRegistrationTokensGeneratePost(completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Generate registration token

Generate a new runner registration token

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// Generate registration token
RunnerRegistrationTokenAPI.apiV1RunnersRegistrationTokensGeneratePost() { (response, error) in
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

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1RunnersRegistrationTokensGet**
```swift
    open class func apiV1RunnersRegistrationTokensGet(start: Int? = nil, count: Int? = nil, sort: Sort_apiV1RunnersRegistrationTokensGet? = nil, completion: @escaping (_ data: ApiV1RunnersRegistrationTokensGet200Response?, _ error: Error?) -> Void)
```

List registration tokens

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let sort = "sort_example" // String | Sort registration tokens by criteria (optional)

// List registration tokens
RunnerRegistrationTokenAPI.apiV1RunnersRegistrationTokensGet(start: start, count: count, sort: sort) { (response, error) in
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
 **sort** | **String** | Sort registration tokens by criteria | [optional] 

### Return type

[**ApiV1RunnersRegistrationTokensGet200Response**](ApiV1RunnersRegistrationTokensGet200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1RunnersRegistrationTokensRegistrationTokenIdDelete**
```swift
    open class func apiV1RunnersRegistrationTokensRegistrationTokenIdDelete(registrationTokenId: Int, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Remove registration token

Remove a registration token. Runners that used this token for their registration are automatically removed.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let registrationTokenId = 987 // Int | 

// Remove registration token
RunnerRegistrationTokenAPI.apiV1RunnersRegistrationTokensRegistrationTokenIdDelete(registrationTokenId: registrationTokenId) { (response, error) in
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
 **registrationTokenId** | **Int** |  | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

