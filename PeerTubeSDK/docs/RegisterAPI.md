# RegisterAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**acceptRegistration**](RegisterAPI.md#acceptregistration) | **POST** /api/v1/users/registrations/{registrationId}/accept | Accept registration
[**deleteRegistration**](RegisterAPI.md#deleteregistration) | **DELETE** /api/v1/users/registrations/{registrationId} | Delete registration
[**listRegistrations**](RegisterAPI.md#listregistrations) | **GET** /api/v1/users/registrations | List registrations
[**registerUser**](RegisterAPI.md#registeruser) | **POST** /api/v1/users/register | Register a user
[**rejectRegistration**](RegisterAPI.md#rejectregistration) | **POST** /api/v1/users/registrations/{registrationId}/reject | Reject registration
[**requestRegistration**](RegisterAPI.md#requestregistration) | **POST** /api/v1/users/registrations/request | Request registration
[**resendEmailToVerifyRegistration**](RegisterAPI.md#resendemailtoverifyregistration) | **POST** /api/v1/users/registrations/ask-send-verify-email | Resend verification link to registration request email
[**resendEmailToVerifyUser**](RegisterAPI.md#resendemailtoverifyuser) | **POST** /api/v1/users/ask-send-verify-email | Resend user verification link
[**verifyRegistrationEmail**](RegisterAPI.md#verifyregistrationemail) | **POST** /api/v1/users/registrations/{registrationId}/verify-email | Verify a registration email
[**verifyUser**](RegisterAPI.md#verifyuser) | **POST** /api/v1/users/{id}/verify-email | Verify a user


# **acceptRegistration**
```swift
    open class func acceptRegistration(registrationId: Int, userRegistrationAcceptOrReject: UserRegistrationAcceptOrReject? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Accept registration

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let registrationId = 987 // Int | Registration ID
let userRegistrationAcceptOrReject = UserRegistrationAcceptOrReject(moderationResponse: "moderationResponse_example", preventEmailDelivery: false) // UserRegistrationAcceptOrReject |  (optional)

// Accept registration
RegisterAPI.acceptRegistration(registrationId: registrationId, userRegistrationAcceptOrReject: userRegistrationAcceptOrReject) { (response, error) in
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
 **registrationId** | **Int** | Registration ID | 
 **userRegistrationAcceptOrReject** | [**UserRegistrationAcceptOrReject**](UserRegistrationAcceptOrReject.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteRegistration**
```swift
    open class func deleteRegistration(registrationId: Int, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete registration

Delete the registration entry. It will not remove the user associated with this registration (if any)

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let registrationId = 987 // Int | Registration ID

// Delete registration
RegisterAPI.deleteRegistration(registrationId: registrationId) { (response, error) in
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
 **registrationId** | **Int** | Registration ID | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listRegistrations**
```swift
    open class func listRegistrations(start: Int? = nil, count: Int? = nil, search: String? = nil, sort: Sort_listRegistrations? = nil, completion: @escaping (_ data: ListRegistrations200Response?, _ error: Error?) -> Void)
```

List registrations

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let search = "search_example" // String |  (optional)
let sort = "sort_example" // String |  (optional)

// List registrations
RegisterAPI.listRegistrations(start: start, count: count, search: search, sort: sort) { (response, error) in
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
 **start** | **Int** | Offset used to paginate results | [optional] 
 **count** | **Int** | Number of items to return | [optional] [default to 15]
 **search** | **String** |  | [optional] 
 **sort** | **String** |  | [optional] 

### Return type

[**ListRegistrations200Response**](ListRegistrations200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **registerUser**
```swift
    open class func registerUser(registerUser: RegisterUser, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Register a user

Signup has to be enabled and signup approval is not required

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let registerUser = RegisterUser(username: "username_example", password: "password_example", email: "email_example", displayName: "displayName_example", channel: RegisterUser_channel(name: "name_example", displayName: "displayName_example")) // RegisterUser | 

// Register a user
RegisterAPI.registerUser(registerUser: registerUser) { (response, error) in
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
 **registerUser** | [**RegisterUser**](RegisterUser.md) |  | 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rejectRegistration**
```swift
    open class func rejectRegistration(registrationId: Int, userRegistrationAcceptOrReject: UserRegistrationAcceptOrReject? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Reject registration

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let registrationId = 987 // Int | Registration ID
let userRegistrationAcceptOrReject = UserRegistrationAcceptOrReject(moderationResponse: "moderationResponse_example", preventEmailDelivery: false) // UserRegistrationAcceptOrReject |  (optional)

// Reject registration
RegisterAPI.rejectRegistration(registrationId: registrationId, userRegistrationAcceptOrReject: userRegistrationAcceptOrReject) { (response, error) in
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
 **registrationId** | **Int** | Registration ID | 
 **userRegistrationAcceptOrReject** | [**UserRegistrationAcceptOrReject**](UserRegistrationAcceptOrReject.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **requestRegistration**
```swift
    open class func requestRegistration(userRegistrationRequest: UserRegistrationRequest? = nil, completion: @escaping (_ data: UserRegistration?, _ error: Error?) -> Void)
```

Request registration

Signup has to be enabled and require approval on the instance

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let userRegistrationRequest = UserRegistrationRequest(username: "username_example", password: "password_example", email: "email_example", displayName: "displayName_example", channel: RegisterUser_channel(name: "name_example", displayName: "displayName_example"), registrationReason: "registrationReason_example") // UserRegistrationRequest |  (optional)

// Request registration
RegisterAPI.requestRegistration(userRegistrationRequest: userRegistrationRequest) { (response, error) in
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
 **userRegistrationRequest** | [**UserRegistrationRequest**](UserRegistrationRequest.md) |  | [optional] 

### Return type

[**UserRegistration**](UserRegistration.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resendEmailToVerifyRegistration**
```swift
    open class func resendEmailToVerifyRegistration(resendEmailToVerifyRegistrationRequest: ResendEmailToVerifyRegistrationRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Resend verification link to registration request email

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let resendEmailToVerifyRegistrationRequest = resendEmailToVerifyRegistration_request(email: "email_example") // ResendEmailToVerifyRegistrationRequest |  (optional)

// Resend verification link to registration request email
RegisterAPI.resendEmailToVerifyRegistration(resendEmailToVerifyRegistrationRequest: resendEmailToVerifyRegistrationRequest) { (response, error) in
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
 **resendEmailToVerifyRegistrationRequest** | [**ResendEmailToVerifyRegistrationRequest**](ResendEmailToVerifyRegistrationRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

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
RegisterAPI.resendEmailToVerifyUser(resendEmailToVerifyUserRequest: resendEmailToVerifyUserRequest) { (response, error) in
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

# **verifyRegistrationEmail**
```swift
    open class func verifyRegistrationEmail(registrationId: Int, verifyRegistrationEmailRequest: VerifyRegistrationEmailRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Verify a registration email

Following a user registration request, the user will receive an email asking to click a link containing a secret. 

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let registrationId = 987 // Int | Registration ID
let verifyRegistrationEmailRequest = verifyRegistrationEmail_request(verificationString: "verificationString_example") // VerifyRegistrationEmailRequest |  (optional)

// Verify a registration email
RegisterAPI.verifyRegistrationEmail(registrationId: registrationId, verifyRegistrationEmailRequest: verifyRegistrationEmailRequest) { (response, error) in
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
 **registrationId** | **Int** | Registration ID | 
 **verifyRegistrationEmailRequest** | [**VerifyRegistrationEmailRequest**](VerifyRegistrationEmailRequest.md) |  | [optional] 

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
RegisterAPI.verifyUser(id: id, verifyUserRequest: verifyUserRequest) { (response, error) in
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

