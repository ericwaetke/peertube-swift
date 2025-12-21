# MyNotificationsAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1UsersMeNotificationSettingsPut**](MyNotificationsAPI.md#apiv1usersmenotificationsettingsput) | **PUT** /api/v1/users/me/notification-settings | Update my notification settings
[**apiV1UsersMeNotificationsGet**](MyNotificationsAPI.md#apiv1usersmenotificationsget) | **GET** /api/v1/users/me/notifications | List my notifications
[**apiV1UsersMeNotificationsReadAllPost**](MyNotificationsAPI.md#apiv1usersmenotificationsreadallpost) | **POST** /api/v1/users/me/notifications/read-all | Mark all my notification as read
[**apiV1UsersMeNotificationsReadPost**](MyNotificationsAPI.md#apiv1usersmenotificationsreadpost) | **POST** /api/v1/users/me/notifications/read | Mark notifications as read by their id


# **apiV1UsersMeNotificationSettingsPut**
```swift
    open class func apiV1UsersMeNotificationSettingsPut(userNotificationSettings: UserNotificationSettings? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Update my notification settings

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let userNotificationSettings = UserNotificationSettings(abuseAsModerator: 123, videoAutoBlacklistAsModerator: 123, newUserRegistration: 123, newVideoFromSubscription: 123, blacklistOnMyVideo: 123, myVideoPublished: 123, myVideoImportFinished: 123, commentMention: 123, newCommentOnMyVideo: 123, newFollow: 123, newInstanceFollower: 123, autoInstanceFollowing: 123, abuseStateChange: 123, abuseNewMessage: 123, newPeerTubeVersion: 123, newPluginVersion: 123, myVideoStudioEditionFinished: 123, myVideoTranscriptionGenerated: 123) // UserNotificationSettings |  (optional)

// Update my notification settings
MyNotificationsAPI.apiV1UsersMeNotificationSettingsPut(userNotificationSettings: userNotificationSettings) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userNotificationSettings** | [**UserNotificationSettings**](UserNotificationSettings.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1UsersMeNotificationsGet**
```swift
    open class func apiV1UsersMeNotificationsGet(typeOneOf: [NotificationType]? = nil, unread: Bool? = nil, start: Int? = nil, count: Int? = nil, sort: String? = nil, completion: @escaping (_ data: NotificationListResponse?, _ error: Error?) -> Void)
```

List my notifications

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let typeOneOf = [NotificationType()] // [NotificationType] | only list notifications of these types (optional)
let unread = true // Bool | only list unread notifications (optional)
let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let sort = "sort_example" // String | Sort column (optional)

// List my notifications
MyNotificationsAPI.apiV1UsersMeNotificationsGet(typeOneOf: typeOneOf, unread: unread, start: start, count: count, sort: sort) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **typeOneOf** | [**[NotificationType]**](NotificationType.md) | only list notifications of these types | [optional] 
 **unread** | **Bool** | only list unread notifications | [optional] 
 **start** | **Int** | Offset used to paginate results | [optional] 
 **count** | **Int** | Number of items to return | [optional] [default to 15]
 **sort** | **String** | Sort column | [optional] 

### Return type

[**NotificationListResponse**](NotificationListResponse.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1UsersMeNotificationsReadAllPost**
```swift
    open class func apiV1UsersMeNotificationsReadAllPost(completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Mark all my notification as read

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// Mark all my notification as read
MyNotificationsAPI.apiV1UsersMeNotificationsReadAllPost() { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1UsersMeNotificationsReadPost**
```swift
    open class func apiV1UsersMeNotificationsReadPost(apiV1UsersMeNotificationsReadPostRequest: ApiV1UsersMeNotificationsReadPostRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Mark notifications as read by their id

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let apiV1UsersMeNotificationsReadPostRequest = _api_v1_users_me_notifications_read_post_request(ids: [123]) // ApiV1UsersMeNotificationsReadPostRequest |  (optional)

// Mark notifications as read by their id
MyNotificationsAPI.apiV1UsersMeNotificationsReadPost(apiV1UsersMeNotificationsReadPostRequest: apiV1UsersMeNotificationsReadPostRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **apiV1UsersMeNotificationsReadPostRequest** | [**ApiV1UsersMeNotificationsReadPostRequest**](ApiV1UsersMeNotificationsReadPostRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

