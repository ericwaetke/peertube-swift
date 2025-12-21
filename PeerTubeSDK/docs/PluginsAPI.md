# PluginsAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addPlugin**](PluginsAPI.md#addplugin) | **POST** /api/v1/plugins/install | Install a plugin
[**apiV1PluginsNpmNamePublicSettingsGet**](PluginsAPI.md#apiv1pluginsnpmnamepublicsettingsget) | **GET** /api/v1/plugins/{npmName}/public-settings | Get a plugin&#39;s public settings
[**apiV1PluginsNpmNameRegisteredSettingsGet**](PluginsAPI.md#apiv1pluginsnpmnameregisteredsettingsget) | **GET** /api/v1/plugins/{npmName}/registered-settings | Get a plugin&#39;s registered settings
[**apiV1PluginsNpmNameSettingsPut**](PluginsAPI.md#apiv1pluginsnpmnamesettingsput) | **PUT** /api/v1/plugins/{npmName}/settings | Set a plugin&#39;s settings
[**getAvailablePlugins**](PluginsAPI.md#getavailableplugins) | **GET** /api/v1/plugins/available | List available plugins
[**getPlugin**](PluginsAPI.md#getplugin) | **GET** /api/v1/plugins/{npmName} | Get a plugin
[**getPlugins**](PluginsAPI.md#getplugins) | **GET** /api/v1/plugins | List plugins
[**uninstallPlugin**](PluginsAPI.md#uninstallplugin) | **POST** /api/v1/plugins/uninstall | Uninstall a plugin
[**updatePlugin**](PluginsAPI.md#updateplugin) | **POST** /api/v1/plugins/update | Update a plugin


# **addPlugin**
```swift
    open class func addPlugin(addPluginRequest: AddPluginRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Install a plugin

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let addPluginRequest = addPlugin_request(npmName: "npmName_example", path: "path_example") // AddPluginRequest |  (optional)

// Install a plugin
PluginsAPI.addPlugin(addPluginRequest: addPluginRequest) { (response, error) in
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
 **addPluginRequest** | [**AddPluginRequest**](AddPluginRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1PluginsNpmNamePublicSettingsGet**
```swift
    open class func apiV1PluginsNpmNamePublicSettingsGet(npmName: String, completion: @escaping (_ data: [String: JSONValue]?, _ error: Error?) -> Void)
```

Get a plugin's public settings

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let npmName = "npmName_example" // String | name of the plugin/theme on npmjs.com or in its package.json

// Get a plugin's public settings
PluginsAPI.apiV1PluginsNpmNamePublicSettingsGet(npmName: npmName) { (response, error) in
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
 **npmName** | **String** | name of the plugin/theme on npmjs.com or in its package.json | 

### Return type

**[String: JSONValue]**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1PluginsNpmNameRegisteredSettingsGet**
```swift
    open class func apiV1PluginsNpmNameRegisteredSettingsGet(npmName: String, completion: @escaping (_ data: [String: JSONValue]?, _ error: Error?) -> Void)
```

Get a plugin's registered settings

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let npmName = "npmName_example" // String | name of the plugin/theme on npmjs.com or in its package.json

// Get a plugin's registered settings
PluginsAPI.apiV1PluginsNpmNameRegisteredSettingsGet(npmName: npmName) { (response, error) in
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
 **npmName** | **String** | name of the plugin/theme on npmjs.com or in its package.json | 

### Return type

**[String: JSONValue]**

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1PluginsNpmNameSettingsPut**
```swift
    open class func apiV1PluginsNpmNameSettingsPut(npmName: String, apiV1PluginsNpmNameSettingsPutRequest: ApiV1PluginsNpmNameSettingsPutRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Set a plugin's settings

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let npmName = "npmName_example" // String | name of the plugin/theme on npmjs.com or in its package.json
let apiV1PluginsNpmNameSettingsPutRequest = _api_v1_plugins__npmName__settings_put_request(settings: "TODO") // ApiV1PluginsNpmNameSettingsPutRequest |  (optional)

// Set a plugin's settings
PluginsAPI.apiV1PluginsNpmNameSettingsPut(npmName: npmName, apiV1PluginsNpmNameSettingsPutRequest: apiV1PluginsNpmNameSettingsPutRequest) { (response, error) in
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
 **npmName** | **String** | name of the plugin/theme on npmjs.com or in its package.json | 
 **apiV1PluginsNpmNameSettingsPutRequest** | [**ApiV1PluginsNpmNameSettingsPutRequest**](ApiV1PluginsNpmNameSettingsPutRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAvailablePlugins**
```swift
    open class func getAvailablePlugins(search: String? = nil, pluginType: Int? = nil, currentPeerTubeEngine: String? = nil, start: Int? = nil, count: Int? = nil, sort: String? = nil, completion: @escaping (_ data: PluginResponse?, _ error: Error?) -> Void)
```

List available plugins

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let search = "search_example" // String |  (optional)
let pluginType = 987 // Int |  (optional)
let currentPeerTubeEngine = "currentPeerTubeEngine_example" // String |  (optional)
let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let sort = "sort_example" // String | Sort column (optional)

// List available plugins
PluginsAPI.getAvailablePlugins(search: search, pluginType: pluginType, currentPeerTubeEngine: currentPeerTubeEngine, start: start, count: count, sort: sort) { (response, error) in
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
 **search** | **String** |  | [optional] 
 **pluginType** | **Int** |  | [optional] 
 **currentPeerTubeEngine** | **String** |  | [optional] 
 **start** | **Int** | Offset used to paginate results | [optional] 
 **count** | **Int** | Number of items to return | [optional] [default to 15]
 **sort** | **String** | Sort column | [optional] 

### Return type

[**PluginResponse**](PluginResponse.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPlugin**
```swift
    open class func getPlugin(npmName: String, completion: @escaping (_ data: Plugin?, _ error: Error?) -> Void)
```

Get a plugin

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let npmName = "npmName_example" // String | name of the plugin/theme on npmjs.com or in its package.json

// Get a plugin
PluginsAPI.getPlugin(npmName: npmName) { (response, error) in
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
 **npmName** | **String** | name of the plugin/theme on npmjs.com or in its package.json | 

### Return type

[**Plugin**](Plugin.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPlugins**
```swift
    open class func getPlugins(pluginType: Int? = nil, uninstalled: Bool? = nil, start: Int? = nil, count: Int? = nil, sort: String? = nil, completion: @escaping (_ data: PluginResponse?, _ error: Error?) -> Void)
```

List plugins

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let pluginType = 987 // Int |  (optional)
let uninstalled = true // Bool |  (optional)
let start = 987 // Int | Offset used to paginate results (optional)
let count = 987 // Int | Number of items to return (optional) (default to 15)
let sort = "sort_example" // String | Sort column (optional)

// List plugins
PluginsAPI.getPlugins(pluginType: pluginType, uninstalled: uninstalled, start: start, count: count, sort: sort) { (response, error) in
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
 **pluginType** | **Int** |  | [optional] 
 **uninstalled** | **Bool** |  | [optional] 
 **start** | **Int** | Offset used to paginate results | [optional] 
 **count** | **Int** | Number of items to return | [optional] [default to 15]
 **sort** | **String** | Sort column | [optional] 

### Return type

[**PluginResponse**](PluginResponse.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **uninstallPlugin**
```swift
    open class func uninstallPlugin(uninstallPluginRequest: UninstallPluginRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Uninstall a plugin

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let uninstallPluginRequest = uninstallPlugin_request(npmName: "npmName_example") // UninstallPluginRequest |  (optional)

// Uninstall a plugin
PluginsAPI.uninstallPlugin(uninstallPluginRequest: uninstallPluginRequest) { (response, error) in
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
 **uninstallPluginRequest** | [**UninstallPluginRequest**](UninstallPluginRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updatePlugin**
```swift
    open class func updatePlugin(addPluginRequest: AddPluginRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Update a plugin

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let addPluginRequest = addPlugin_request(npmName: "npmName_example", path: "path_example") // AddPluginRequest |  (optional)

// Update a plugin
PluginsAPI.updatePlugin(addPluginRequest: addPluginRequest) { (response, error) in
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
 **addPluginRequest** | [**AddPluginRequest**](AddPluginRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

