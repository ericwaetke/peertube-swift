# ConfigAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1ConfigInstanceAvatarDelete**](ConfigAPI.md#apiv1configinstanceavatardelete) | **DELETE** /api/v1/config/instance-avatar | Delete instance avatar
[**apiV1ConfigInstanceAvatarPickPost**](ConfigAPI.md#apiv1configinstanceavatarpickpost) | **POST** /api/v1/config/instance-avatar/pick | Update instance avatar
[**apiV1ConfigInstanceBannerDelete**](ConfigAPI.md#apiv1configinstancebannerdelete) | **DELETE** /api/v1/config/instance-banner | Delete instance banner
[**apiV1ConfigInstanceBannerPickPost**](ConfigAPI.md#apiv1configinstancebannerpickpost) | **POST** /api/v1/config/instance-banner/pick | Update instance banner
[**apiV1ConfigInstanceLogoLogoTypeDelete**](ConfigAPI.md#apiv1configinstancelogologotypedelete) | **DELETE** /api/v1/config/instance-logo/:logoType | Delete instance logo
[**apiV1ConfigInstanceLogoLogoTypePickPost**](ConfigAPI.md#apiv1configinstancelogologotypepickpost) | **POST** /api/v1/config/instance-logo/:logoType/pick | Update instance logo
[**delCustomConfig**](ConfigAPI.md#delcustomconfig) | **DELETE** /api/v1/config/custom | Delete instance runtime configuration
[**getAbout**](ConfigAPI.md#getabout) | **GET** /api/v1/config/about | Get instance \&quot;About\&quot; information
[**getConfig**](ConfigAPI.md#getconfig) | **GET** /api/v1/config | Get instance public configuration
[**getCustomConfig**](ConfigAPI.md#getcustomconfig) | **GET** /api/v1/config/custom | Get instance runtime configuration
[**putCustomConfig**](ConfigAPI.md#putcustomconfig) | **PUT** /api/v1/config/custom | Set instance runtime configuration


# **apiV1ConfigInstanceAvatarDelete**
```swift
    open class func apiV1ConfigInstanceAvatarDelete(completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete instance avatar

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// Delete instance avatar
ConfigAPI.apiV1ConfigInstanceAvatarDelete() { (response, error) in
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

# **apiV1ConfigInstanceAvatarPickPost**
```swift
    open class func apiV1ConfigInstanceAvatarPickPost(avatarfile: URL? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Update instance avatar

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let avatarfile = URL(string: "https://example.com")! // URL | The file to upload. (optional)

// Update instance avatar
ConfigAPI.apiV1ConfigInstanceAvatarPickPost(avatarfile: avatarfile) { (response, error) in
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
 **avatarfile** | **URL** | The file to upload. | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1ConfigInstanceBannerDelete**
```swift
    open class func apiV1ConfigInstanceBannerDelete(completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete instance banner

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// Delete instance banner
ConfigAPI.apiV1ConfigInstanceBannerDelete() { (response, error) in
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

# **apiV1ConfigInstanceBannerPickPost**
```swift
    open class func apiV1ConfigInstanceBannerPickPost(bannerfile: URL? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Update instance banner

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let bannerfile = URL(string: "https://example.com")! // URL | The file to upload. (optional)

// Update instance banner
ConfigAPI.apiV1ConfigInstanceBannerPickPost(bannerfile: bannerfile) { (response, error) in
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
 **bannerfile** | **URL** | The file to upload. | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1ConfigInstanceLogoLogoTypeDelete**
```swift
    open class func apiV1ConfigInstanceLogoLogoTypeDelete(logoType: LogoType_apiV1ConfigInstanceLogoLogoTypeDelete, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete instance logo

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let logoType = "logoType_example" // String | 

// Delete instance logo
ConfigAPI.apiV1ConfigInstanceLogoLogoTypeDelete(logoType: logoType) { (response, error) in
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
 **logoType** | **String** |  | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1ConfigInstanceLogoLogoTypePickPost**
```swift
    open class func apiV1ConfigInstanceLogoLogoTypePickPost(logoType: LogoType_apiV1ConfigInstanceLogoLogoTypePickPost, logofile: URL? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Update instance logo

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let logoType = "logoType_example" // String | 
let logofile = URL(string: "https://example.com")! // URL | The file to upload. (optional)

// Update instance logo
ConfigAPI.apiV1ConfigInstanceLogoLogoTypePickPost(logoType: logoType, logofile: logofile) { (response, error) in
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
 **logoType** | **String** |  | 
 **logofile** | **URL** | The file to upload. | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **delCustomConfig**
```swift
    open class func delCustomConfig(completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete instance runtime configuration

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// Delete instance runtime configuration
ConfigAPI.delCustomConfig() { (response, error) in
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

# **getAbout**
```swift
    open class func getAbout(completion: @escaping (_ data: ServerConfigAbout?, _ error: Error?) -> Void)
```

Get instance \"About\" information

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// Get instance \"About\" information
ConfigAPI.getAbout() { (response, error) in
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

[**ServerConfigAbout**](ServerConfigAbout.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getConfig**
```swift
    open class func getConfig(completion: @escaping (_ data: ServerConfig?, _ error: Error?) -> Void)
```

Get instance public configuration

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// Get instance public configuration
ConfigAPI.getConfig() { (response, error) in
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

[**ServerConfig**](ServerConfig.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCustomConfig**
```swift
    open class func getCustomConfig(completion: @escaping (_ data: ServerConfigCustom?, _ error: Error?) -> Void)
```

Get instance runtime configuration

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// Get instance runtime configuration
ConfigAPI.getCustomConfig() { (response, error) in
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

[**ServerConfigCustom**](ServerConfigCustom.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putCustomConfig**
```swift
    open class func putCustomConfig(completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Set instance runtime configuration

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// Set instance runtime configuration
ConfigAPI.putCustomConfig() { (response, error) in
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

