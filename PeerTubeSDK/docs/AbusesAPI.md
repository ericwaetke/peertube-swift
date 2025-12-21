# AbusesAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1AbusesAbuseIdDelete**](AbusesAPI.md#apiv1abusesabuseiddelete) | **DELETE** /api/v1/abuses/{abuseId} | Delete an abuse
[**apiV1AbusesAbuseIdMessagesAbuseMessageIdDelete**](AbusesAPI.md#apiv1abusesabuseidmessagesabusemessageiddelete) | **DELETE** /api/v1/abuses/{abuseId}/messages/{abuseMessageId} | Delete an abuse message
[**apiV1AbusesAbuseIdMessagesGet**](AbusesAPI.md#apiv1abusesabuseidmessagesget) | **GET** /api/v1/abuses/{abuseId}/messages | List messages of an abuse
[**apiV1AbusesAbuseIdMessagesPost**](AbusesAPI.md#apiv1abusesabuseidmessagespost) | **POST** /api/v1/abuses/{abuseId}/messages | Add message to an abuse
[**apiV1AbusesAbuseIdPut**](AbusesAPI.md#apiv1abusesabuseidput) | **PUT** /api/v1/abuses/{abuseId} | Update an abuse
[**apiV1AbusesPost**](AbusesAPI.md#apiv1abusespost) | **POST** /api/v1/abuses | Report an abuse
[**getAbuses**](AbusesAPI.md#getabuses) | **GET** /api/v1/abuses | List abuses
[**getMyAbuses**](AbusesAPI.md#getmyabuses) | **GET** /api/v1/users/me/abuses | List my abuses


# **apiV1AbusesAbuseIdDelete**
```swift
    open class func apiV1AbusesAbuseIdDelete(abuseId: Int, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete an abuse

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let abuseId = 987 // Int | Abuse id

// Delete an abuse
AbusesAPI.apiV1AbusesAbuseIdDelete(abuseId: abuseId) { (response, error) in
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
 **abuseId** | **Int** | Abuse id | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1AbusesAbuseIdMessagesAbuseMessageIdDelete**
```swift
    open class func apiV1AbusesAbuseIdMessagesAbuseMessageIdDelete(abuseId: Int, abuseMessageId: Int, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete an abuse message

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let abuseId = 987 // Int | Abuse id
let abuseMessageId = 987 // Int | Abuse message id

// Delete an abuse message
AbusesAPI.apiV1AbusesAbuseIdMessagesAbuseMessageIdDelete(abuseId: abuseId, abuseMessageId: abuseMessageId) { (response, error) in
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
 **abuseId** | **Int** | Abuse id | 
 **abuseMessageId** | **Int** | Abuse message id | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1AbusesAbuseIdMessagesGet**
```swift
    open class func apiV1AbusesAbuseIdMessagesGet(abuseId: Int, completion: @escaping (_ data: ApiV1AbusesAbuseIdMessagesGet200Response?, _ error: Error?) -> Void)
```

List messages of an abuse

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let abuseId = 987 // Int | Abuse id

// List messages of an abuse
AbusesAPI.apiV1AbusesAbuseIdMessagesGet(abuseId: abuseId) { (response, error) in
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
 **abuseId** | **Int** | Abuse id | 

### Return type

[**ApiV1AbusesAbuseIdMessagesGet200Response**](ApiV1AbusesAbuseIdMessagesGet200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1AbusesAbuseIdMessagesPost**
```swift
    open class func apiV1AbusesAbuseIdMessagesPost(abuseId: Int, apiV1AbusesAbuseIdMessagesPostRequest: ApiV1AbusesAbuseIdMessagesPostRequest, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Add message to an abuse

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let abuseId = 987 // Int | Abuse id
let apiV1AbusesAbuseIdMessagesPostRequest = _api_v1_abuses__abuseId__messages_post_request(message: "message_example") // ApiV1AbusesAbuseIdMessagesPostRequest | 

// Add message to an abuse
AbusesAPI.apiV1AbusesAbuseIdMessagesPost(abuseId: abuseId, apiV1AbusesAbuseIdMessagesPostRequest: apiV1AbusesAbuseIdMessagesPostRequest) { (response, error) in
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
 **abuseId** | **Int** | Abuse id | 
 **apiV1AbusesAbuseIdMessagesPostRequest** | [**ApiV1AbusesAbuseIdMessagesPostRequest**](ApiV1AbusesAbuseIdMessagesPostRequest.md) |  | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1AbusesAbuseIdPut**
```swift
    open class func apiV1AbusesAbuseIdPut(abuseId: Int, apiV1AbusesAbuseIdPutRequest: ApiV1AbusesAbuseIdPutRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Update an abuse

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let abuseId = 987 // Int | Abuse id
let apiV1AbusesAbuseIdPutRequest = _api_v1_abuses__abuseId__put_request(state: AbuseStateSet(), moderationComment: "moderationComment_example") // ApiV1AbusesAbuseIdPutRequest |  (optional)

// Update an abuse
AbusesAPI.apiV1AbusesAbuseIdPut(abuseId: abuseId, apiV1AbusesAbuseIdPutRequest: apiV1AbusesAbuseIdPutRequest) { (response, error) in
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
 **abuseId** | **Int** | Abuse id | 
 **apiV1AbusesAbuseIdPutRequest** | [**ApiV1AbusesAbuseIdPutRequest**](ApiV1AbusesAbuseIdPutRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1AbusesPost**
```swift
    open class func apiV1AbusesPost(apiV1AbusesPostRequest: ApiV1AbusesPostRequest, completion: @escaping (_ data: ApiV1AbusesPost200Response?, _ error: Error?) -> Void)
```

Report an abuse

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let apiV1AbusesPostRequest = _api_v1_abuses_post_request(reason: "reason_example", predefinedReasons: ["predefinedReasons_example"], video: _api_v1_abuses_post_request_video(id: 123, startAt: 123, endAt: 123), comment: _api_v1_abuses_post_request_comment(id: 123), account: _api_v1_abuses_post_request_account(id: 123)) // ApiV1AbusesPostRequest | 

// Report an abuse
AbusesAPI.apiV1AbusesPost(apiV1AbusesPostRequest: apiV1AbusesPostRequest) { (response, error) in
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
 **apiV1AbusesPostRequest** | [**ApiV1AbusesPostRequest**](ApiV1AbusesPostRequest.md) |  | 

### Return type

[**ApiV1AbusesPost200Response**](ApiV1AbusesPost200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAbuses**
```swift
    open class func getAbuses(id: Int? = nil, predefinedReason: [PredefinedReason_getAbuses]? = nil, search: String? = nil, state: AbuseStateSet? = nil, searchReporter: String? = nil, searchReportee: String? = nil, searchVideo: String? = nil, searchVideoChannel: String? = nil, videoIs: VideoIs_getAbuses? = nil, filter: Filter_getAbuses? = nil, start: Int? = nil, count: Int? = nil, sort: Sort_getAbuses? = nil, completion: @escaping (_ data: GetMyAbuses200Response?, _ error: Error?) -> Void)
```

List abuses

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = 987 // Int | only list the report with this id (optional)
let predefinedReason = ["predefinedReason_example"] // [String] | predefined reason the listed reports should contain (optional)
let search = "search_example" // String | plain search that will match with video titles, reporter names and more (optional)
let state = AbuseStateSet() // AbuseStateSet |  (optional)
let searchReporter = "searchReporter_example" // String | only list reports of a specific reporter (optional)
let searchReportee = "searchReportee_example" // String | only list reports of a specific reportee (optional)
let searchVideo = "searchVideo_example" // String | only list reports of a specific video (optional)
let searchVideoChannel = "searchVideoChannel_example" // String | only list reports of a specific video channel (optional)
let videoIs = "videoIs_example" // String | only list deleted or blocklisted videos (optional)
let filter = "filter_example" // String | only list account, comment or video reports (optional)
let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let sort = "sort_example" // String | Sort abuses by criteria (optional)

// List abuses
AbusesAPI.getAbuses(id: id, predefinedReason: predefinedReason, search: search, state: state, searchReporter: searchReporter, searchReportee: searchReportee, searchVideo: searchVideo, searchVideoChannel: searchVideoChannel, videoIs: videoIs, filter: filter, start: start, count: count, sort: sort) { (response, error) in
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
 **id** | **Int** | only list the report with this id | [optional] 
 **predefinedReason** | [**[String]**](String.md) | predefined reason the listed reports should contain | [optional] 
 **search** | **String** | plain search that will match with video titles, reporter names and more | [optional] 
 **state** | [**AbuseStateSet**](.md) |  | [optional] 
 **searchReporter** | **String** | only list reports of a specific reporter | [optional] 
 **searchReportee** | **String** | only list reports of a specific reportee | [optional] 
 **searchVideo** | **String** | only list reports of a specific video | [optional] 
 **searchVideoChannel** | **String** | only list reports of a specific video channel | [optional] 
 **videoIs** | **String** | only list deleted or blocklisted videos | [optional] 
 **filter** | **String** | only list account, comment or video reports | [optional] 
 **start** | **Int** | Offset used to paginate results | [optional] 
 **count** | **Int** | Number of items to return | [optional] [default to 15]
 **sort** | **String** | Sort abuses by criteria | [optional] 

### Return type

[**GetMyAbuses200Response**](GetMyAbuses200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMyAbuses**
```swift
    open class func getMyAbuses(id: Int? = nil, state: AbuseStateSet? = nil, sort: Sort_getMyAbuses? = nil, start: Int? = nil, count: Int? = nil, completion: @escaping (_ data: GetMyAbuses200Response?, _ error: Error?) -> Void)
```

List my abuses

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = 987 // Int | only list the report with this id (optional)
let state = AbuseStateSet() // AbuseStateSet |  (optional)
let sort = "sort_example" // String | Sort abuses by criteria (optional)
let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)

// List my abuses
AbusesAPI.getMyAbuses(id: id, state: state, sort: sort, start: start, count: count) { (response, error) in
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
 **id** | **Int** | only list the report with this id | [optional] 
 **state** | [**AbuseStateSet**](.md) |  | [optional] 
 **sort** | **String** | Sort abuses by criteria | [optional] 
 **start** | **Int** | Offset used to paginate results | [optional] 
 **count** | **Int** | Number of items to return | [optional] [default to 15]

### Return type

[**GetMyAbuses200Response**](GetMyAbuses200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

