# InstanceFollowsAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1ServerFollowersGet**](InstanceFollowsAPI.md#apiv1serverfollowersget) | **GET** /api/v1/server/followers | List instances following the server
[**apiV1ServerFollowersHandleAcceptPost**](InstanceFollowsAPI.md#apiv1serverfollowershandleacceptpost) | **POST** /api/v1/server/followers/{handle}/accept | Accept a pending follower to your server
[**apiV1ServerFollowersHandleDelete**](InstanceFollowsAPI.md#apiv1serverfollowershandledelete) | **DELETE** /api/v1/server/followers/{handle} | Remove or reject a follower to your server
[**apiV1ServerFollowersHandleRejectPost**](InstanceFollowsAPI.md#apiv1serverfollowershandlerejectpost) | **POST** /api/v1/server/followers/{handle}/reject | Reject a pending follower to your server
[**apiV1ServerFollowingGet**](InstanceFollowsAPI.md#apiv1serverfollowingget) | **GET** /api/v1/server/following | List instances followed by the server
[**apiV1ServerFollowingHostOrHandleDelete**](InstanceFollowsAPI.md#apiv1serverfollowinghostorhandledelete) | **DELETE** /api/v1/server/following/{hostOrHandle} | Unfollow an actor (PeerTube instance, channel or account)
[**apiV1ServerFollowingPost**](InstanceFollowsAPI.md#apiv1serverfollowingpost) | **POST** /api/v1/server/following | Follow a list of actors (PeerTube instance, channel or account)


# **apiV1ServerFollowersGet**
```swift
    open class func apiV1ServerFollowersGet(state: State_apiV1ServerFollowersGet? = nil, actorType: ActorType_apiV1ServerFollowersGet? = nil, start: Int? = nil, count: Int? = nil, sort: String? = nil, completion: @escaping (_ data: GetAccountFollowers200Response?, _ error: Error?) -> Void)
```

List instances following the server

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let state = "state_example" // String |  (optional)
let actorType = "actorType_example" // String |  (optional)
let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let sort = "sort_example" // String | Sort column (optional)

// List instances following the server
InstanceFollowsAPI.apiV1ServerFollowersGet(state: state, actorType: actorType, start: start, count: count, sort: sort) { (response, error) in
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
 **state** | **String** |  | [optional] 
 **actorType** | **String** |  | [optional] 
 **start** | **Int** | Offset used to paginate results | [optional] 
 **count** | **Int** | Number of items to return | [optional] [default to 15]
 **sort** | **String** | Sort column | [optional] 

### Return type

[**GetAccountFollowers200Response**](GetAccountFollowers200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1ServerFollowersHandleAcceptPost**
```swift
    open class func apiV1ServerFollowersHandleAcceptPost(handle: String, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Accept a pending follower to your server

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let handle = "handle_example" // String | The remote actor handle to remove from your followers

// Accept a pending follower to your server
InstanceFollowsAPI.apiV1ServerFollowersHandleAcceptPost(handle: handle) { (response, error) in
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
 **handle** | **String** | The remote actor handle to remove from your followers | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1ServerFollowersHandleDelete**
```swift
    open class func apiV1ServerFollowersHandleDelete(handle: String, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Remove or reject a follower to your server

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let handle = "handle_example" // String | The remote actor handle to remove from your followers

// Remove or reject a follower to your server
InstanceFollowsAPI.apiV1ServerFollowersHandleDelete(handle: handle) { (response, error) in
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
 **handle** | **String** | The remote actor handle to remove from your followers | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1ServerFollowersHandleRejectPost**
```swift
    open class func apiV1ServerFollowersHandleRejectPost(handle: String, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Reject a pending follower to your server

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let handle = "handle_example" // String | The remote actor handle to remove from your followers

// Reject a pending follower to your server
InstanceFollowsAPI.apiV1ServerFollowersHandleRejectPost(handle: handle) { (response, error) in
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
 **handle** | **String** | The remote actor handle to remove from your followers | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1ServerFollowingGet**
```swift
    open class func apiV1ServerFollowingGet(state: State_apiV1ServerFollowingGet? = nil, actorType: ActorType_apiV1ServerFollowingGet? = nil, start: Int? = nil, count: Int? = nil, sort: String? = nil, completion: @escaping (_ data: GetAccountFollowers200Response?, _ error: Error?) -> Void)
```

List instances followed by the server

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let state = "state_example" // String |  (optional)
let actorType = "actorType_example" // String |  (optional)
let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let sort = "sort_example" // String | Sort column (optional)

// List instances followed by the server
InstanceFollowsAPI.apiV1ServerFollowingGet(state: state, actorType: actorType, start: start, count: count, sort: sort) { (response, error) in
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
 **state** | **String** |  | [optional] 
 **actorType** | **String** |  | [optional] 
 **start** | **Int** | Offset used to paginate results | [optional] 
 **count** | **Int** | Number of items to return | [optional] [default to 15]
 **sort** | **String** | Sort column | [optional] 

### Return type

[**GetAccountFollowers200Response**](GetAccountFollowers200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1ServerFollowingHostOrHandleDelete**
```swift
    open class func apiV1ServerFollowingHostOrHandleDelete(hostOrHandle: String, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Unfollow an actor (PeerTube instance, channel or account)

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let hostOrHandle = "hostOrHandle_example" // String | The hostOrHandle to unfollow

// Unfollow an actor (PeerTube instance, channel or account)
InstanceFollowsAPI.apiV1ServerFollowingHostOrHandleDelete(hostOrHandle: hostOrHandle) { (response, error) in
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
 **hostOrHandle** | **String** | The hostOrHandle to unfollow | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1ServerFollowingPost**
```swift
    open class func apiV1ServerFollowingPost(apiV1ServerFollowingPostRequest: ApiV1ServerFollowingPostRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Follow a list of actors (PeerTube instance, channel or account)

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let apiV1ServerFollowingPostRequest = _api_v1_server_following_post_request(hosts: ["hosts_example"], handles: ["handles_example"]) // ApiV1ServerFollowingPostRequest |  (optional)

// Follow a list of actors (PeerTube instance, channel or account)
InstanceFollowsAPI.apiV1ServerFollowingPost(apiV1ServerFollowingPostRequest: apiV1ServerFollowingPostRequest) { (response, error) in
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
 **apiV1ServerFollowingPostRequest** | [**ApiV1ServerFollowingPostRequest**](ApiV1ServerFollowingPostRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

