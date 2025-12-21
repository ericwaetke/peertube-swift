# HomepageAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1CustomPagesHomepageInstanceGet**](HomepageAPI.md#apiv1custompageshomepageinstanceget) | **GET** /api/v1/custom-pages/homepage/instance | Get instance custom homepage
[**apiV1CustomPagesHomepageInstancePut**](HomepageAPI.md#apiv1custompageshomepageinstanceput) | **PUT** /api/v1/custom-pages/homepage/instance | Set instance custom homepage


# **apiV1CustomPagesHomepageInstanceGet**
```swift
    open class func apiV1CustomPagesHomepageInstanceGet(completion: @escaping (_ data: CustomHomepage?, _ error: Error?) -> Void)
```

Get instance custom homepage

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// Get instance custom homepage
HomepageAPI.apiV1CustomPagesHomepageInstanceGet() { (response, error) in
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

[**CustomHomepage**](CustomHomepage.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1CustomPagesHomepageInstancePut**
```swift
    open class func apiV1CustomPagesHomepageInstancePut(apiV1CustomPagesHomepageInstancePutRequest: ApiV1CustomPagesHomepageInstancePutRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Set instance custom homepage

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let apiV1CustomPagesHomepageInstancePutRequest = _api_v1_custom_pages_homepage_instance_put_request(content: "content_example") // ApiV1CustomPagesHomepageInstancePutRequest |  (optional)

// Set instance custom homepage
HomepageAPI.apiV1CustomPagesHomepageInstancePut(apiV1CustomPagesHomepageInstancePutRequest: apiV1CustomPagesHomepageInstancePutRequest) { (response, error) in
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
 **apiV1CustomPagesHomepageInstancePutRequest** | [**ApiV1CustomPagesHomepageInstancePutRequest**](ApiV1CustomPagesHomepageInstancePutRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

