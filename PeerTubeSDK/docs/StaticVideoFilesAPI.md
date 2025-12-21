# StaticVideoFilesAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**staticStreamingPlaylistsHlsFilenameGet**](StaticVideoFilesAPI.md#staticstreamingplaylistshlsfilenameget) | **GET** /static/streaming-playlists/hls/{filename} | Get public HLS video file
[**staticStreamingPlaylistsHlsPrivateFilenameGet**](StaticVideoFilesAPI.md#staticstreamingplaylistshlsprivatefilenameget) | **GET** /static/streaming-playlists/hls/private/{filename} | Get private HLS video file
[**staticWebVideosFilenameGet**](StaticVideoFilesAPI.md#staticwebvideosfilenameget) | **GET** /static/web-videos/{filename} | Get public Web Video file
[**staticWebVideosPrivateFilenameGet**](StaticVideoFilesAPI.md#staticwebvideosprivatefilenameget) | **GET** /static/web-videos/private/{filename} | Get private Web Video file


# **staticStreamingPlaylistsHlsFilenameGet**
```swift
    open class func staticStreamingPlaylistsHlsFilenameGet(filename: String, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Get public HLS video file

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let filename = "filename_example" // String | Filename

// Get public HLS video file
StaticVideoFilesAPI.staticStreamingPlaylistsHlsFilenameGet(filename: filename) { (response, error) in
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
 **filename** | **String** | Filename | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **staticStreamingPlaylistsHlsPrivateFilenameGet**
```swift
    open class func staticStreamingPlaylistsHlsPrivateFilenameGet(filename: String, videoFileToken: String? = nil, reinjectVideoFileToken: Bool? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Get private HLS video file

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let filename = "filename_example" // String | Filename
let videoFileToken = "videoFileToken_example" // String | Video file token [generated](#operation/requestVideoToken) by PeerTube so you don't need to provide an OAuth token in the request header. (optional)
let reinjectVideoFileToken = true // Bool | Ask the server to reinject videoFileToken in URLs in m3u8 playlist (optional)

// Get private HLS video file
StaticVideoFilesAPI.staticStreamingPlaylistsHlsPrivateFilenameGet(filename: filename, videoFileToken: videoFileToken, reinjectVideoFileToken: reinjectVideoFileToken) { (response, error) in
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
 **filename** | **String** | Filename | 
 **videoFileToken** | **String** | Video file token [generated](#operation/requestVideoToken) by PeerTube so you don&#39;t need to provide an OAuth token in the request header. | [optional] 
 **reinjectVideoFileToken** | **Bool** | Ask the server to reinject videoFileToken in URLs in m3u8 playlist | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **staticWebVideosFilenameGet**
```swift
    open class func staticWebVideosFilenameGet(filename: String, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Get public Web Video file

**PeerTube >= 6.0**

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let filename = "filename_example" // String | Filename

// Get public Web Video file
StaticVideoFilesAPI.staticWebVideosFilenameGet(filename: filename) { (response, error) in
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
 **filename** | **String** | Filename | 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **staticWebVideosPrivateFilenameGet**
```swift
    open class func staticWebVideosPrivateFilenameGet(filename: String, videoFileToken: String? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Get private Web Video file

**PeerTube >= 6.0**

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let filename = "filename_example" // String | Filename
let videoFileToken = "videoFileToken_example" // String | Video file token [generated](#operation/requestVideoToken) by PeerTube so you don't need to provide an OAuth token in the request header. (optional)

// Get private Web Video file
StaticVideoFilesAPI.staticWebVideosPrivateFilenameGet(filename: filename, videoFileToken: videoFileToken) { (response, error) in
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
 **filename** | **String** | Filename | 
 **videoFileToken** | **String** | Video file token [generated](#operation/requestVideoToken) by PeerTube so you don&#39;t need to provide an OAuth token in the request header. | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

