# SessionAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1UsersIdTokenSessionsGet**](SessionAPI.md#apiv1usersidtokensessionsget) | **GET** /api/v1/users/{id}/token-sessions | List token sessions
[**apiV1UsersIdTokenSessionsTokenSessionIdRevokeGet**](SessionAPI.md#apiv1usersidtokensessionstokensessionidrevokeget) | **GET** /api/v1/users/{id}/token-sessions/{tokenSessionId}/revoke | List token sessions
[**getOAuthClient**](SessionAPI.md#getoauthclient) | **GET** /api/v1/oauth-clients/local | Login prerequisite
[**getOAuthToken**](SessionAPI.md#getoauthtoken) | **POST** /api/v1/users/token | Login
[**revokeOAuthToken**](SessionAPI.md#revokeoauthtoken) | **POST** /api/v1/users/revoke-token | Logout


# **apiV1UsersIdTokenSessionsGet**
```swift
    open class func apiV1UsersIdTokenSessionsGet(id: Int, completion: @escaping (_ data: ApiV1UsersIdTokenSessionsGet200Response?, _ error: Error?) -> Void)
```

List token sessions

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = 987 // Int | Entity id

// List token sessions
SessionAPI.apiV1UsersIdTokenSessionsGet(id: id) { (response, error) in
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

[**ApiV1UsersIdTokenSessionsGet200Response**](ApiV1UsersIdTokenSessionsGet200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1UsersIdTokenSessionsTokenSessionIdRevokeGet**
```swift
    open class func apiV1UsersIdTokenSessionsTokenSessionIdRevokeGet(id: Int, tokenSessionId: Int, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

List token sessions

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = 987 // Int | Entity id
let tokenSessionId = 987 // Int | Token session Id

// List token sessions
SessionAPI.apiV1UsersIdTokenSessionsTokenSessionIdRevokeGet(id: id, tokenSessionId: tokenSessionId) { (response, error) in
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
 **tokenSessionId** | **Int** | Token session Id | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getOAuthClient**
```swift
    open class func getOAuthClient(completion: @escaping (_ data: OAuthClient?, _ error: Error?) -> Void)
```

Login prerequisite

You need to retrieve a client id and secret before [logging in](#operation/getOAuthToken).

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// Login prerequisite
SessionAPI.getOAuthClient() { (response, error) in
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

[**OAuthClient**](OAuthClient.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getOAuthToken**
```swift
    open class func getOAuthToken(xPeertubeOtp: String? = nil, clientId: String? = nil, clientSecret: String? = nil, grantType: GrantType_getOAuthToken? = nil, username: String? = nil, password: String? = nil, externalAuthToken: String? = nil, refreshToken: String? = nil, completion: @escaping (_ data: GetOAuthToken200Response?, _ error: Error?) -> Void)
```

Login

With your [client id and secret](#operation/getOAuthClient), you can retrieve an access and refresh tokens.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let xPeertubeOtp = "xPeertubeOtp_example" // String | If the user enabled two factor authentication, you need to provide the OTP code in this header (optional)
let clientId = "clientId_example" // String |  (optional)
let clientSecret = "clientSecret_example" // String |  (optional)
let grantType = "grantType_example" // String |  (optional)
let username = "username_example" // String | immutable name of the user, used to find or mention its actor (optional)
let password = "password_example" // String |  (optional)
let externalAuthToken = "externalAuthToken_example" // String | If you want to authenticate using an external authentication token you got from an auth plugin (like `peertube-plugin-auth-openid-connect` for example) instead of a password or a refresh token, provide it here. (optional)
let refreshToken = "refreshToken_example" // String |  (optional)

// Login
SessionAPI.getOAuthToken(xPeertubeOtp: xPeertubeOtp, clientId: clientId, clientSecret: clientSecret, grantType: grantType, username: username, password: password, externalAuthToken: externalAuthToken, refreshToken: refreshToken) { (response, error) in
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
 **xPeertubeOtp** | **String** | If the user enabled two factor authentication, you need to provide the OTP code in this header | [optional] 
 **clientId** | **String** |  | [optional] 
 **clientSecret** | **String** |  | [optional] 
 **grantType** | **String** |  | [optional] 
 **username** | **String** | immutable name of the user, used to find or mention its actor | [optional] 
 **password** | **String** |  | [optional] 
 **externalAuthToken** | **String** | If you want to authenticate using an external authentication token you got from an auth plugin (like &#x60;peertube-plugin-auth-openid-connect&#x60; for example) instead of a password or a refresh token, provide it here. | [optional] 
 **refreshToken** | **String** |  | [optional] 

### Return type

[**GetOAuthToken200Response**](GetOAuthToken200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/x-www-form-urlencoded
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **revokeOAuthToken**
```swift
    open class func revokeOAuthToken(completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Logout

Revokes your access token and its associated refresh token, destroying your current session.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// Logout
SessionAPI.revokeOAuthToken() { (response, error) in
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

