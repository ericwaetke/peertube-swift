# UserExportsAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deleteUserExport**](UserExportsAPI.md#deleteuserexport) | **DELETE** /api/v1/users/{userId}/exports/{id} | Delete a user export
[**listUserExports**](UserExportsAPI.md#listuserexports) | **GET** /api/v1/users/{userId}/exports | List user exports
[**requestUserExport**](UserExportsAPI.md#requestuserexport) | **POST** /api/v1/users/{userId}/exports/request | Request user export


# **deleteUserExport**
```swift
    open class func deleteUserExport(userId: Int, id: Int, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete a user export

**PeerTube >= 6.1**

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let userId = 987 // Int | User id
let id = 987 // Int | Entity id

// Delete a user export
UserExportsAPI.deleteUserExport(userId: userId, id: id) { (response, error) in
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
 **userId** | **Int** | User id | 
 **id** | **Int** | Entity id | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listUserExports**
```swift
    open class func listUserExports(userId: Int, completion: @escaping (_ data: ListUserExports200Response?, _ error: Error?) -> Void)
```

List user exports

**PeerTube >= 6.1**

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let userId = 987 // Int | User id

// List user exports
UserExportsAPI.listUserExports(userId: userId) { (response, error) in
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
 **userId** | **Int** | User id | 

### Return type

[**ListUserExports200Response**](ListUserExports200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **requestUserExport**
```swift
    open class func requestUserExport(userId: Int, requestUserExportRequest: RequestUserExportRequest? = nil, completion: @escaping (_ data: RequestUserExport200Response?, _ error: Error?) -> Void)
```

Request user export

Request an archive of user data. An email is sent when the archive is ready.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let userId = 987 // Int | User id
let requestUserExportRequest = requestUserExport_request(withVideoFiles: false) // RequestUserExportRequest |  (optional)

// Request user export
UserExportsAPI.requestUserExport(userId: userId, requestUserExportRequest: requestUserExportRequest) { (response, error) in
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
 **userId** | **Int** | User id | 
 **requestUserExportRequest** | [**RequestUserExportRequest**](RequestUserExportRequest.md) |  | [optional] 

### Return type

[**RequestUserExport200Response**](RequestUserExport200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

