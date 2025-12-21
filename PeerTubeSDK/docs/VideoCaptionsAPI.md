# VideoCaptionsAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addVideoCaption**](VideoCaptionsAPI.md#addvideocaption) | **PUT** /api/v1/videos/{id}/captions/{captionLanguage} | Add or replace a video caption
[**delVideoCaption**](VideoCaptionsAPI.md#delvideocaption) | **DELETE** /api/v1/videos/{id}/captions/{captionLanguage} | Delete a video caption
[**generateVideoCaption**](VideoCaptionsAPI.md#generatevideocaption) | **POST** /api/v1/videos/{id}/captions/generate | Generate a video caption
[**getVideoCaptions**](VideoCaptionsAPI.md#getvideocaptions) | **GET** /api/v1/videos/{id}/captions | List captions of a video


# **addVideoCaption**
```swift
    open class func addVideoCaption(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, captionLanguage: String, captionfile: URL? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Add or replace a video caption

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let captionLanguage = "captionLanguage_example" // String | The caption language
let captionfile = URL(string: "https://example.com")! // URL | The file to upload. (optional)

// Add or replace a video caption
VideoCaptionsAPI.addVideoCaption(id: id, captionLanguage: captionLanguage, captionfile: captionfile) { (response, error) in
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
 **captionLanguage** | **String** | The caption language | 
 **captionfile** | **URL** | The file to upload. | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **delVideoCaption**
```swift
    open class func delVideoCaption(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, captionLanguage: String, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete a video caption

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let captionLanguage = "captionLanguage_example" // String | The caption language

// Delete a video caption
VideoCaptionsAPI.delVideoCaption(id: id, captionLanguage: captionLanguage) { (response, error) in
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
 **captionLanguage** | **String** | The caption language | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **generateVideoCaption**
```swift
    open class func generateVideoCaption(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, generateVideoCaptionRequest: GenerateVideoCaptionRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Generate a video caption

**PeerTube >= 6.2** This feature has to be enabled by the administrator

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let generateVideoCaptionRequest = generateVideoCaption_request(forceTranscription: false) // GenerateVideoCaptionRequest |  (optional)

// Generate a video caption
VideoCaptionsAPI.generateVideoCaption(id: id, generateVideoCaptionRequest: generateVideoCaptionRequest) { (response, error) in
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
 **generateVideoCaptionRequest** | [**GenerateVideoCaptionRequest**](GenerateVideoCaptionRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getVideoCaptions**
```swift
    open class func getVideoCaptions(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, xPeertubeVideoPassword: String? = nil, completion: @escaping (_ data: GetVideoCaptions200Response?, _ error: Error?) -> Void)
```

List captions of a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let xPeertubeVideoPassword = "xPeertubeVideoPassword_example" // String | Required on password protected video (optional)

// List captions of a video
VideoCaptionsAPI.getVideoCaptions(id: id, xPeertubeVideoPassword: xPeertubeVideoPassword) { (response, error) in
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

[**GetVideoCaptions200Response**](GetVideoCaptions200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

