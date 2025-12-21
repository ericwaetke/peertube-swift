# LiveVideoResponse

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**rtmpUrl** | **String** | Included in the response if an appropriate token is provided | [optional] 
**rtmpsUrl** | **String** | Included in the response if an appropriate token is provided | [optional] 
**streamKey** | **String** | RTMP stream key to use to stream into this live video. Included in the response if an appropriate token is provided | [optional] 
**saveReplay** | **Bool** |  | [optional] 
**replaySettings** | [**LiveVideoReplaySettings**](LiveVideoReplaySettings.md) |  | [optional] 
**permanentLive** | **Bool** | User can stream multiple times in a permanent live | [optional] 
**latencyMode** | [**LiveVideoLatencyMode**](LiveVideoLatencyMode.md) | User can select live latency mode if enabled by the instance | [optional] 
**schedules** | [LiveSchedule] |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


