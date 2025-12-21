# MyHistoryAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1UsersMeHistoryVideosGet**](MyHistoryAPI.md#apiv1usersmehistoryvideosget) | **GET** /api/v1/users/me/history/videos | List watched videos history
[**apiV1UsersMeHistoryVideosRemovePost**](MyHistoryAPI.md#apiv1usersmehistoryvideosremovepost) | **POST** /api/v1/users/me/history/videos/remove | Clear video history
[**apiV1UsersMeHistoryVideosVideoIdDelete**](MyHistoryAPI.md#apiv1usersmehistoryvideosvideoiddelete) | **DELETE** /api/v1/users/me/history/videos/{videoId} | Delete history element


# **apiV1UsersMeHistoryVideosGet**
```swift
    open class func apiV1UsersMeHistoryVideosGet(start: Int? = nil, count: Int? = nil, search: String? = nil, completion: @escaping (_ data: VideoListResponse?, _ error: Error?) -> Void)
```

List watched videos history

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let search = "search_example" // String | Plain text search, applied to various parts of the model depending on endpoint (optional)

// List watched videos history
MyHistoryAPI.apiV1UsersMeHistoryVideosGet(start: start, count: count, search: search) { (response, error) in
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
 **search** | **String** | Plain text search, applied to various parts of the model depending on endpoint | [optional] 

### Return type

[**VideoListResponse**](VideoListResponse.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1UsersMeHistoryVideosRemovePost**
```swift
    open class func apiV1UsersMeHistoryVideosRemovePost(beforeDate: Date? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Clear video history

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let beforeDate = Date() // Date | history before this date will be deleted (optional)

// Clear video history
MyHistoryAPI.apiV1UsersMeHistoryVideosRemovePost(beforeDate: beforeDate) { (response, error) in
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
 **beforeDate** | **Date** | history before this date will be deleted | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1UsersMeHistoryVideosVideoIdDelete**
```swift
    open class func apiV1UsersMeHistoryVideosVideoIdDelete(videoId: Int, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete history element

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let videoId = 987 // Int | 

// Delete history element
MyHistoryAPI.apiV1UsersMeHistoryVideosVideoIdDelete(videoId: videoId) { (response, error) in
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
 **videoId** | **Int** |  | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

