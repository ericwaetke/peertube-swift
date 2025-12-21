# VideoTranscodingAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1VideosIdStudioEditPost**](VideoTranscodingAPI.md#apiv1videosidstudioeditpost) | **POST** /api/v1/videos/{id}/studio/edit | Create a studio task
[**createVideoTranscoding**](VideoTranscodingAPI.md#createvideotranscoding) | **POST** /api/v1/videos/{id}/transcoding | Create a transcoding job


# **apiV1VideosIdStudioEditPost**
```swift
    open class func apiV1VideosIdStudioEditPost(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Create a studio task

Create a task to edit a video  (cut, add intro/outro etc)

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid

// Create a studio task
VideoTranscodingAPI.apiV1VideosIdStudioEditPost(id: id) { (response, error) in
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

 - **Content-Type**: multipart/form-data
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createVideoTranscoding**
```swift
    open class func createVideoTranscoding(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, createVideoTranscodingRequest: CreateVideoTranscodingRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Create a transcoding job

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let createVideoTranscodingRequest = createVideoTranscoding_request(transcodingType: "transcodingType_example", forceTranscoding: false) // CreateVideoTranscodingRequest |  (optional)

// Create a transcoding job
VideoTranscodingAPI.createVideoTranscoding(id: id, createVideoTranscodingRequest: createVideoTranscodingRequest) { (response, error) in
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
 **createVideoTranscodingRequest** | [**CreateVideoTranscodingRequest**](CreateVideoTranscodingRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

