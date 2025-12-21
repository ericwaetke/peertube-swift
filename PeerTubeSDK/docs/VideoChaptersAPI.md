# VideoChaptersAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getVideoChapters**](VideoChaptersAPI.md#getvideochapters) | **GET** /api/v1/videos/{id}/chapters | Get chapters of a video
[**replaceVideoChapters**](VideoChaptersAPI.md#replacevideochapters) | **PUT** /api/v1/videos/{id}/chapters | Replace video chapters


# **getVideoChapters**
```swift
    open class func getVideoChapters(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, xPeertubeVideoPassword: String? = nil, completion: @escaping (_ data: VideoChapters?, _ error: Error?) -> Void)
```

Get chapters of a video

**PeerTube >= 6.0**

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let xPeertubeVideoPassword = "xPeertubeVideoPassword_example" // String | Required on password protected video (optional)

// Get chapters of a video
VideoChaptersAPI.getVideoChapters(id: id, xPeertubeVideoPassword: xPeertubeVideoPassword) { (response, error) in
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
 **xPeertubeVideoPassword** | **String** | Required on password protected video | [optional] 

### Return type

[**VideoChapters**](VideoChapters.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **replaceVideoChapters**
```swift
    open class func replaceVideoChapters(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, replaceVideoChaptersRequest: ReplaceVideoChaptersRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Replace video chapters

**PeerTube >= 6.0**

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let replaceVideoChaptersRequest = replaceVideoChapters_request(chapters: [replaceVideoChapters_request_chapters_inner(title: "title_example", timecode: 123)]) // ReplaceVideoChaptersRequest |  (optional)

// Replace video chapters
VideoChaptersAPI.replaceVideoChapters(id: id, replaceVideoChaptersRequest: replaceVideoChaptersRequest) { (response, error) in
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
 **replaceVideoChaptersRequest** | [**ReplaceVideoChaptersRequest**](ReplaceVideoChaptersRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

