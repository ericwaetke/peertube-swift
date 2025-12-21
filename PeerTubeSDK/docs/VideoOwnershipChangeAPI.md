# VideoOwnershipChangeAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1VideosIdGiveOwnershipPost**](VideoOwnershipChangeAPI.md#apiv1videosidgiveownershippost) | **POST** /api/v1/videos/{id}/give-ownership | Request ownership change
[**apiV1VideosOwnershipGet**](VideoOwnershipChangeAPI.md#apiv1videosownershipget) | **GET** /api/v1/videos/ownership | List video ownership changes
[**apiV1VideosOwnershipIdAcceptPost**](VideoOwnershipChangeAPI.md#apiv1videosownershipidacceptpost) | **POST** /api/v1/videos/ownership/{id}/accept | Accept ownership change request
[**apiV1VideosOwnershipIdRefusePost**](VideoOwnershipChangeAPI.md#apiv1videosownershipidrefusepost) | **POST** /api/v1/videos/ownership/{id}/refuse | Refuse ownership change request


# **apiV1VideosIdGiveOwnershipPost**
```swift
    open class func apiV1VideosIdGiveOwnershipPost(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, apiV1VideosIdGiveOwnershipPostRequest: ApiV1VideosIdGiveOwnershipPostRequest, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Request ownership change

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let apiV1VideosIdGiveOwnershipPostRequest = _api_v1_videos__id__give_ownership_post_request(username: "username_example") // ApiV1VideosIdGiveOwnershipPostRequest | 

// Request ownership change
VideoOwnershipChangeAPI.apiV1VideosIdGiveOwnershipPost(id: id, apiV1VideosIdGiveOwnershipPostRequest: apiV1VideosIdGiveOwnershipPostRequest) { (response, error) in
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
 **apiV1VideosIdGiveOwnershipPostRequest** | [**ApiV1VideosIdGiveOwnershipPostRequest**](ApiV1VideosIdGiveOwnershipPostRequest.md) |  | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1VideosOwnershipGet**
```swift
    open class func apiV1VideosOwnershipGet(completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

List video ownership changes

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// List video ownership changes
VideoOwnershipChangeAPI.apiV1VideosOwnershipGet() { (response, error) in
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
This endpoint does not need any parameter.

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1VideosOwnershipIdAcceptPost**
```swift
    open class func apiV1VideosOwnershipIdAcceptPost(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Accept ownership change request

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid

// Accept ownership change request
VideoOwnershipChangeAPI.apiV1VideosOwnershipIdAcceptPost(id: id) { (response, error) in
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

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1VideosOwnershipIdRefusePost**
```swift
    open class func apiV1VideosOwnershipIdRefusePost(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Refuse ownership change request

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid

// Refuse ownership change request
VideoOwnershipChangeAPI.apiV1VideosOwnershipIdRefusePost(id: id) { (response, error) in
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

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

