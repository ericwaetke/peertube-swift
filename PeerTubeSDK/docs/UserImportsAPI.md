# UserImportsAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getLatestUserImport**](UserImportsAPI.md#getlatestuserimport) | **GET** /api/v1/users/{userId}/imports/latest | Get latest user import
[**userImportResumable**](UserImportsAPI.md#userimportresumable) | **PUT** /api/v1/users/{userId}/imports/import-resumable | Send chunk for the resumable user import
[**userImportResumableCancel**](UserImportsAPI.md#userimportresumablecancel) | **DELETE** /api/v1/users/{userId}/imports/import-resumable | Cancel the resumable user import
[**userImportResumableInit**](UserImportsAPI.md#userimportresumableinit) | **POST** /api/v1/users/{userId}/imports/import-resumable | Initialize the resumable user import


# **getLatestUserImport**
```swift
    open class func getLatestUserImport(userId: Int, completion: @escaping (_ data: GetLatestUserImport200Response?, _ error: Error?) -> Void)
```

Get latest user import

**PeerTube >= 6.1**

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let userId = 987 // Int | User id

// Get latest user import
UserImportsAPI.getLatestUserImport(userId: userId) { (response, error) in
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

[**GetLatestUserImport200Response**](GetLatestUserImport200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **userImportResumable**
```swift
    open class func userImportResumable(userId: Int, uploadId: String, contentRange: String, contentLength: Double, body: URL? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Send chunk for the resumable user import

**PeerTube >= 6.1** Uses [a resumable protocol](https://github.com/kukhariev/node-uploadx/blob/master/proto.md) to continue, pause or resume the import of the archive

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let userId = 987 // Int | User id
let uploadId = "uploadId_example" // String | Created session id to proceed with. If you didn't send chunks in the last hour, it is not valid anymore and you need to initialize a new upload. 
let contentRange = "contentRange_example" // String | Specifies the bytes in the file that the request is uploading.  For example, a value of `bytes 0-262143/1000000` shows that the request is sending the first 262144 bytes (256 x 1024) in a 2,469,036 byte file. 
let contentLength = 987 // Double | Size of the chunk that the request is sending.  Remember that larger chunks are more efficient. PeerTube's web client uses chunks varying from 1048576 bytes (~1MB) and increases or reduces size depending on connection health. 
let body = URL(string: "https://example.com")! // URL |  (optional)

// Send chunk for the resumable user import
UserImportsAPI.userImportResumable(userId: userId, uploadId: uploadId, contentRange: contentRange, contentLength: contentLength, body: body) { (response, error) in
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
 **uploadId** | **String** | Created session id to proceed with. If you didn&#39;t send chunks in the last hour, it is not valid anymore and you need to initialize a new upload.  | 
 **contentRange** | **String** | Specifies the bytes in the file that the request is uploading.  For example, a value of &#x60;bytes 0-262143/1000000&#x60; shows that the request is sending the first 262144 bytes (256 x 1024) in a 2,469,036 byte file.  | 
 **contentLength** | **Double** | Size of the chunk that the request is sending.  Remember that larger chunks are more efficient. PeerTube&#39;s web client uses chunks varying from 1048576 bytes (~1MB) and increases or reduces size depending on connection health.  | 
 **body** | **URL** |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/octet-stream
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **userImportResumableCancel**
```swift
    open class func userImportResumableCancel(userId: Int, uploadId: String, contentLength: Double, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Cancel the resumable user import

**PeerTube >= 6.1** Uses [a resumable protocol](https://github.com/kukhariev/node-uploadx/blob/master/proto.md) to cancel the resumable user import

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let userId = 987 // Int | User id
let uploadId = "uploadId_example" // String | Created session id to proceed with. If you didn't send chunks in the last hour, it is not valid anymore and you need to initialize a new upload. 
let contentLength = 987 // Double | 

// Cancel the resumable user import
UserImportsAPI.userImportResumableCancel(userId: userId, uploadId: uploadId, contentLength: contentLength) { (response, error) in
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
 **uploadId** | **String** | Created session id to proceed with. If you didn&#39;t send chunks in the last hour, it is not valid anymore and you need to initialize a new upload.  | 
 **contentLength** | **Double** |  | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **userImportResumableInit**
```swift
    open class func userImportResumableInit(userId: Int, xUploadContentLength: Double, xUploadContentType: String, userImportResumable: UserImportResumable? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Initialize the resumable user import

**PeerTube >= 6.1** Uses [a resumable protocol](https://github.com/kukhariev/node-uploadx/blob/master/proto.md) to initialize the import of the archive

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let userId = 987 // Int | User id
let xUploadContentLength = 987 // Double | Number of bytes that will be uploaded in subsequent requests. Set this value to the size of the file you are uploading.
let xUploadContentType = "xUploadContentType_example" // String | MIME type of the file that you are uploading. Depending on your instance settings, acceptable values might vary.
let userImportResumable = UserImportResumable(filename: "filename_example") // UserImportResumable |  (optional)

// Initialize the resumable user import
UserImportsAPI.userImportResumableInit(userId: userId, xUploadContentLength: xUploadContentLength, xUploadContentType: xUploadContentType, userImportResumable: userImportResumable) { (response, error) in
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
 **xUploadContentLength** | **Double** | Number of bytes that will be uploaded in subsequent requests. Set this value to the size of the file you are uploading. | 
 **xUploadContentType** | **String** | MIME type of the file that you are uploading. Depending on your instance settings, acceptable values might vary. | 
 **userImportResumable** | [**UserImportResumable**](UserImportResumable.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

