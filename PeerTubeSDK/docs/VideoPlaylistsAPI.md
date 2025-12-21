# VideoPlaylistsAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addPlaylist**](VideoPlaylistsAPI.md#addplaylist) | **POST** /api/v1/video-playlists | Create a video playlist
[**addVideoPlaylistVideo**](VideoPlaylistsAPI.md#addvideoplaylistvideo) | **POST** /api/v1/video-playlists/{playlistId}/videos | Add a video in a playlist
[**apiV1AccountsNameVideoPlaylistsGet**](VideoPlaylistsAPI.md#apiv1accountsnamevideoplaylistsget) | **GET** /api/v1/accounts/{name}/video-playlists | List playlists of an account
[**apiV1UsersMeVideoPlaylistsVideosExistGet**](VideoPlaylistsAPI.md#apiv1usersmevideoplaylistsvideosexistget) | **GET** /api/v1/users/me/video-playlists/videos-exist | Check video exists in my playlists
[**apiV1VideoChannelsChannelHandleVideoPlaylistsGet**](VideoPlaylistsAPI.md#apiv1videochannelschannelhandlevideoplaylistsget) | **GET** /api/v1/video-channels/{channelHandle}/video-playlists | List playlists of a channel
[**apiV1VideoPlaylistsPlaylistIdDelete**](VideoPlaylistsAPI.md#apiv1videoplaylistsplaylistiddelete) | **DELETE** /api/v1/video-playlists/{playlistId} | Delete a video playlist
[**apiV1VideoPlaylistsPlaylistIdGet**](VideoPlaylistsAPI.md#apiv1videoplaylistsplaylistidget) | **GET** /api/v1/video-playlists/{playlistId} | Get a video playlist
[**apiV1VideoPlaylistsPlaylistIdPut**](VideoPlaylistsAPI.md#apiv1videoplaylistsplaylistidput) | **PUT** /api/v1/video-playlists/{playlistId} | Update a video playlist
[**delVideoPlaylistVideo**](VideoPlaylistsAPI.md#delvideoplaylistvideo) | **DELETE** /api/v1/video-playlists/{playlistId}/videos/{playlistElementId} | Delete an element from a playlist
[**getPlaylistPrivacyPolicies**](VideoPlaylistsAPI.md#getplaylistprivacypolicies) | **GET** /api/v1/video-playlists/privacies | List available playlist privacy policies
[**getPlaylists**](VideoPlaylistsAPI.md#getplaylists) | **GET** /api/v1/video-playlists | List video playlists
[**getVideoPlaylistVideos**](VideoPlaylistsAPI.md#getvideoplaylistvideos) | **GET** /api/v1/video-playlists/{playlistId}/videos | List videos of a playlist
[**putVideoPlaylistVideo**](VideoPlaylistsAPI.md#putvideoplaylistvideo) | **PUT** /api/v1/video-playlists/{playlistId}/videos/{playlistElementId} | Update a playlist element
[**reorderVideoPlaylist**](VideoPlaylistsAPI.md#reordervideoplaylist) | **POST** /api/v1/video-playlists/{playlistId}/videos/reorder | Reorder playlist elements
[**reorderVideoPlaylistsOfChannel**](VideoPlaylistsAPI.md#reordervideoplaylistsofchannel) | **POST** /api/v1/video-channels/{channelHandle}/video-playlists/reorder | Reorder channel playlists
[**searchPlaylists**](VideoPlaylistsAPI.md#searchplaylists) | **GET** /api/v1/search/video-playlists | Search playlists


# **addPlaylist**
```swift
    open class func addPlaylist(displayName: String, thumbnailfile: URL? = nil, privacy: VideoPlaylistPrivacySet? = nil, description: String? = nil, videoChannelId: Int? = nil, completion: @escaping (_ data: AddPlaylist200Response?, _ error: Error?) -> Void)
```

Create a video playlist

If the video playlist is set as public, `videoChannelId` is mandatory.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let displayName = "displayName_example" // String | Video playlist display name
let thumbnailfile = URL(string: "https://example.com")! // URL | Video playlist thumbnail file (optional)
let privacy = VideoPlaylistPrivacySet() // VideoPlaylistPrivacySet |  (optional)
let description = "description_example" // String | Video playlist description (optional)
let videoChannelId =  // Int | Video channel in which the playlist will be published (optional)

// Create a video playlist
VideoPlaylistsAPI.addPlaylist(displayName: displayName, thumbnailfile: thumbnailfile, privacy: privacy, description: description, videoChannelId: videoChannelId) { (response, error) in
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
 **displayName** | **String** | Video playlist display name | 
 **thumbnailfile** | **URL** | Video playlist thumbnail file | [optional] 
 **privacy** | [**VideoPlaylistPrivacySet**](VideoPlaylistPrivacySet.md) |  | [optional] 
 **description** | **String** | Video playlist description | [optional] 
 **videoChannelId** | [**Int**](Int.md) | Video channel in which the playlist will be published | [optional] 

### Return type

[**AddPlaylist200Response**](AddPlaylist200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **addVideoPlaylistVideo**
```swift
    open class func addVideoPlaylistVideo(playlistId: Int, addVideoPlaylistVideoRequest: AddVideoPlaylistVideoRequest? = nil, completion: @escaping (_ data: AddVideoPlaylistVideo200Response?, _ error: Error?) -> Void)
```

Add a video in a playlist

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let playlistId = 987 // Int | Playlist id
let addVideoPlaylistVideoRequest = addVideoPlaylistVideo_request(videoId: addVideoPlaylistVideo_request_videoId(), startTimestamp: 123, stopTimestamp: 123) // AddVideoPlaylistVideoRequest |  (optional)

// Add a video in a playlist
VideoPlaylistsAPI.addVideoPlaylistVideo(playlistId: playlistId, addVideoPlaylistVideoRequest: addVideoPlaylistVideoRequest) { (response, error) in
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
 **playlistId** | **Int** | Playlist id | 
 **addVideoPlaylistVideoRequest** | [**AddVideoPlaylistVideoRequest**](AddVideoPlaylistVideoRequest.md) |  | [optional] 

### Return type

[**AddVideoPlaylistVideo200Response**](AddVideoPlaylistVideo200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
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
VideoPlaylistsAPI.apiV1AccountsNameVideoPlaylistsGet(name: name, start: start, count: count, sort: sort, search: search, playlistType: playlistType, includeCollaborations: includeCollaborations, channelNameOneOf: channelNameOneOf) { (response, error) in
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

# **apiV1UsersMeVideoPlaylistsVideosExistGet**
```swift
    open class func apiV1UsersMeVideoPlaylistsVideosExistGet(videoIds: [Int], completion: @escaping (_ data: ApiV1UsersMeVideoPlaylistsVideosExistGet200Response?, _ error: Error?) -> Void)
```

Check video exists in my playlists

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let videoIds = [123] // [Int] | The video ids to check

// Check video exists in my playlists
VideoPlaylistsAPI.apiV1UsersMeVideoPlaylistsVideosExistGet(videoIds: videoIds) { (response, error) in
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
 **videoIds** | [**[Int]**](Int.md) | The video ids to check | 

### Return type

[**ApiV1UsersMeVideoPlaylistsVideosExistGet200Response**](ApiV1UsersMeVideoPlaylistsVideosExistGet200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1VideoChannelsChannelHandleVideoPlaylistsGet**
```swift
    open class func apiV1VideoChannelsChannelHandleVideoPlaylistsGet(channelHandle: String, start: Int? = nil, count: Int? = nil, sort: String? = nil, playlistType: VideoPlaylistTypeSet? = nil, completion: @escaping (_ data: ApiV1VideoChannelsChannelHandleVideoPlaylistsGet200Response?, _ error: Error?) -> Void)
```

List playlists of a channel

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let channelHandle = "channelHandle_example" // String | The video channel handle
let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let sort = "sort_example" // String | Sort column (optional)
let playlistType = VideoPlaylistTypeSet() // VideoPlaylistTypeSet |  (optional)

// List playlists of a channel
VideoPlaylistsAPI.apiV1VideoChannelsChannelHandleVideoPlaylistsGet(channelHandle: channelHandle, start: start, count: count, sort: sort, playlistType: playlistType) { (response, error) in
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
 **sort** | **String** | Sort column | [optional] 
 **playlistType** | [**VideoPlaylistTypeSet**](.md) |  | [optional] 

### Return type

[**ApiV1VideoChannelsChannelHandleVideoPlaylistsGet200Response**](ApiV1VideoChannelsChannelHandleVideoPlaylistsGet200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1VideoPlaylistsPlaylistIdDelete**
```swift
    open class func apiV1VideoPlaylistsPlaylistIdDelete(playlistId: Int, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete a video playlist

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let playlistId = 987 // Int | Playlist id

// Delete a video playlist
VideoPlaylistsAPI.apiV1VideoPlaylistsPlaylistIdDelete(playlistId: playlistId) { (response, error) in
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
 **playlistId** | **Int** | Playlist id | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1VideoPlaylistsPlaylistIdGet**
```swift
    open class func apiV1VideoPlaylistsPlaylistIdGet(playlistId: Int, completion: @escaping (_ data: VideoPlaylist?, _ error: Error?) -> Void)
```

Get a video playlist

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let playlistId = 987 // Int | Playlist id

// Get a video playlist
VideoPlaylistsAPI.apiV1VideoPlaylistsPlaylistIdGet(playlistId: playlistId) { (response, error) in
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
 **playlistId** | **Int** | Playlist id | 

### Return type

[**VideoPlaylist**](VideoPlaylist.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1VideoPlaylistsPlaylistIdPut**
```swift
    open class func apiV1VideoPlaylistsPlaylistIdPut(playlistId: Int, displayName: String? = nil, thumbnailfile: URL? = nil, privacy: VideoPlaylistPrivacySet? = nil, description: String? = nil, videoChannelId: Int? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Update a video playlist

If the video playlist is set as public, the playlist must have a assigned channel.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let playlistId = 987 // Int | Playlist id
let displayName = "displayName_example" // String | Video playlist display name (optional)
let thumbnailfile = URL(string: "https://example.com")! // URL | Video playlist thumbnail file (optional)
let privacy = VideoPlaylistPrivacySet() // VideoPlaylistPrivacySet |  (optional)
let description = "description_example" // String | Video playlist description (optional)
let videoChannelId =  // Int | Video channel in which the playlist will be published (optional)

// Update a video playlist
VideoPlaylistsAPI.apiV1VideoPlaylistsPlaylistIdPut(playlistId: playlistId, displayName: displayName, thumbnailfile: thumbnailfile, privacy: privacy, description: description, videoChannelId: videoChannelId) { (response, error) in
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
 **playlistId** | **Int** | Playlist id | 
 **displayName** | **String** | Video playlist display name | [optional] 
 **thumbnailfile** | **URL** | Video playlist thumbnail file | [optional] 
 **privacy** | [**VideoPlaylistPrivacySet**](VideoPlaylistPrivacySet.md) |  | [optional] 
 **description** | **String** | Video playlist description | [optional] 
 **videoChannelId** | [**Int**](Int.md) | Video channel in which the playlist will be published | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **delVideoPlaylistVideo**
```swift
    open class func delVideoPlaylistVideo(playlistId: Int, playlistElementId: Int, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete an element from a playlist

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let playlistId = 987 // Int | Playlist id
let playlistElementId = 987 // Int | Playlist element id

// Delete an element from a playlist
VideoPlaylistsAPI.delVideoPlaylistVideo(playlistId: playlistId, playlistElementId: playlistElementId) { (response, error) in
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
 **playlistId** | **Int** | Playlist id | 
 **playlistElementId** | **Int** | Playlist element id | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPlaylistPrivacyPolicies**
```swift
    open class func getPlaylistPrivacyPolicies(completion: @escaping (_ data: [String]?, _ error: Error?) -> Void)
```

List available playlist privacy policies

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// List available playlist privacy policies
VideoPlaylistsAPI.getPlaylistPrivacyPolicies() { (response, error) in
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

# **getPlaylists**
```swift
    open class func getPlaylists(start: Int? = nil, count: Int? = nil, sort: String? = nil, playlistType: VideoPlaylistTypeSet? = nil, completion: @escaping (_ data: ApiV1VideoChannelsChannelHandleVideoPlaylistsGet200Response?, _ error: Error?) -> Void)
```

List video playlists

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let sort = "sort_example" // String | Sort column (optional)
let playlistType = VideoPlaylistTypeSet() // VideoPlaylistTypeSet |  (optional)

// List video playlists
VideoPlaylistsAPI.getPlaylists(start: start, count: count, sort: sort, playlistType: playlistType) { (response, error) in
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
 **playlistType** | [**VideoPlaylistTypeSet**](.md) |  | [optional] 

### Return type

[**ApiV1VideoChannelsChannelHandleVideoPlaylistsGet200Response**](ApiV1VideoChannelsChannelHandleVideoPlaylistsGet200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getVideoPlaylistVideos**
```swift
    open class func getVideoPlaylistVideos(playlistId: Int, start: Int? = nil, count: Int? = nil, completion: @escaping (_ data: GetVideoPlaylistVideos200Response?, _ error: Error?) -> Void)
```

List videos of a playlist

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let playlistId = 987 // Int | Playlist id
let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)

// List videos of a playlist
VideoPlaylistsAPI.getVideoPlaylistVideos(playlistId: playlistId, start: start, count: count) { (response, error) in
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
 **playlistId** | **Int** | Playlist id | 
 **start** | **Int** | Offset used to paginate results | [optional] 
 **count** | **Int** | Number of items to return | [optional] [default to 15]

### Return type

[**GetVideoPlaylistVideos200Response**](GetVideoPlaylistVideos200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putVideoPlaylistVideo**
```swift
    open class func putVideoPlaylistVideo(playlistId: Int, playlistElementId: Int, putVideoPlaylistVideoRequest: PutVideoPlaylistVideoRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Update a playlist element

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let playlistId = 987 // Int | Playlist id
let playlistElementId = 987 // Int | Playlist element id
let putVideoPlaylistVideoRequest = putVideoPlaylistVideo_request(startTimestamp: 123, stopTimestamp: 123) // PutVideoPlaylistVideoRequest |  (optional)

// Update a playlist element
VideoPlaylistsAPI.putVideoPlaylistVideo(playlistId: playlistId, playlistElementId: playlistElementId, putVideoPlaylistVideoRequest: putVideoPlaylistVideoRequest) { (response, error) in
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
 **playlistId** | **Int** | Playlist id | 
 **playlistElementId** | **Int** | Playlist element id | 
 **putVideoPlaylistVideoRequest** | [**PutVideoPlaylistVideoRequest**](PutVideoPlaylistVideoRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reorderVideoPlaylist**
```swift
    open class func reorderVideoPlaylist(playlistId: Int, reorderVideoPlaylistsOfChannelRequest: ReorderVideoPlaylistsOfChannelRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Reorder playlist elements

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let playlistId = 987 // Int | Playlist id
let reorderVideoPlaylistsOfChannelRequest = reorderVideoPlaylistsOfChannel_request(startPosition: 123, insertAfterPosition: 123, reorderLength: 123) // ReorderVideoPlaylistsOfChannelRequest |  (optional)

// Reorder playlist elements
VideoPlaylistsAPI.reorderVideoPlaylist(playlistId: playlistId, reorderVideoPlaylistsOfChannelRequest: reorderVideoPlaylistsOfChannelRequest) { (response, error) in
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
 **playlistId** | **Int** | Playlist id | 
 **reorderVideoPlaylistsOfChannelRequest** | [**ReorderVideoPlaylistsOfChannelRequest**](ReorderVideoPlaylistsOfChannelRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reorderVideoPlaylistsOfChannel**
```swift
    open class func reorderVideoPlaylistsOfChannel(channelHandle: String, reorderVideoPlaylistsOfChannelRequest: ReorderVideoPlaylistsOfChannelRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Reorder channel playlists

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let channelHandle = "channelHandle_example" // String | The video channel handle
let reorderVideoPlaylistsOfChannelRequest = reorderVideoPlaylistsOfChannel_request(startPosition: 123, insertAfterPosition: 123, reorderLength: 123) // ReorderVideoPlaylistsOfChannelRequest |  (optional)

// Reorder channel playlists
VideoPlaylistsAPI.reorderVideoPlaylistsOfChannel(channelHandle: channelHandle, reorderVideoPlaylistsOfChannelRequest: reorderVideoPlaylistsOfChannelRequest) { (response, error) in
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
 **reorderVideoPlaylistsOfChannelRequest** | [**ReorderVideoPlaylistsOfChannelRequest**](ReorderVideoPlaylistsOfChannelRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **searchPlaylists**
```swift
    open class func searchPlaylists(search: String, start: Int? = nil, count: Int? = nil, searchTarget: SearchTarget_searchPlaylists? = nil, sort: String? = nil, host: String? = nil, uuids: [String]? = nil, completion: @escaping (_ data: ApiV1VideoChannelsChannelHandleVideoPlaylistsGet200Response?, _ error: Error?) -> Void)
```

Search playlists

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let search = "search_example" // String | String to search. If the user can make a remote URI search, and the string is an URI then the PeerTube instance will fetch the remote object and add it to its database. Then, you can use the REST API to fetch the complete playlist information and interact with it. 
let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let searchTarget = "searchTarget_example" // String | If the administrator enabled search index support, you can override the default search target.  **Warning**: If you choose to make an index search, PeerTube will get results from a third party service. It means the instance may not yet know the objects you fetched. If you want to load video/channel information:   * If the current user has the ability to make a remote URI search (this information is available in the config endpoint),   then reuse the search API to make a search using the object URI so PeerTube instance fetches the remote object and fill its database.   After that, you can use the classic REST API endpoints to fetch the complete object or interact with it   * If the current user doesn't have the ability to make a remote URI search, then redirect the user on the origin instance or fetch   the data from the origin instance API  (optional)
let sort = "sort_example" // String | Sort column (optional)
let host = "host_example" // String | Find elements owned by this host (optional)
let uuids = ["inner_example"] // [String] | Find elements with specific UUIDs (optional)

// Search playlists
VideoPlaylistsAPI.searchPlaylists(search: search, start: start, count: count, searchTarget: searchTarget, sort: sort, host: host, uuids: uuids) { (response, error) in
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
 **search** | **String** | String to search. If the user can make a remote URI search, and the string is an URI then the PeerTube instance will fetch the remote object and add it to its database. Then, you can use the REST API to fetch the complete playlist information and interact with it.  | 
 **start** | **Int** | Offset used to paginate results | [optional] 
 **count** | **Int** | Number of items to return | [optional] [default to 15]
 **searchTarget** | **String** | If the administrator enabled search index support, you can override the default search target.  **Warning**: If you choose to make an index search, PeerTube will get results from a third party service. It means the instance may not yet know the objects you fetched. If you want to load video/channel information:   * If the current user has the ability to make a remote URI search (this information is available in the config endpoint),   then reuse the search API to make a search using the object URI so PeerTube instance fetches the remote object and fill its database.   After that, you can use the classic REST API endpoints to fetch the complete object or interact with it   * If the current user doesn&#39;t have the ability to make a remote URI search, then redirect the user on the origin instance or fetch   the data from the origin instance API  | [optional] 
 **sort** | **String** | Sort column | [optional] 
 **host** | **String** | Find elements owned by this host | [optional] 
 **uuids** | [**[String]**](String.md) | Find elements with specific UUIDs | [optional] 

### Return type

[**ApiV1VideoChannelsChannelHandleVideoPlaylistsGet200Response**](ApiV1VideoChannelsChannelHandleVideoPlaylistsGet200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

