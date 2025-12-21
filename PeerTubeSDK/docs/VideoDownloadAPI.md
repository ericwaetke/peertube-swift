# VideoDownloadAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**downloadVideosGenerateVideoIdGet**](VideoDownloadAPI.md#downloadvideosgeneratevideoidget) | **GET** /download/videos/generate/{videoId} | Download video file


# **downloadVideosGenerateVideoIdGet**
```swift
    open class func downloadVideosGenerateVideoIdGet(videoId: Int, videoFileIds: [Int], videoFileToken: String? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Download video file

Generate a mp4 container that contains at most 1 video stream and at most 1 audio stream. Mainly used to merge the HLS audio only video file and the HLS video only resolution file.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let videoId = 987 // Int | The video id
let videoFileIds = [123] // [Int] | streams of video files to mux in the output
let videoFileToken = "videoFileToken_example" // String | Video file token [generated](#operation/requestVideoToken) by PeerTube so you don't need to provide an OAuth token in the request header. (optional)

// Download video file
VideoDownloadAPI.downloadVideosGenerateVideoIdGet(videoId: videoId, videoFileIds: videoFileIds, videoFileToken: videoFileToken) { (response, error) in
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
 **videoFileIds** | [**[Int]**](Int.md) | streams of video files to mux in the output | 
 **videoFileToken** | **String** | Video file token [generated](#operation/requestVideoToken) by PeerTube so you don&#39;t need to provide an OAuth token in the request header. | [optional] 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

