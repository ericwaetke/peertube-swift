# PlayerSettingsAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getChannelPlayerSettings**](PlayerSettingsAPI.md#getchannelplayersettings) | **GET** /api/v1/player-settings/video-channels/{channelHandle} | Get channel player settings
[**getVideoPlayerSettings**](PlayerSettingsAPI.md#getvideoplayersettings) | **GET** /api/v1/player-settings/videos/{id} | Get video player settings
[**updateChannelPlayerSettings**](PlayerSettingsAPI.md#updatechannelplayersettings) | **PUT** /api/v1/player-settings/video-channels/{channelHandle} | Update channel player settings
[**updateVideoPlayerSettings**](PlayerSettingsAPI.md#updatevideoplayersettings) | **PUT** /api/v1/player-settings/videos/{id} | Update video player settings


# **getChannelPlayerSettings**
```swift
    open class func getChannelPlayerSettings(channelHandle: String, raw: Bool? = nil, completion: @escaping (_ data: PlayerChannelSettings?, _ error: Error?) -> Void)
```

Get channel player settings

Get player settings for a video channel.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let channelHandle = "channelHandle_example" // String | The video channel handle
let raw = true // Bool | Return raw settings without applying instance defaults (optional) (default to false)

// Get channel player settings
PlayerSettingsAPI.getChannelPlayerSettings(channelHandle: channelHandle, raw: raw) { (response, error) in
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
 **raw** | **Bool** | Return raw settings without applying instance defaults | [optional] [default to false]

### Return type

[**PlayerChannelSettings**](PlayerChannelSettings.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getVideoPlayerSettings**
```swift
    open class func getVideoPlayerSettings(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, raw: Bool? = nil, completion: @escaping (_ data: PlayerVideoSettings?, _ error: Error?) -> Void)
```

Get video player settings

Get player settings for a specific video. Returns video-specific settings merged with channel player settings.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let raw = true // Bool | Return raw settings without merging channel defaults (optional) (default to false)

// Get video player settings
PlayerSettingsAPI.getVideoPlayerSettings(id: id, raw: raw) { (response, error) in
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
 **raw** | **Bool** | Return raw settings without merging channel defaults | [optional] [default to false]

### Return type

[**PlayerVideoSettings**](PlayerVideoSettings.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateChannelPlayerSettings**
```swift
    open class func updateChannelPlayerSettings(channelHandle: String, playerChannelSettingsUpdate: PlayerChannelSettingsUpdate? = nil, completion: @escaping (_ data: PlayerChannelSettings?, _ error: Error?) -> Void)
```

Update channel player settings

Update default player settings for a video channel.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let channelHandle = "channelHandle_example" // String | The video channel handle
let playerChannelSettingsUpdate = PlayerChannelSettingsUpdate(theme: PlayerThemeChannelSetting()) // PlayerChannelSettingsUpdate |  (optional)

// Update channel player settings
PlayerSettingsAPI.updateChannelPlayerSettings(channelHandle: channelHandle, playerChannelSettingsUpdate: playerChannelSettingsUpdate) { (response, error) in
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
 **playerChannelSettingsUpdate** | [**PlayerChannelSettingsUpdate**](PlayerChannelSettingsUpdate.md) |  | [optional] 

### Return type

[**PlayerChannelSettings**](PlayerChannelSettings.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateVideoPlayerSettings**
```swift
    open class func updateVideoPlayerSettings(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, playerVideoSettingsUpdate: PlayerVideoSettingsUpdate? = nil, completion: @escaping (_ data: PlayerVideoSettings?, _ error: Error?) -> Void)
```

Update video player settings

Update player settings for a specific video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let playerVideoSettingsUpdate = PlayerVideoSettingsUpdate(theme: PlayerThemeVideoSetting()) // PlayerVideoSettingsUpdate |  (optional)

// Update video player settings
PlayerSettingsAPI.updateVideoPlayerSettings(id: id, playerVideoSettingsUpdate: playerVideoSettingsUpdate) { (response, error) in
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
 **playerVideoSettingsUpdate** | [**PlayerVideoSettingsUpdate**](PlayerVideoSettingsUpdate.md) |  | [optional] 

### Return type

[**PlayerVideoSettings**](PlayerVideoSettings.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

