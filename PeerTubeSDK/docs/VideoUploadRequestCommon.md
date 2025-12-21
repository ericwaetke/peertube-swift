# VideoUploadRequestCommon

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | **String** | Video name | 
**channelId** | **Int** | Channel id that will contain this video | 
**privacy** | [**VideoPrivacySet**](VideoPrivacySet.md) |  | [optional] 
**category** | **Int** | category id of the video (see [/videos/categories](#operation/getCategories)) | [optional] 
**licence** | **Int** | licence id of the video (see [/videos/licences](#operation/getLicences)) | [optional] 
**language** | **String** | language id of the video (see [/videos/languages](#operation/getLanguages)) | [optional] 
**description** | **String** | Video description | [optional] 
**waitTranscoding** | **Bool** | Whether or not we wait transcoding before publish the video | [optional] 
**generateTranscription** | **Bool** | **PeerTube &gt;&#x3D; 6.2** If enabled by the admin, automatically generate a subtitle of the video | [optional] 
**support** | **String** | A text tell the audience how to support the video creator | [optional] 
**nsfw** | **Bool** | Whether or not this video contains sensitive content | [optional] 
**nsfwSummary** | **JSONValue** | More information about the sensitive content of the video | [optional] 
**nsfwFlags** | [**NSFWFlag**](NSFWFlag.md) |  | [optional] 
**tags** | **Set<String>** | Video tags (maximum 5 tags each between 2 and 30 characters) | [optional] 
**commentsPolicy** | [**VideoCommentsPolicySet**](VideoCommentsPolicySet.md) |  | [optional] 
**downloadEnabled** | **Bool** | Enable or disable downloading for this video | [optional] 
**originallyPublishedAt** | **Date** | Date when the content was originally published | [optional] 
**scheduleUpdate** | [**VideoScheduledUpdate**](VideoScheduledUpdate.md) |  | [optional] 
**thumbnailfile** | **URL** | Video thumbnail file | [optional] 
**previewfile** | **URL** | Video preview file | [optional] 
**videoPasswords** | **Set<String>** |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


