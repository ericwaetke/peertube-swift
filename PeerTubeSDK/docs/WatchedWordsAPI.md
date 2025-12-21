# WatchedWordsAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1WatchedWordsAccountsAccountNameListsGet**](WatchedWordsAPI.md#apiv1watchedwordsaccountsaccountnamelistsget) | **GET** /api/v1/watched-words/accounts/{accountName}/lists | List account watched words
[**apiV1WatchedWordsAccountsAccountNameListsListIdDelete**](WatchedWordsAPI.md#apiv1watchedwordsaccountsaccountnamelistslistiddelete) | **DELETE** /api/v1/watched-words/accounts/{accountName}/lists/{listId} | Delete account watched words
[**apiV1WatchedWordsAccountsAccountNameListsListIdPut**](WatchedWordsAPI.md#apiv1watchedwordsaccountsaccountnamelistslistidput) | **PUT** /api/v1/watched-words/accounts/{accountName}/lists/{listId} | Update account watched words
[**apiV1WatchedWordsAccountsAccountNameListsPost**](WatchedWordsAPI.md#apiv1watchedwordsaccountsaccountnamelistspost) | **POST** /api/v1/watched-words/accounts/{accountName}/lists | Add account watched words
[**apiV1WatchedWordsServerListsGet**](WatchedWordsAPI.md#apiv1watchedwordsserverlistsget) | **GET** /api/v1/watched-words/server/lists | List server watched words
[**apiV1WatchedWordsServerListsListIdDelete**](WatchedWordsAPI.md#apiv1watchedwordsserverlistslistiddelete) | **DELETE** /api/v1/watched-words/server/lists/{listId} | Delete server watched words
[**apiV1WatchedWordsServerListsListIdPut**](WatchedWordsAPI.md#apiv1watchedwordsserverlistslistidput) | **PUT** /api/v1/watched-words/server/lists/{listId} | Update server watched words
[**apiV1WatchedWordsServerListsPost**](WatchedWordsAPI.md#apiv1watchedwordsserverlistspost) | **POST** /api/v1/watched-words/server/lists | Add server watched words


# **apiV1WatchedWordsAccountsAccountNameListsGet**
```swift
    open class func apiV1WatchedWordsAccountsAccountNameListsGet(accountName: String, completion: @escaping (_ data: ApiV1WatchedWordsAccountsAccountNameListsGet200Response?, _ error: Error?) -> Void)
```

List account watched words

**PeerTube >= 6.2**

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let accountName = "accountName_example" // String | account name to list watched words

// List account watched words
WatchedWordsAPI.apiV1WatchedWordsAccountsAccountNameListsGet(accountName: accountName) { (response, error) in
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
 **accountName** | **String** | account name to list watched words | 

### Return type

[**ApiV1WatchedWordsAccountsAccountNameListsGet200Response**](ApiV1WatchedWordsAccountsAccountNameListsGet200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1WatchedWordsAccountsAccountNameListsListIdDelete**
```swift
    open class func apiV1WatchedWordsAccountsAccountNameListsListIdDelete(accountName: String, listId: String, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete account watched words

**PeerTube >= 6.2**

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let accountName = "accountName_example" // String | 
let listId = "listId_example" // String | list of watched words to delete

// Delete account watched words
WatchedWordsAPI.apiV1WatchedWordsAccountsAccountNameListsListIdDelete(accountName: accountName, listId: listId) { (response, error) in
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
 **accountName** | **String** |  | 
 **listId** | **String** | list of watched words to delete | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1WatchedWordsAccountsAccountNameListsListIdPut**
```swift
    open class func apiV1WatchedWordsAccountsAccountNameListsListIdPut(accountName: String, listId: String, apiV1WatchedWordsAccountsAccountNameListsPostRequest: ApiV1WatchedWordsAccountsAccountNameListsPostRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Update account watched words

**PeerTube >= 6.2**

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let accountName = "accountName_example" // String | 
let listId = "listId_example" // String | list of watched words to update
let apiV1WatchedWordsAccountsAccountNameListsPostRequest = _api_v1_watched_words_accounts__accountName__lists_post_request(listName: "listName_example", words: ["words_example"]) // ApiV1WatchedWordsAccountsAccountNameListsPostRequest |  (optional)

// Update account watched words
WatchedWordsAPI.apiV1WatchedWordsAccountsAccountNameListsListIdPut(accountName: accountName, listId: listId, apiV1WatchedWordsAccountsAccountNameListsPostRequest: apiV1WatchedWordsAccountsAccountNameListsPostRequest) { (response, error) in
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
 **accountName** | **String** |  | 
 **listId** | **String** | list of watched words to update | 
 **apiV1WatchedWordsAccountsAccountNameListsPostRequest** | [**ApiV1WatchedWordsAccountsAccountNameListsPostRequest**](ApiV1WatchedWordsAccountsAccountNameListsPostRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1WatchedWordsAccountsAccountNameListsPost**
```swift
    open class func apiV1WatchedWordsAccountsAccountNameListsPost(accountName: String, apiV1WatchedWordsAccountsAccountNameListsPostRequest: ApiV1WatchedWordsAccountsAccountNameListsPostRequest? = nil, completion: @escaping (_ data: ApiV1WatchedWordsAccountsAccountNameListsPost200Response?, _ error: Error?) -> Void)
```

Add account watched words

**PeerTube >= 6.2**

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let accountName = "accountName_example" // String | 
let apiV1WatchedWordsAccountsAccountNameListsPostRequest = _api_v1_watched_words_accounts__accountName__lists_post_request(listName: "listName_example", words: ["words_example"]) // ApiV1WatchedWordsAccountsAccountNameListsPostRequest |  (optional)

// Add account watched words
WatchedWordsAPI.apiV1WatchedWordsAccountsAccountNameListsPost(accountName: accountName, apiV1WatchedWordsAccountsAccountNameListsPostRequest: apiV1WatchedWordsAccountsAccountNameListsPostRequest) { (response, error) in
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
 **accountName** | **String** |  | 
 **apiV1WatchedWordsAccountsAccountNameListsPostRequest** | [**ApiV1WatchedWordsAccountsAccountNameListsPostRequest**](ApiV1WatchedWordsAccountsAccountNameListsPostRequest.md) |  | [optional] 

### Return type

[**ApiV1WatchedWordsAccountsAccountNameListsPost200Response**](ApiV1WatchedWordsAccountsAccountNameListsPost200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1WatchedWordsServerListsGet**
```swift
    open class func apiV1WatchedWordsServerListsGet(completion: @escaping (_ data: ApiV1WatchedWordsAccountsAccountNameListsGet200Response?, _ error: Error?) -> Void)
```

List server watched words

**PeerTube >= 6.2**

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// List server watched words
WatchedWordsAPI.apiV1WatchedWordsServerListsGet() { (response, error) in
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

[**ApiV1WatchedWordsAccountsAccountNameListsGet200Response**](ApiV1WatchedWordsAccountsAccountNameListsGet200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1WatchedWordsServerListsListIdDelete**
```swift
    open class func apiV1WatchedWordsServerListsListIdDelete(listId: String, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete server watched words

**PeerTube >= 6.2**

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let listId = "listId_example" // String | list of watched words to delete

// Delete server watched words
WatchedWordsAPI.apiV1WatchedWordsServerListsListIdDelete(listId: listId) { (response, error) in
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
 **listId** | **String** | list of watched words to delete | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1WatchedWordsServerListsListIdPut**
```swift
    open class func apiV1WatchedWordsServerListsListIdPut(listId: String, apiV1WatchedWordsAccountsAccountNameListsPostRequest: ApiV1WatchedWordsAccountsAccountNameListsPostRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Update server watched words

**PeerTube >= 6.2**

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let listId = "listId_example" // String | list of watched words to update
let apiV1WatchedWordsAccountsAccountNameListsPostRequest = _api_v1_watched_words_accounts__accountName__lists_post_request(listName: "listName_example", words: ["words_example"]) // ApiV1WatchedWordsAccountsAccountNameListsPostRequest |  (optional)

// Update server watched words
WatchedWordsAPI.apiV1WatchedWordsServerListsListIdPut(listId: listId, apiV1WatchedWordsAccountsAccountNameListsPostRequest: apiV1WatchedWordsAccountsAccountNameListsPostRequest) { (response, error) in
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
 **listId** | **String** | list of watched words to update | 
 **apiV1WatchedWordsAccountsAccountNameListsPostRequest** | [**ApiV1WatchedWordsAccountsAccountNameListsPostRequest**](ApiV1WatchedWordsAccountsAccountNameListsPostRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1WatchedWordsServerListsPost**
```swift
    open class func apiV1WatchedWordsServerListsPost(apiV1WatchedWordsAccountsAccountNameListsPostRequest: ApiV1WatchedWordsAccountsAccountNameListsPostRequest? = nil, completion: @escaping (_ data: ApiV1WatchedWordsAccountsAccountNameListsPost200Response?, _ error: Error?) -> Void)
```

Add server watched words

**PeerTube >= 6.2**

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let apiV1WatchedWordsAccountsAccountNameListsPostRequest = _api_v1_watched_words_accounts__accountName__lists_post_request(listName: "listName_example", words: ["words_example"]) // ApiV1WatchedWordsAccountsAccountNameListsPostRequest |  (optional)

// Add server watched words
WatchedWordsAPI.apiV1WatchedWordsServerListsPost(apiV1WatchedWordsAccountsAccountNameListsPostRequest: apiV1WatchedWordsAccountsAccountNameListsPostRequest) { (response, error) in
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
 **apiV1WatchedWordsAccountsAccountNameListsPostRequest** | [**ApiV1WatchedWordsAccountsAccountNameListsPostRequest**](ApiV1WatchedWordsAccountsAccountNameListsPostRequest.md) |  | [optional] 

### Return type

[**ApiV1WatchedWordsAccountsAccountNameListsPost200Response**](ApiV1WatchedWordsAccountsAccountNameListsPost200Response.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

