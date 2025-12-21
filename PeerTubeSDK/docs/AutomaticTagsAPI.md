# AutomaticTagsAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1AutomaticTagsAccountsAccountNameAvailableGet**](AutomaticTagsAPI.md#apiv1automatictagsaccountsaccountnameavailableget) | **GET** /api/v1/automatic-tags/accounts/{accountName}/available | Get account available auto tags
[**apiV1AutomaticTagsPoliciesAccountsAccountNameCommentsGet**](AutomaticTagsAPI.md#apiv1automatictagspoliciesaccountsaccountnamecommentsget) | **GET** /api/v1/automatic-tags/policies/accounts/{accountName}/comments | Get account auto tag policies on comments
[**apiV1AutomaticTagsPoliciesAccountsAccountNameCommentsPut**](AutomaticTagsAPI.md#apiv1automatictagspoliciesaccountsaccountnamecommentsput) | **PUT** /api/v1/automatic-tags/policies/accounts/{accountName}/comments | Update account auto tag policies on comments
[**apiV1AutomaticTagsServerAvailableGet**](AutomaticTagsAPI.md#apiv1automatictagsserveravailableget) | **GET** /api/v1/automatic-tags/server/available | Get server available auto tags


# **apiV1AutomaticTagsAccountsAccountNameAvailableGet**
```swift
    open class func apiV1AutomaticTagsAccountsAccountNameAvailableGet(accountName: String, completion: @escaping (_ data: AutomaticTagAvailable?, _ error: Error?) -> Void)
```

Get account available auto tags

**PeerTube >= 6.2**

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let accountName = "accountName_example" // String | account name to get auto tag policies

// Get account available auto tags
AutomaticTagsAPI.apiV1AutomaticTagsAccountsAccountNameAvailableGet(accountName: accountName) { (response, error) in
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
 **accountName** | **String** | account name to get auto tag policies | 

### Return type

[**AutomaticTagAvailable**](AutomaticTagAvailable.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1AutomaticTagsPoliciesAccountsAccountNameCommentsGet**
```swift
    open class func apiV1AutomaticTagsPoliciesAccountsAccountNameCommentsGet(accountName: String, completion: @escaping (_ data: CommentAutoTagPolicies?, _ error: Error?) -> Void)
```

Get account auto tag policies on comments

**PeerTube >= 6.2**

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let accountName = "accountName_example" // String | account name to get auto tag policies

// Get account auto tag policies on comments
AutomaticTagsAPI.apiV1AutomaticTagsPoliciesAccountsAccountNameCommentsGet(accountName: accountName) { (response, error) in
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
 **accountName** | **String** | account name to get auto tag policies | 

### Return type

[**CommentAutoTagPolicies**](CommentAutoTagPolicies.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1AutomaticTagsPoliciesAccountsAccountNameCommentsPut**
```swift
    open class func apiV1AutomaticTagsPoliciesAccountsAccountNameCommentsPut(accountName: String, apiV1AutomaticTagsPoliciesAccountsAccountNameCommentsPutRequest: ApiV1AutomaticTagsPoliciesAccountsAccountNameCommentsPutRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Update account auto tag policies on comments

**PeerTube >= 6.2**

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let accountName = "accountName_example" // String | account name to update auto tag policies
let apiV1AutomaticTagsPoliciesAccountsAccountNameCommentsPutRequest = _api_v1_automatic_tags_policies_accounts__accountName__comments_put_request(review: ["review_example"]) // ApiV1AutomaticTagsPoliciesAccountsAccountNameCommentsPutRequest |  (optional)

// Update account auto tag policies on comments
AutomaticTagsAPI.apiV1AutomaticTagsPoliciesAccountsAccountNameCommentsPut(accountName: accountName, apiV1AutomaticTagsPoliciesAccountsAccountNameCommentsPutRequest: apiV1AutomaticTagsPoliciesAccountsAccountNameCommentsPutRequest) { (response, error) in
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
 **accountName** | **String** | account name to update auto tag policies | 
 **apiV1AutomaticTagsPoliciesAccountsAccountNameCommentsPutRequest** | [**ApiV1AutomaticTagsPoliciesAccountsAccountNameCommentsPutRequest**](ApiV1AutomaticTagsPoliciesAccountsAccountNameCommentsPutRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1AutomaticTagsServerAvailableGet**
```swift
    open class func apiV1AutomaticTagsServerAvailableGet(completion: @escaping (_ data: AutomaticTagAvailable?, _ error: Error?) -> Void)
```

Get server available auto tags

**PeerTube >= 6.2**

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// Get server available auto tags
AutomaticTagsAPI.apiV1AutomaticTagsServerAvailableGet() { (response, error) in
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

[**AutomaticTagAvailable**](AutomaticTagAvailable.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

