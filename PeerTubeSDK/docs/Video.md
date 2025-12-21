# Video

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **Int** | object id for the video | [optional] 
**uuid** | **UUID** | universal identifier for the video, that can be used across instances | [optional] 
**shortUUID** | **String** | translation of a uuid v4 with a bigger alphabet to have a shorter uuid | [optional] 
**isLive** | **Bool** |  | [optional] 
**liveSchedules** | [LiveSchedule] |  | [optional] 
**createdAt** | **Date** | time at which the video object was first drafted | [optional] 
**publishedAt** | **Date** | time at which the video was marked as ready for playback (with restrictions depending on &#x60;privacy&#x60;). Usually set after a &#x60;state&#x60; evolution. | [optional] 
**updatedAt** | **Date** | last time the video&#39;s metadata was modified | [optional] 
**originallyPublishedAt** | **Date** | used to represent a date of first publication, prior to the practical publication date of &#x60;publishedAt&#x60; | [optional] 
**category** | [**VideoConstantNumberCategory**](VideoConstantNumberCategory.md) | category in which the video is classified | [optional] 
**licence** | [**VideoConstantNumberLicence**](VideoConstantNumberLicence.md) | licence under which the video is distributed | [optional] 
**language** | [**VideoConstantStringLanguage**](VideoConstantStringLanguage.md) | main language used in the video | [optional] 
**privacy** | [**VideoPrivacyConstant**](VideoPrivacyConstant.md) | privacy policy used to distribute the video | [optional] 
**truncatedDescription** | **String** | truncated description of the video, written in Markdown.  | [optional] 
**duration** | **Int** | duration of the video in seconds | [optional] 
**aspectRatio** | **Float** | **PeerTube &gt;&#x3D; 6.1** Aspect ratio of the video stream | [optional] 
**isLocal** | **Bool** |  | [optional] 
**name** | **String** | title of the video | [optional] 
**thumbnailPath** | **String** |  | [optional] 
**previewPath** | **String** |  | [optional] 
**embedPath** | **String** |  | [optional] 
**views** | **Int** |  | [optional] 
**likes** | **Int** |  | [optional] 
**dislikes** | **Int** |  | [optional] 
**comments** | **Int** | **PeerTube &gt;&#x3D; 7.2** Number of comments on the video | [optional] 
**nsfw** | **Bool** |  | [optional] 
**nsfwFlags** | [**NSFWFlag**](NSFWFlag.md) |  | [optional] 
**nsfwSummary** | **String** | **PeerTube &gt;&#x3D; 7.2** More information about the sensitive content of the video | [optional] 
**waitTranscoding** | **Bool** |  | [optional] 
**state** | [**VideoStateConstant**](VideoStateConstant.md) | represents the internal state of the video processing within the PeerTube instance | [optional] 
**scheduledUpdate** | [**VideoScheduledUpdate**](VideoScheduledUpdate.md) |  | [optional] 
**blacklisted** | **Bool** |  | [optional] 
**blacklistedReason** | **String** |  | [optional] 
**account** | [**AccountSummary**](AccountSummary.md) |  | [optional] 
**channel** | [**VideoChannelSummary**](VideoChannelSummary.md) |  | [optional] 
**userHistory** | [**VideoUserHistory**](VideoUserHistory.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


