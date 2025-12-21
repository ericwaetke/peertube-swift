# VideoBlocksAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addVideoBlock**](VideoBlocksAPI.md#addvideoblock) | **POST** /api/v1/videos/{id}/blacklist | Block a video
[**delVideoBlock**](VideoBlocksAPI.md#delvideoblock) | **DELETE** /api/v1/videos/{id}/blacklist | Unblock a video by its id
[**getVideoBlocks**](VideoBlocksAPI.md#getvideoblocks) | **GET** /api/v1/videos/blacklist | List video blocks


# **addVideoBlock**
```swift
    open class func addVideoBlock(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Block a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid

// Block a video
VideoBlocksAPI.addVideoBlock(id: id) { (response, error) in
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

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **delVideoBlock**
```swift
    open class func delVideoBlock(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Unblock a video by its id

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid

// Unblock a video by its id
VideoBlocksAPI.delVideoBlock(id: id) { (response, error) in
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

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getVideoBlocks**
```swift
    open class func getVideoBlocks(type: ModelType_getVideoBlocks? = nil, search: String? = nil, start: Int? = nil, count: Int? = nil, sort: Sort_getVideoBlocks? = nil, completion: @escaping (_ data: GetVideoBlocks200Response?, _ error: Error?) -> Void)
```

List video blocks

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let type = 987 // Int | list only blocks that match this type: - `1`: manual block - `2`: automatic block that needs review  (optional)
let search = "search_example" // String | plain search that will match with video titles, and more (optional)
let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let sort = "sort_example" // String | Sort blocklists by criteria (optional)

// List video blocks
VideoBlocksAPI.getVideoBlocks(type: type, search: search, start: start, count: count, sort: sort) { (response, error) in
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
 **type** | **Int** | list only blocks that match this type: - &#x60;1&#x60;: manual block - &#x60;2&#x60;: automatic block that needs review  | [optional] 
 **search** | **String** | plain search that will match with video titles, and more | [optional] 
 **start** | **Int** | Offset used to paginate results | [optional] 
 **count** | **Int** | Number of items to return | [optional] [default to 15]
 **sort** | **String** | Sort blocklists by criteria | [optional] 

### Return type

[**GetVideoBlocks200Response**](GetVideoBlocks200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

