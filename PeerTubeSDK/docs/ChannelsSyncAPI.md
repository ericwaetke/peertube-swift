# ChannelsSyncAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addVideoChannelSync**](ChannelsSyncAPI.md#addvideochannelsync) | **POST** /api/v1/video-channel-syncs | Create a synchronization for a video channel
[**apiV1AccountsNameVideoChannelSyncsGet**](ChannelsSyncAPI.md#apiv1accountsnamevideochannelsyncsget) | **GET** /api/v1/accounts/{name}/video-channel-syncs | List the synchronizations of video channels of an account
[**apiV1VideoChannelsChannelHandleImportVideosPost**](ChannelsSyncAPI.md#apiv1videochannelschannelhandleimportvideospost) | **POST** /api/v1/video-channels/{channelHandle}/import-videos | Import videos in channel
[**delVideoChannelSync**](ChannelsSyncAPI.md#delvideochannelsync) | **DELETE** /api/v1/video-channel-syncs/{channelSyncId} | Delete a video channel synchronization
[**triggerVideoChannelSync**](ChannelsSyncAPI.md#triggervideochannelsync) | **POST** /api/v1/video-channel-syncs/{channelSyncId}/sync | Triggers the channel synchronization job, fetching all the videos from the remote channel


# **addVideoChannelSync**
```swift
    open class func addVideoChannelSync(videoChannelSyncCreate: VideoChannelSyncCreate? = nil, completion: @escaping (_ data: AddVideoChannelSync200Response?, _ error: Error?) -> Void)
```

Create a synchronization for a video channel

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let videoChannelSyncCreate = VideoChannelSyncCreate(externalChannelUrl: "externalChannelUrl_example", videoChannelId: 123) // VideoChannelSyncCreate |  (optional)

// Create a synchronization for a video channel
ChannelsSyncAPI.addVideoChannelSync(videoChannelSyncCreate: videoChannelSyncCreate) { (response, error) in
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
 **videoChannelSyncCreate** | [**VideoChannelSyncCreate**](VideoChannelSyncCreate.md) |  | [optional] 

### Return type

[**AddVideoChannelSync200Response**](AddVideoChannelSync200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
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
ChannelsSyncAPI.apiV1AccountsNameVideoChannelSyncsGet(name: name, start: start, count: count, sort: sort, includeCollaborations: includeCollaborations) { (response, error) in
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

# **apiV1VideoChannelsChannelHandleImportVideosPost**
```swift
    open class func apiV1VideoChannelsChannelHandleImportVideosPost(channelHandle: String, importVideosInChannelCreate: ImportVideosInChannelCreate? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Import videos in channel

Import a remote channel/playlist videos into a channel

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let channelHandle = "channelHandle_example" // String | The video channel handle
let importVideosInChannelCreate = ImportVideosInChannelCreate(externalChannelUrl: "externalChannelUrl_example", videoChannelSyncId: 123) // ImportVideosInChannelCreate |  (optional)

// Import videos in channel
ChannelsSyncAPI.apiV1VideoChannelsChannelHandleImportVideosPost(channelHandle: channelHandle, importVideosInChannelCreate: importVideosInChannelCreate) { (response, error) in
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
 **importVideosInChannelCreate** | [**ImportVideosInChannelCreate**](ImportVideosInChannelCreate.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **delVideoChannelSync**
```swift
    open class func delVideoChannelSync(channelSyncId: Int, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete a video channel synchronization

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let channelSyncId = 987 // Int | Channel Sync id

// Delete a video channel synchronization
ChannelsSyncAPI.delVideoChannelSync(channelSyncId: channelSyncId) { (response, error) in
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
 **channelSyncId** | **Int** | Channel Sync id | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **triggerVideoChannelSync**
```swift
    open class func triggerVideoChannelSync(channelSyncId: Int, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Triggers the channel synchronization job, fetching all the videos from the remote channel

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let channelSyncId = 987 // Int | Channel Sync id

// Triggers the channel synchronization job, fetching all the videos from the remote channel
ChannelsSyncAPI.triggerVideoChannelSync(channelSyncId: channelSyncId) { (response, error) in
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
 **channelSyncId** | **Int** | Channel Sync id | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

