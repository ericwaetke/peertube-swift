# UserWithStats

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **Int** |  | [optional] 
**username** | **String** | immutable name of the user, used to find or mention its actor | [optional] 
**email** | **String** | The user email | [optional] 
**emailVerified** | **Bool** | Has the user confirmed their email address? | [optional] 
**emailPublic** | **Bool** | Has the user accepted to display the email publicly? | [optional] 
**nsfwPolicy** | [**NSFWPolicy**](NSFWPolicy.md) |  | [optional] 
**nsfwFlagsDisplayed** | [**NSFWFlag**](NSFWFlag.md) |  | [optional] 
**nsfwFlagsHidden** | [**NSFWFlag**](NSFWFlag.md) |  | [optional] 
**nsfwFlagsWarned** | [**NSFWFlag**](NSFWFlag.md) |  | [optional] 
**nsfwFlagsBlurred** | [**NSFWFlag**](NSFWFlag.md) |  | [optional] 
**adminFlags** | [**UserAdminFlags**](UserAdminFlags.md) |  | [optional] 
**autoPlayNextVideo** | **Bool** | Automatically start playing the upcoming video after the currently playing video | [optional] 
**autoPlayNextVideoPlaylist** | **Bool** | Automatically start playing the video on the playlist after the currently playing video | [optional] 
**autoPlayVideo** | **Bool** | Automatically start playing the video on the watch page | [optional] 
**p2pEnabled** | **Bool** | whether to enable P2P in the player or not | [optional] 
**videosHistoryEnabled** | **Bool** | whether to keep track of watched history or not | [optional] 
**videoLanguages** | **[String]** | list of languages to filter videos down to | [optional] 
**language** | **String** | default language for this user | [optional] 
**videoQuota** | **Int** | The user video quota in bytes | [optional] 
**videoQuotaDaily** | **Int** | The user daily video quota in bytes | [optional] 
**role** | [**UserRole**](UserRole.md) |  | [optional] 
**theme** | **String** | Theme enabled by this user | [optional] 
**account** | [**Account**](Account.md) |  | [optional] 
**notificationSettings** | [**UserNotificationSettings**](UserNotificationSettings.md) |  | [optional] 
**videoChannels** | [VideoChannel] |  | [optional] 
**blocked** | **Bool** |  | [optional] 
**blockedReason** | **String** |  | [optional] 
**noInstanceConfigWarningModal** | **Bool** |  | [optional] 
**noAccountSetupWarningModal** | **Bool** |  | [optional] 
**noWelcomeModal** | **Bool** |  | [optional] 
**createdAt** | **String** |  | [optional] 
**pluginAuth** | **String** | Auth plugin to use to authenticate the user | [optional] 
**lastLoginDate** | **Date** |  | [optional] 
**twoFactorEnabled** | **Bool** | Whether the user has enabled two-factor authentication or not | [optional] 
**newFeaturesInfoRead** | **Double** | New features information the user has read | [optional] 
**videosCount** | **Int** | Count of videos published | [optional] 
**abusesCount** | **Int** | Count of reports/abuses of which the user is a target | [optional] 
**abusesAcceptedCount** | **Int** | Count of reports/abuses created by the user and accepted/acted upon by the moderation team | [optional] 
**abusesCreatedCount** | **Int** | Count of reports/abuses created by the user | [optional] 
**videoCommentsCount** | **Int** | Count of comments published | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


