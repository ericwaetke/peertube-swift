# VideoCommentsAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1UsersMeVideosCommentsGet**](VideoCommentsAPI.md#apiv1usersmevideoscommentsget) | **GET** /api/v1/users/me/videos/comments | List comments on user&#39;s videos
[**apiV1VideosCommentsGet**](VideoCommentsAPI.md#apiv1videoscommentsget) | **GET** /api/v1/videos/comments | List instance comments
[**apiV1VideosIdCommentThreadsGet**](VideoCommentsAPI.md#apiv1videosidcommentthreadsget) | **GET** /api/v1/videos/{id}/comment-threads | List threads of a video
[**apiV1VideosIdCommentThreadsPost**](VideoCommentsAPI.md#apiv1videosidcommentthreadspost) | **POST** /api/v1/videos/{id}/comment-threads | Create a thread
[**apiV1VideosIdCommentThreadsThreadIdGet**](VideoCommentsAPI.md#apiv1videosidcommentthreadsthreadidget) | **GET** /api/v1/videos/{id}/comment-threads/{threadId} | Get a thread
[**apiV1VideosIdCommentsCommentIdApprovePost**](VideoCommentsAPI.md#apiv1videosidcommentscommentidapprovepost) | **POST** /api/v1/videos/{id}/comments/{commentId}/approve | Approve a comment
[**apiV1VideosIdCommentsCommentIdDelete**](VideoCommentsAPI.md#apiv1videosidcommentscommentiddelete) | **DELETE** /api/v1/videos/{id}/comments/{commentId} | Delete a comment or a reply
[**apiV1VideosIdCommentsCommentIdPost**](VideoCommentsAPI.md#apiv1videosidcommentscommentidpost) | **POST** /api/v1/videos/{id}/comments/{commentId} | Reply to a thread of a video


# **apiV1UsersMeVideosCommentsGet**
```swift
    open class func apiV1UsersMeVideosCommentsGet(search: String? = nil, searchAccount: String? = nil, searchVideo: String? = nil, videoId: Int? = nil, videoChannelId: Int? = nil, autoTagOneOf: GetAccountVideosTagsAllOfParameter? = nil, isHeldForReview: Bool? = nil, includeCollaborations: Bool? = nil, completion: @escaping (_ data: ApiV1UsersMeVideosCommentsGet200Response?, _ error: Error?) -> Void)
```

List comments on user's videos

**PeerTube >= 6.2**

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let search = "search_example" // String | Plain text search, applied to various parts of the model depending on endpoint (optional)
let searchAccount = "searchAccount_example" // String | Filter comments by searching on the account (optional)
let searchVideo = "searchVideo_example" // String | Filter comments by searching on the video (optional)
let videoId = 987 // Int | Limit results on this specific video (optional)
let videoChannelId = 987 // Int | Limit results on this specific video channel (optional)
let autoTagOneOf = getAccountVideos_tagsAllOf_parameter() // GetAccountVideosTagsAllOfParameter | **PeerTube >= 6.2** filter on comments that contain one of these automatic tags (optional)
let isHeldForReview = true // Bool | only display comments that are held for review (optional)
let includeCollaborations = true // Bool | **PeerTube >= 8.0** Include objects from collaborated channels (optional)

// List comments on user's videos
VideoCommentsAPI.apiV1UsersMeVideosCommentsGet(search: search, searchAccount: searchAccount, searchVideo: searchVideo, videoId: videoId, videoChannelId: videoChannelId, autoTagOneOf: autoTagOneOf, isHeldForReview: isHeldForReview, includeCollaborations: includeCollaborations) { (response, error) in
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
 **search** | **String** | Plain text search, applied to various parts of the model depending on endpoint | [optional] 
 **searchAccount** | **String** | Filter comments by searching on the account | [optional] 
 **searchVideo** | **String** | Filter comments by searching on the video | [optional] 
 **videoId** | **Int** | Limit results on this specific video | [optional] 
 **videoChannelId** | **Int** | Limit results on this specific video channel | [optional] 
 **autoTagOneOf** | [**GetAccountVideosTagsAllOfParameter**](.md) | **PeerTube &gt;&#x3D; 6.2** filter on comments that contain one of these automatic tags | [optional] 
 **isHeldForReview** | **Bool** | only display comments that are held for review | [optional] 
 **includeCollaborations** | **Bool** | **PeerTube &gt;&#x3D; 8.0** Include objects from collaborated channels | [optional] 

### Return type

[**ApiV1UsersMeVideosCommentsGet200Response**](ApiV1UsersMeVideosCommentsGet200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1VideosCommentsGet**
```swift
    open class func apiV1VideosCommentsGet(search: String? = nil, searchAccount: String? = nil, searchVideo: String? = nil, videoId: Int? = nil, videoChannelId: Int? = nil, autoTagOneOf: GetAccountVideosTagsAllOfParameter? = nil, isLocal: Bool? = nil, onLocalVideo: Bool? = nil, completion: @escaping (_ data: ApiV1UsersMeVideosCommentsGet200Response?, _ error: Error?) -> Void)
```

List instance comments

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let search = "search_example" // String | Plain text search, applied to various parts of the model depending on endpoint (optional)
let searchAccount = "searchAccount_example" // String | Filter comments by searching on the account (optional)
let searchVideo = "searchVideo_example" // String | Filter comments by searching on the video (optional)
let videoId = 987 // Int | Limit results on this specific video (optional)
let videoChannelId = 987 // Int | Limit results on this specific video channel (optional)
let autoTagOneOf = getAccountVideos_tagsAllOf_parameter() // GetAccountVideosTagsAllOfParameter | **PeerTube >= 6.2** filter on comments that contain one of these automatic tags (optional)
let isLocal = true // Bool | **PeerTube >= 4.0** Display only local or remote objects (optional)
let onLocalVideo = true // Bool | Display only objects of local or remote videos (optional)

// List instance comments
VideoCommentsAPI.apiV1VideosCommentsGet(search: search, searchAccount: searchAccount, searchVideo: searchVideo, videoId: videoId, videoChannelId: videoChannelId, autoTagOneOf: autoTagOneOf, isLocal: isLocal, onLocalVideo: onLocalVideo) { (response, error) in
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
 **search** | **String** | Plain text search, applied to various parts of the model depending on endpoint | [optional] 
 **searchAccount** | **String** | Filter comments by searching on the account | [optional] 
 **searchVideo** | **String** | Filter comments by searching on the video | [optional] 
 **videoId** | **Int** | Limit results on this specific video | [optional] 
 **videoChannelId** | **Int** | Limit results on this specific video channel | [optional] 
 **autoTagOneOf** | [**GetAccountVideosTagsAllOfParameter**](.md) | **PeerTube &gt;&#x3D; 6.2** filter on comments that contain one of these automatic tags | [optional] 
 **isLocal** | **Bool** | **PeerTube &gt;&#x3D; 4.0** Display only local or remote objects | [optional] 
 **onLocalVideo** | **Bool** | Display only objects of local or remote videos | [optional] 

### Return type

[**ApiV1UsersMeVideosCommentsGet200Response**](ApiV1UsersMeVideosCommentsGet200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1VideosIdCommentThreadsGet**
```swift
    open class func apiV1VideosIdCommentThreadsGet(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, start: Int? = nil, count: Int? = nil, sort: Sort_apiV1VideosIdCommentThreadsGet? = nil, xPeertubeVideoPassword: String? = nil, completion: @escaping (_ data: CommentThreadResponse?, _ error: Error?) -> Void)
```

List threads of a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let sort = "sort_example" // String | Sort comments by criteria (optional)
let xPeertubeVideoPassword = "xPeertubeVideoPassword_example" // String | Required on password protected video (optional)

// List threads of a video
VideoCommentsAPI.apiV1VideosIdCommentThreadsGet(id: id, start: start, count: count, sort: sort, xPeertubeVideoPassword: xPeertubeVideoPassword) { (response, error) in
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
 **start** | **Int** | Offset used to paginate results | [optional] 
 **count** | **Int** | Number of items to return | [optional] [default to 15]
 **sort** | **String** | Sort comments by criteria | [optional] 
 **xPeertubeVideoPassword** | **String** | Required on password protected video | [optional] 

### Return type

[**CommentThreadResponse**](CommentThreadResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1VideosIdCommentThreadsPost**
```swift
    open class func apiV1VideosIdCommentThreadsPost(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, apiV1VideosIdCommentThreadsPostRequest: ApiV1VideosIdCommentThreadsPostRequest? = nil, completion: @escaping (_ data: CommentThreadPostResponse?, _ error: Error?) -> Void)
```

Create a thread

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let apiV1VideosIdCommentThreadsPostRequest = _api_v1_videos__id__comment_threads_post_request(text: "text_example") // ApiV1VideosIdCommentThreadsPostRequest |  (optional)

// Create a thread
VideoCommentsAPI.apiV1VideosIdCommentThreadsPost(id: id, apiV1VideosIdCommentThreadsPostRequest: apiV1VideosIdCommentThreadsPostRequest) { (response, error) in
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
 **apiV1VideosIdCommentThreadsPostRequest** | [**ApiV1VideosIdCommentThreadsPostRequest**](ApiV1VideosIdCommentThreadsPostRequest.md) |  | [optional] 

### Return type

[**CommentThreadPostResponse**](CommentThreadPostResponse.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1VideosIdCommentThreadsThreadIdGet**
```swift
    open class func apiV1VideosIdCommentThreadsThreadIdGet(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, threadId: Int, xPeertubeVideoPassword: String? = nil, completion: @escaping (_ data: VideoCommentThreadTree?, _ error: Error?) -> Void)
```

Get a thread

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let threadId = 987 // Int | The thread id (root comment id)
let xPeertubeVideoPassword = "xPeertubeVideoPassword_example" // String | Required on password protected video (optional)

// Get a thread
VideoCommentsAPI.apiV1VideosIdCommentThreadsThreadIdGet(id: id, threadId: threadId, xPeertubeVideoPassword: xPeertubeVideoPassword) { (response, error) in
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
 **threadId** | **Int** | The thread id (root comment id) | 
 **xPeertubeVideoPassword** | **String** | Required on password protected video | [optional] 

### Return type

[**VideoCommentThreadTree**](VideoCommentThreadTree.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1VideosIdCommentsCommentIdApprovePost**
```swift
    open class func apiV1VideosIdCommentsCommentIdApprovePost(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, commentId: Int, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Approve a comment

**PeerTube >= 6.2** Approve a comment that requires a review

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let commentId = 987 // Int | The comment id

// Approve a comment
VideoCommentsAPI.apiV1VideosIdCommentsCommentIdApprovePost(id: id, commentId: commentId) { (response, error) in
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
 **commentId** | **Int** | The comment id | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1VideosIdCommentsCommentIdDelete**
```swift
    open class func apiV1VideosIdCommentsCommentIdDelete(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, commentId: Int, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete a comment or a reply

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let commentId = 987 // Int | The comment id

// Delete a comment or a reply
VideoCommentsAPI.apiV1VideosIdCommentsCommentIdDelete(id: id, commentId: commentId) { (response, error) in
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
 **commentId** | **Int** | The comment id | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1VideosIdCommentsCommentIdPost**
```swift
    open class func apiV1VideosIdCommentsCommentIdPost(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, commentId: Int, xPeertubeVideoPassword: String? = nil, apiV1VideosIdCommentThreadsPostRequest: ApiV1VideosIdCommentThreadsPostRequest? = nil, completion: @escaping (_ data: CommentThreadPostResponse?, _ error: Error?) -> Void)
```

Reply to a thread of a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let commentId = 987 // Int | The comment id
let xPeertubeVideoPassword = "xPeertubeVideoPassword_example" // String | Required on password protected video (optional)
let apiV1VideosIdCommentThreadsPostRequest = _api_v1_videos__id__comment_threads_post_request(text: "text_example") // ApiV1VideosIdCommentThreadsPostRequest |  (optional)

// Reply to a thread of a video
VideoCommentsAPI.apiV1VideosIdCommentsCommentIdPost(id: id, commentId: commentId, xPeertubeVideoPassword: xPeertubeVideoPassword, apiV1VideosIdCommentThreadsPostRequest: apiV1VideosIdCommentThreadsPostRequest) { (response, error) in
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
 **commentId** | **Int** | The comment id | 
 **xPeertubeVideoPassword** | **String** | Required on password protected video | [optional] 
 **apiV1VideosIdCommentThreadsPostRequest** | [**ApiV1VideosIdCommentThreadsPostRequest**](ApiV1VideosIdCommentThreadsPostRequest.md) |  | [optional] 

### Return type

[**CommentThreadPostResponse**](CommentThreadPostResponse.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

