# VideoPasswordsAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addVideoPassword**](VideoPasswordsAPI.md#addvideopassword) | **POST** /api/v1/videos/{id}/passwords | Add a video password
[**listVideoPasswords**](VideoPasswordsAPI.md#listvideopasswords) | **GET** /api/v1/videos/{id}/passwords | List video passwords
[**removeVideoPassword**](VideoPasswordsAPI.md#removevideopassword) | **DELETE** /api/v1/videos/{id}/passwords/{videoPasswordId} | Delete a video password
[**updateVideoPasswordList**](VideoPasswordsAPI.md#updatevideopasswordlist) | **PUT** /api/v1/videos/{id}/passwords | Update video passwords


# **addVideoPassword**
```swift
    open class func addVideoPassword(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, addVideoPasswordRequest: AddVideoPasswordRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Add a video password

**PeerTube >= 8.0**

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let addVideoPasswordRequest = addVideoPassword_request(password: "password_example") // AddVideoPasswordRequest |  (optional)

// Add a video password
VideoPasswordsAPI.addVideoPassword(id: id, addVideoPasswordRequest: addVideoPasswordRequest) { (response, error) in
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
 **id** | [**ApiV1VideosOwnershipIdAcceptPostIdParameter**](.md) | The object id, uuid or short uuid | 
 **addVideoPasswordRequest** | [**AddVideoPasswordRequest**](AddVideoPasswordRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listVideoPasswords**
```swift
    open class func listVideoPasswords(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, start: Int? = nil, count: Int? = nil, sort: String? = nil, completion: @escaping (_ data: VideoPasswordList?, _ error: Error?) -> Void)
```

List video passwords

**PeerTube >= 6.0**

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let sort = "sort_example" // String | Sort column (optional)

// List video passwords
VideoPasswordsAPI.listVideoPasswords(id: id, start: start, count: count, sort: sort) { (response, error) in
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
 **id** | [**ApiV1VideosOwnershipIdAcceptPostIdParameter**](.md) | The object id, uuid or short uuid | 
 **start** | **Int** | Offset used to paginate results | [optional] 
 **count** | **Int** | Number of items to return | [optional] [default to 15]
 **sort** | **String** | Sort column | [optional] 

### Return type

[**VideoPasswordList**](VideoPasswordList.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **removeVideoPassword**
```swift
    open class func removeVideoPassword(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, videoPasswordId: Int, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete a video password

**PeerTube >= 6.0**

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let videoPasswordId = 987 // Int | The video password id

// Delete a video password
VideoPasswordsAPI.removeVideoPassword(id: id, videoPasswordId: videoPasswordId) { (response, error) in
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
 **id** | [**ApiV1VideosOwnershipIdAcceptPostIdParameter**](.md) | The object id, uuid or short uuid | 
 **videoPasswordId** | **Int** | The video password id | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateVideoPasswordList**
```swift
    open class func updateVideoPasswordList(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, updateVideoPasswordListRequest: UpdateVideoPasswordListRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Update video passwords

**PeerTube >= 6.0**

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let updateVideoPasswordListRequest = updateVideoPasswordList_request(passwords: ["passwords_example"]) // UpdateVideoPasswordListRequest |  (optional)

// Update video passwords
VideoPasswordsAPI.updateVideoPasswordList(id: id, updateVideoPasswordListRequest: updateVideoPasswordListRequest) { (response, error) in
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
 **id** | [**ApiV1VideosOwnershipIdAcceptPostIdParameter**](.md) | The object id, uuid or short uuid | 
 **updateVideoPasswordListRequest** | [**UpdateVideoPasswordListRequest**](UpdateVideoPasswordListRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

