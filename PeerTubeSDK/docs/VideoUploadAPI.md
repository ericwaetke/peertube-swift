# VideoUploadAPI

All URIs are relative to *https://peertube2.cpy.re*

Method | HTTP request | Description
------------- | ------------- | -------------
[**importVideo**](VideoUploadAPI.md#importvideo) | **POST** /api/v1/videos/imports | Import a video
[**replaceVideoSourceResumable**](VideoUploadAPI.md#replacevideosourceresumable) | **PUT** /api/v1/videos/{id}/source/replace-resumable | Send chunk for the resumable replacement of a video
[**replaceVideoSourceResumableCancel**](VideoUploadAPI.md#replacevideosourceresumablecancel) | **DELETE** /api/v1/videos/{id}/source/replace-resumable | Cancel the resumable replacement of a video
[**replaceVideoSourceResumableInit**](VideoUploadAPI.md#replacevideosourceresumableinit) | **POST** /api/v1/videos/{id}/source/replace-resumable | Initialize the resumable replacement of a video
[**uploadLegacy**](VideoUploadAPI.md#uploadlegacy) | **POST** /api/v1/videos/upload | Upload a video
[**uploadResumable**](VideoUploadAPI.md#uploadresumable) | **PUT** /api/v1/videos/upload-resumable | Send chunk for the resumable upload of a video
[**uploadResumableCancel**](VideoUploadAPI.md#uploadresumablecancel) | **DELETE** /api/v1/videos/upload-resumable | Cancel the resumable upload of a video, deleting any data uploaded so far
[**uploadResumableInit**](VideoUploadAPI.md#uploadresumableinit) | **POST** /api/v1/videos/upload-resumable | Initialize the resumable upload of a video


# **importVideo**
```swift
    open class func importVideo(name: String, channelId: Int, targetUrl: String? = nil, magnetUri: String? = nil, torrentfile: URL? = nil, privacy: VideoPrivacySet? = nil, category: Int? = nil, licence: Int? = nil, language: String? = nil, description: String? = nil, waitTranscoding: Bool? = nil, generateTranscription: Bool? = nil, support: String? = nil, nsfw: Bool? = nil, nsfwSummary: JSONValue? = nil, nsfwFlags: NSFWFlag? = nil, tags: Set<String>? = nil, commentsPolicy: VideoCommentsPolicySet? = nil, downloadEnabled: Bool? = nil, originallyPublishedAt: Date? = nil, scheduleUpdate: VideoScheduledUpdate? = nil, thumbnailfile: URL? = nil, previewfile: URL? = nil, videoPasswords: Set<String>? = nil, completion: @escaping (_ data: VideoUploadResponse?, _ error: Error?) -> Void)
```

Import a video

Import a torrent or magnetURI or HTTP resource (if enabled by the instance administrator)

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let name = "name_example" // String | Video name
let channelId = 987 // Int | Channel id that will contain this video
let targetUrl = "null" // String | remote URL where to find the import's source video (optional)
let magnetUri = "null" // String | magnet URI allowing to resolve the import's source video (optional)
let torrentfile = URL(string: "https://example.com")! // URL | Torrent file containing only the video file (optional)
let privacy = VideoPrivacySet() // VideoPrivacySet |  (optional)
let category = 987 // Int | category id of the video (see [/videos/categories](#operation/getCategories)) (optional)
let licence = 987 // Int | licence id of the video (see [/videos/licences](#operation/getLicences)) (optional)
let language = "language_example" // String | language id of the video (see [/videos/languages](#operation/getLanguages)) (optional)
let description = "description_example" // String | Video description (optional)
let waitTranscoding = true // Bool | Whether or not we wait transcoding before publish the video (optional)
let generateTranscription = true // Bool | **PeerTube >= 6.2** If enabled by the admin, automatically generate a subtitle of the video (optional)
let support = "support_example" // String | A text tell the audience how to support the video creator (optional)
let nsfw = true // Bool | Whether or not this video contains sensitive content (optional)
let nsfwSummary =  // JSONValue | More information about the sensitive content of the video (optional)
let nsfwFlags = NSFWFlag() // NSFWFlag |  (optional)
let tags = ["inner_example"] // Set<String> | Video tags (maximum 5 tags each between 2 and 30 characters) (optional)
let commentsPolicy = VideoCommentsPolicySet() // VideoCommentsPolicySet |  (optional)
let downloadEnabled = true // Bool | Enable or disable downloading for this video (optional)
let originallyPublishedAt = Date() // Date | Date when the content was originally published (optional)
let scheduleUpdate = VideoScheduledUpdate(privacy: VideoPrivacySet(), updateAt: Date()) // VideoScheduledUpdate |  (optional)
let thumbnailfile = URL(string: "https://example.com")! // URL | Video thumbnail file (optional)
let previewfile = URL(string: "https://example.com")! // URL | Video preview file (optional)
let videoPasswords = ["inner_example"] // Set<String> |  (optional)

// Import a video
VideoUploadAPI.importVideo(name: name, channelId: channelId, targetUrl: targetUrl, magnetUri: magnetUri, torrentfile: torrentfile, privacy: privacy, category: category, licence: licence, language: language, description: description, waitTranscoding: waitTranscoding, generateTranscription: generateTranscription, support: support, nsfw: nsfw, nsfwSummary: nsfwSummary, nsfwFlags: nsfwFlags, tags: tags, commentsPolicy: commentsPolicy, downloadEnabled: downloadEnabled, originallyPublishedAt: originallyPublishedAt, scheduleUpdate: scheduleUpdate, thumbnailfile: thumbnailfile, previewfile: previewfile, videoPasswords: videoPasswords) { (response, error) in
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
 **name** | **String** | Video name | 
 **channelId** | **Int** | Channel id that will contain this video | 
 **targetUrl** | [**String**](String.md) | remote URL where to find the import&#39;s source video | [optional] 
 **magnetUri** | [**String**](String.md) | magnet URI allowing to resolve the import&#39;s source video | [optional] 
 **torrentfile** | [**URL**](URL.md) | Torrent file containing only the video file | [optional] 
 **privacy** | [**VideoPrivacySet**](VideoPrivacySet.md) |  | [optional] 
 **category** | **Int** | category id of the video (see [/videos/categories](#operation/getCategories)) | [optional] 
 **licence** | **Int** | licence id of the video (see [/videos/licences](#operation/getLicences)) | [optional] 
 **language** | **String** | language id of the video (see [/videos/languages](#operation/getLanguages)) | [optional] 
 **description** | **String** | Video description | [optional] 
 **waitTranscoding** | **Bool** | Whether or not we wait transcoding before publish the video | [optional] 
 **generateTranscription** | **Bool** | **PeerTube &gt;&#x3D; 6.2** If enabled by the admin, automatically generate a subtitle of the video | [optional] 
 **support** | **String** | A text tell the audience how to support the video creator | [optional] 
 **nsfw** | **Bool** | Whether or not this video contains sensitive content | [optional] 
 **nsfwSummary** | [**JSONValue**](JSONValue.md) | More information about the sensitive content of the video | [optional] 
 **nsfwFlags** | [**NSFWFlag**](NSFWFlag.md) |  | [optional] 
 **tags** | [**Set&lt;String&gt;**](String.md) | Video tags (maximum 5 tags each between 2 and 30 characters) | [optional] 
 **commentsPolicy** | [**VideoCommentsPolicySet**](VideoCommentsPolicySet.md) |  | [optional] 
 **downloadEnabled** | **Bool** | Enable or disable downloading for this video | [optional] 
 **originallyPublishedAt** | **Date** | Date when the content was originally published | [optional] 
 **scheduleUpdate** | [**VideoScheduledUpdate**](VideoScheduledUpdate.md) |  | [optional] 
 **thumbnailfile** | **URL** | Video thumbnail file | [optional] 
 **previewfile** | **URL** | Video preview file | [optional] 
 **videoPasswords** | [**Set&lt;String&gt;**](String.md) |  | [optional] 

### Return type

[**VideoUploadResponse**](VideoUploadResponse.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **replaceVideoSourceResumable**
```swift
    open class func replaceVideoSourceResumable(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, uploadId: String, contentRange: String, contentLength: Double, body: URL? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Send chunk for the resumable replacement of a video

**PeerTube >= 6.0** Uses [a resumable protocol](https://github.com/kukhariev/node-uploadx/blob/master/proto.md) to continue, pause or resume the replacement of a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let uploadId = "uploadId_example" // String | Created session id to proceed with. If you didn't send chunks in the last hour, it is not valid anymore and you need to initialize a new upload. 
let contentRange = "contentRange_example" // String | Specifies the bytes in the file that the request is uploading.  For example, a value of `bytes 0-262143/1000000` shows that the request is sending the first 262144 bytes (256 x 1024) in a 2,469,036 byte file. 
let contentLength = 987 // Double | Size of the chunk that the request is sending.  Remember that larger chunks are more efficient. PeerTube's web client uses chunks varying from 1048576 bytes (~1MB) and increases or reduces size depending on connection health. 
let body = URL(string: "https://example.com")! // URL |  (optional)

// Send chunk for the resumable replacement of a video
VideoUploadAPI.replaceVideoSourceResumable(id: id, uploadId: uploadId, contentRange: contentRange, contentLength: contentLength, body: body) { (response, error) in
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
 **id** | [**ApiV1VideosOwnershipIdAcceptPostIdParameter**](.md) | The object id, uuid or short uuid | 
 **uploadId** | **String** | Created session id to proceed with. If you didn&#39;t send chunks in the last hour, it is not valid anymore and you need to initialize a new upload.  | 
 **contentRange** | **String** | Specifies the bytes in the file that the request is uploading.  For example, a value of &#x60;bytes 0-262143/1000000&#x60; shows that the request is sending the first 262144 bytes (256 x 1024) in a 2,469,036 byte file.  | 
 **contentLength** | **Double** | Size of the chunk that the request is sending.  Remember that larger chunks are more efficient. PeerTube&#39;s web client uses chunks varying from 1048576 bytes (~1MB) and increases or reduces size depending on connection health.  | 
 **body** | **URL** |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/octet-stream
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **replaceVideoSourceResumableCancel**
```swift
    open class func replaceVideoSourceResumableCancel(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, uploadId: String, contentLength: Double, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Cancel the resumable replacement of a video

**PeerTube >= 6.0** Uses [a resumable protocol](https://github.com/kukhariev/node-uploadx/blob/master/proto.md) to cancel the replacement of a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let uploadId = "uploadId_example" // String | Created session id to proceed with. If you didn't send chunks in the last hour, it is not valid anymore and you need to initialize a new upload. 
let contentLength = 987 // Double | 

// Cancel the resumable replacement of a video
VideoUploadAPI.replaceVideoSourceResumableCancel(id: id, uploadId: uploadId, contentLength: contentLength) { (response, error) in
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
 **id** | [**ApiV1VideosOwnershipIdAcceptPostIdParameter**](.md) | The object id, uuid or short uuid | 
 **uploadId** | **String** | Created session id to proceed with. If you didn&#39;t send chunks in the last hour, it is not valid anymore and you need to initialize a new upload.  | 
 **contentLength** | **Double** |  | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **replaceVideoSourceResumableInit**
```swift
    open class func replaceVideoSourceResumableInit(id: ApiV1VideosOwnershipIdAcceptPostIdParameter, xUploadContentLength: Double, xUploadContentType: String, videoReplaceSourceRequestResumable: VideoReplaceSourceRequestResumable? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Initialize the resumable replacement of a video

**PeerTube >= 6.0** Uses [a resumable protocol](https://github.com/kukhariev/node-uploadx/blob/master/proto.md) to initialize the replacement of a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = _api_v1_videos_ownership__id__accept_post_id_parameter() // ApiV1VideosOwnershipIdAcceptPostIdParameter | The object id, uuid or short uuid
let xUploadContentLength = 987 // Double | Number of bytes that will be uploaded in subsequent requests. Set this value to the size of the file you are uploading.
let xUploadContentType = "xUploadContentType_example" // String | MIME type of the file that you are uploading. Depending on your instance settings, acceptable values might vary.
let videoReplaceSourceRequestResumable = VideoReplaceSourceRequestResumable(filename: "filename_example") // VideoReplaceSourceRequestResumable |  (optional)

// Initialize the resumable replacement of a video
VideoUploadAPI.replaceVideoSourceResumableInit(id: id, xUploadContentLength: xUploadContentLength, xUploadContentType: xUploadContentType, videoReplaceSourceRequestResumable: videoReplaceSourceRequestResumable) { (response, error) in
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
 **id** | [**ApiV1VideosOwnershipIdAcceptPostIdParameter**](.md) | The object id, uuid or short uuid | 
 **xUploadContentLength** | **Double** | Number of bytes that will be uploaded in subsequent requests. Set this value to the size of the file you are uploading. | 
 **xUploadContentType** | **String** | MIME type of the file that you are uploading. Depending on your instance settings, acceptable values might vary. | 
 **videoReplaceSourceRequestResumable** | [**VideoReplaceSourceRequestResumable**](VideoReplaceSourceRequestResumable.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **uploadLegacy**
```swift
    open class func uploadLegacy(name: String, channelId: Int, videofile: URL, privacy: VideoPrivacySet? = nil, category: Int? = nil, licence: Int? = nil, language: String? = nil, description: String? = nil, waitTranscoding: Bool? = nil, generateTranscription: Bool? = nil, support: String? = nil, nsfw: Bool? = nil, nsfwSummary: JSONValue? = nil, nsfwFlags: NSFWFlag? = nil, tags: Set<String>? = nil, commentsPolicy: VideoCommentsPolicySet? = nil, downloadEnabled: Bool? = nil, originallyPublishedAt: Date? = nil, scheduleUpdate: VideoScheduledUpdate? = nil, thumbnailfile: URL? = nil, previewfile: URL? = nil, videoPasswords: Set<String>? = nil, completion: @escaping (_ data: VideoUploadResponse?, _ error: Error?) -> Void)
```

Upload a video

Uses a single request to upload a video.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let name = "name_example" // String | Video name
let channelId = 987 // Int | Channel id that will contain this video
let videofile = URL(string: "https://example.com")! // URL | Video file
let privacy = VideoPrivacySet() // VideoPrivacySet |  (optional)
let category = 987 // Int | category id of the video (see [/videos/categories](#operation/getCategories)) (optional)
let licence = 987 // Int | licence id of the video (see [/videos/licences](#operation/getLicences)) (optional)
let language = "language_example" // String | language id of the video (see [/videos/languages](#operation/getLanguages)) (optional)
let description = "description_example" // String | Video description (optional)
let waitTranscoding = true // Bool | Whether or not we wait transcoding before publish the video (optional)
let generateTranscription = true // Bool | **PeerTube >= 6.2** If enabled by the admin, automatically generate a subtitle of the video (optional)
let support = "support_example" // String | A text tell the audience how to support the video creator (optional)
let nsfw = true // Bool | Whether or not this video contains sensitive content (optional)
let nsfwSummary =  // JSONValue | More information about the sensitive content of the video (optional)
let nsfwFlags = NSFWFlag() // NSFWFlag |  (optional)
let tags = ["inner_example"] // Set<String> | Video tags (maximum 5 tags each between 2 and 30 characters) (optional)
let commentsPolicy = VideoCommentsPolicySet() // VideoCommentsPolicySet |  (optional)
let downloadEnabled = true // Bool | Enable or disable downloading for this video (optional)
let originallyPublishedAt = Date() // Date | Date when the content was originally published (optional)
let scheduleUpdate = VideoScheduledUpdate(privacy: VideoPrivacySet(), updateAt: Date()) // VideoScheduledUpdate |  (optional)
let thumbnailfile = URL(string: "https://example.com")! // URL | Video thumbnail file (optional)
let previewfile = URL(string: "https://example.com")! // URL | Video preview file (optional)
let videoPasswords = ["inner_example"] // Set<String> |  (optional)

// Upload a video
VideoUploadAPI.uploadLegacy(name: name, channelId: channelId, videofile: videofile, privacy: privacy, category: category, licence: licence, language: language, description: description, waitTranscoding: waitTranscoding, generateTranscription: generateTranscription, support: support, nsfw: nsfw, nsfwSummary: nsfwSummary, nsfwFlags: nsfwFlags, tags: tags, commentsPolicy: commentsPolicy, downloadEnabled: downloadEnabled, originallyPublishedAt: originallyPublishedAt, scheduleUpdate: scheduleUpdate, thumbnailfile: thumbnailfile, previewfile: previewfile, videoPasswords: videoPasswords) { (response, error) in
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
 **name** | **String** | Video name | 
 **channelId** | **Int** | Channel id that will contain this video | 
 **videofile** | **URL** | Video file | 
 **privacy** | [**VideoPrivacySet**](VideoPrivacySet.md) |  | [optional] 
 **category** | **Int** | category id of the video (see [/videos/categories](#operation/getCategories)) | [optional] 
 **licence** | **Int** | licence id of the video (see [/videos/licences](#operation/getLicences)) | [optional] 
 **language** | **String** | language id of the video (see [/videos/languages](#operation/getLanguages)) | [optional] 
 **description** | **String** | Video description | [optional] 
 **waitTranscoding** | **Bool** | Whether or not we wait transcoding before publish the video | [optional] 
 **generateTranscription** | **Bool** | **PeerTube &gt;&#x3D; 6.2** If enabled by the admin, automatically generate a subtitle of the video | [optional] 
 **support** | **String** | A text tell the audience how to support the video creator | [optional] 
 **nsfw** | **Bool** | Whether or not this video contains sensitive content | [optional] 
 **nsfwSummary** | [**JSONValue**](JSONValue.md) | More information about the sensitive content of the video | [optional] 
 **nsfwFlags** | [**NSFWFlag**](NSFWFlag.md) |  | [optional] 
 **tags** | [**Set&lt;String&gt;**](String.md) | Video tags (maximum 5 tags each between 2 and 30 characters) | [optional] 
 **commentsPolicy** | [**VideoCommentsPolicySet**](VideoCommentsPolicySet.md) |  | [optional] 
 **downloadEnabled** | **Bool** | Enable or disable downloading for this video | [optional] 
 **originallyPublishedAt** | **Date** | Date when the content was originally published | [optional] 
 **scheduleUpdate** | [**VideoScheduledUpdate**](VideoScheduledUpdate.md) |  | [optional] 
 **thumbnailfile** | **URL** | Video thumbnail file | [optional] 
 **previewfile** | **URL** | Video preview file | [optional] 
 **videoPasswords** | [**Set&lt;String&gt;**](String.md) |  | [optional] 

### Return type

[**VideoUploadResponse**](VideoUploadResponse.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **uploadResumable**
```swift
    open class func uploadResumable(uploadId: String, contentRange: String, contentLength: Double, body: URL? = nil, completion: @escaping (_ data: VideoUploadResponse?, _ error: Error?) -> Void)
```

Send chunk for the resumable upload of a video

Uses [a resumable protocol](https://github.com/kukhariev/node-uploadx/blob/master/proto.md) to continue, pause or resume the upload of a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let uploadId = "uploadId_example" // String | Created session id to proceed with. If you didn't send chunks in the last hour, it is not valid anymore and you need to initialize a new upload. 
let contentRange = "contentRange_example" // String | Specifies the bytes in the file that the request is uploading.  For example, a value of `bytes 0-262143/1000000` shows that the request is sending the first 262144 bytes (256 x 1024) in a 2,469,036 byte file. 
let contentLength = 987 // Double | Size of the chunk that the request is sending.  Remember that larger chunks are more efficient. PeerTube's web client uses chunks varying from 1048576 bytes (~1MB) and increases or reduces size depending on connection health. 
let body = URL(string: "https://example.com")! // URL |  (optional)

// Send chunk for the resumable upload of a video
VideoUploadAPI.uploadResumable(uploadId: uploadId, contentRange: contentRange, contentLength: contentLength, body: body) { (response, error) in
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
 **uploadId** | **String** | Created session id to proceed with. If you didn&#39;t send chunks in the last hour, it is not valid anymore and you need to initialize a new upload.  | 
 **contentRange** | **String** | Specifies the bytes in the file that the request is uploading.  For example, a value of &#x60;bytes 0-262143/1000000&#x60; shows that the request is sending the first 262144 bytes (256 x 1024) in a 2,469,036 byte file.  | 
 **contentLength** | **Double** | Size of the chunk that the request is sending.  Remember that larger chunks are more efficient. PeerTube&#39;s web client uses chunks varying from 1048576 bytes (~1MB) and increases or reduces size depending on connection health.  | 
 **body** | **URL** |  | [optional] 

### Return type

[**VideoUploadResponse**](VideoUploadResponse.md)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/octet-stream
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **uploadResumableCancel**
```swift
    open class func uploadResumableCancel(uploadId: String, contentLength: Double, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Cancel the resumable upload of a video, deleting any data uploaded so far

Uses [a resumable protocol](https://github.com/kukhariev/node-uploadx/blob/master/proto.md) to cancel the upload of a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let uploadId = "uploadId_example" // String | Created session id to proceed with. If you didn't send chunks in the last hour, it is not valid anymore and you need to initialize a new upload. 
let contentLength = 987 // Double | 

// Cancel the resumable upload of a video, deleting any data uploaded so far
VideoUploadAPI.uploadResumableCancel(uploadId: uploadId, contentLength: contentLength) { (response, error) in
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
 **uploadId** | **String** | Created session id to proceed with. If you didn&#39;t send chunks in the last hour, it is not valid anymore and you need to initialize a new upload.  | 
 **contentLength** | **Double** |  | 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **uploadResumableInit**
```swift
    open class func uploadResumableInit(xUploadContentLength: Double, xUploadContentType: String, videoUploadRequestResumable: VideoUploadRequestResumable? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Initialize the resumable upload of a video

Uses [a resumable protocol](https://github.com/kukhariev/node-uploadx/blob/master/proto.md) to initialize the upload of a video

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let xUploadContentLength = 987 // Double | Number of bytes that will be uploaded in subsequent requests. Set this value to the size of the file you are uploading.
let xUploadContentType = "xUploadContentType_example" // String | MIME type of the file that you are uploading. Depending on your instance settings, acceptable values might vary.
let videoUploadRequestResumable = VideoUploadRequestResumable(name: "name_example", channelId: 123, privacy: VideoPrivacySet(), category: 123, licence: 123, language: "language_example", description: "description_example", waitTranscoding: false, generateTranscription: false, support: "support_example", nsfw: false, nsfwSummary: 123, nsfwFlags: NSFWFlag(), tags: ["tags_example"], commentsPolicy: VideoCommentsPolicySet(), downloadEnabled: false, originallyPublishedAt: Date(), scheduleUpdate: VideoScheduledUpdate(privacy: nil, updateAt: Date()), thumbnailfile: URL(string: "https://example.com")!, previewfile: URL(string: "https://example.com")!, videoPasswords: ["videoPasswords_example"], filename: "filename_example") // VideoUploadRequestResumable |  (optional)

// Initialize the resumable upload of a video
VideoUploadAPI.uploadResumableInit(xUploadContentLength: xUploadContentLength, xUploadContentType: xUploadContentType, videoUploadRequestResumable: videoUploadRequestResumable) { (response, error) in
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
 **xUploadContentLength** | **Double** | Number of bytes that will be uploaded in subsequent requests. Set this value to the size of the file you are uploading. | 
 **xUploadContentType** | **String** | MIME type of the file that you are uploading. Depending on your instance settings, acceptable values might vary. | 
 **videoUploadRequestResumable** | [**VideoUploadRequestResumable**](VideoUploadRequestResumable.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

[OAuth2](../README.md#OAuth2)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

