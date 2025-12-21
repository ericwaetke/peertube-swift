# AccountsAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1AccountsNameRatingsGet**](AccountsAPI.md#apiv1accountsnameratingsget) | **GET** /api/v1/accounts/{name}/ratings | List ratings of an account
[**apiV1AccountsNameVideoChannelSyncsGet**](AccountsAPI.md#apiv1accountsnamevideochannelsyncsget) | **GET** /api/v1/accounts/{name}/video-channel-syncs | List the synchronizations of video channels of an account
[**apiV1AccountsNameVideoChannelsGet**](AccountsAPI.md#apiv1accountsnamevideochannelsget) | **GET** /api/v1/accounts/{name}/video-channels | List video channels of an account
[**apiV1AccountsNameVideoPlaylistsGet**](AccountsAPI.md#apiv1accountsnamevideoplaylistsget) | **GET** /api/v1/accounts/{name}/video-playlists | List playlists of an account
[**getAccount**](AccountsAPI.md#getaccount) | **GET** /api/v1/accounts/{name} | Get an account
[**getAccountFollowers**](AccountsAPI.md#getaccountfollowers) | **GET** /api/v1/accounts/{name}/followers | List followers of an account
[**getAccountVideos**](AccountsAPI.md#getaccountvideos) | **GET** /api/v1/accounts/{name}/videos | List videos of an account
[**getAccounts**](AccountsAPI.md#getaccounts) | **GET** /api/v1/accounts | List accounts


# **apiV1AccountsNameRatingsGet**
```swift
    open class func apiV1AccountsNameRatingsGet(name: String, start: Int? = nil, count: Int? = nil, sort: String? = nil, rating: Rating_apiV1AccountsNameRatingsGet? = nil, completion: @escaping (_ data: [VideoRating]?, _ error: Error?) -> Void)
```

List ratings of an account

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let name = "name_example" // String | The username or handle of the account
let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let sort = "sort_example" // String | Sort column (optional)
let rating = "rating_example" // String | Optionally filter which ratings to retrieve (optional)

// List ratings of an account
AccountsAPI.apiV1AccountsNameRatingsGet(name: name, start: start, count: count, sort: sort, rating: rating) { (response, error) in
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
 **sort** | **String** | Sort column | [optional] 
 **rating** | **String** | Optionally filter which ratings to retrieve | [optional] 

### Return type

[**[VideoRating]**](VideoRating.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1AccountsNameVideoChannelSyncsGet**
```swift
    open class func apiV1AccountsNameVideoChannelSyncsGet(name: String, start: Int? = nil, count: Int? = nil, sort: String? = nil, includeCollaborations: Bool? = nil, completion: @escaping (_ data: VideoChannelSyncList?, _ error: Error?) -> Void)
```

List the synchronizations of video channels of an account

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let name = "name_example" // String | The username or handle of the account
let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let sort = "sort_example" // String | Sort column (optional)
let includeCollaborations = true // Bool | **PeerTube >= 8.0** Include objects from collaborated channels (optional)

// List the synchronizations of video channels of an account
AccountsAPI.apiV1AccountsNameVideoChannelSyncsGet(name: name, start: start, count: count, sort: sort, includeCollaborations: includeCollaborations) { (response, error) in
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
 **sort** | **String** | Sort column | [optional] 
 **includeCollaborations** | **Bool** | **PeerTube &gt;&#x3D; 8.0** Include objects from collaborated channels | [optional] 

### Return type

[**VideoChannelSyncList**](VideoChannelSyncList.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1AccountsNameVideoChannelsGet**
```swift
    open class func apiV1AccountsNameVideoChannelsGet(name: String, withStats: Bool? = nil, start: Int? = nil, count: Int? = nil, search: String? = nil, sort: String? = nil, includeCollaborations: Bool? = nil, completion: @escaping (_ data: VideoChannelList?, _ error: Error?) -> Void)
```

List video channels of an account

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let name = "name_example" // String | The username or handle of the account
let withStats = true // Bool | include daily view statistics for the last 30 days and total views (only if authenticated as the account user) (optional)
let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let search = "search_example" // String | Plain text search, applied to various parts of the model depending on endpoint (optional)
let sort = "sort_example" // String | Sort column (optional)
let includeCollaborations = true // Bool | **PeerTube >= 8.0** Include objects from collaborated channels (optional)

// List video channels of an account
AccountsAPI.apiV1AccountsNameVideoChannelsGet(name: name, withStats: withStats, start: start, count: count, search: search, sort: sort, includeCollaborations: includeCollaborations) { (response, error) in
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
 **withStats** | **Bool** | include daily view statistics for the last 30 days and total views (only if authenticated as the account user) | [optional] 
 **start** | **Int** | Offset used to paginate results | [optional] 
 **count** | **Int** | Number of items to return | [optional] [default to 15]
 **search** | **String** | Plain text search, applied to various parts of the model depending on endpoint | [optional] 
 **sort** | **String** | Sort column | [optional] 
 **includeCollaborations** | **Bool** | **PeerTube &gt;&#x3D; 8.0** Include objects from collaborated channels | [optional] 

### Return type

[**VideoChannelList**](VideoChannelList.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1AccountsNameVideoPlaylistsGet**
```swift
    open class func apiV1AccountsNameVideoPlaylistsGet(name: String, start: Int? = nil, count: Int? = nil, sort: String? = nil, search: String? = nil, playlistType: VideoPlaylistTypeSet? = nil, includeCollaborations: Bool? = nil, channelNameOneOf: GetAccountVideosTagsAllOfParameter? = nil, completion: @escaping (_ data: ApiV1VideoChannelsChannelHandleVideoPlaylistsGet200Response?, _ error: Error?) -> Void)
```

List playlists of an account

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let name = "name_example" // String | The username or handle of the account
let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let sort = "sort_example" // String | Sort column (optional)
let search = "search_example" // String | Plain text search, applied to various parts of the model depending on endpoint (optional)
let playlistType = VideoPlaylistTypeSet() // VideoPlaylistTypeSet |  (optional)
let includeCollaborations = true // Bool | **PeerTube >= 8.0** Include objects from collaborated channels (optional)
let channelNameOneOf = getAccountVideos_tagsAllOf_parameter() // GetAccountVideosTagsAllOfParameter | **PeerTube >= 8.0** Filter on playlists that are published on a channel with one of these names (optional)

// List playlists of an account
AccountsAPI.apiV1AccountsNameVideoPlaylistsGet(name: name, start: start, count: count, sort: sort, search: search, playlistType: playlistType, includeCollaborations: includeCollaborations, channelNameOneOf: channelNameOneOf) { (response, error) in
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
 **sort** | **String** | Sort column | [optional] 
 **search** | **String** | Plain text search, applied to various parts of the model depending on endpoint | [optional] 
 **playlistType** | [**VideoPlaylistTypeSet**](.md) |  | [optional] 
 **includeCollaborations** | **Bool** | **PeerTube &gt;&#x3D; 8.0** Include objects from collaborated channels | [optional] 
 **channelNameOneOf** | [**GetAccountVideosTagsAllOfParameter**](.md) | **PeerTube &gt;&#x3D; 8.0** Filter on playlists that are published on a channel with one of these names | [optional] 

### Return type

[**ApiV1VideoChannelsChannelHandleVideoPlaylistsGet200Response**](ApiV1VideoChannelsChannelHandleVideoPlaylistsGet200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAccount**
```swift
    open class func getAccount(name: String, completion: @escaping (_ data: Account?, _ error: Error?) -> Void)
```

Get an account

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let name = "name_example" // String | The username or handle of the account

// Get an account
AccountsAPI.getAccount(name: name) { (response, error) in
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

### Return type

[**Account**](Account.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAccountFollowers**
```swift
    open class func getAccountFollowers(name: String, start: Int? = nil, count: Int? = nil, sort: Sort_getAccountFollowers? = nil, search: String? = nil, completion: @escaping (_ data: GetAccountFollowers200Response?, _ error: Error?) -> Void)
```

List followers of an account

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let name = "name_example" // String | The username or handle of the account
let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let sort = "sort_example" // String | Sort followers by criteria (optional)
let search = "search_example" // String | Plain text search, applied to various parts of the model depending on endpoint (optional)

// List followers of an account
AccountsAPI.getAccountFollowers(name: name, start: start, count: count, sort: sort, search: search) { (response, error) in
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
 **sort** | **String** | Sort followers by criteria | [optional] 
 **search** | **String** | Plain text search, applied to various parts of the model depending on endpoint | [optional] 

### Return type

[**GetAccountFollowers200Response**](GetAccountFollowers200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

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
AccountsAPI.getAccountVideos(name: name, start: start, count: count, skipCount: skipCount, sort: sort, nsfw: nsfw, nsfwFlagsIncluded: nsfwFlagsIncluded, nsfwFlagsExcluded: nsfwFlagsExcluded, isLive: isLive, includeScheduledLive: includeScheduledLive, categoryOneOf: categoryOneOf, licenceOneOf: licenceOneOf, languageOneOf: languageOneOf, tagsOneOf: tagsOneOf, tagsAllOf: tagsAllOf, isLocal: isLocal, include: include, hasHLSFiles: hasHLSFiles, hasWebVideoFiles: hasWebVideoFiles, host: host, autoTagOneOf: autoTagOneOf, privacyOneOf: privacyOneOf, excludeAlreadyWatched: excludeAlreadyWatched, search: search) { (response, error) in
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

# **getAccounts**
```swift
    open class func getAccounts(start: Int? = nil, count: Int? = nil, sort: String? = nil, completion: @escaping (_ data: GetAccounts200Response?, _ error: Error?) -> Void)
```

List accounts

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let sort = "sort_example" // String | Sort column (optional)

// List accounts
AccountsAPI.getAccounts(start: start, count: count, sort: sort) { (response, error) in
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
 **sort** | **String** | Sort column | [optional] 

### Return type

[**GetAccounts200Response**](GetAccounts200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

