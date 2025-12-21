# VideoRatesAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1UsersMeVideosVideoIdRatingGet**](VideoRatesAPI.md#apiv1usersmevideosvideoidratingget) | **GET** /api/v1/users/me/videos/{videoId}/rating | Get rate of my user for a video
[**apiV1VideosIdRatePut**](VideoRatesAPI.md#apiv1videosidrateput) | **PUT** /api/v1/videos/{id}/rate | Like/dislike a video


# **apiV1UsersMeVideosVideoIdRatingGet**
```swift
    open class func apiV1UsersMeVideosVideoIdRatingGet(videoId: Int, completion: @escaping (_ data: GetMeVideoRating?, _ error: Error?) -> Void)
```

Get rate of my user for a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let videoId = 987 // Int | The video id

// Get rate of my user for a video
VideoRatesAPI.apiV1UsersMeVideosVideoIdRatingGet(videoId: videoId) { (response, error) in
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

### Return type

[**GetMeVideoRating**](GetMeVideoRating.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1VideosIdRatePut**
```swift
    open class func apiV1VideosIdRatePut(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, xPeertubeVideoPassword: String? = nil, apiV1VideosIdRatePutRequest: ApiV1VideosIdRatePutRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Like/dislike a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let xPeertubeVideoPassword = "xPeertubeVideoPassword_example" // String | Required on password protected video (optional)
let apiV1VideosIdRatePutRequest = _api_v1_videos__id__rate_put_request(rating: "rating_example") // ApiV1VideosIdRatePutRequest |  (optional)

// Like/dislike a video
VideoRatesAPI.apiV1VideosIdRatePut(id: id, xPeertubeVideoPassword: xPeertubeVideoPassword, apiV1VideosIdRatePutRequest: apiV1VideosIdRatePutRequest) { (response, error) in
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
 **xPeertubeVideoPassword** | **String** | Required on password protected video | [optional] 
 **apiV1VideosIdRatePutRequest** | [**ApiV1VideosIdRatePutRequest**](ApiV1VideosIdRatePutRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

