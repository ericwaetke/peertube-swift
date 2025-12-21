# VideoFilesAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**delVideoHLS**](VideoFilesAPI.md#delvideohls) | **DELETE** /api/v1/videos/{id}/hls | Delete video HLS files
[**delVideoWebVideos**](VideoFilesAPI.md#delvideowebvideos) | **DELETE** /api/v1/videos/{id}/web-videos | Delete video Web Video files


# **delVideoHLS**
```swift
    open class func delVideoHLS(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete video HLS files

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid

// Delete video HLS files
VideoFilesAPI.delVideoHLS(id: id) { (response, error) in
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

# **delVideoWebVideos**
```swift
    open class func delVideoWebVideos(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete video Web Video files

**PeerTube >= 6.0**

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid

// Delete video Web Video files
VideoFilesAPI.delVideoWebVideos(id: id) { (response, error) in
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

