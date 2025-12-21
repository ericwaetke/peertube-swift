# VideoMirroringAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**delMirroredVideo**](VideoMirroringAPI.md#delmirroredvideo) | **DELETE** /api/v1/server/redundancy/videos/{redundancyId} | Delete a mirror done on a video
[**getMirroredVideos**](VideoMirroringAPI.md#getmirroredvideos) | **GET** /api/v1/server/redundancy/videos | List videos being mirrored
[**putMirroredVideo**](VideoMirroringAPI.md#putmirroredvideo) | **POST** /api/v1/server/redundancy/videos | Mirror a video


# **delMirroredVideo**
```swift
    open class func delMirroredVideo(redundancyId: String, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete a mirror done on a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let redundancyId = "redundancyId_example" // String | id of an existing redundancy on a video

// Delete a mirror done on a video
VideoMirroringAPI.delMirroredVideo(redundancyId: redundancyId) { (response, error) in
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
 **redundancyId** | **String** | id of an existing redundancy on a video | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMirroredVideos**
```swift
    open class func getMirroredVideos(target: Target_getMirroredVideos, start: Int? = nil, count: Int? = nil, sort: Sort_getMirroredVideos? = nil, completion: @escaping (_ data: [VideoRedundancy]?, _ error: Error?) -> Void)
```

List videos being mirrored

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let target = "target_example" // String | direction of the mirror
let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let sort = "sort_example" // String | Sort abuses by criteria (optional)

// List videos being mirrored
VideoMirroringAPI.getMirroredVideos(target: target, start: start, count: count, sort: sort) { (response, error) in
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
 **target** | **String** | direction of the mirror | 
 **start** | **Int** | Offset used to paginate results | [optional] 
 **count** | **Int** | Number of items to return | [optional] [default to 15]
 **sort** | **String** | Sort abuses by criteria | [optional] 

### Return type

[**[VideoRedundancy]**](VideoRedundancy.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putMirroredVideo**
```swift
    open class func putMirroredVideo(putMirroredVideoRequest: PutMirroredVideoRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Mirror a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let putMirroredVideoRequest = putMirroredVideo_request(videoId: 123) // PutMirroredVideoRequest |  (optional)

// Mirror a video
VideoMirroringAPI.putMirroredVideo(putMirroredVideoRequest: putMirroredVideoRequest) { (response, error) in
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
 **putMirroredVideoRequest** | [**PutMirroredVideoRequest**](PutMirroredVideoRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

