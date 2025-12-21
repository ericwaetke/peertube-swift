# PlaybackMetricCreate

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**playerMode** | **String** |  | 
**resolution** | **Double** | Current player video resolution | [optional] 
**fps** | **Double** | Current player video fps | [optional] 
**p2pEnabled** | **Bool** |  | 
**p2pPeers** | **Double** | P2P peers connected (doesn&#39;t include WebSeed peers) | [optional] 
**resolutionChanges** | **Double** | How many resolution changes occurred since the last metric creation | 
**bufferStalled** | **Double** | How many times buffer has been stalled since the last metric creation | [optional] 
**errors** | **Double** | How many errors occurred since the last metric creation | 
**downloadedBytesP2P** | **Double** | How many bytes were downloaded with P2P since the last metric creation | 
**downloadedBytesHTTP** | **Double** | How many bytes were downloaded with HTTP since the last metric creation | 
**uploadedBytesP2P** | **Double** | How many bytes were uploaded with P2P since the last metric creation | 
**videoId** | [**ApiV1VideosOwnershipIdAcceptPostIdParameter**](ApiV1VideosOwnershipIdAcceptPostIdParameter.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


