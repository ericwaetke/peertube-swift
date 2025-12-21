# RunnerJobsAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1RunnersJobsGet**](RunnerJobsAPI.md#apiv1runnersjobsget) | **GET** /api/v1/runners/jobs | List jobs
[**apiV1RunnersJobsJobUUIDAbortPost**](RunnerJobsAPI.md#apiv1runnersjobsjobuuidabortpost) | **POST** /api/v1/runners/jobs/{jobUUID}/abort | Abort job
[**apiV1RunnersJobsJobUUIDAcceptPost**](RunnerJobsAPI.md#apiv1runnersjobsjobuuidacceptpost) | **POST** /api/v1/runners/jobs/{jobUUID}/accept | Accept job
[**apiV1RunnersJobsJobUUIDCancelGet**](RunnerJobsAPI.md#apiv1runnersjobsjobuuidcancelget) | **GET** /api/v1/runners/jobs/{jobUUID}/cancel | Cancel a job
[**apiV1RunnersJobsJobUUIDDelete**](RunnerJobsAPI.md#apiv1runnersjobsjobuuiddelete) | **DELETE** /api/v1/runners/jobs/{jobUUID} | Delete a job
[**apiV1RunnersJobsJobUUIDErrorPost**](RunnerJobsAPI.md#apiv1runnersjobsjobuuiderrorpost) | **POST** /api/v1/runners/jobs/{jobUUID}/error | Post job error
[**apiV1RunnersJobsJobUUIDSuccessPost**](RunnerJobsAPI.md#apiv1runnersjobsjobuuidsuccesspost) | **POST** /api/v1/runners/jobs/{jobUUID}/success | Post job success
[**apiV1RunnersJobsJobUUIDUpdatePost**](RunnerJobsAPI.md#apiv1runnersjobsjobuuidupdatepost) | **POST** /api/v1/runners/jobs/{jobUUID}/update | Update job
[**apiV1RunnersJobsRequestPost**](RunnerJobsAPI.md#apiv1runnersjobsrequestpost) | **POST** /api/v1/runners/jobs/request | Request a new job


# **apiV1RunnersJobsGet**
```swift
    open class func apiV1RunnersJobsGet(start: Int? = nil, count: Int? = nil, sort: Sort_apiV1RunnersJobsGet? = nil, search: String? = nil, stateOneOf: [RunnerJobState]? = nil, completion: @escaping (_ data: ApiV1RunnersJobsGet200Response?, _ error: Error?) -> Void)
```

List jobs

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let sort = "sort_example" // String | Sort runner jobs by criteria (optional)
let search = "search_example" // String | Plain text search, applied to various parts of the model depending on endpoint (optional)
let stateOneOf = [RunnerJobState()] // [RunnerJobState] |  (optional)

// List jobs
RunnerJobsAPI.apiV1RunnersJobsGet(start: start, count: count, sort: sort, search: search, stateOneOf: stateOneOf) { (response, error) in
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
 **sort** | **String** | Sort runner jobs by criteria | [optional] 
 **search** | **String** | Plain text search, applied to various parts of the model depending on endpoint | [optional] 
 **stateOneOf** | [**[RunnerJobState]**](RunnerJobState.md) |  | [optional] 

### Return type

[**ApiV1RunnersJobsGet200Response**](ApiV1RunnersJobsGet200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1RunnersJobsJobUUIDAbortPost**
```swift
    open class func apiV1RunnersJobsJobUUIDAbortPost(jobUUID: UUID, apiV1RunnersJobsJobUUIDAbortPostRequest: ApiV1RunnersJobsJobUUIDAbortPostRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Abort job

API used by PeerTube runners

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let jobUUID = 987 // UUID | 
let apiV1RunnersJobsJobUUIDAbortPostRequest = _api_v1_runners_jobs__jobUUID__abort_post_request(runnerToken: "runnerToken_example", jobToken: "jobToken_example", reason: "reason_example") // ApiV1RunnersJobsJobUUIDAbortPostRequest |  (optional)

// Abort job
RunnerJobsAPI.apiV1RunnersJobsJobUUIDAbortPost(jobUUID: jobUUID, apiV1RunnersJobsJobUUIDAbortPostRequest: apiV1RunnersJobsJobUUIDAbortPostRequest) { (response, error) in
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
 **jobUUID** | **UUID** |  | 
 **apiV1RunnersJobsJobUUIDAbortPostRequest** | [**ApiV1RunnersJobsJobUUIDAbortPostRequest**](ApiV1RunnersJobsJobUUIDAbortPostRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1RunnersJobsJobUUIDAcceptPost**
```swift
    open class func apiV1RunnersJobsJobUUIDAcceptPost(jobUUID: UUID, apiV1RunnersUnregisterPostRequest: ApiV1RunnersUnregisterPostRequest? = nil, completion: @escaping (_ data: ApiV1RunnersJobsJobUUIDAcceptPost200Response?, _ error: Error?) -> Void)
```

Accept job

API used by PeerTube runners

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let jobUUID = 987 // UUID | 
let apiV1RunnersUnregisterPostRequest = _api_v1_runners_unregister_post_request(runnerToken: "runnerToken_example") // ApiV1RunnersUnregisterPostRequest |  (optional)

// Accept job
RunnerJobsAPI.apiV1RunnersJobsJobUUIDAcceptPost(jobUUID: jobUUID, apiV1RunnersUnregisterPostRequest: apiV1RunnersUnregisterPostRequest) { (response, error) in
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
 **jobUUID** | **UUID** |  | 
 **apiV1RunnersUnregisterPostRequest** | [**ApiV1RunnersUnregisterPostRequest**](ApiV1RunnersUnregisterPostRequest.md) |  | [optional] 

### Return type

[**ApiV1RunnersJobsJobUUIDAcceptPost200Response**](ApiV1RunnersJobsJobUUIDAcceptPost200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1RunnersJobsJobUUIDCancelGet**
```swift
    open class func apiV1RunnersJobsJobUUIDCancelGet(jobUUID: UUID, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Cancel a job

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let jobUUID = 987 // UUID | 

// Cancel a job
RunnerJobsAPI.apiV1RunnersJobsJobUUIDCancelGet(jobUUID: jobUUID) { (response, error) in
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
 **jobUUID** | **UUID** |  | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1RunnersJobsJobUUIDDelete**
```swift
    open class func apiV1RunnersJobsJobUUIDDelete(jobUUID: UUID, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete a job

The endpoint will first cancel the job if needed, and then remove it from the database. Children jobs will also be removed

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let jobUUID = 987 // UUID | 

// Delete a job
RunnerJobsAPI.apiV1RunnersJobsJobUUIDDelete(jobUUID: jobUUID) { (response, error) in
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
 **jobUUID** | **UUID** |  | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1RunnersJobsJobUUIDErrorPost**
```swift
    open class func apiV1RunnersJobsJobUUIDErrorPost(jobUUID: UUID, apiV1RunnersJobsJobUUIDErrorPostRequest: ApiV1RunnersJobsJobUUIDErrorPostRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Post job error

API used by PeerTube runners

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let jobUUID = 987 // UUID | 
let apiV1RunnersJobsJobUUIDErrorPostRequest = _api_v1_runners_jobs__jobUUID__error_post_request(runnerToken: "runnerToken_example", jobToken: "jobToken_example", message: "message_example") // ApiV1RunnersJobsJobUUIDErrorPostRequest |  (optional)

// Post job error
RunnerJobsAPI.apiV1RunnersJobsJobUUIDErrorPost(jobUUID: jobUUID, apiV1RunnersJobsJobUUIDErrorPostRequest: apiV1RunnersJobsJobUUIDErrorPostRequest) { (response, error) in
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
 **jobUUID** | **UUID** |  | 
 **apiV1RunnersJobsJobUUIDErrorPostRequest** | [**ApiV1RunnersJobsJobUUIDErrorPostRequest**](ApiV1RunnersJobsJobUUIDErrorPostRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1RunnersJobsJobUUIDSuccessPost**
```swift
    open class func apiV1RunnersJobsJobUUIDSuccessPost(jobUUID: UUID, apiV1RunnersJobsJobUUIDSuccessPostRequest: ApiV1RunnersJobsJobUUIDSuccessPostRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Post job success

API used by PeerTube runners

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let jobUUID = 987 // UUID | 
let apiV1RunnersJobsJobUUIDSuccessPostRequest = _api_v1_runners_jobs__jobUUID__success_post_request(runnerToken: "runnerToken_example", jobToken: "jobToken_example", payload: _api_v1_runners_jobs__jobUUID__success_post_request_payload(videoFile: URL(string: "https://example.com")!, resolutionPlaylistFile: URL(string: "https://example.com")!)) // ApiV1RunnersJobsJobUUIDSuccessPostRequest |  (optional)

// Post job success
RunnerJobsAPI.apiV1RunnersJobsJobUUIDSuccessPost(jobUUID: jobUUID, apiV1RunnersJobsJobUUIDSuccessPostRequest: apiV1RunnersJobsJobUUIDSuccessPostRequest) { (response, error) in
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
 **jobUUID** | **UUID** |  | 
 **apiV1RunnersJobsJobUUIDSuccessPostRequest** | [**ApiV1RunnersJobsJobUUIDSuccessPostRequest**](ApiV1RunnersJobsJobUUIDSuccessPostRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1RunnersJobsJobUUIDUpdatePost**
```swift
    open class func apiV1RunnersJobsJobUUIDUpdatePost(jobUUID: UUID, apiV1RunnersJobsJobUUIDUpdatePostRequest: ApiV1RunnersJobsJobUUIDUpdatePostRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Update job

API used by PeerTube runners

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let jobUUID = 987 // UUID | 
let apiV1RunnersJobsJobUUIDUpdatePostRequest = _api_v1_runners_jobs__jobUUID__update_post_request(runnerToken: "runnerToken_example", jobToken: "jobToken_example", progress: 123, payload: _api_v1_runners_jobs__jobUUID__update_post_request_payload(type: "type_example", masterPlaylistFile: URL(string: "https://example.com")!, resolutionPlaylistFile: URL(string: "https://example.com")!, resolutionPlaylistFilename: "resolutionPlaylistFilename_example", videoChunkFile: URL(string: "https://example.com")!, videoChunkFilename: "videoChunkFilename_example")) // ApiV1RunnersJobsJobUUIDUpdatePostRequest |  (optional)

// Update job
RunnerJobsAPI.apiV1RunnersJobsJobUUIDUpdatePost(jobUUID: jobUUID, apiV1RunnersJobsJobUUIDUpdatePostRequest: apiV1RunnersJobsJobUUIDUpdatePostRequest) { (response, error) in
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
 **jobUUID** | **UUID** |  | 
 **apiV1RunnersJobsJobUUIDUpdatePostRequest** | [**ApiV1RunnersJobsJobUUIDUpdatePostRequest**](ApiV1RunnersJobsJobUUIDUpdatePostRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1RunnersJobsRequestPost**
```swift
    open class func apiV1RunnersJobsRequestPost(apiV1RunnersJobsRequestPostRequest: ApiV1RunnersJobsRequestPostRequest? = nil, completion: @escaping (_ data: ApiV1RunnersJobsRequestPost200Response?, _ error: Error?) -> Void)
```

Request a new job

API used by PeerTube runners

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let apiV1RunnersJobsRequestPostRequest = _api_v1_runners_jobs_request_post_request(runnerToken: "runnerToken_example", jobTypes: ["jobTypes_example"]) // ApiV1RunnersJobsRequestPostRequest |  (optional)

// Request a new job
RunnerJobsAPI.apiV1RunnersJobsRequestPost(apiV1RunnersJobsRequestPostRequest: apiV1RunnersJobsRequestPostRequest) { (response, error) in
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
 **apiV1RunnersJobsRequestPostRequest** | [**ApiV1RunnersJobsRequestPostRequest**](ApiV1RunnersJobsRequestPostRequest.md) |  | [optional] 

### Return type

[**ApiV1RunnersJobsRequestPost200Response**](ApiV1RunnersJobsRequestPost200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

