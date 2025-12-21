# StatsAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1MetricsPlaybackPost**](StatsAPI.md#apiv1metricsplaybackpost) | **POST** /api/v1/metrics/playback | Create playback metrics
[**getInstanceStats**](StatsAPI.md#getinstancestats) | **GET** /api/v1/server/stats | Get instance stats


# **apiV1MetricsPlaybackPost**
```swift
    open class func apiV1MetricsPlaybackPost(playbackMetricCreate: PlaybackMetricCreate? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Create playback metrics

These metrics are exposed by OpenTelemetry metrics exporter if enabled.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let playbackMetricCreate = PlaybackMetricCreate(playerMode: "playerMode_example", resolution: 123, fps: 123, p2pEnabled: false, p2pPeers: 123, resolutionChanges: 123, bufferStalled: 123, errors: 123, downloadedBytesP2P: 123, downloadedBytesHTTP: 123, uploadedBytesP2P: 123, videoId: _api_v1_videos_ownership__id__accept_post_id_parameter()) // PlaybackMetricCreate |  (optional)

// Create playback metrics
StatsAPI.apiV1MetricsPlaybackPost(playbackMetricCreate: playbackMetricCreate) { (response, error) in
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
 **playbackMetricCreate** | [**PlaybackMetricCreate**](PlaybackMetricCreate.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getInstanceStats**
```swift
    open class func getInstanceStats(completion: @escaping (_ data: ServerStats?, _ error: Error?) -> Void)
```

Get instance stats

Get instance public statistics. This endpoint is cached.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// Get instance stats
StatsAPI.getInstanceStats() { (response, error) in
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

[**ServerStats**](ServerStats.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

