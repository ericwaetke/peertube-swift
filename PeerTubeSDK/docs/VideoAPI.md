# VideoAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addLive**](VideoAPI.md#addlive) | **POST** /api/v1/videos/live | Create a live
[**addView**](VideoAPI.md#addview) | **POST** /api/v1/videos/{id}/views | Notify user is watching a video
[**apiV1VideosIdStudioEditPost**](VideoAPI.md#apiv1videosidstudioeditpost) | **POST** /api/v1/videos/{id}/studio/edit | Create a studio task
[**delVideo**](VideoAPI.md#delvideo) | **DELETE** /api/v1/videos/{id} | Delete a video
[**deleteVideoSourceFile**](VideoAPI.md#deletevideosourcefile) | **DELETE** /api/v1/videos/{id}/source/file | Delete video source file
[**getAccountVideos**](VideoAPI.md#getaccountvideos) | **GET** /api/v1/accounts/{name}/videos | List videos of an account
[**getCategories**](VideoAPI.md#getcategories) | **GET** /api/v1/videos/categories | List available video categories
[**getLanguages**](VideoAPI.md#getlanguages) | **GET** /api/v1/videos/languages | List available video languages
[**getLicences**](VideoAPI.md#getlicences) | **GET** /api/v1/videos/licences | List available video licences
[**getLiveId**](VideoAPI.md#getliveid) | **GET** /api/v1/videos/live/{id} | Get information about a live
[**getVideo**](VideoAPI.md#getvideo) | **GET** /api/v1/videos/{id} | Get a video
[**getVideoChannelVideos**](VideoAPI.md#getvideochannelvideos) | **GET** /api/v1/video-channels/{channelHandle}/videos | List videos of a video channel
[**getVideoDesc**](VideoAPI.md#getvideodesc) | **GET** /api/v1/videos/{id}/description | Get complete video description
[**getVideoPrivacyPolicies**](VideoAPI.md#getvideoprivacypolicies) | **GET** /api/v1/videos/privacies | List available video privacy policies
[**getVideoSource**](VideoAPI.md#getvideosource) | **GET** /api/v1/videos/{id}/source | Get video source file metadata
[**getVideos**](VideoAPI.md#getvideos) | **GET** /api/v1/videos | List videos
[**listVideoStoryboards**](VideoAPI.md#listvideostoryboards) | **GET** /api/v1/videos/{id}/storyboards | List storyboards of a video
[**putVideo**](VideoAPI.md#putvideo) | **PUT** /api/v1/videos/{id} | Update a video
[**replaceVideoSourceResumable**](VideoAPI.md#replacevideosourceresumable) | **PUT** /api/v1/videos/{id}/source/replace-resumable | Send chunk for the resumable replacement of a video
[**replaceVideoSourceResumableCancel**](VideoAPI.md#replacevideosourceresumablecancel) | **DELETE** /api/v1/videos/{id}/source/replace-resumable | Cancel the resumable replacement of a video
[**replaceVideoSourceResumableInit**](VideoAPI.md#replacevideosourceresumableinit) | **POST** /api/v1/videos/{id}/source/replace-resumable | Initialize the resumable replacement of a video
[**requestVideoToken**](VideoAPI.md#requestvideotoken) | **POST** /api/v1/videos/{id}/token | Request video token
[**searchVideos**](VideoAPI.md#searchvideos) | **GET** /api/v1/search/videos | Search videos
[**updateLiveId**](VideoAPI.md#updateliveid) | **PUT** /api/v1/videos/live/{id} | Update information about a live
[**uploadLegacy**](VideoAPI.md#uploadlegacy) | **POST** /api/v1/videos/upload | Upload a video
[**uploadResumable**](VideoAPI.md#uploadresumable) | **PUT** /api/v1/videos/upload-resumable | Send chunk for the resumable upload of a video
[**uploadResumableCancel**](VideoAPI.md#uploadresumablecancel) | **DELETE** /api/v1/videos/upload-resumable | Cancel the resumable upload of a video, deleting any data uploaded so far
[**uploadResumableInit**](VideoAPI.md#uploadresumableinit) | **POST** /api/v1/videos/upload-resumable | Initialize the resumable upload of a video


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
VideoAPI.addLive(channelId: channelId, name: name, saveReplay: saveReplay, replaySettings: replaySettings, permanentLive: permanentLive, latencyMode: latencyMode, thumbnailfile: thumbnailfile, previewfile: previewfile, privacy: privacy, category: category, licence: licence, language: language, description: description, support: support, nsfw: nsfw, nsfwSummary: nsfwSummary, nsfwFlags: nsfwFlags, tags: tags, commentsPolicy: commentsPolicy, downloadEnabled: downloadEnabled, schedules: schedules) { (response, error) in
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

# **addView**
```swift
    open class func addView(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, userViewingVideo: UserViewingVideo, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Notify user is watching a video

Call this endpoint regularly (every 5-10 seconds for example) to notify the server the user is watching the video. After a while, PeerTube will increase video's viewers counter. If the user is authenticated, PeerTube will also store the current player time.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let userViewingVideo = UserViewingVideo(currentTime: 123, viewEvent: "viewEvent_example", sessionId: "sessionId_example", client: "client_example", device: VideoStatsUserAgentDevice(), operatingSystem: "operatingSystem_example") // UserViewingVideo | 

// Notify user is watching a video
VideoAPI.addView(id: id, userViewingVideo: userViewingVideo) { (response, error) in
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
 **userViewingVideo** | [**UserViewingVideo**](UserViewingVideo.md) |  | 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

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
VideoAPI.apiV1VideosIdStudioEditPost(id: id) { (response, error) in
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

# **delVideo**
```swift
    open class func delVideo(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid

// Delete a video
VideoAPI.delVideo(id: id) { (response, error) in
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

# **deleteVideoSourceFile**
```swift
    open class func deleteVideoSourceFile(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete video source file

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid

// Delete video source file
VideoAPI.deleteVideoSourceFile(id: id) { (response, error) in
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

# **getAccountVideos**
```swift
    open class func getAccountVideos(name: String, start: Int? = nil, count: Int? = nil, skipCount: SkipCount_getAccountVideos? = nil, sort: Sort_getAccountVideos? = nil, nsfw: Nsfw_getAccountVideos? = nil, nsfwFlagsIncluded: NSFWFlag? = nil, nsfwFlagsExcluded: NSFWFlag? = nil, isLive: Bool? = nil, includeScheduledLive: Bool? = nil, categoryOneOf: GetAccountVideosCategoryOneOfParameter? = nil, licenceOneOf: GetAccountVideosLicenceOneOfParameter? = nil, languageOneOf: GetAccountVideosLanguageOneOfParameter? = nil, tagsOneOf: GetAccountVideosTagsOneOfParameter? = nil, tagsAllOf: GetAccountVideosTagsAllOfParameter? = nil, isLocal: Bool? = nil, include: Include_getAccountVideos? = nil, hasHLSFiles: Bool? = nil, hasWebVideoFiles: Bool? = nil, host: String? = nil, autoTagOneOf: GetAccountVideosTagsAllOfParameter? = nil, privacyOneOf: VideoPrivacySet? = nil, excludeAlreadyWatched: Bool? = nil, search: String? = nil, completion: @escaping (_ data: VideoListResponse?, _ error: Error?) -> Void)
```

List videos of an account

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let name = "name_example" // String | The username or handle of the account
let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let skipCount = "skipCount_example" // String | if you don't need the `total` in the response (optional) (default to ._false)
let sort = "sort_example" // String |  (optional)
let nsfw = "nsfw_example" // String | whether to include nsfw videos, if any (optional)
let nsfwFlagsIncluded = NSFWFlag() // NSFWFlag |  (optional)
let nsfwFlagsExcluded = NSFWFlag() // NSFWFlag |  (optional)
let isLive = true // Bool | whether or not the video is a live (optional)
let includeScheduledLive = true // Bool | whether or not include live that are scheduled for later (optional)
let categoryOneOf = getAccountVideos_categoryOneOf_parameter() // GetAccountVideosCategoryOneOfParameter | category id of the video (see [/videos/categories](#operation/getCategories)) (optional)
let licenceOneOf = getAccountVideos_licenceOneOf_parameter() // GetAccountVideosLicenceOneOfParameter | licence id of the video (see [/videos/licences](#operation/getLicences)) (optional)
let languageOneOf = getAccountVideos_languageOneOf_parameter() // GetAccountVideosLanguageOneOfParameter | language id of the video (see [/videos/languages](#operation/getLanguages)). Use `_unknown` to filter on videos that don't have a video language (optional)
let tagsOneOf = getAccountVideos_tagsOneOf_parameter() // GetAccountVideosTagsOneOfParameter | tag(s) of the video (optional)
let tagsAllOf = getAccountVideos_tagsAllOf_parameter() // GetAccountVideosTagsAllOfParameter | tag(s) of the video, where all should be present in the video (optional)
let isLocal = true // Bool | **PeerTube >= 4.0** Display only local or remote objects (optional)
let include = 987 // Int | **Only administrators and moderators can use this parameter**  Include additional videos in results (can be combined using bitwise or operator) - `0` NONE - `1` NOT_PUBLISHED_STATE - `2` BLACKLISTED - `4` BLOCKED_OWNER - `8` FILES - `16` CAPTIONS - `32` VIDEO SOURCE  (optional)
let hasHLSFiles = true // Bool | **PeerTube >= 4.0** Display only videos that have HLS files (optional)
let hasWebVideoFiles = true // Bool | **PeerTube >= 6.0** Display only videos that have Web Video files (optional)
let host = "host_example" // String | Find elements owned by this host (optional)
let autoTagOneOf = getAccountVideos_tagsAllOf_parameter() // GetAccountVideosTagsAllOfParameter | **PeerTube >= 6.2** **Admins and moderators only** filter on videos that contain one of these automatic tags (optional)
let privacyOneOf = VideoPrivacySet() // VideoPrivacySet | **PeerTube >= 4.0** Display only videos in this specific privacy/privacies (optional)
let excludeAlreadyWatched = true // Bool | Whether or not to exclude videos that are in the user's video history (optional)
let search = "search_example" // String | Plain text search, applied to various parts of the model depending on endpoint (optional)

// List videos of an account
VideoAPI.getAccountVideos(name: name, start: start, count: count, skipCount: skipCount, sort: sort, nsfw: nsfw, nsfwFlagsIncluded: nsfwFlagsIncluded, nsfwFlagsExcluded: nsfwFlagsExcluded, isLive: isLive, includeScheduledLive: includeScheduledLive, categoryOneOf: categoryOneOf, licenceOneOf: licenceOneOf, languageOneOf: languageOneOf, tagsOneOf: tagsOneOf, tagsAllOf: tagsAllOf, isLocal: isLocal, include: include, hasHLSFiles: hasHLSFiles, hasWebVideoFiles: hasWebVideoFiles, host: host, autoTagOneOf: autoTagOneOf, privacyOneOf: privacyOneOf, excludeAlreadyWatched: excludeAlreadyWatched, search: search) { (response, error) in
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
 **name** | **String** | The username or handle of the account | 
 **start** | **Int** | Offset used to paginate results | [optional] 
 **count** | **Int** | Number of items to return | [optional] [default to 15]
 **skipCount** | **String** | if you don&#39;t need the &#x60;total&#x60; in the response | [optional] [default to ._false]
 **sort** | **String** |  | [optional] 
 **nsfw** | **String** | whether to include nsfw videos, if any | [optional] 
 **nsfwFlagsIncluded** | [**NSFWFlag**](.md) |  | [optional] 
 **nsfwFlagsExcluded** | [**NSFWFlag**](.md) |  | [optional] 
 **isLive** | **Bool** | whether or not the video is a live | [optional] 
 **includeScheduledLive** | **Bool** | whether or not include live that are scheduled for later | [optional] 
 **categoryOneOf** | [**GetAccountVideosCategoryOneOfParameter**](.md) | category id of the video (see [/videos/categories](#operation/getCategories)) | [optional] 
 **licenceOneOf** | [**GetAccountVideosLicenceOneOfParameter**](.md) | licence id of the video (see [/videos/licences](#operation/getLicences)) | [optional] 
 **languageOneOf** | [**GetAccountVideosLanguageOneOfParameter**](.md) | language id of the video (see [/videos/languages](#operation/getLanguages)). Use &#x60;_unknown&#x60; to filter on videos that don&#39;t have a video language | [optional] 
 **tagsOneOf** | [**GetAccountVideosTagsOneOfParameter**](.md) | tag(s) of the video | [optional] 
 **tagsAllOf** | [**GetAccountVideosTagsAllOfParameter**](.md) | tag(s) of the video, where all should be present in the video | [optional] 
 **isLocal** | **Bool** | **PeerTube &gt;&#x3D; 4.0** Display only local or remote objects | [optional] 
 **include** | **Int** | **Only administrators and moderators can use this parameter**  Include additional videos in results (can be combined using bitwise or operator) - &#x60;0&#x60; NONE - &#x60;1&#x60; NOT_PUBLISHED_STATE - &#x60;2&#x60; BLACKLISTED - &#x60;4&#x60; BLOCKED_OWNER - &#x60;8&#x60; FILES - &#x60;16&#x60; CAPTIONS - &#x60;32&#x60; VIDEO SOURCE  | [optional] 
 **hasHLSFiles** | **Bool** | **PeerTube &gt;&#x3D; 4.0** Display only videos that have HLS files | [optional] 
 **hasWebVideoFiles** | **Bool** | **PeerTube &gt;&#x3D; 6.0** Display only videos that have Web Video files | [optional] 
 **host** | **String** | Find elements owned by this host | [optional] 
 **autoTagOneOf** | [**GetAccountVideosTagsAllOfParameter**](.md) | **PeerTube &gt;&#x3D; 6.2** **Admins and moderators only** filter on videos that contain one of these automatic tags | [optional] 
 **privacyOneOf** | [**VideoPrivacySet**](.md) | **PeerTube &gt;&#x3D; 4.0** Display only videos in this specific privacy/privacies | [optional] 
 **excludeAlreadyWatched** | **Bool** | Whether or not to exclude videos that are in the user&#39;s video history | [optional] 
 **search** | **String** | Plain text search, applied to various parts of the model depending on endpoint | [optional] 

### Return type

[**VideoListResponse**](VideoListResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCategories**
```swift
    open class func getCategories(completion: @escaping (_ data: [String]?, _ error: Error?) -> Void)
```

List available video categories

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// List available video categories
VideoAPI.getCategories() { (response, error) in
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
This endpoint does not need any parameter.

### Return type

**[String]**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLanguages**
```swift
    open class func getLanguages(completion: @escaping (_ data: [String]?, _ error: Error?) -> Void)
```

List available video languages

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// List available video languages
VideoAPI.getLanguages() { (response, error) in
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
This endpoint does not need any parameter.

### Return type

**[String]**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLicences**
```swift
    open class func getLicences(completion: @escaping (_ data: [String]?, _ error: Error?) -> Void)
```

List available video licences

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// List available video licences
VideoAPI.getLicences() { (response, error) in
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
This endpoint does not need any parameter.

### Return type

**[String]**

### Authorization

No authorization required

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
VideoAPI.getLiveId(id: id) { (response, error) in
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

# **getVideo**
```swift
    open class func getVideo(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, xPeertubeVideoPassword: String? = nil, completion: @escaping (_ data: VideoDetails?, _ error: Error?) -> Void)
```

Get a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let xPeertubeVideoPassword = "xPeertubeVideoPassword_example" // String | Required on password protected video (optional)

// Get a video
VideoAPI.getVideo(id: id, xPeertubeVideoPassword: xPeertubeVideoPassword) { (response, error) in
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

[**VideoDetails**](VideoDetails.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getVideoChannelVideos**
```swift
    open class func getVideoChannelVideos(channelHandle: String, start: Int? = nil, count: Int? = nil, skipCount: SkipCount_getVideoChannelVideos? = nil, sort: Sort_getVideoChannelVideos? = nil, nsfw: Nsfw_getVideoChannelVideos? = nil, nsfwFlagsIncluded: NSFWFlag? = nil, nsfwFlagsExcluded: NSFWFlag? = nil, isLive: Bool? = nil, includeScheduledLive: Bool? = nil, categoryOneOf: GetAccountVideosCategoryOneOfParameter? = nil, licenceOneOf: GetAccountVideosLicenceOneOfParameter? = nil, languageOneOf: GetAccountVideosLanguageOneOfParameter? = nil, tagsOneOf: GetAccountVideosTagsOneOfParameter? = nil, tagsAllOf: GetAccountVideosTagsAllOfParameter? = nil, isLocal: Bool? = nil, include: Include_getVideoChannelVideos? = nil, hasHLSFiles: Bool? = nil, hasWebVideoFiles: Bool? = nil, host: String? = nil, autoTagOneOf: GetAccountVideosTagsAllOfParameter? = nil, privacyOneOf: VideoPrivacySet? = nil, excludeAlreadyWatched: Bool? = nil, search: String? = nil, completion: @escaping (_ data: VideoListResponse?, _ error: Error?) -> Void)
```

List videos of a video channel

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let channelHandle = "channelHandle_example" // String | The video channel handle
let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let skipCount = "skipCount_example" // String | if you don't need the `total` in the response (optional) (default to ._false)
let sort = "sort_example" // String |  (optional)
let nsfw = "nsfw_example" // String | whether to include nsfw videos, if any (optional)
let nsfwFlagsIncluded = NSFWFlag() // NSFWFlag |  (optional)
let nsfwFlagsExcluded = NSFWFlag() // NSFWFlag |  (optional)
let isLive = true // Bool | whether or not the video is a live (optional)
let includeScheduledLive = true // Bool | whether or not include live that are scheduled for later (optional)
let categoryOneOf = getAccountVideos_categoryOneOf_parameter() // GetAccountVideosCategoryOneOfParameter | category id of the video (see [/videos/categories](#operation/getCategories)) (optional)
let licenceOneOf = getAccountVideos_licenceOneOf_parameter() // GetAccountVideosLicenceOneOfParameter | licence id of the video (see [/videos/licences](#operation/getLicences)) (optional)
let languageOneOf = getAccountVideos_languageOneOf_parameter() // GetAccountVideosLanguageOneOfParameter | language id of the video (see [/videos/languages](#operation/getLanguages)). Use `_unknown` to filter on videos that don't have a video language (optional)
let tagsOneOf = getAccountVideos_tagsOneOf_parameter() // GetAccountVideosTagsOneOfParameter | tag(s) of the video (optional)
let tagsAllOf = getAccountVideos_tagsAllOf_parameter() // GetAccountVideosTagsAllOfParameter | tag(s) of the video, where all should be present in the video (optional)
let isLocal = true // Bool | **PeerTube >= 4.0** Display only local or remote objects (optional)
let include = 987 // Int | **Only administrators and moderators can use this parameter**  Include additional videos in results (can be combined using bitwise or operator) - `0` NONE - `1` NOT_PUBLISHED_STATE - `2` BLACKLISTED - `4` BLOCKED_OWNER - `8` FILES - `16` CAPTIONS - `32` VIDEO SOURCE  (optional)
let hasHLSFiles = true // Bool | **PeerTube >= 4.0** Display only videos that have HLS files (optional)
let hasWebVideoFiles = true // Bool | **PeerTube >= 6.0** Display only videos that have Web Video files (optional)
let host = "host_example" // String | Find elements owned by this host (optional)
let autoTagOneOf = getAccountVideos_tagsAllOf_parameter() // GetAccountVideosTagsAllOfParameter | **PeerTube >= 6.2** **Admins and moderators only** filter on videos that contain one of these automatic tags (optional)
let privacyOneOf = VideoPrivacySet() // VideoPrivacySet | **PeerTube >= 4.0** Display only videos in this specific privacy/privacies (optional)
let excludeAlreadyWatched = true // Bool | Whether or not to exclude videos that are in the user's video history (optional)
let search = "search_example" // String | Plain text search, applied to various parts of the model depending on endpoint (optional)

// List videos of a video channel
VideoAPI.getVideoChannelVideos(channelHandle: channelHandle, start: start, count: count, skipCount: skipCount, sort: sort, nsfw: nsfw, nsfwFlagsIncluded: nsfwFlagsIncluded, nsfwFlagsExcluded: nsfwFlagsExcluded, isLive: isLive, includeScheduledLive: includeScheduledLive, categoryOneOf: categoryOneOf, licenceOneOf: licenceOneOf, languageOneOf: languageOneOf, tagsOneOf: tagsOneOf, tagsAllOf: tagsAllOf, isLocal: isLocal, include: include, hasHLSFiles: hasHLSFiles, hasWebVideoFiles: hasWebVideoFiles, host: host, autoTagOneOf: autoTagOneOf, privacyOneOf: privacyOneOf, excludeAlreadyWatched: excludeAlreadyWatched, search: search) { (response, error) in
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
 **channelHandle** | **String** | The video channel handle | 
 **start** | **Int** | Offset used to paginate results | [optional] 
 **count** | **Int** | Number of items to return | [optional] [default to 15]
 **skipCount** | **String** | if you don&#39;t need the &#x60;total&#x60; in the response | [optional] [default to ._false]
 **sort** | **String** |  | [optional] 
 **nsfw** | **String** | whether to include nsfw videos, if any | [optional] 
 **nsfwFlagsIncluded** | [**NSFWFlag**](.md) |  | [optional] 
 **nsfwFlagsExcluded** | [**NSFWFlag**](.md) |  | [optional] 
 **isLive** | **Bool** | whether or not the video is a live | [optional] 
 **includeScheduledLive** | **Bool** | whether or not include live that are scheduled for later | [optional] 
 **categoryOneOf** | [**GetAccountVideosCategoryOneOfParameter**](.md) | category id of the video (see [/videos/categories](#operation/getCategories)) | [optional] 
 **licenceOneOf** | [**GetAccountVideosLicenceOneOfParameter**](.md) | licence id of the video (see [/videos/licences](#operation/getLicences)) | [optional] 
 **languageOneOf** | [**GetAccountVideosLanguageOneOfParameter**](.md) | language id of the video (see [/videos/languages](#operation/getLanguages)). Use &#x60;_unknown&#x60; to filter on videos that don&#39;t have a video language | [optional] 
 **tagsOneOf** | [**GetAccountVideosTagsOneOfParameter**](.md) | tag(s) of the video | [optional] 
 **tagsAllOf** | [**GetAccountVideosTagsAllOfParameter**](.md) | tag(s) of the video, where all should be present in the video | [optional] 
 **isLocal** | **Bool** | **PeerTube &gt;&#x3D; 4.0** Display only local or remote objects | [optional] 
 **include** | **Int** | **Only administrators and moderators can use this parameter**  Include additional videos in results (can be combined using bitwise or operator) - &#x60;0&#x60; NONE - &#x60;1&#x60; NOT_PUBLISHED_STATE - &#x60;2&#x60; BLACKLISTED - &#x60;4&#x60; BLOCKED_OWNER - &#x60;8&#x60; FILES - &#x60;16&#x60; CAPTIONS - &#x60;32&#x60; VIDEO SOURCE  | [optional] 
 **hasHLSFiles** | **Bool** | **PeerTube &gt;&#x3D; 4.0** Display only videos that have HLS files | [optional] 
 **hasWebVideoFiles** | **Bool** | **PeerTube &gt;&#x3D; 6.0** Display only videos that have Web Video files | [optional] 
 **host** | **String** | Find elements owned by this host | [optional] 
 **autoTagOneOf** | [**GetAccountVideosTagsAllOfParameter**](.md) | **PeerTube &gt;&#x3D; 6.2** **Admins and moderators only** filter on videos that contain one of these automatic tags | [optional] 
 **privacyOneOf** | [**VideoPrivacySet**](.md) | **PeerTube &gt;&#x3D; 4.0** Display only videos in this specific privacy/privacies | [optional] 
 **excludeAlreadyWatched** | **Bool** | Whether or not to exclude videos that are in the user&#39;s video history | [optional] 
 **search** | **String** | Plain text search, applied to various parts of the model depending on endpoint | [optional] 

### Return type

[**VideoListResponse**](VideoListResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getVideoDesc**
```swift
    open class func getVideoDesc(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, xPeertubeVideoPassword: String? = nil, completion: @escaping (_ data: String?, _ error: Error?) -> Void)
```

Get complete video description

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let xPeertubeVideoPassword = "xPeertubeVideoPassword_example" // String | Required on password protected video (optional)

// Get complete video description
VideoAPI.getVideoDesc(id: id, xPeertubeVideoPassword: xPeertubeVideoPassword) { (response, error) in
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

**String**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getVideoPrivacyPolicies**
```swift
    open class func getVideoPrivacyPolicies(completion: @escaping (_ data: [String]?, _ error: Error?) -> Void)
```

List available video privacy policies

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// List available video privacy policies
VideoAPI.getVideoPrivacyPolicies() { (response, error) in
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
This endpoint does not need any parameter.

### Return type

**[String]**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getVideoSource**
```swift
    open class func getVideoSource(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, completion: @escaping (_ data: VideoSource?, _ error: Error?) -> Void)
```

Get video source file metadata

Get metadata and download link of original video file

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid

// Get video source file metadata
VideoAPI.getVideoSource(id: id) { (response, error) in
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

[**VideoSource**](VideoSource.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getVideos**
```swift
    open class func getVideos(start: Int? = nil, count: Int? = nil, skipCount: SkipCount_getVideos? = nil, sort: Sort_getVideos? = nil, nsfw: Nsfw_getVideos? = nil, nsfwFlagsIncluded: NSFWFlag? = nil, nsfwFlagsExcluded: NSFWFlag? = nil, isLive: Bool? = nil, includeScheduledLive: Bool? = nil, categoryOneOf: GetAccountVideosCategoryOneOfParameter? = nil, licenceOneOf: GetAccountVideosLicenceOneOfParameter? = nil, languageOneOf: GetAccountVideosLanguageOneOfParameter? = nil, tagsOneOf: GetAccountVideosTagsOneOfParameter? = nil, tagsAllOf: GetAccountVideosTagsAllOfParameter? = nil, isLocal: Bool? = nil, include: Include_getVideos? = nil, hasHLSFiles: Bool? = nil, hasWebVideoFiles: Bool? = nil, host: String? = nil, autoTagOneOf: GetAccountVideosTagsAllOfParameter? = nil, privacyOneOf: VideoPrivacySet? = nil, excludeAlreadyWatched: Bool? = nil, search: String? = nil, completion: @escaping (_ data: VideoListResponse?, _ error: Error?) -> Void)
```

List videos

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let skipCount = "skipCount_example" // String | if you don't need the `total` in the response (optional) (default to ._false)
let sort = "sort_example" // String |  (optional)
let nsfw = "nsfw_example" // String | whether to include nsfw videos, if any (optional)
let nsfwFlagsIncluded = NSFWFlag() // NSFWFlag |  (optional)
let nsfwFlagsExcluded = NSFWFlag() // NSFWFlag |  (optional)
let isLive = true // Bool | whether or not the video is a live (optional)
let includeScheduledLive = true // Bool | whether or not include live that are scheduled for later (optional)
let categoryOneOf = getAccountVideos_categoryOneOf_parameter() // GetAccountVideosCategoryOneOfParameter | category id of the video (see [/videos/categories](#operation/getCategories)) (optional)
let licenceOneOf = getAccountVideos_licenceOneOf_parameter() // GetAccountVideosLicenceOneOfParameter | licence id of the video (see [/videos/licences](#operation/getLicences)) (optional)
let languageOneOf = getAccountVideos_languageOneOf_parameter() // GetAccountVideosLanguageOneOfParameter | language id of the video (see [/videos/languages](#operation/getLanguages)). Use `_unknown` to filter on videos that don't have a video language (optional)
let tagsOneOf = getAccountVideos_tagsOneOf_parameter() // GetAccountVideosTagsOneOfParameter | tag(s) of the video (optional)
let tagsAllOf = getAccountVideos_tagsAllOf_parameter() // GetAccountVideosTagsAllOfParameter | tag(s) of the video, where all should be present in the video (optional)
let isLocal = true // Bool | **PeerTube >= 4.0** Display only local or remote objects (optional)
let include = 987 // Int | **Only administrators and moderators can use this parameter**  Include additional videos in results (can be combined using bitwise or operator) - `0` NONE - `1` NOT_PUBLISHED_STATE - `2` BLACKLISTED - `4` BLOCKED_OWNER - `8` FILES - `16` CAPTIONS - `32` VIDEO SOURCE  (optional)
let hasHLSFiles = true // Bool | **PeerTube >= 4.0** Display only videos that have HLS files (optional)
let hasWebVideoFiles = true // Bool | **PeerTube >= 6.0** Display only videos that have Web Video files (optional)
let host = "host_example" // String | Find elements owned by this host (optional)
let autoTagOneOf = getAccountVideos_tagsAllOf_parameter() // GetAccountVideosTagsAllOfParameter | **PeerTube >= 6.2** **Admins and moderators only** filter on videos that contain one of these automatic tags (optional)
let privacyOneOf = VideoPrivacySet() // VideoPrivacySet | **PeerTube >= 4.0** Display only videos in this specific privacy/privacies (optional)
let excludeAlreadyWatched = true // Bool | Whether or not to exclude videos that are in the user's video history (optional)
let search = "search_example" // String | Plain text search, applied to various parts of the model depending on endpoint (optional)

// List videos
VideoAPI.getVideos(start: start, count: count, skipCount: skipCount, sort: sort, nsfw: nsfw, nsfwFlagsIncluded: nsfwFlagsIncluded, nsfwFlagsExcluded: nsfwFlagsExcluded, isLive: isLive, includeScheduledLive: includeScheduledLive, categoryOneOf: categoryOneOf, licenceOneOf: licenceOneOf, languageOneOf: languageOneOf, tagsOneOf: tagsOneOf, tagsAllOf: tagsAllOf, isLocal: isLocal, include: include, hasHLSFiles: hasHLSFiles, hasWebVideoFiles: hasWebVideoFiles, host: host, autoTagOneOf: autoTagOneOf, privacyOneOf: privacyOneOf, excludeAlreadyWatched: excludeAlreadyWatched, search: search) { (response, error) in
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
 **start** | **Int** | Offset used to paginate results | [optional] 
 **count** | **Int** | Number of items to return | [optional] [default to 15]
 **skipCount** | **String** | if you don&#39;t need the &#x60;total&#x60; in the response | [optional] [default to ._false]
 **sort** | **String** |  | [optional] 
 **nsfw** | **String** | whether to include nsfw videos, if any | [optional] 
 **nsfwFlagsIncluded** | [**NSFWFlag**](.md) |  | [optional] 
 **nsfwFlagsExcluded** | [**NSFWFlag**](.md) |  | [optional] 
 **isLive** | **Bool** | whether or not the video is a live | [optional] 
 **includeScheduledLive** | **Bool** | whether or not include live that are scheduled for later | [optional] 
 **categoryOneOf** | [**GetAccountVideosCategoryOneOfParameter**](.md) | category id of the video (see [/videos/categories](#operation/getCategories)) | [optional] 
 **licenceOneOf** | [**GetAccountVideosLicenceOneOfParameter**](.md) | licence id of the video (see [/videos/licences](#operation/getLicences)) | [optional] 
 **languageOneOf** | [**GetAccountVideosLanguageOneOfParameter**](.md) | language id of the video (see [/videos/languages](#operation/getLanguages)). Use &#x60;_unknown&#x60; to filter on videos that don&#39;t have a video language | [optional] 
 **tagsOneOf** | [**GetAccountVideosTagsOneOfParameter**](.md) | tag(s) of the video | [optional] 
 **tagsAllOf** | [**GetAccountVideosTagsAllOfParameter**](.md) | tag(s) of the video, where all should be present in the video | [optional] 
 **isLocal** | **Bool** | **PeerTube &gt;&#x3D; 4.0** Display only local or remote objects | [optional] 
 **include** | **Int** | **Only administrators and moderators can use this parameter**  Include additional videos in results (can be combined using bitwise or operator) - &#x60;0&#x60; NONE - &#x60;1&#x60; NOT_PUBLISHED_STATE - &#x60;2&#x60; BLACKLISTED - &#x60;4&#x60; BLOCKED_OWNER - &#x60;8&#x60; FILES - &#x60;16&#x60; CAPTIONS - &#x60;32&#x60; VIDEO SOURCE  | [optional] 
 **hasHLSFiles** | **Bool** | **PeerTube &gt;&#x3D; 4.0** Display only videos that have HLS files | [optional] 
 **hasWebVideoFiles** | **Bool** | **PeerTube &gt;&#x3D; 6.0** Display only videos that have Web Video files | [optional] 
 **host** | **String** | Find elements owned by this host | [optional] 
 **autoTagOneOf** | [**GetAccountVideosTagsAllOfParameter**](.md) | **PeerTube &gt;&#x3D; 6.2** **Admins and moderators only** filter on videos that contain one of these automatic tags | [optional] 
 **privacyOneOf** | [**VideoPrivacySet**](.md) | **PeerTube &gt;&#x3D; 4.0** Display only videos in this specific privacy/privacies | [optional] 
 **excludeAlreadyWatched** | **Bool** | Whether or not to exclude videos that are in the user&#39;s video history | [optional] 
 **search** | **String** | Plain text search, applied to various parts of the model depending on endpoint | [optional] 

### Return type

[**VideoListResponse**](VideoListResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listVideoStoryboards**
```swift
    open class func listVideoStoryboards(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, completion: @escaping (_ data: ListVideoStoryboards200Response?, _ error: Error?) -> Void)
```

List storyboards of a video

**PeerTube >= 6.0**

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid

// List storyboards of a video
VideoAPI.listVideoStoryboards(id: id) { (response, error) in
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

[**ListVideoStoryboards200Response**](ListVideoStoryboards200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putVideo**
```swift
    open class func putVideo(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, channelId: Int? = nil, thumbnailfile: URL? = nil, previewfile: URL? = nil, category: Int? = nil, licence: Int? = nil, language: String? = nil, privacy: VideoPrivacySet? = nil, description: String? = nil, waitTranscoding: String? = nil, support: String? = nil, nsfw: Bool? = nil, nsfwSummary: JSONValue? = nil, nsfwFlags: NSFWFlag? = nil, name: String? = nil, tags: [String]? = nil, commentsPolicy: VideoCommentsPolicySet? = nil, downloadEnabled: Bool? = nil, originallyPublishedAt: Date? = nil, scheduleUpdate: VideoScheduledUpdate? = nil, videoPasswords: Set<String>? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Update a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let channelId = 987 // Int | New channel of the video. The channel must be owned by the same account as the previous one. Use the \\\"change ownership\\\" endpoints to give a video to a channel owned by another account on the local PeerTube instance. (optional)
let thumbnailfile = URL(string: "https://example.com")! // URL | Video thumbnail file (optional)
let previewfile = URL(string: "https://example.com")! // URL | Video preview file (optional)
let category = 987 // Int | category id of the video (see [/videos/categories](#operation/getCategories)) (optional)
let licence = 987 // Int | licence id of the video (see [/videos/licences](#operation/getLicences)) (optional)
let language = "language_example" // String | language id of the video (see [/videos/languages](#operation/getLanguages)) (optional)
let privacy = VideoPrivacySet() // VideoPrivacySet |  (optional)
let description = "description_example" // String | Video description (optional)
let waitTranscoding = "waitTranscoding_example" // String | Whether or not we wait transcoding before publish the video (optional)
let support = "support_example" // String | A text tell the audience how to support the video creator (optional)
let nsfw = true // Bool | Whether or not this video contains sensitive content (optional)
let nsfwSummary =  // JSONValue | More information about the sensitive content of the video (optional)
let nsfwFlags = NSFWFlag() // NSFWFlag |  (optional)
let name = "name_example" // String | Video name (optional)
let tags = ["inner_example"] // [String] | Video tags (maximum 5 tags each between 2 and 30 characters) (optional)
let commentsPolicy = VideoCommentsPolicySet() // VideoCommentsPolicySet |  (optional)
let downloadEnabled = true // Bool | Enable or disable downloading for this video (optional)
let originallyPublishedAt = Date() // Date | Date when the content was originally published (optional)
let scheduleUpdate = VideoScheduledUpdate(privacy: VideoPrivacySet(), updateAt: Date()) // VideoScheduledUpdate |  (optional)
let videoPasswords = ["inner_example"] // Set<String> |  (optional)

// Update a video
VideoAPI.putVideo(id: id, channelId: channelId, thumbnailfile: thumbnailfile, previewfile: previewfile, category: category, licence: licence, language: language, privacy: privacy, description: description, waitTranscoding: waitTranscoding, support: support, nsfw: nsfw, nsfwSummary: nsfwSummary, nsfwFlags: nsfwFlags, name: name, tags: tags, commentsPolicy: commentsPolicy, downloadEnabled: downloadEnabled, originallyPublishedAt: originallyPublishedAt, scheduleUpdate: scheduleUpdate, videoPasswords: videoPasswords) { (response, error) in
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
 **channelId** | **Int** | New channel of the video. The channel must be owned by the same account as the previous one. Use the \\\&quot;change ownership\\\&quot; endpoints to give a video to a channel owned by another account on the local PeerTube instance. | [optional] 
 **thumbnailfile** | **URL** | Video thumbnail file | [optional] 
 **previewfile** | **URL** | Video preview file | [optional] 
 **category** | **Int** | category id of the video (see [/videos/categories](#operation/getCategories)) | [optional] 
 **licence** | **Int** | licence id of the video (see [/videos/licences](#operation/getLicences)) | [optional] 
 **language** | **String** | language id of the video (see [/videos/languages](#operation/getLanguages)) | [optional] 
 **privacy** | [**VideoPrivacySet**](VideoPrivacySet.md) |  | [optional] 
 **description** | **String** | Video description | [optional] 
 **waitTranscoding** | **String** | Whether or not we wait transcoding before publish the video | [optional] 
 **support** | **String** | A text tell the audience how to support the video creator | [optional] 
 **nsfw** | **Bool** | Whether or not this video contains sensitive content | [optional] 
 **nsfwSummary** | [**JSONValue**](JSONValue.md) | More information about the sensitive content of the video | [optional] 
 **nsfwFlags** | [**NSFWFlag**](NSFWFlag.md) |  | [optional] 
 **name** | **String** | Video name | [optional] 
 **tags** | [**[String]**](String.md) | Video tags (maximum 5 tags each between 2 and 30 characters) | [optional] 
 **commentsPolicy** | [**VideoCommentsPolicySet**](VideoCommentsPolicySet.md) |  | [optional] 
 **downloadEnabled** | **Bool** | Enable or disable downloading for this video | [optional] 
 **originallyPublishedAt** | **Date** | Date when the content was originally published | [optional] 
 **scheduleUpdate** | [**VideoScheduledUpdate**](VideoScheduledUpdate.md) |  | [optional] 
 **videoPasswords** | [**Set&lt;String&gt;**](String.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **replaceVideoSourceResumable**
```swift
    open class func replaceVideoSourceResumable(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, uploadId: String, contentRange: String, contentLength: Double, body: URL? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Send chunk for the resumable replacement of a video

**PeerTube >= 6.0** Uses [a resumable protocol](https://github.com/kukhariev/node-uploadx/blob/master/proto.md) to continue, pause or resume the replacement of a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let uploadId = "uploadId_example" // String | Created session id to proceed with. If you didn't send chunks in the last hour, it is not valid anymore and you need to initialize a new upload. 
let contentRange = "contentRange_example" // String | Specifies the bytes in the file that the request is uploading.  For example, a value of `bytes 0-262143/1000000` shows that the request is sending the first 262144 bytes (256 x 1024) in a 2,469,036 byte file. 
let contentLength = 987 // Double | Size of the chunk that the request is sending.  Remember that larger chunks are more efficient. PeerTube's web client uses chunks varying from 1048576 bytes (~1MB) and increases or reduces size depending on connection health. 
let body = URL(string: "https://example.com")! // URL |  (optional)

// Send chunk for the resumable replacement of a video
VideoAPI.replaceVideoSourceResumable(id: id, uploadId: uploadId, contentRange: contentRange, contentLength: contentLength, body: body) { (response, error) in
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

# **replaceVideoSourceResumableCancel**
```swift
    open class func replaceVideoSourceResumableCancel(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, uploadId: String, contentLength: Double, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Cancel the resumable replacement of a video

**PeerTube >= 6.0** Uses [a resumable protocol](https://github.com/kukhariev/node-uploadx/blob/master/proto.md) to cancel the replacement of a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let uploadId = "uploadId_example" // String | Created session id to proceed with. If you didn't send chunks in the last hour, it is not valid anymore and you need to initialize a new upload. 
let contentLength = 987 // Double | 

// Cancel the resumable replacement of a video
VideoAPI.replaceVideoSourceResumableCancel(id: id, uploadId: uploadId, contentLength: contentLength) { (response, error) in
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

# **replaceVideoSourceResumableInit**
```swift
    open class func replaceVideoSourceResumableInit(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, xUploadContentLength: Double, xUploadContentType: String, videoReplaceSourceRequestResumable: VideoReplaceSourceRequestResumable? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Initialize the resumable replacement of a video

**PeerTube >= 6.0** Uses [a resumable protocol](https://github.com/kukhariev/node-uploadx/blob/master/proto.md) to initialize the replacement of a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let xUploadContentLength = 987 // Double | Number of bytes that will be uploaded in subsequent requests. Set this value to the size of the file you are uploading.
let xUploadContentType = "xUploadContentType_example" // String | MIME type of the file that you are uploading. Depending on your instance settings, acceptable values might vary.
let videoReplaceSourceRequestResumable = VideoReplaceSourceRequestResumable(filename: "filename_example") // VideoReplaceSourceRequestResumable |  (optional)

// Initialize the resumable replacement of a video
VideoAPI.replaceVideoSourceResumableInit(id: id, xUploadContentLength: xUploadContentLength, xUploadContentType: xUploadContentType, videoReplaceSourceRequestResumable: videoReplaceSourceRequestResumable) { (response, error) in
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
 **xUploadContentLength** | **Double** | Number of bytes that will be uploaded in subsequent requests. Set this value to the size of the file you are uploading. | 
 **xUploadContentType** | **String** | MIME type of the file that you are uploading. Depending on your instance settings, acceptable values might vary. | 
 **videoReplaceSourceRequestResumable** | [**VideoReplaceSourceRequestResumable**](VideoReplaceSourceRequestResumable.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **requestVideoToken**
```swift
    open class func requestVideoToken(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, xPeertubeVideoPassword: String? = nil, completion: @escaping (_ data: VideoTokenResponse?, _ error: Error?) -> Void)
```

Request video token

Request special tokens that expire quickly to use them in some context (like accessing private static files)

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let xPeertubeVideoPassword = "xPeertubeVideoPassword_example" // String | Required on password protected video (optional)

// Request video token
VideoAPI.requestVideoToken(id: id, xPeertubeVideoPassword: xPeertubeVideoPassword) { (response, error) in
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

[**VideoTokenResponse**](VideoTokenResponse.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **searchVideos**
```swift
    open class func searchVideos(search: String, uuids: [String]? = nil, searchTarget: SearchTarget_searchVideos? = nil, start: Int? = nil, count: Int? = nil, skipCount: SkipCount_searchVideos? = nil, sort: Sort_searchVideos? = nil, nsfw: Nsfw_searchVideos? = nil, nsfwFlagsIncluded: NSFWFlag? = nil, nsfwFlagsExcluded: NSFWFlag? = nil, isLive: Bool? = nil, includeScheduledLive: Bool? = nil, categoryOneOf: GetAccountVideosCategoryOneOfParameter? = nil, licenceOneOf: GetAccountVideosLicenceOneOfParameter? = nil, languageOneOf: GetAccountVideosLanguageOneOfParameter? = nil, tagsOneOf: GetAccountVideosTagsOneOfParameter? = nil, tagsAllOf: GetAccountVideosTagsAllOfParameter? = nil, isLocal: Bool? = nil, include: Include_searchVideos? = nil, hasHLSFiles: Bool? = nil, hasWebVideoFiles: Bool? = nil, host: String? = nil, autoTagOneOf: GetAccountVideosTagsAllOfParameter? = nil, privacyOneOf: VideoPrivacySet? = nil, excludeAlreadyWatched: Bool? = nil, startDate: Date? = nil, endDate: Date? = nil, originallyPublishedStartDate: Date? = nil, originallyPublishedEndDate: Date? = nil, durationMin: Int? = nil, durationMax: Int? = nil, completion: @escaping (_ data: VideoListResponse?, _ error: Error?) -> Void)
```

Search videos

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let search = "search_example" // String | String to search. If the user can make a remote URI search, and the string is an URI then the PeerTube instance will fetch the remote object and add it to its database. Then, you can use the REST API to fetch the complete video information and interact with it. 
let uuids = ["inner_example"] // [String] | Find elements with specific UUIDs (optional)
let searchTarget = "searchTarget_example" // String | If the administrator enabled search index support, you can override the default search target.  **Warning**: If you choose to make an index search, PeerTube will get results from a third party service. It means the instance may not yet know the objects you fetched. If you want to load video/channel information:   * If the current user has the ability to make a remote URI search (this information is available in the config endpoint),   then reuse the search API to make a search using the object URI so PeerTube instance fetches the remote object and fill its database.   After that, you can use the classic REST API endpoints to fetch the complete object or interact with it   * If the current user doesn't have the ability to make a remote URI search, then redirect the user on the origin instance or fetch   the data from the origin instance API  (optional)
let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let skipCount = "skipCount_example" // String | if you don't need the `total` in the response (optional) (default to ._false)
let sort = "sort_example" // String |  (optional)
let nsfw = "nsfw_example" // String | whether to include nsfw videos, if any (optional)
let nsfwFlagsIncluded = NSFWFlag() // NSFWFlag |  (optional)
let nsfwFlagsExcluded = NSFWFlag() // NSFWFlag |  (optional)
let isLive = true // Bool | whether or not the video is a live (optional)
let includeScheduledLive = true // Bool | whether or not include live that are scheduled for later (optional)
let categoryOneOf = getAccountVideos_categoryOneOf_parameter() // GetAccountVideosCategoryOneOfParameter | category id of the video (see [/videos/categories](#operation/getCategories)) (optional)
let licenceOneOf = getAccountVideos_licenceOneOf_parameter() // GetAccountVideosLicenceOneOfParameter | licence id of the video (see [/videos/licences](#operation/getLicences)) (optional)
let languageOneOf = getAccountVideos_languageOneOf_parameter() // GetAccountVideosLanguageOneOfParameter | language id of the video (see [/videos/languages](#operation/getLanguages)). Use `_unknown` to filter on videos that don't have a video language (optional)
let tagsOneOf = getAccountVideos_tagsOneOf_parameter() // GetAccountVideosTagsOneOfParameter | tag(s) of the video (optional)
let tagsAllOf = getAccountVideos_tagsAllOf_parameter() // GetAccountVideosTagsAllOfParameter | tag(s) of the video, where all should be present in the video (optional)
let isLocal = true // Bool | **PeerTube >= 4.0** Display only local or remote objects (optional)
let include = 987 // Int | **Only administrators and moderators can use this parameter**  Include additional videos in results (can be combined using bitwise or operator) - `0` NONE - `1` NOT_PUBLISHED_STATE - `2` BLACKLISTED - `4` BLOCKED_OWNER - `8` FILES - `16` CAPTIONS - `32` VIDEO SOURCE  (optional)
let hasHLSFiles = true // Bool | **PeerTube >= 4.0** Display only videos that have HLS files (optional)
let hasWebVideoFiles = true // Bool | **PeerTube >= 6.0** Display only videos that have Web Video files (optional)
let host = "host_example" // String | Find elements owned by this host (optional)
let autoTagOneOf = getAccountVideos_tagsAllOf_parameter() // GetAccountVideosTagsAllOfParameter | **PeerTube >= 6.2** **Admins and moderators only** filter on videos that contain one of these automatic tags (optional)
let privacyOneOf = VideoPrivacySet() // VideoPrivacySet | **PeerTube >= 4.0** Display only videos in this specific privacy/privacies (optional)
let excludeAlreadyWatched = true // Bool | Whether or not to exclude videos that are in the user's video history (optional)
let startDate = Date() // Date | Get videos that are published after this date (optional)
let endDate = Date() // Date | Get videos that are published before this date (optional)
let originallyPublishedStartDate = Date() // Date | Get videos that are originally published after this date (optional)
let originallyPublishedEndDate = Date() // Date | Get videos that are originally published before this date (optional)
let durationMin = 987 // Int | Get videos that have this minimum duration (optional)
let durationMax = 987 // Int | Get videos that have this maximum duration (optional)

// Search videos
VideoAPI.searchVideos(search: search, uuids: uuids, searchTarget: searchTarget, start: start, count: count, skipCount: skipCount, sort: sort, nsfw: nsfw, nsfwFlagsIncluded: nsfwFlagsIncluded, nsfwFlagsExcluded: nsfwFlagsExcluded, isLive: isLive, includeScheduledLive: includeScheduledLive, categoryOneOf: categoryOneOf, licenceOneOf: licenceOneOf, languageOneOf: languageOneOf, tagsOneOf: tagsOneOf, tagsAllOf: tagsAllOf, isLocal: isLocal, include: include, hasHLSFiles: hasHLSFiles, hasWebVideoFiles: hasWebVideoFiles, host: host, autoTagOneOf: autoTagOneOf, privacyOneOf: privacyOneOf, excludeAlreadyWatched: excludeAlreadyWatched, startDate: startDate, endDate: endDate, originallyPublishedStartDate: originallyPublishedStartDate, originallyPublishedEndDate: originallyPublishedEndDate, durationMin: durationMin, durationMax: durationMax) { (response, error) in
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
 **search** | **String** | String to search. If the user can make a remote URI search, and the string is an URI then the PeerTube instance will fetch the remote object and add it to its database. Then, you can use the REST API to fetch the complete video information and interact with it.  | 
 **uuids** | [**[String]**](String.md) | Find elements with specific UUIDs | [optional] 
 **searchTarget** | **String** | If the administrator enabled search index support, you can override the default search target.  **Warning**: If you choose to make an index search, PeerTube will get results from a third party service. It means the instance may not yet know the objects you fetched. If you want to load video/channel information:   * If the current user has the ability to make a remote URI search (this information is available in the config endpoint),   then reuse the search API to make a search using the object URI so PeerTube instance fetches the remote object and fill its database.   After that, you can use the classic REST API endpoints to fetch the complete object or interact with it   * If the current user doesn&#39;t have the ability to make a remote URI search, then redirect the user on the origin instance or fetch   the data from the origin instance API  | [optional] 
 **start** | **Int** | Offset used to paginate results | [optional] 
 **count** | **Int** | Number of items to return | [optional] [default to 15]
 **skipCount** | **String** | if you don&#39;t need the &#x60;total&#x60; in the response | [optional] [default to ._false]
 **sort** | **String** |  | [optional] 
 **nsfw** | **String** | whether to include nsfw videos, if any | [optional] 
 **nsfwFlagsIncluded** | [**NSFWFlag**](.md) |  | [optional] 
 **nsfwFlagsExcluded** | [**NSFWFlag**](.md) |  | [optional] 
 **isLive** | **Bool** | whether or not the video is a live | [optional] 
 **includeScheduledLive** | **Bool** | whether or not include live that are scheduled for later | [optional] 
 **categoryOneOf** | [**GetAccountVideosCategoryOneOfParameter**](.md) | category id of the video (see [/videos/categories](#operation/getCategories)) | [optional] 
 **licenceOneOf** | [**GetAccountVideosLicenceOneOfParameter**](.md) | licence id of the video (see [/videos/licences](#operation/getLicences)) | [optional] 
 **languageOneOf** | [**GetAccountVideosLanguageOneOfParameter**](.md) | language id of the video (see [/videos/languages](#operation/getLanguages)). Use &#x60;_unknown&#x60; to filter on videos that don&#39;t have a video language | [optional] 
 **tagsOneOf** | [**GetAccountVideosTagsOneOfParameter**](.md) | tag(s) of the video | [optional] 
 **tagsAllOf** | [**GetAccountVideosTagsAllOfParameter**](.md) | tag(s) of the video, where all should be present in the video | [optional] 
 **isLocal** | **Bool** | **PeerTube &gt;&#x3D; 4.0** Display only local or remote objects | [optional] 
 **include** | **Int** | **Only administrators and moderators can use this parameter**  Include additional videos in results (can be combined using bitwise or operator) - &#x60;0&#x60; NONE - &#x60;1&#x60; NOT_PUBLISHED_STATE - &#x60;2&#x60; BLACKLISTED - &#x60;4&#x60; BLOCKED_OWNER - &#x60;8&#x60; FILES - &#x60;16&#x60; CAPTIONS - &#x60;32&#x60; VIDEO SOURCE  | [optional] 
 **hasHLSFiles** | **Bool** | **PeerTube &gt;&#x3D; 4.0** Display only videos that have HLS files | [optional] 
 **hasWebVideoFiles** | **Bool** | **PeerTube &gt;&#x3D; 6.0** Display only videos that have Web Video files | [optional] 
 **host** | **String** | Find elements owned by this host | [optional] 
 **autoTagOneOf** | [**GetAccountVideosTagsAllOfParameter**](.md) | **PeerTube &gt;&#x3D; 6.2** **Admins and moderators only** filter on videos that contain one of these automatic tags | [optional] 
 **privacyOneOf** | [**VideoPrivacySet**](.md) | **PeerTube &gt;&#x3D; 4.0** Display only videos in this specific privacy/privacies | [optional] 
 **excludeAlreadyWatched** | **Bool** | Whether or not to exclude videos that are in the user&#39;s video history | [optional] 
 **startDate** | **Date** | Get videos that are published after this date | [optional] 
 **endDate** | **Date** | Get videos that are published before this date | [optional] 
 **originallyPublishedStartDate** | **Date** | Get videos that are originally published after this date | [optional] 
 **originallyPublishedEndDate** | **Date** | Get videos that are originally published before this date | [optional] 
 **durationMin** | **Int** | Get videos that have this minimum duration | [optional] 
 **durationMax** | **Int** | Get videos that have this maximum duration | [optional] 

### Return type

[**VideoListResponse**](VideoListResponse.md)

### Authorization

No authorization required

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
VideoAPI.updateLiveId(id: id, liveVideoUpdate: liveVideoUpdate) { (response, error) in
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

# **uploadLegacy**
```swift
    open class func uploadLegacy(name: String, channelId: Int, videofile: URL, privacy: VideoPrivacySet? = nil, category: Int? = nil, licence: Int? = nil, language: String? = nil, description: String? = nil, waitTranscoding: Bool? = nil, generateTranscription: Bool? = nil, support: String? = nil, nsfw: Bool? = nil, nsfwSummary: JSONValue? = nil, nsfwFlags: NSFWFlag? = nil, tags: Set<String>? = nil, commentsPolicy: VideoCommentsPolicySet? = nil, downloadEnabled: Bool? = nil, originallyPublishedAt: Date? = nil, scheduleUpdate: VideoScheduledUpdate? = nil, thumbnailfile: URL? = nil, previewfile: URL? = nil, videoPasswords: Set<String>? = nil, completion: @escaping (_ data: VideoUploadResponse?, _ error: Error?) -> Void)
```

Upload a video

Uses a single request to upload a video.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let name = "name_example" // String | Video name
let channelId = 987 // Int | Channel id that will contain this video
let videofile = URL(string: "https://example.com")! // URL | Video file
let privacy = VideoPrivacySet() // VideoPrivacySet |  (optional)
let category = 987 // Int | category id of the video (see [/videos/categories](#operation/getCategories)) (optional)
let licence = 987 // Int | licence id of the video (see [/videos/licences](#operation/getLicences)) (optional)
let language = "language_example" // String | language id of the video (see [/videos/languages](#operation/getLanguages)) (optional)
let description = "description_example" // String | Video description (optional)
let waitTranscoding = true // Bool | Whether or not we wait transcoding before publish the video (optional)
let generateTranscription = true // Bool | **PeerTube >= 6.2** If enabled by the admin, automatically generate a subtitle of the video (optional)
let support = "support_example" // String | A text tell the audience how to support the video creator (optional)
let nsfw = true // Bool | Whether or not this video contains sensitive content (optional)
let nsfwSummary =  // JSONValue | More information about the sensitive content of the video (optional)
let nsfwFlags = NSFWFlag() // NSFWFlag |  (optional)
let tags = ["inner_example"] // Set<String> | Video tags (maximum 5 tags each between 2 and 30 characters) (optional)
let commentsPolicy = VideoCommentsPolicySet() // VideoCommentsPolicySet |  (optional)
let downloadEnabled = true // Bool | Enable or disable downloading for this video (optional)
let originallyPublishedAt = Date() // Date | Date when the content was originally published (optional)
let scheduleUpdate = VideoScheduledUpdate(privacy: VideoPrivacySet(), updateAt: Date()) // VideoScheduledUpdate |  (optional)
let thumbnailfile = URL(string: "https://example.com")! // URL | Video thumbnail file (optional)
let previewfile = URL(string: "https://example.com")! // URL | Video preview file (optional)
let videoPasswords = ["inner_example"] // Set<String> |  (optional)

// Upload a video
VideoAPI.uploadLegacy(name: name, channelId: channelId, videofile: videofile, privacy: privacy, category: category, licence: licence, language: language, description: description, waitTranscoding: waitTranscoding, generateTranscription: generateTranscription, support: support, nsfw: nsfw, nsfwSummary: nsfwSummary, nsfwFlags: nsfwFlags, tags: tags, commentsPolicy: commentsPolicy, downloadEnabled: downloadEnabled, originallyPublishedAt: originallyPublishedAt, scheduleUpdate: scheduleUpdate, thumbnailfile: thumbnailfile, previewfile: previewfile, videoPasswords: videoPasswords) { (response, error) in
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
 **name** | **String** | Video name | 
 **channelId** | **Int** | Channel id that will contain this video | 
 **videofile** | **URL** | Video file | 
 **privacy** | [**VideoPrivacySet**](VideoPrivacySet.md) |  | [optional] 
 **category** | **Int** | category id of the video (see [/videos/categories](#operation/getCategories)) | [optional] 
 **licence** | **Int** | licence id of the video (see [/videos/licences](#operation/getLicences)) | [optional] 
 **language** | **String** | language id of the video (see [/videos/languages](#operation/getLanguages)) | [optional] 
 **description** | **String** | Video description | [optional] 
 **waitTranscoding** | **Bool** | Whether or not we wait transcoding before publish the video | [optional] 
 **generateTranscription** | **Bool** | **PeerTube &gt;&#x3D; 6.2** If enabled by the admin, automatically generate a subtitle of the video | [optional] 
 **support** | **String** | A text tell the audience how to support the video creator | [optional] 
 **nsfw** | **Bool** | Whether or not this video contains sensitive content | [optional] 
 **nsfwSummary** | [**JSONValue**](JSONValue.md) | More information about the sensitive content of the video | [optional] 
 **nsfwFlags** | [**NSFWFlag**](NSFWFlag.md) |  | [optional] 
 **tags** | [**Set&lt;String&gt;**](String.md) | Video tags (maximum 5 tags each between 2 and 30 characters) | [optional] 
 **commentsPolicy** | [**VideoCommentsPolicySet**](VideoCommentsPolicySet.md) |  | [optional] 
 **downloadEnabled** | **Bool** | Enable or disable downloading for this video | [optional] 
 **originallyPublishedAt** | **Date** | Date when the content was originally published | [optional] 
 **scheduleUpdate** | [**VideoScheduledUpdate**](VideoScheduledUpdate.md) |  | [optional] 
 **thumbnailfile** | **URL** | Video thumbnail file | [optional] 
 **previewfile** | **URL** | Video preview file | [optional] 
 **videoPasswords** | [**Set&lt;String&gt;**](String.md) |  | [optional] 

### Return type

[**VideoUploadResponse**](VideoUploadResponse.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **uploadResumable**
```swift
    open class func uploadResumable(uploadId: String, contentRange: String, contentLength: Double, body: URL? = nil, completion: @escaping (_ data: VideoUploadResponse?, _ error: Error?) -> Void)
```

Send chunk for the resumable upload of a video

Uses [a resumable protocol](https://github.com/kukhariev/node-uploadx/blob/master/proto.md) to continue, pause or resume the upload of a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let uploadId = "uploadId_example" // String | Created session id to proceed with. If you didn't send chunks in the last hour, it is not valid anymore and you need to initialize a new upload. 
let contentRange = "contentRange_example" // String | Specifies the bytes in the file that the request is uploading.  For example, a value of `bytes 0-262143/1000000` shows that the request is sending the first 262144 bytes (256 x 1024) in a 2,469,036 byte file. 
let contentLength = 987 // Double | Size of the chunk that the request is sending.  Remember that larger chunks are more efficient. PeerTube's web client uses chunks varying from 1048576 bytes (~1MB) and increases or reduces size depending on connection health. 
let body = URL(string: "https://example.com")! // URL |  (optional)

// Send chunk for the resumable upload of a video
VideoAPI.uploadResumable(uploadId: uploadId, contentRange: contentRange, contentLength: contentLength, body: body) { (response, error) in
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
 **uploadId** | **String** | Created session id to proceed with. If you didn&#39;t send chunks in the last hour, it is not valid anymore and you need to initialize a new upload.  | 
 **contentRange** | **String** | Specifies the bytes in the file that the request is uploading.  For example, a value of &#x60;bytes 0-262143/1000000&#x60; shows that the request is sending the first 262144 bytes (256 x 1024) in a 2,469,036 byte file.  | 
 **contentLength** | **Double** | Size of the chunk that the request is sending.  Remember that larger chunks are more efficient. PeerTube&#39;s web client uses chunks varying from 1048576 bytes (~1MB) and increases or reduces size depending on connection health.  | 
 **body** | **URL** |  | [optional] 

### Return type

[**VideoUploadResponse**](VideoUploadResponse.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/octet-stream
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **uploadResumableCancel**
```swift
    open class func uploadResumableCancel(uploadId: String, contentLength: Double, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Cancel the resumable upload of a video, deleting any data uploaded so far

Uses [a resumable protocol](https://github.com/kukhariev/node-uploadx/blob/master/proto.md) to cancel the upload of a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let uploadId = "uploadId_example" // String | Created session id to proceed with. If you didn't send chunks in the last hour, it is not valid anymore and you need to initialize a new upload. 
let contentLength = 987 // Double | 

// Cancel the resumable upload of a video, deleting any data uploaded so far
VideoAPI.uploadResumableCancel(uploadId: uploadId, contentLength: contentLength) { (response, error) in
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

# **uploadResumableInit**
```swift
    open class func uploadResumableInit(xUploadContentLength: Double, xUploadContentType: String, videoUploadRequestResumable: VideoUploadRequestResumable? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Initialize the resumable upload of a video

Uses [a resumable protocol](https://github.com/kukhariev/node-uploadx/blob/master/proto.md) to initialize the upload of a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let xUploadContentLength = 987 // Double | Number of bytes that will be uploaded in subsequent requests. Set this value to the size of the file you are uploading.
let xUploadContentType = "xUploadContentType_example" // String | MIME type of the file that you are uploading. Depending on your instance settings, acceptable values might vary.
let videoUploadRequestResumable = VideoUploadRequestResumable(name: "name_example", channelId: 123, privacy: VideoPrivacySet(), category: 123, licence: 123, language: "language_example", description: "description_example", waitTranscoding: false, generateTranscription: false, support: "support_example", nsfw: false, nsfwSummary: 123, nsfwFlags: NSFWFlag(), tags: ["tags_example"], commentsPolicy: VideoCommentsPolicySet(), downloadEnabled: false, originallyPublishedAt: Date(), scheduleUpdate: VideoScheduledUpdate(privacy: nil, updateAt: Date()), thumbnailfile: URL(string: "https://example.com")!, previewfile: URL(string: "https://example.com")!, videoPasswords: ["videoPasswords_example"], filename: "filename_example") // VideoUploadRequestResumable |  (optional)

// Initialize the resumable upload of a video
VideoAPI.uploadResumableInit(xUploadContentLength: xUploadContentLength, xUploadContentType: xUploadContentType, videoUploadRequestResumable: videoUploadRequestResumable) { (response, error) in
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
 **xUploadContentLength** | **Double** | Number of bytes that will be uploaded in subsequent requests. Set this value to the size of the file you are uploading. | 
 **xUploadContentType** | **String** | MIME type of the file that you are uploading. Depending on your instance settings, acceptable values might vary. | 
 **videoUploadRequestResumable** | [**VideoUploadRequestResumable**](VideoUploadRequestResumable.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

