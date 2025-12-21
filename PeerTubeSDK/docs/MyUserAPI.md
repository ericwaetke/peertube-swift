# MyUserAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1UsersMeAvatarDelete**](MyUserAPI.md#apiv1usersmeavatardelete) | **DELETE** /api/v1/users/me/avatar | Delete my avatar
[**apiV1UsersMeAvatarPickPost**](MyUserAPI.md#apiv1usersmeavatarpickpost) | **POST** /api/v1/users/me/avatar/pick | Update my user avatar
[**apiV1UsersMeNewFeatureInfoReadPost**](MyUserAPI.md#apiv1usersmenewfeatureinforeadpost) | **POST** /api/v1/users/me/new-feature-info/read | Mark feature info as read
[**apiV1UsersMeVideoQuotaUsedGet**](MyUserAPI.md#apiv1usersmevideoquotausedget) | **GET** /api/v1/users/me/video-quota-used | Get my user used quota
[**apiV1UsersMeVideosGet**](MyUserAPI.md#apiv1usersmevideosget) | **GET** /api/v1/users/me/videos | List videos of my user
[**apiV1UsersMeVideosImportsGet**](MyUserAPI.md#apiv1usersmevideosimportsget) | **GET** /api/v1/users/me/videos/imports | Get video imports of my user
[**apiV1UsersMeVideosVideoIdRatingGet**](MyUserAPI.md#apiv1usersmevideosvideoidratingget) | **GET** /api/v1/users/me/videos/{videoId}/rating | Get rate of my user for a video
[**getMyAbuses**](MyUserAPI.md#getmyabuses) | **GET** /api/v1/users/me/abuses | List my abuses
[**getUserInfo**](MyUserAPI.md#getuserinfo) | **GET** /api/v1/users/me | Get my user information
[**putUserInfo**](MyUserAPI.md#putuserinfo) | **PUT** /api/v1/users/me | Update my user information


# **apiV1UsersMeAvatarDelete**
```swift
    open class func apiV1UsersMeAvatarDelete(completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete my avatar

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// Delete my avatar
MyUserAPI.apiV1UsersMeAvatarDelete() { (response, error) in
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

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1UsersMeAvatarPickPost**
```swift
    open class func apiV1UsersMeAvatarPickPost(avatarfile: URL? = nil, completion: @escaping (_ data: ApiV1UsersMeAvatarPickPost200Response?, _ error: Error?) -> Void)
```

Update my user avatar

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let avatarfile = URL(string: "https://example.com")! // URL | The file to upload (optional)

// Update my user avatar
MyUserAPI.apiV1UsersMeAvatarPickPost(avatarfile: avatarfile) { (response, error) in
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
 **avatarfile** | **URL** | The file to upload | [optional] 

### Return type

[**ApiV1UsersMeAvatarPickPost200Response**](ApiV1UsersMeAvatarPickPost200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1UsersMeNewFeatureInfoReadPost**
```swift
    open class func apiV1UsersMeNewFeatureInfoReadPost(apiV1UsersMeNewFeatureInfoReadPostRequest: ApiV1UsersMeNewFeatureInfoReadPostRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Mark feature info as read

**PeerTube >= v8.0.0

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let apiV1UsersMeNewFeatureInfoReadPostRequest = _api_v1_users_me_new_feature_info_read_post_request(feature: NewFeatureInfoType()) // ApiV1UsersMeNewFeatureInfoReadPostRequest |  (optional)

// Mark feature info as read
MyUserAPI.apiV1UsersMeNewFeatureInfoReadPost(apiV1UsersMeNewFeatureInfoReadPostRequest: apiV1UsersMeNewFeatureInfoReadPostRequest) { (response, error) in
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
 **apiV1UsersMeNewFeatureInfoReadPostRequest** | [**ApiV1UsersMeNewFeatureInfoReadPostRequest**](ApiV1UsersMeNewFeatureInfoReadPostRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1UsersMeVideoQuotaUsedGet**
```swift
    open class func apiV1UsersMeVideoQuotaUsedGet(completion: @escaping (_ data: ApiV1UsersMeVideoQuotaUsedGet200Response?, _ error: Error?) -> Void)
```

Get my user used quota

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// Get my user used quota
MyUserAPI.apiV1UsersMeVideoQuotaUsedGet() { (response, error) in
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

[**ApiV1UsersMeVideoQuotaUsedGet200Response**](ApiV1UsersMeVideoQuotaUsedGet200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1UsersMeVideosGet**
```swift
    open class func apiV1UsersMeVideosGet(channelNameOneOf: GetAccountVideosTagsAllOfParameter? = nil, start: Int? = nil, count: Int? = nil, skipCount: SkipCount_apiV1UsersMeVideosGet? = nil, sort: Sort_apiV1UsersMeVideosGet? = nil, nsfw: Nsfw_apiV1UsersMeVideosGet? = nil, nsfwFlagsIncluded: NSFWFlag? = nil, nsfwFlagsExcluded: NSFWFlag? = nil, isLive: Bool? = nil, includeScheduledLive: Bool? = nil, categoryOneOf: GetAccountVideosCategoryOneOfParameter? = nil, licenceOneOf: GetAccountVideosLicenceOneOfParameter? = nil, languageOneOf: GetAccountVideosLanguageOneOfParameter? = nil, tagsOneOf: GetAccountVideosTagsOneOfParameter? = nil, tagsAllOf: GetAccountVideosTagsAllOfParameter? = nil, isLocal: Bool? = nil, include: Include_apiV1UsersMeVideosGet? = nil, hasHLSFiles: Bool? = nil, hasWebVideoFiles: Bool? = nil, host: String? = nil, autoTagOneOf: GetAccountVideosTagsAllOfParameter? = nil, privacyOneOf: VideoPrivacySet? = nil, excludeAlreadyWatched: Bool? = nil, search: String? = nil, includeCollaborations: Bool? = nil, completion: @escaping (_ data: VideoListResponse?, _ error: Error?) -> Void)
```

List videos of my user

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let channelNameOneOf = getAccountVideos_tagsAllOf_parameter() // GetAccountVideosTagsAllOfParameter | **PeerTube >= 7.2** Filter on videos that are published by a channel with one of these names (optional)
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
let includeCollaborations = true // Bool | **PeerTube >= 8.0** Include objects from collaborated channels (optional)

// List videos of my user
MyUserAPI.apiV1UsersMeVideosGet(channelNameOneOf: channelNameOneOf, start: start, count: count, skipCount: skipCount, sort: sort, nsfw: nsfw, nsfwFlagsIncluded: nsfwFlagsIncluded, nsfwFlagsExcluded: nsfwFlagsExcluded, isLive: isLive, includeScheduledLive: includeScheduledLive, categoryOneOf: categoryOneOf, licenceOneOf: licenceOneOf, languageOneOf: languageOneOf, tagsOneOf: tagsOneOf, tagsAllOf: tagsAllOf, isLocal: isLocal, include: include, hasHLSFiles: hasHLSFiles, hasWebVideoFiles: hasWebVideoFiles, host: host, autoTagOneOf: autoTagOneOf, privacyOneOf: privacyOneOf, excludeAlreadyWatched: excludeAlreadyWatched, search: search, includeCollaborations: includeCollaborations) { (response, error) in
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
 **channelNameOneOf** | [**GetAccountVideosTagsAllOfParameter**](.md) | **PeerTube &gt;&#x3D; 7.2** Filter on videos that are published by a channel with one of these names | [optional] 
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
 **includeCollaborations** | **Bool** | **PeerTube &gt;&#x3D; 8.0** Include objects from collaborated channels | [optional] 

### Return type

[**VideoListResponse**](VideoListResponse.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1UsersMeVideosImportsGet**
```swift
    open class func apiV1UsersMeVideosImportsGet(id: Int, start: Int? = nil, count: Int? = nil, sort: String? = nil, includeCollaborations: Bool? = nil, videoId: Int? = nil, targetUrl: String? = nil, videoChannelSyncId: Double? = nil, search: String? = nil, completion: @escaping (_ data: VideoImportsList?, _ error: Error?) -> Void)
```

Get video imports of my user

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = 987 // Int | Entity id
let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let sort = "sort_example" // String | Sort column (optional)
let includeCollaborations = true // Bool | **PeerTube >= 8.0** Include objects from collaborated channels (optional)
let videoId = 987 // Int | Filter on import video ID (optional)
let targetUrl = "targetUrl_example" // String | Filter on import target URL (optional)
let videoChannelSyncId = 987 // Double | Filter on imports created by a specific channel synchronization (optional)
let search = "search_example" // String | Search in video names (optional)

// Get video imports of my user
MyUserAPI.apiV1UsersMeVideosImportsGet(id: id, start: start, count: count, sort: sort, includeCollaborations: includeCollaborations, videoId: videoId, targetUrl: targetUrl, videoChannelSyncId: videoChannelSyncId, search: search) { (response, error) in
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
 **id** | **Int** | Entity id | 
 **start** | **Int** | Offset used to paginate results | [optional] 
 **count** | **Int** | Number of items to return | [optional] [default to 15]
 **sort** | **String** | Sort column | [optional] 
 **includeCollaborations** | **Bool** | **PeerTube &gt;&#x3D; 8.0** Include objects from collaborated channels | [optional] 
 **videoId** | **Int** | Filter on import video ID | [optional] 
 **targetUrl** | **String** | Filter on import target URL | [optional] 
 **videoChannelSyncId** | **Double** | Filter on imports created by a specific channel synchronization | [optional] 
 **search** | **String** | Search in video names | [optional] 

### Return type

[**VideoImportsList**](VideoImportsList.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1UsersMeVideosVideoIdRatingGet**
```swift
    open class func apiV1UsersMeVideosVideoIdRatingGet(videoId: Int, completion: @escaping (_ data: GetMeVideoRating?, _ error: Error?) -> Void)
```

Get rate of my user for a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let videoId = 987 // Int | The video id

// Get rate of my user for a video
MyUserAPI.apiV1UsersMeVideosVideoIdRatingGet(videoId: videoId) { (response, error) in
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
 **videoId** | **Int** | The video id | 

### Return type

[**GetMeVideoRating**](GetMeVideoRating.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMyAbuses**
```swift
    open class func getMyAbuses(id: Int? = nil, state: AbuseStateSet? = nil, sort: Sort_getMyAbuses? = nil, start: Int? = nil, count: Int? = nil, completion: @escaping (_ data: GetMyAbuses200Response?, _ error: Error?) -> Void)
```

List my abuses

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = 987 // Int | only list the report with this id (optional)
let state = AbuseStateSet() // AbuseStateSet |  (optional)
let sort = "sort_example" // String | Sort abuses by criteria (optional)
let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)

// List my abuses
MyUserAPI.getMyAbuses(id: id, state: state, sort: sort, start: start, count: count) { (response, error) in
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
 **id** | **Int** | only list the report with this id | [optional] 
 **state** | [**AbuseStateSet**](.md) |  | [optional] 
 **sort** | **String** | Sort abuses by criteria | [optional] 
 **start** | **Int** | Offset used to paginate results | [optional] 
 **count** | **Int** | Number of items to return | [optional] [default to 15]

### Return type

[**GetMyAbuses200Response**](GetMyAbuses200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUserInfo**
```swift
    open class func getUserInfo(completion: @escaping (_ data: [User]?, _ error: Error?) -> Void)
```

Get my user information

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// Get my user information
MyUserAPI.getUserInfo() { (response, error) in
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

[**[User]**](User.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putUserInfo**
```swift
    open class func putUserInfo(updateMe: UpdateMe, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Update my user information

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let updateMe = UpdateMe(password: "password_example", currentPassword: "currentPassword_example", email: "email_example", displayName: "displayName_example", nsfwPolicy: "nsfwPolicy_example", nsfwFlagsDisplayed: NSFWFlag(), nsfwFlagsHidden: nil, nsfwFlagsWarned: nil, nsfwFlagsBlurred: nil, p2pEnabled: false, autoPlayVideo: false, autoPlayNextVideo: false, autoPlayNextVideoPlaylist: false, videosHistoryEnabled: false, videoLanguages: ["videoLanguages_example"], language: "language_example", theme: "theme_example", noInstanceConfigWarningModal: false, noAccountSetupWarningModal: false, noWelcomeModal: false) // UpdateMe | 

// Update my user information
MyUserAPI.putUserInfo(updateMe: updateMe) { (response, error) in
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
 **updateMe** | [**UpdateMe**](UpdateMe.md) |  | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

