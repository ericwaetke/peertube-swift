# VideosForXMLInner

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**link** | **String** | video watch page URL | [optional] 
**guid** | **String** | video canonical URL | [optional] 
**pubDate** | **Date** | video publication date | [optional] 
**description** | **String** | video description | [optional] 
**contentEncoded** | **String** | video description | [optional] 
**dcCreator** | **String** | publisher user name | [optional] 
**mediaCategory** | **Int** | video category (MRSS) | [optional] 
**mediaCommunity** | [**VideosForXMLInnerMediaCommunity**](VideosForXMLInnerMediaCommunity.md) |  | [optional] 
**mediaEmbed** | [**VideosForXMLInnerMediaEmbed**](VideosForXMLInnerMediaEmbed.md) |  | [optional] 
**mediaPlayer** | [**VideosForXMLInnerMediaPlayer**](VideosForXMLInnerMediaPlayer.md) |  | [optional] 
**mediaThumbnail** | [**VideosForXMLInnerMediaThumbnail**](VideosForXMLInnerMediaThumbnail.md) |  | [optional] 
**mediaTitle** | **String** | see [media:title](https://www.rssboard.org/media-rss#media-title) (MRSS). We only use &#x60;plain&#x60; titles. | [optional] 
**mediaDescription** | **String** |  | [optional] 
**mediaRating** | **String** | see [media:rating](https://www.rssboard.org/media-rss#media-rating) (MRSS) | [optional] 
**enclosure** | [**VideosForXMLInnerEnclosure**](VideosForXMLInnerEnclosure.md) |  | [optional] 
**mediaGroup** | [VideosForXMLInnerMediaGroupInner] | list of streamable files for the video. see [media:peerLink](https://www.rssboard.org/media-rss#media-peerlink) and [media:content](https://www.rssboard.org/media-rss#media-content) or  (MRSS) | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


