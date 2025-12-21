# VideoFile

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **Int** |  | [optional] 
**magnetUri** | **String** | magnet URI allowing to resolve the video via BitTorrent without a metainfo file | [optional] 
**resolution** | [**VideoResolutionConstant**](VideoResolutionConstant.md) |  | [optional] 
**size** | **Int** | Video file size in bytes | [optional] 
**torrentUrl** | **String** | Direct URL of the torrent file | [optional] 
**torrentDownloadUrl** | **String** | URL endpoint that transfers the torrent file as an attachment (so that the browser opens a download dialog) | [optional] 
**fileUrl** | **String** | Direct URL of the video | [optional] 
**playlistUrl** | **String** | Playlist URL of the file if it is owned by a playlist | [optional] 
**fileDownloadUrl** | **String** | URL endpoint that transfers the video file as an attachment (so that the browser opens a download dialog) | [optional] 
**fps** | **Double** | Frames per second of the video file | [optional] 
**width** | **Double** | **PeerTube &gt;&#x3D; 6.1** Video stream width | [optional] 
**height** | **Double** | **PeerTube &gt;&#x3D; 6.1** Video stream height | [optional] 
**metadataUrl** | **String** | URL dereferencing the output of ffprobe on the file | [optional] 
**hasAudio** | **Bool** | **PeerTube &gt;&#x3D; 6.2** The file container has an audio stream | [optional] 
**hasVideo** | **Bool** | **PeerTube &gt;&#x3D; 6.2** The file container has a video stream | [optional] 
**storage** | [**FileStorage**](FileStorage.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


