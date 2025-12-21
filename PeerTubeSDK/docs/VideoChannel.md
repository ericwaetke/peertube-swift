# VideoChannel

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **Int** |  | [optional] 
**url** | **String** |  | [optional] 
**name** | **String** | immutable name of the actor, used to find or mention it | [optional] 
**avatars** | [ActorImage] |  | [optional] 
**host** | **String** | server on which the actor is resident | [optional] 
**hostRedundancyAllowed** | **Bool** | whether this actor&#39;s host allows redundancy of its videos | [optional] 
**followingCount** | **Int** | number of actors subscribed to by this actor, as seen by this instance | [optional] 
**followersCount** | **Int** | number of followers of this actor, as seen by this instance | [optional] 
**createdAt** | **Date** |  | [optional] 
**updatedAt** | **Date** |  | [optional] 
**displayName** | **String** | editable name of the channel, displayed in its representations | [optional] 
**description** | **String** |  | [optional] 
**support** | **String** | text shown by default on all videos of this channel, to tell the audience how to support it | [optional] 
**isLocal** | **Bool** |  | [optional] 
**banners** | [ActorImage] |  | [optional] 
**ownerAccount** | [**Account**](Account.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


