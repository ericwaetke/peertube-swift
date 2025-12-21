# MySubscriptionsAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1UsersMeSubscriptionsExistGet**](MySubscriptionsAPI.md#apiv1usersmesubscriptionsexistget) | **GET** /api/v1/users/me/subscriptions/exist | Get if subscriptions exist for my user
[**apiV1UsersMeSubscriptionsGet**](MySubscriptionsAPI.md#apiv1usersmesubscriptionsget) | **GET** /api/v1/users/me/subscriptions | List my user subscriptions
[**apiV1UsersMeSubscriptionsPost**](MySubscriptionsAPI.md#apiv1usersmesubscriptionspost) | **POST** /api/v1/users/me/subscriptions | Add subscription to my user
[**apiV1UsersMeSubscriptionsSubscriptionHandleDelete**](MySubscriptionsAPI.md#apiv1usersmesubscriptionssubscriptionhandledelete) | **DELETE** /api/v1/users/me/subscriptions/{subscriptionHandle} | Delete subscription of my user
[**apiV1UsersMeSubscriptionsSubscriptionHandleGet**](MySubscriptionsAPI.md#apiv1usersmesubscriptionssubscriptionhandleget) | **GET** /api/v1/users/me/subscriptions/{subscriptionHandle} | Get subscription of my user
[**apiV1UsersMeSubscriptionsVideosGet**](MySubscriptionsAPI.md#apiv1usersmesubscriptionsvideosget) | **GET** /api/v1/users/me/subscriptions/videos | List videos of subscriptions of my user


# **apiV1UsersMeSubscriptionsExistGet**
```swift
    open class func apiV1UsersMeSubscriptionsExistGet(uris: [String], completion: @escaping (_ data: JSONValue?, _ error: Error?) -> Void)
```

Get if subscriptions exist for my user

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let uris = ["inner_example"] // [String] | list of uris to check if each is part of the user subscriptions

// Get if subscriptions exist for my user
MySubscriptionsAPI.apiV1UsersMeSubscriptionsExistGet(uris: uris) { (response, error) in
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
 **uris** | [**[String]**](String.md) | list of uris to check if each is part of the user subscriptions | 

### Return type

**JSONValue**

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1UsersMeSubscriptionsGet**
```swift
    open class func apiV1UsersMeSubscriptionsGet(start: Int? = nil, count: Int? = nil, sort: Sort_apiV1UsersMeSubscriptionsGet? = nil, completion: @escaping (_ data: VideoChannelList?, _ error: Error?) -> Void)
```

List my user subscriptions

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let sort = "sort_example" // String |  (optional)

// List my user subscriptions
MySubscriptionsAPI.apiV1UsersMeSubscriptionsGet(start: start, count: count, sort: sort) { (response, error) in
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
 **sort** | **String** |  | [optional] 

### Return type

[**VideoChannelList**](VideoChannelList.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1UsersMeSubscriptionsPost**
```swift
    open class func apiV1UsersMeSubscriptionsPost(apiV1UsersMeSubscriptionsPostRequest: ApiV1UsersMeSubscriptionsPostRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Add subscription to my user

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let apiV1UsersMeSubscriptionsPostRequest = _api_v1_users_me_subscriptions_post_request(uri: "uri_example") // ApiV1UsersMeSubscriptionsPostRequest |  (optional)

// Add subscription to my user
MySubscriptionsAPI.apiV1UsersMeSubscriptionsPost(apiV1UsersMeSubscriptionsPostRequest: apiV1UsersMeSubscriptionsPostRequest) { (response, error) in
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
 **apiV1UsersMeSubscriptionsPostRequest** | [**ApiV1UsersMeSubscriptionsPostRequest**](ApiV1UsersMeSubscriptionsPostRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1UsersMeSubscriptionsSubscriptionHandleDelete**
```swift
    open class func apiV1UsersMeSubscriptionsSubscriptionHandleDelete(subscriptionHandle: String, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete subscription of my user

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let subscriptionHandle = "subscriptionHandle_example" // String | The subscription handle

// Delete subscription of my user
MySubscriptionsAPI.apiV1UsersMeSubscriptionsSubscriptionHandleDelete(subscriptionHandle: subscriptionHandle) { (response, error) in
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
 **subscriptionHandle** | **String** | The subscription handle | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1UsersMeSubscriptionsSubscriptionHandleGet**
```swift
    open class func apiV1UsersMeSubscriptionsSubscriptionHandleGet(subscriptionHandle: String, completion: @escaping (_ data: VideoChannel?, _ error: Error?) -> Void)
```

Get subscription of my user

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let subscriptionHandle = "subscriptionHandle_example" // String | The subscription handle

// Get subscription of my user
MySubscriptionsAPI.apiV1UsersMeSubscriptionsSubscriptionHandleGet(subscriptionHandle: subscriptionHandle) { (response, error) in
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
 **subscriptionHandle** | **String** | The subscription handle | 

### Return type

[**VideoChannel**](VideoChannel.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1UsersMeSubscriptionsVideosGet**
```swift
    open class func apiV1UsersMeSubscriptionsVideosGet(start: Int? = nil, count: Int? = nil, skipCount: SkipCount_apiV1UsersMeSubscriptionsVideosGet? = nil, sort: Sort_apiV1UsersMeSubscriptionsVideosGet? = nil, nsfw: Nsfw_apiV1UsersMeSubscriptionsVideosGet? = nil, nsfwFlagsIncluded: NSFWFlag? = nil, nsfwFlagsExcluded: NSFWFlag? = nil, isLive: Bool? = nil, includeScheduledLive: Bool? = nil, categoryOneOf: GetAccountVideosCategoryOneOfParameter? = nil, licenceOneOf: GetAccountVideosLicenceOneOfParameter? = nil, languageOneOf: GetAccountVideosLanguageOneOfParameter? = nil, tagsOneOf: GetAccountVideosTagsOneOfParameter? = nil, tagsAllOf: GetAccountVideosTagsAllOfParameter? = nil, isLocal: Bool? = nil, include: Include_apiV1UsersMeSubscriptionsVideosGet? = nil, hasHLSFiles: Bool? = nil, hasWebVideoFiles: Bool? = nil, host: String? = nil, autoTagOneOf: GetAccountVideosTagsAllOfParameter? = nil, privacyOneOf: VideoPrivacySet? = nil, excludeAlreadyWatched: Bool? = nil, search: String? = nil, completion: @escaping (_ data: VideoListResponse?, _ error: Error?) -> Void)
```

List videos of subscriptions of my user

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

// List videos of subscriptions of my user
MySubscriptionsAPI.apiV1UsersMeSubscriptionsVideosGet(start: start, count: count, skipCount: skipCount, sort: sort, nsfw: nsfw, nsfwFlagsIncluded: nsfwFlagsIncluded, nsfwFlagsExcluded: nsfwFlagsExcluded, isLive: isLive, includeScheduledLive: includeScheduledLive, categoryOneOf: categoryOneOf, licenceOneOf: licenceOneOf, languageOneOf: languageOneOf, tagsOneOf: tagsOneOf, tagsAllOf: tagsAllOf, isLocal: isLocal, include: include, hasHLSFiles: hasHLSFiles, hasWebVideoFiles: hasWebVideoFiles, host: host, autoTagOneOf: autoTagOneOf, privacyOneOf: privacyOneOf, excludeAlreadyWatched: excludeAlreadyWatched, search: search) { (response, error) in
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

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

