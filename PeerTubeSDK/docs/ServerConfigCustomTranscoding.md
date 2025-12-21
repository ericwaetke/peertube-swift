# ServerConfigCustomTranscoding

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**enabled** | **Bool** |  | [optional] 
**originalFile** | [**ServerConfigCustomTranscodingOriginalFile**](ServerConfigCustomTranscodingOriginalFile.md) |  | [optional] 
**allowAdditionalExtensions** | **Bool** | Allow your users to upload .mkv, .mov, .avi, .wmv, .flv, .f4v, .3g2, .3gp, .mts, m2ts, .mxf, .nut videos | [optional] 
**allowAudioFiles** | **Bool** | If a user uploads an audio file, PeerTube will create a video by merging the preview file and the audio file | [optional] 
**threads** | **Int** | Amount of threads used by ffmpeg for 1 transcoding job | [optional] 
**concurrency** | **Double** | Amount of transcoding jobs to execute in parallel | [optional] 
**profile** | **String** | New profiles can be added by plugins ; available in core PeerTube: &#39;default&#39;.  | [optional] 
**resolutions** | [**ServerConfigCustomTranscodingResolutions**](ServerConfigCustomTranscodingResolutions.md) |  | [optional] 
**webVideos** | [**ServerConfigCustomTranscodingWebVideos**](ServerConfigCustomTranscodingWebVideos.md) |  | [optional] 
**hls** | [**ServerConfigCustomTranscodingHls**](ServerConfigCustomTranscodingHls.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


