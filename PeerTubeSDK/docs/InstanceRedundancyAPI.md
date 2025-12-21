# InstanceRedundancyAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1ServerRedundancyHostPut**](InstanceRedundancyAPI.md#apiv1serverredundancyhostput) | **PUT** /api/v1/server/redundancy/{host} | Update a server redundancy policy


# **apiV1ServerRedundancyHostPut**
```swift
    open class func apiV1ServerRedundancyHostPut(host: String, apiV1ServerRedundancyHostPutRequest: ApiV1ServerRedundancyHostPutRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Update a server redundancy policy

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let host = "host_example" // String | server domain to mirror
let apiV1ServerRedundancyHostPutRequest = _api_v1_server_redundancy__host__put_request(redundancyAllowed: false) // ApiV1ServerRedundancyHostPutRequest |  (optional)

// Update a server redundancy policy
InstanceRedundancyAPI.apiV1ServerRedundancyHostPut(host: host, apiV1ServerRedundancyHostPutRequest: apiV1ServerRedundancyHostPutRequest) { (response, error) in
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
 **host** | **String** | server domain to mirror | 
 **apiV1ServerRedundancyHostPutRequest** | [**ApiV1ServerRedundancyHostPutRequest**](ApiV1ServerRedundancyHostPutRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

