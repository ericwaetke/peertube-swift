# JobAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1JobsPausePost**](JobAPI.md#apiv1jobspausepost) | **POST** /api/v1/jobs/pause | Pause job queue
[**apiV1JobsResumePost**](JobAPI.md#apiv1jobsresumepost) | **POST** /api/v1/jobs/resume | Resume job queue
[**getJobs**](JobAPI.md#getjobs) | **GET** /api/v1/jobs/{state} | List instance jobs


# **apiV1JobsPausePost**
```swift
    open class func apiV1JobsPausePost(completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Pause job queue

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// Pause job queue
JobAPI.apiV1JobsPausePost() { (response, error) in
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

# **apiV1JobsResumePost**
```swift
    open class func apiV1JobsResumePost(completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Resume job queue

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// Resume job queue
JobAPI.apiV1JobsResumePost() { (response, error) in
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

# **getJobs**
```swift
    open class func getJobs(state: State_getJobs, jobType: JobType_getJobs? = nil, start: Int? = nil, count: Int? = nil, sort: String? = nil, completion: @escaping (_ data: GetJobs200Response?, _ error: Error?) -> Void)
```

List instance jobs

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let state = "state_example" // String | The state of the job ('' for for no filter)
let jobType = "jobType_example" // String | job type (optional)
let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let sort = "sort_example" // String | Sort column (optional)

// List instance jobs
JobAPI.getJobs(state: state, jobType: jobType, start: start, count: count, sort: sort) { (response, error) in
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
 **state** | **String** | The state of the job (&#39;&#39; for for no filter) | 
 **jobType** | **String** | job type | [optional] 
 **start** | **Int** | Offset used to paginate results | [optional] 
 **count** | **Int** | Number of items to return | [optional] [default to 15]
 **sort** | **String** | Sort column | [optional] 

### Return type

[**GetJobs200Response**](GetJobs200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

