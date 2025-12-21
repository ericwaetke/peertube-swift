# UsersAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addUser**](UsersAPI.md#adduser) | **POST** /api/v1/users | Create a user
[**apiV1UsersAskResetPasswordPost**](UsersAPI.md#apiv1usersaskresetpasswordpost) | **POST** /api/v1/users/ask-reset-password | Ask to reset password
[**apiV1UsersIdResetPasswordPost**](UsersAPI.md#apiv1usersidresetpasswordpost) | **POST** /api/v1/users/{id}/reset-password | Reset password
[**confirmTwoFactorRequest**](UsersAPI.md#confirmtwofactorrequest) | **POST** /api/v1/users/{id}/two-factor/confirm-request | Confirm two factor auth
[**delUser**](UsersAPI.md#deluser) | **DELETE** /api/v1/users/{id} | Delete a user
[**disableTwoFactor**](UsersAPI.md#disabletwofactor) | **POST** /api/v1/users/{id}/two-factor/disable | Disable two factor auth
[**getUser**](UsersAPI.md#getuser) | **GET** /api/v1/users/{id} | Get a user
[**getUsers**](UsersAPI.md#getusers) | **GET** /api/v1/users | List users
[**putUser**](UsersAPI.md#putuser) | **PUT** /api/v1/users/{id} | Update a user
[**requestTwoFactor**](UsersAPI.md#requesttwofactor) | **POST** /api/v1/users/{id}/two-factor/request | Request two factor auth
[**resendEmailToVerifyUser**](UsersAPI.md#resendemailtoverifyuser) | **POST** /api/v1/users/ask-send-verify-email | Resend user verification link
[**verifyUser**](UsersAPI.md#verifyuser) | **POST** /api/v1/users/{id}/verify-email | Verify a user


# **addUser**
```swift
    open class func addUser(addUser: AddUser, completion: @escaping (_ data: AddUserResponse?, _ error: Error?) -> Void)
```

Create a user

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let addUser = AddUser(username: "username_example", password: "password_example", email: "email_example", videoQuota: 123, videoQuotaDaily: 123, channelName: "channelName_example", role: User_role(id: nil, label: "label_example"), adminFlags: UserAdminFlags()) // AddUser | If the smtp server is configured, you can leave the password empty and an email will be sent asking the user to set it first. 

// Create a user
UsersAPI.addUser(addUser: addUser) { (response, error) in
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
 **addUser** | [**AddUser**](AddUser.md) | If the smtp server is configured, you can leave the password empty and an email will be sent asking the user to set it first.  | 

### Return type

[**AddUserResponse**](AddUserResponse.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1UsersAskResetPasswordPost**
```swift
    open class func apiV1UsersAskResetPasswordPost(resendEmailToVerifyUserRequest: ResendEmailToVerifyUserRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Ask to reset password

An email containing a reset password link

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let resendEmailToVerifyUserRequest = resendEmailToVerifyUser_request(email: "email_example") // ResendEmailToVerifyUserRequest |  (optional)

// Ask to reset password
UsersAPI.apiV1UsersAskResetPasswordPost(resendEmailToVerifyUserRequest: resendEmailToVerifyUserRequest) { (response, error) in
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
 **resendEmailToVerifyUserRequest** | [**ResendEmailToVerifyUserRequest**](ResendEmailToVerifyUserRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1UsersIdResetPasswordPost**
```swift
    open class func apiV1UsersIdResetPasswordPost(id: Int, apiV1UsersIdResetPasswordPostRequest: ApiV1UsersIdResetPasswordPostRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Reset password

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = 987 // Int | Entity id
let apiV1UsersIdResetPasswordPostRequest = _api_v1_users__id__reset_password_post_request(verificationString: "verificationString_example", password: "password_example") // ApiV1UsersIdResetPasswordPostRequest |  (optional)

// Reset password
UsersAPI.apiV1UsersIdResetPasswordPost(id: id, apiV1UsersIdResetPasswordPostRequest: apiV1UsersIdResetPasswordPostRequest) { (response, error) in
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
 **id** | **Int** | Entity id | 
 **apiV1UsersIdResetPasswordPostRequest** | [**ApiV1UsersIdResetPasswordPostRequest**](ApiV1UsersIdResetPasswordPostRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **confirmTwoFactorRequest**
```swift
    open class func confirmTwoFactorRequest(id: Int, confirmTwoFactorRequestRequest: ConfirmTwoFactorRequestRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Confirm two factor auth

Confirm a two factor authentication request

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = 987 // Int | Entity id
let confirmTwoFactorRequestRequest = confirmTwoFactorRequest_request(requestToken: "requestToken_example", otpToken: "otpToken_example") // ConfirmTwoFactorRequestRequest |  (optional)

// Confirm two factor auth
UsersAPI.confirmTwoFactorRequest(id: id, confirmTwoFactorRequestRequest: confirmTwoFactorRequestRequest) { (response, error) in
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
 **id** | **Int** | Entity id | 
 **confirmTwoFactorRequestRequest** | [**ConfirmTwoFactorRequestRequest**](ConfirmTwoFactorRequestRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **delUser**
```swift
    open class func delUser(id: Int, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete a user

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = 987 // Int | Entity id

// Delete a user
UsersAPI.delUser(id: id) { (response, error) in
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
 **id** | **Int** | Entity id | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **disableTwoFactor**
```swift
    open class func disableTwoFactor(id: Int, requestTwoFactorRequest: RequestTwoFactorRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Disable two factor auth

Disable two factor authentication of a user

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = 987 // Int | Entity id
let requestTwoFactorRequest = requestTwoFactor_request(currentPassword: "currentPassword_example") // RequestTwoFactorRequest |  (optional)

// Disable two factor auth
UsersAPI.disableTwoFactor(id: id, requestTwoFactorRequest: requestTwoFactorRequest) { (response, error) in
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
 **id** | **Int** | Entity id | 
 **requestTwoFactorRequest** | [**RequestTwoFactorRequest**](RequestTwoFactorRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUser**
```swift
    open class func getUser(id: Int, withStats: Bool? = nil, completion: @escaping (_ data: GetUser200Response?, _ error: Error?) -> Void)
```

Get a user

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = 987 // Int | Entity id
let withStats = true // Bool | include statistics about the user (only available as a moderator/admin) (optional)

// Get a user
UsersAPI.getUser(id: id, withStats: withStats) { (response, error) in
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
 **id** | **Int** | Entity id | 
 **withStats** | **Bool** | include statistics about the user (only available as a moderator/admin) | [optional] 

### Return type

[**GetUser200Response**](GetUser200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUsers**
```swift
    open class func getUsers(search: String? = nil, blocked: Bool? = nil, start: Int? = nil, count: Int? = nil, sort: Sort_getUsers? = nil, completion: @escaping (_ data: [User]?, _ error: Error?) -> Void)
```

List users

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let search = "search_example" // String | Plain text search that will match with user usernames or emails (optional)
let blocked = true // Bool | Filter results down to (un)banned users (optional)
let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let sort = "sort_example" // String | Sort users by criteria (optional)

// List users
UsersAPI.getUsers(search: search, blocked: blocked, start: start, count: count, sort: sort) { (response, error) in
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
 **search** | **String** | Plain text search that will match with user usernames or emails | [optional] 
 **blocked** | **Bool** | Filter results down to (un)banned users | [optional] 
 **start** | **Int** | Offset used to paginate results | [optional] 
 **count** | **Int** | Number of items to return | [optional] [default to 15]
 **sort** | **String** | Sort users by criteria | [optional] 

### Return type

[**[User]**](User.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putUser**
```swift
    open class func putUser(id: Int, updateUser: UpdateUser, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Update a user

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = 987 // Int | Entity id
let updateUser = UpdateUser(email: "email_example", emailVerified: false, videoQuota: 123, videoQuotaDaily: 123, pluginAuth: "pluginAuth_example", role: User_role(id: nil, label: "label_example"), adminFlags: UserAdminFlags(), password: "password_example") // UpdateUser | 

// Update a user
UsersAPI.putUser(id: id, updateUser: updateUser) { (response, error) in
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
 **id** | **Int** | Entity id | 
 **updateUser** | [**UpdateUser**](UpdateUser.md) |  | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **requestTwoFactor**
```swift
    open class func requestTwoFactor(id: Int, requestTwoFactorRequest: RequestTwoFactorRequest? = nil, completion: @escaping (_ data: [RequestTwoFactorResponse]?, _ error: Error?) -> Void)
```

Request two factor auth

Request two factor authentication for a user

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = 987 // Int | Entity id
let requestTwoFactorRequest = requestTwoFactor_request(currentPassword: "currentPassword_example") // RequestTwoFactorRequest |  (optional)

// Request two factor auth
UsersAPI.requestTwoFactor(id: id, requestTwoFactorRequest: requestTwoFactorRequest) { (response, error) in
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
 **id** | **Int** | Entity id | 
 **requestTwoFactorRequest** | [**RequestTwoFactorRequest**](RequestTwoFactorRequest.md) |  | [optional] 

### Return type

[**[RequestTwoFactorResponse]**](RequestTwoFactorResponse.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resendEmailToVerifyUser**
```swift
    open class func resendEmailToVerifyUser(resendEmailToVerifyUserRequest: ResendEmailToVerifyUserRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Resend user verification link

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let resendEmailToVerifyUserRequest = resendEmailToVerifyUser_request(email: "email_example") // ResendEmailToVerifyUserRequest |  (optional)

// Resend user verification link
UsersAPI.resendEmailToVerifyUser(resendEmailToVerifyUserRequest: resendEmailToVerifyUserRequest) { (response, error) in
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
 **resendEmailToVerifyUserRequest** | [**ResendEmailToVerifyUserRequest**](ResendEmailToVerifyUserRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **verifyUser**
```swift
    open class func verifyUser(id: Int, verifyUserRequest: VerifyUserRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Verify a user

Following a user registration, the new user will receive an email asking to click a link containing a secret. This endpoint can also be used to verify a new email set in the user account. 

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = 987 // Int | Entity id
let verifyUserRequest = verifyUser_request(verificationString: "verificationString_example", isPendingEmail: false) // VerifyUserRequest |  (optional)

// Verify a user
UsersAPI.verifyUser(id: id, verifyUserRequest: verifyUserRequest) { (response, error) in
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
 **id** | **Int** | Entity id | 
 **verifyUserRequest** | [**VerifyUserRequest**](VerifyUserRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

