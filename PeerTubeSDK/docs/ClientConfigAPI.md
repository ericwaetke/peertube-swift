# ClientConfigAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**updateClientLanguage**](ClientConfigAPI.md#updateclientlanguage) | **POST** /api/v1/client-config/update-language | Update client language


# **updateClientLanguage**
```swift
    open class func updateClientLanguage(updateClientLanguageRequest: UpdateClientLanguageRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Update client language

Set a cookie so that, the next time the client refreshes the HTML of the web interface, PeerTube will use the next language

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let updateClientLanguageRequest = updateClientLanguage_request(language: "language_example") // UpdateClientLanguageRequest |  (optional)

// Update client language
ClientConfigAPI.updateClientLanguage(updateClientLanguageRequest: updateClientLanguageRequest) { (response, error) in
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
 **updateClientLanguageRequest** | [**UpdateClientLanguageRequest**](UpdateClientLanguageRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

