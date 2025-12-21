# UserViewingVideo

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**currentTime** | **Int** | timestamp within the video, in seconds | 
**viewEvent** | **String** | Event since last viewing call:  * &#x60;seek&#x60; - If the user seeked the video  | [optional] 
**sessionId** | **String** | Optional param to represent the current viewer session. Used by the backend to properly count one view per session per video. PeerTube admin can configure the server to not trust this &#x60;sessionId&#x60; parameter but use the request IP address instead to identify a viewer.  | [optional] 
**client** | **String** | Client software used to watch the video. For example \&quot;Firefox\&quot;, \&quot;PeerTube Approval Android\&quot;, etc.  | [optional] 
**device** | [**VideoStatsUserAgentDevice**](VideoStatsUserAgentDevice.md) | Device used to watch the video. For example \&quot;desktop\&quot;, \&quot;mobile\&quot;, \&quot;smarttv\&quot;, etc.  | [optional] 
**operatingSystem** | **String** | Operating system used to watch the video. For example \&quot;Windows\&quot;, \&quot;Ubuntu\&quot;, etc.  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


