# LiveVideosAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addLive**](LiveVideosAPI.md#addlive) | **POST** /api/v1/videos/live | Create a live
[**apiV1VideosIdLiveSessionGet**](LiveVideosAPI.md#apiv1videosidlivesessionget) | **GET** /api/v1/videos/{id}/live-session | Get live session of a replay
[**apiV1VideosLiveIdSessionsGet**](LiveVideosAPI.md#apiv1videosliveidsessionsget) | **GET** /api/v1/videos/live/{id}/sessions | List live sessions
[**getLiveId**](LiveVideosAPI.md#getliveid) | **GET** /api/v1/videos/live/{id} | Get information about a live
[**updateLiveId**](LiveVideosAPI.md#updateliveid) | **PUT** /api/v1/videos/live/{id} | Update information about a live


# **addLive**
```swift
    open class func addLive(channelId: Int, name: String, saveReplay: Bool? = nil, replaySettings: LiveVideoReplaySettings? = nil, permanentLive: Bool? = nil, latencyMode: LiveVideoLatencyMode? = nil, thumbnailfile: URL? = nil, previewfile: URL? = nil, privacy: VideoPrivacySet? = nil, category: Int? = nil, licence: Int? = nil, language: String? = nil, description: String? = nil, support: String? = nil, nsfw: Bool? = nil, nsfwSummary: JSONValue? = nil, nsfwFlags: NSFWFlag? = nil, tags: [String]? = nil, commentsPolicy: VideoCommentsPolicySet? = nil, downloadEnabled: Bool? = nil, schedules: [LiveSchedule]? = nil, completion: @escaping (_ data: VideoUploadResponse?, _ error: Error?) -> Void)
```

Create a live

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let channelId = 987 // Int | Channel id that will contain this live video
let name = "name_example" // String | Live video/replay name
let saveReplay = true // Bool |  (optional)
let replaySettings = LiveVideoReplaySettings(privacy: VideoPrivacySet()) // LiveVideoReplaySettings |  (optional)
let permanentLive = true // Bool | User can stream multiple times in a permanent live (optional)
let latencyMode = LiveVideoLatencyMode() // LiveVideoLatencyMode | User can select live latency mode if enabled by the instance (optional)
let thumbnailfile = URL(string: "https://example.com")! // URL | Live video/replay thumbnail file (optional)
let previewfile = URL(string: "https://example.com")! // URL | Live video/replay preview file (optional)
let privacy = VideoPrivacySet() // VideoPrivacySet |  (optional)
let category = 987 // Int | category id of the video (see [/videos/categories](#operation/getCategories)) (optional)
let licence = 987 // Int | licence id of the video (see [/videos/licences](#operation/getLicences)) (optional)
let language = "language_example" // String | language id of the video (see [/videos/languages](#operation/getLanguages)) (optional)
let description = "description_example" // String | Live video/replay description (optional)
let support = "support_example" // String | A text tell the audience how to support the creator (optional)
let nsfw = true // Bool | Whether or not this live video/replay contains sensitive content (optional)
let nsfwSummary =  // JSONValue | More information about the sensitive content of the video (optional)
let nsfwFlags = NSFWFlag() // NSFWFlag |  (optional)
let tags = ["inner_example"] // [String] | Live video/replay tags (maximum 5 tags each between 2 and 30 characters) (optional)
let commentsPolicy = VideoCommentsPolicySet() // VideoCommentsPolicySet |  (optional)
let downloadEnabled = true // Bool | Enable or disable downloading for the replay of this live video (optional)
let schedules = [LiveSchedule(startAt: Date())] // [LiveSchedule] |  (optional)

// Create a live
LiveVideosAPI.addLive(channelId: channelId, name: name, saveReplay: saveReplay, replaySettings: replaySettings, permanentLive: permanentLive, latencyMode: latencyMode, thumbnailfile: thumbnailfile, previewfile: previewfile, privacy: privacy, category: category, licence: licence, language: language, description: description, support: support, nsfw: nsfw, nsfwSummary: nsfwSummary, nsfwFlags: nsfwFlags, tags: tags, commentsPolicy: commentsPolicy, downloadEnabled: downloadEnabled, schedules: schedules) { (response, error) in
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
 **channelId** | **Int** | Channel id that will contain this live video | 
 **name** | **String** | Live video/replay name | 
 **saveReplay** | **Bool** |  | [optional] 
 **replaySettings** | [**LiveVideoReplaySettings**](LiveVideoReplaySettings.md) |  | [optional] 
 **permanentLive** | **Bool** | User can stream multiple times in a permanent live | [optional] 
 **latencyMode** | [**LiveVideoLatencyMode**](LiveVideoLatencyMode.md) | User can select live latency mode if enabled by the instance | [optional] 
 **thumbnailfile** | **URL** | Live video/replay thumbnail file | [optional] 
 **previewfile** | **URL** | Live video/replay preview file | [optional] 
 **privacy** | [**VideoPrivacySet**](VideoPrivacySet.md) |  | [optional] 
 **category** | **Int** | category id of the video (see [/videos/categories](#operation/getCategories)) | [optional] 
 **licence** | **Int** | licence id of the video (see [/videos/licences](#operation/getLicences)) | [optional] 
 **language** | **String** | language id of the video (see [/videos/languages](#operation/getLanguages)) | [optional] 
 **description** | **String** | Live video/replay description | [optional] 
 **support** | **String** | A text tell the audience how to support the creator | [optional] 
 **nsfw** | **Bool** | Whether or not this live video/replay contains sensitive content | [optional] 
 **nsfwSummary** | [**JSONValue**](JSONValue.md) | More information about the sensitive content of the video | [optional] 
 **nsfwFlags** | [**NSFWFlag**](NSFWFlag.md) |  | [optional] 
 **tags** | [**[String]**](String.md) | Live video/replay tags (maximum 5 tags each between 2 and 30 characters) | [optional] 
 **commentsPolicy** | [**VideoCommentsPolicySet**](VideoCommentsPolicySet.md) |  | [optional] 
 **downloadEnabled** | **Bool** | Enable or disable downloading for the replay of this live video | [optional] 
 **schedules** | [**[LiveSchedule]**](LiveSchedule.md) |  | [optional] 

### Return type

[**VideoUploadResponse**](VideoUploadResponse.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1VideosIdLiveSessionGet**
```swift
    open class func apiV1VideosIdLiveSessionGet(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, xPeertubeVideoPassword: String? = nil, completion: @escaping (_ data: LiveVideoSessionResponse?, _ error: Error?) -> Void)
```

Get live session of a replay

If the video is a replay of a live, you can find the associated live session using this endpoint

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let xPeertubeVideoPassword = "xPeertubeVideoPassword_example" // String | Required on password protected video (optional)

// Get live session of a replay
LiveVideosAPI.apiV1VideosIdLiveSessionGet(id: id, xPeertubeVideoPassword: xPeertubeVideoPassword) { (response, error) in
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

[**LiveVideoSessionResponse**](LiveVideoSessionResponse.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1VideosLiveIdSessionsGet**
```swift
    open class func apiV1VideosLiveIdSessionsGet(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, sort: String? = nil, completion: @escaping (_ data: ApiV1VideosLiveIdSessionsGet200Response?, _ error: Error?) -> Void)
```

List live sessions

List all sessions created in a particular live

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let sort = "sort_example" // String | Sort column (optional)

// List live sessions
LiveVideosAPI.apiV1VideosLiveIdSessionsGet(id: id, sort: sort) { (response, error) in
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
 **sort** | **String** | Sort column | [optional] 

### Return type

[**ApiV1VideosLiveIdSessionsGet200Response**](ApiV1VideosLiveIdSessionsGet200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLiveId**
```swift
    open class func getLiveId(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, completion: @escaping (_ data: LiveVideoResponse?, _ error: Error?) -> Void)
```

Get information about a live

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid

// Get information about a live
LiveVideosAPI.getLiveId(id: id) { (response, error) in
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

[**LiveVideoResponse**](LiveVideoResponse.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateLiveId**
```swift
    open class func updateLiveId(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, liveVideoUpdate: LiveVideoUpdate? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Update information about a live

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let liveVideoUpdate = LiveVideoUpdate(saveReplay: false, replaySettings: LiveVideoReplaySettings(privacy: VideoPrivacySet()), permanentLive: false, latencyMode: LiveVideoLatencyMode(), schedules: [LiveSchedule(startAt: Date())]) // LiveVideoUpdate |  (optional)

// Update information about a live
LiveVideosAPI.updateLiveId(id: id, liveVideoUpdate: liveVideoUpdate) { (response, error) in
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
 **liveVideoUpdate** | [**LiveVideoUpdate**](LiveVideoUpdate.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

