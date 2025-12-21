# VideoFeedsAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getSyndicatedComments**](VideoFeedsAPI.md#getsyndicatedcomments) | **GET** /feeds/video-comments.{format} | Comments on videos feeds
[**getSyndicatedSubscriptionVideos**](VideoFeedsAPI.md#getsyndicatedsubscriptionvideos) | **GET** /feeds/subscriptions.{format} | Videos of subscriptions feeds
[**getSyndicatedVideos**](VideoFeedsAPI.md#getsyndicatedvideos) | **GET** /feeds/videos.{format} | Common videos feeds
[**getVideosPodcastFeed**](VideoFeedsAPI.md#getvideospodcastfeed) | **GET** /feeds/podcast/videos.xml | Videos podcast feed


# **getSyndicatedComments**
```swift
    open class func getSyndicatedComments(format: Format_getSyndicatedComments, videoId: String? = nil, accountId: String? = nil, accountName: String? = nil, videoChannelId: String? = nil, videoChannelName: String? = nil, completion: @escaping (_ data: [VideoCommentsForXMLInner]?, _ error: Error?) -> Void)
```

Comments on videos feeds

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let format = "format_example" // String | format expected (we focus on making `rss` the most feature-rich ; it serves [Media RSS](https://www.rssboard.org/media-rss))
let videoId = "videoId_example" // String | limit listing comments to a specific video (optional)
let accountId = "accountId_example" // String | limit listing comments to videos of a specific account (optional)
let accountName = "accountName_example" // String | limit listing comments to videos of a specific account (optional)
let videoChannelId = "videoChannelId_example" // String | limit listing comments to videos of a specific video channel (optional)
let videoChannelName = "videoChannelName_example" // String | limit listing comments to videos of a specific video channel (optional)

// Comments on videos feeds
VideoFeedsAPI.getSyndicatedComments(format: format, videoId: videoId, accountId: accountId, accountName: accountName, videoChannelId: videoChannelId, videoChannelName: videoChannelName) { (response, error) in
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
 **format** | **String** | format expected (we focus on making &#x60;rss&#x60; the most feature-rich ; it serves [Media RSS](https://www.rssboard.org/media-rss)) | 
 **videoId** | **String** | limit listing comments to a specific video | [optional] 
 **accountId** | **String** | limit listing comments to videos of a specific account | [optional] 
 **accountName** | **String** | limit listing comments to videos of a specific account | [optional] 
 **videoChannelId** | **String** | limit listing comments to videos of a specific video channel | [optional] 
 **videoChannelName** | **String** | limit listing comments to videos of a specific video channel | [optional] 

### Return type

[**[VideoCommentsForXMLInner]**](VideoCommentsForXMLInner.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/xml, application/rss+xml, text/xml, application/atom+xml, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSyndicatedSubscriptionVideos**
```swift
    open class func getSyndicatedSubscriptionVideos(format: Format_getSyndicatedSubscriptionVideos, accountId: String, token: String, sort: String? = nil, nsfw: Nsfw_getSyndicatedSubscriptionVideos? = nil, isLocal: Bool? = nil, include: Include_getSyndicatedSubscriptionVideos? = nil, privacyOneOf: VideoPrivacySet? = nil, hasHLSFiles: Bool? = nil, hasWebVideoFiles: Bool? = nil, completion: @escaping (_ data: [VideosForXMLInner]?, _ error: Error?) -> Void)
```

Videos of subscriptions feeds

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let format = "format_example" // String | format expected (we focus on making `rss` the most feature-rich ; it serves [Media RSS](https://www.rssboard.org/media-rss))
let accountId = "accountId_example" // String | limit listing to a specific account
let token = "token_example" // String | private token allowing access
let sort = "sort_example" // String | Sort column (optional)
let nsfw = "nsfw_example" // String | whether to include nsfw videos, if any (optional)
let isLocal = true // Bool | **PeerTube >= 4.0** Display only local or remote objects (optional)
let include = 987 // Int | **Only administrators and moderators can use this parameter**  Include additional videos in results (can be combined using bitwise or operator) - `0` NONE - `1` NOT_PUBLISHED_STATE - `2` BLACKLISTED - `4` BLOCKED_OWNER - `8` FILES - `16` CAPTIONS - `32` VIDEO SOURCE  (optional)
let privacyOneOf = VideoPrivacySet() // VideoPrivacySet | **PeerTube >= 4.0** Display only videos in this specific privacy/privacies (optional)
let hasHLSFiles = true // Bool | **PeerTube >= 4.0** Display only videos that have HLS files (optional)
let hasWebVideoFiles = true // Bool | **PeerTube >= 6.0** Display only videos that have Web Video files (optional)

// Videos of subscriptions feeds
VideoFeedsAPI.getSyndicatedSubscriptionVideos(format: format, accountId: accountId, token: token, sort: sort, nsfw: nsfw, isLocal: isLocal, include: include, privacyOneOf: privacyOneOf, hasHLSFiles: hasHLSFiles, hasWebVideoFiles: hasWebVideoFiles) { (response, error) in
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
 **format** | **String** | format expected (we focus on making &#x60;rss&#x60; the most feature-rich ; it serves [Media RSS](https://www.rssboard.org/media-rss)) | 
 **accountId** | **String** | limit listing to a specific account | 
 **token** | **String** | private token allowing access | 
 **sort** | **String** | Sort column | [optional] 
 **nsfw** | **String** | whether to include nsfw videos, if any | [optional] 
 **isLocal** | **Bool** | **PeerTube &gt;&#x3D; 4.0** Display only local or remote objects | [optional] 
 **include** | **Int** | **Only administrators and moderators can use this parameter**  Include additional videos in results (can be combined using bitwise or operator) - &#x60;0&#x60; NONE - &#x60;1&#x60; NOT_PUBLISHED_STATE - &#x60;2&#x60; BLACKLISTED - &#x60;4&#x60; BLOCKED_OWNER - &#x60;8&#x60; FILES - &#x60;16&#x60; CAPTIONS - &#x60;32&#x60; VIDEO SOURCE  | [optional] 
 **privacyOneOf** | [**VideoPrivacySet**](.md) | **PeerTube &gt;&#x3D; 4.0** Display only videos in this specific privacy/privacies | [optional] 
 **hasHLSFiles** | **Bool** | **PeerTube &gt;&#x3D; 4.0** Display only videos that have HLS files | [optional] 
 **hasWebVideoFiles** | **Bool** | **PeerTube &gt;&#x3D; 6.0** Display only videos that have Web Video files | [optional] 

### Return type

[**[VideosForXMLInner]**](VideosForXMLInner.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/xml, application/rss+xml, text/xml, application/atom+xml, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSyndicatedVideos**
```swift
    open class func getSyndicatedVideos(format: Format_getSyndicatedVideos, accountId: String? = nil, accountName: String? = nil, videoChannelId: String? = nil, videoChannelName: String? = nil, sort: String? = nil, nsfw: Nsfw_getSyndicatedVideos? = nil, isLocal: Bool? = nil, include: Include_getSyndicatedVideos? = nil, privacyOneOf: VideoPrivacySet? = nil, hasHLSFiles: Bool? = nil, hasWebVideoFiles: Bool? = nil, completion: @escaping (_ data: [VideosForXMLInner]?, _ error: Error?) -> Void)
```

Common videos feeds

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let format = "format_example" // String | format expected (we focus on making `rss` the most feature-rich ; it serves [Media RSS](https://www.rssboard.org/media-rss))
let accountId = "accountId_example" // String | limit listing to a specific account (optional)
let accountName = "accountName_example" // String | limit listing to a specific account (optional)
let videoChannelId = "videoChannelId_example" // String | limit listing to a specific video channel (optional)
let videoChannelName = "videoChannelName_example" // String | limit listing to a specific video channel (optional)
let sort = "sort_example" // String | Sort column (optional)
let nsfw = "nsfw_example" // String | whether to include nsfw videos, if any (optional)
let isLocal = true // Bool | **PeerTube >= 4.0** Display only local or remote objects (optional)
let include = 987 // Int | **Only administrators and moderators can use this parameter**  Include additional videos in results (can be combined using bitwise or operator) - `0` NONE - `1` NOT_PUBLISHED_STATE - `2` BLACKLISTED - `4` BLOCKED_OWNER - `8` FILES - `16` CAPTIONS - `32` VIDEO SOURCE  (optional)
let privacyOneOf = VideoPrivacySet() // VideoPrivacySet | **PeerTube >= 4.0** Display only videos in this specific privacy/privacies (optional)
let hasHLSFiles = true // Bool | **PeerTube >= 4.0** Display only videos that have HLS files (optional)
let hasWebVideoFiles = true // Bool | **PeerTube >= 6.0** Display only videos that have Web Video files (optional)

// Common videos feeds
VideoFeedsAPI.getSyndicatedVideos(format: format, accountId: accountId, accountName: accountName, videoChannelId: videoChannelId, videoChannelName: videoChannelName, sort: sort, nsfw: nsfw, isLocal: isLocal, include: include, privacyOneOf: privacyOneOf, hasHLSFiles: hasHLSFiles, hasWebVideoFiles: hasWebVideoFiles) { (response, error) in
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
 **format** | **String** | format expected (we focus on making &#x60;rss&#x60; the most feature-rich ; it serves [Media RSS](https://www.rssboard.org/media-rss)) | 
 **accountId** | **String** | limit listing to a specific account | [optional] 
 **accountName** | **String** | limit listing to a specific account | [optional] 
 **videoChannelId** | **String** | limit listing to a specific video channel | [optional] 
 **videoChannelName** | **String** | limit listing to a specific video channel | [optional] 
 **sort** | **String** | Sort column | [optional] 
 **nsfw** | **String** | whether to include nsfw videos, if any | [optional] 
 **isLocal** | **Bool** | **PeerTube &gt;&#x3D; 4.0** Display only local or remote objects | [optional] 
 **include** | **Int** | **Only administrators and moderators can use this parameter**  Include additional videos in results (can be combined using bitwise or operator) - &#x60;0&#x60; NONE - &#x60;1&#x60; NOT_PUBLISHED_STATE - &#x60;2&#x60; BLACKLISTED - &#x60;4&#x60; BLOCKED_OWNER - &#x60;8&#x60; FILES - &#x60;16&#x60; CAPTIONS - &#x60;32&#x60; VIDEO SOURCE  | [optional] 
 **privacyOneOf** | [**VideoPrivacySet**](.md) | **PeerTube &gt;&#x3D; 4.0** Display only videos in this specific privacy/privacies | [optional] 
 **hasHLSFiles** | **Bool** | **PeerTube &gt;&#x3D; 4.0** Display only videos that have HLS files | [optional] 
 **hasWebVideoFiles** | **Bool** | **PeerTube &gt;&#x3D; 6.0** Display only videos that have Web Video files | [optional] 

### Return type

[**[VideosForXMLInner]**](VideosForXMLInner.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/xml, application/rss+xml, text/xml, application/atom+xml, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getVideosPodcastFeed**
```swift
    open class func getVideosPodcastFeed(videoChannelId: String, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Videos podcast feed

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let videoChannelId = "videoChannelId_example" // String | Limit listing to a specific video channel

// Videos podcast feed
VideoFeedsAPI.getVideosPodcastFeed(videoChannelId: videoChannelId) { (response, error) in
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
 **videoChannelId** | **String** | Limit listing to a specific video channel | 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

