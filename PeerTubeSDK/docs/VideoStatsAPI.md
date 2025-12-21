# VideoStatsAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1VideosIdStatsOverallGet**](VideoStatsAPI.md#apiv1videosidstatsoverallget) | **GET** /api/v1/videos/{id}/stats/overall | Get overall stats of a video
[**apiV1VideosIdStatsRetentionGet**](VideoStatsAPI.md#apiv1videosidstatsretentionget) | **GET** /api/v1/videos/{id}/stats/retention | Get retention stats of a video
[**apiV1VideosIdStatsTimeseriesMetricGet**](VideoStatsAPI.md#apiv1videosidstatstimeseriesmetricget) | **GET** /api/v1/videos/{id}/stats/timeseries/{metric} | Get timeserie stats of a video
[**apiV1VideosIdStatsUserAgentGet**](VideoStatsAPI.md#apiv1videosidstatsuseragentget) | **GET** /api/v1/videos/{id}/stats/user-agent | Get user agent stats of a video


# **apiV1VideosIdStatsOverallGet**
```swift
    open class func apiV1VideosIdStatsOverallGet(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, startDate: Date? = nil, endDate: Date? = nil, completion: @escaping (_ data: VideoStatsOverall?, _ error: Error?) -> Void)
```

Get overall stats of a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let startDate = Date() // Date | Filter stats by start date (optional)
let endDate = Date() // Date | Filter stats by end date (optional)

// Get overall stats of a video
VideoStatsAPI.apiV1VideosIdStatsOverallGet(id: id, startDate: startDate, endDate: endDate) { (response, error) in
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
 **startDate** | **Date** | Filter stats by start date | [optional] 
 **endDate** | **Date** | Filter stats by end date | [optional] 

### Return type

[**VideoStatsOverall**](VideoStatsOverall.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1VideosIdStatsRetentionGet**
```swift
    open class func apiV1VideosIdStatsRetentionGet(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, completion: @escaping (_ data: VideoStatsRetention?, _ error: Error?) -> Void)
```

Get retention stats of a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid

// Get retention stats of a video
VideoStatsAPI.apiV1VideosIdStatsRetentionGet(id: id) { (response, error) in
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

[**VideoStatsRetention**](VideoStatsRetention.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1VideosIdStatsTimeseriesMetricGet**
```swift
    open class func apiV1VideosIdStatsTimeseriesMetricGet(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, metric: Metric_apiV1VideosIdStatsTimeseriesMetricGet, startDate: Date? = nil, endDate: Date? = nil, completion: @escaping (_ data: VideoStatsTimeserie?, _ error: Error?) -> Void)
```

Get timeserie stats of a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let metric = "metric_example" // String | The metric to get
let startDate = Date() // Date | Filter stats by start date (optional)
let endDate = Date() // Date | Filter stats by end date (optional)

// Get timeserie stats of a video
VideoStatsAPI.apiV1VideosIdStatsTimeseriesMetricGet(id: id, metric: metric, startDate: startDate, endDate: endDate) { (response, error) in
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
 **metric** | **String** | The metric to get | 
 **startDate** | **Date** | Filter stats by start date | [optional] 
 **endDate** | **Date** | Filter stats by end date | [optional] 

### Return type

[**VideoStatsTimeserie**](VideoStatsTimeserie.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1VideosIdStatsUserAgentGet**
```swift
    open class func apiV1VideosIdStatsUserAgentGet(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, startDate: Date? = nil, endDate: Date? = nil, completion: @escaping (_ data: VideoStatsUserAgent?, _ error: Error?) -> Void)
```

Get user agent stats of a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let startDate = Date() // Date | Filter stats by start date (optional)
let endDate = Date() // Date | Filter stats by end date (optional)

// Get user agent stats of a video
VideoStatsAPI.apiV1VideosIdStatsUserAgentGet(id: id, startDate: startDate, endDate: endDate) { (response, error) in
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
 **startDate** | **Date** | Filter stats by start date | [optional] 
 **endDate** | **Date** | Filter stats by end date | [optional] 

### Return type

[**VideoStatsUserAgent**](VideoStatsUserAgent.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

