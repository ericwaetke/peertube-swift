//
//  PlaylistLoaderDelegate.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 22.12.25.
//

import AVFoundation
import Foundation
import TubeSDK

/// Delegate for intercepting HLS playlist loading to combine video-only and audio-only streams
public class PlaylistLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    public var url: URL
    public var customSchemeURL: URL {
        guard var components = URLComponents(url: self.url, resolvingAgainstBaseURL: false),
            ["http", "https"].contains(components.scheme)
        else {
            return url
        }
        components.scheme = "peertube-hls"
        return components.url!
    }

    public var videoFile: TubeSDK.VideoFile?
    public var audioFile: TubeSDK.VideoFile?

    public init(
        _ url: URL, videoFile: TubeSDK.VideoFile? = nil, audioFile: TubeSDK.VideoFile? = nil
    ) {
        self.url = url
        self.videoFile = videoFile
        self.audioFile = audioFile
    }

    public func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
    ) -> Bool {
        print("🎵 PlaylistLoaderDelegate: resourceLoader called")

        guard let requestURL = loadingRequest.request.url else {
            print("❌ PlaylistLoaderDelegate: No request URL")
            return false
        }

        print("🎵   Request URL: \(requestURL)")

        guard let scheme = requestURL.scheme, scheme == "peertube-hls" else {
            print("❌ PlaylistLoaderDelegate: Wrong scheme: \(requestURL.scheme ?? "nil")")
            return false
        }

        print("🎵   Handling custom scheme request")

        let originalURL = self.url
        let videoFile = self.videoFile
        let audioFile = self.audioFile

        print("🎵   Original URL: \(originalURL)")
        print(
            "🎵   Video file: \(videoFile?.resolution?.label ?? "nil") (A:\(videoFile?.hasAudio ?? false) V:\(videoFile?.hasVideo ?? false))"
        )
        print(
            "🎵   Audio file: \(audioFile?.resolution?.label ?? "nil") (A:\(audioFile?.hasAudio ?? false) V:\(audioFile?.hasVideo ?? false))"
        )

        Task {
            do {
                if let contentInformationRequest = loadingRequest.contentInformationRequest {
                    print("🎵   Processing content information request")
                    let (data, response) = try await URLSession.shared.data(from: originalURL)
                    print("🎵   Fetched playlist data: \(data.count) bytes")

                    contentInformationRequest.contentType = response.mimeType
                    contentInformationRequest.contentLength = Int64(data.count)
                    contentInformationRequest.isByteRangeAccessSupported = false
                    contentInformationRequest.isEntireLengthAvailableOnDemand = true
                    contentInformationRequest.renewalDate = nil
                }

                if let dataRequest = loadingRequest.dataRequest {
                    print("🎵   Processing data request")
                    let (data, _) = try await URLSession.shared.data(from: originalURL)

                    if let playlistString = String(data: data, encoding: .utf8) {
                        print("🎵   Original playlist preview:")
                        let lines = playlistString.components(separatedBy: .newlines)
                        for (i, line) in lines.prefix(10).enumerated() {
                            print("🎵     \(i): \(line)")
                        }
                    }

                    let modifier = PlaylistModifier(baseURL: originalURL)
                    let modifiedData = try await modifier.combineVideoAndAudio(
                        playlistData: data,
                        videoFile: videoFile,
                        audioFile: audioFile
                    )

                    if let modifiedString = String(data: modifiedData, encoding: .utf8) {
                        print("🎵   Modified playlist preview:")
                        let lines = modifiedString.components(separatedBy: .newlines)
                        for (i, line) in lines.prefix(15).enumerated() {
                            print("🎵     \(i): \(line)")
                        }
                    }

                    dataRequest.respond(with: modifiedData)
                    print("🎵   Data request completed")
                }

                loadingRequest.finishLoading()
                print("🎵   Request finished successfully")
            } catch {
                print(
                    "❌ PlaylistLoaderDelegate: Error processing request: \(error.localizedDescription)"
                )
                loadingRequest.finishLoading(with: error)
            }
        }

        return true
    }
}

/// Helper class for modifying HLS playlists
class PlaylistModifier {
    let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    func combineVideoAndAudio(
        playlistData: Data,
        videoFile: TubeSDK.VideoFile?,
        audioFile: TubeSDK.VideoFile?
    ) async throws -> Data {
        print("🎵 PlaylistModifier: Starting combineVideoAndAudio")

        guard let playlistString = String(data: playlistData, encoding: .utf8) else {
            print("❌ PlaylistModifier: Invalid playlist data")
            throw PlaylistModifierError.invalidData
        }

        print("🎵   Original playlist length: \(playlistString.count) characters")

        let lines = playlistString.components(separatedBy: .newlines)
        print("🎵   Playlist has \(lines.count) lines")

        // Check if this is a master playlist or a media playlist
        let isMasterPlaylist = lines.contains { $0.starts(with: "#EXT-X-STREAM-INF:") }
        let isMediaPlaylist = lines.contains { $0.starts(with: "#EXTINF:") }

        print(
            "🎵   Playlist type: \(isMasterPlaylist ? "Master" : isMediaPlaylist ? "Media/Segmented" : "Unknown")"
        )

        // If we have both video and audio files, create appropriate combined playlist
        if let videoFile = videoFile,
            let audioFile = audioFile,
            let videoPlaylistURL = videoFile.playlistUrl,
            let audioPlaylistURL = audioFile.playlistUrl
        {
            print("🎵   Combining video (\(videoPlaylistURL)) with audio (\(audioPlaylistURL))")

            if isMasterPlaylist {
                // Handle master playlist
                return try await handleMasterPlaylist(
                    lines: lines,
                    videoFile: videoFile,
                    audioFile: audioFile
                )
            } else if isMediaPlaylist {
                // For media playlists, we need to create a master playlist wrapper
                return try await createMasterPlaylistWrapper(
                    videoFile: videoFile,
                    audioFile: audioFile
                )
            } else {
                print("⚠️   Unknown playlist type, returning original")
                return playlistData
            }
        } else {
            print("🎵   No audio file to combine or missing URLs")
            return playlistData
        }
    }

    private func handleMasterPlaylist(
        lines: [String],
        videoFile: TubeSDK.VideoFile,
        audioFile: TubeSDK.VideoFile
    ) async throws -> Data {
        print("🎵   Handling master playlist")

        var modifiedLines = lines

        // Add audio media group if not present
        if let audioPlaylistURL = audioFile.playlistUrl {
            try await addAudioGroup(&modifiedLines, audioPlaylistURL: audioPlaylistURL)
        }

        // Update video streams to reference audio group
        updateVideoStreamsWithAudio(&modifiedLines)

        // Make all URLs absolute
        makeURLsAbsolute(&modifiedLines)

        let modifiedPlaylist = modifiedLines.joined(separator: "\n")
        return modifiedPlaylist.data(using: .utf8) ?? Data()
    }

    private func createMasterPlaylistWrapper(
        videoFile: TubeSDK.VideoFile,
        audioFile: TubeSDK.VideoFile
    ) async throws -> Data {
        print("🎵   Creating master playlist wrapper for media playlist")

        guard let videoURL = videoFile.playlistUrl,
            let audioURL = audioFile.playlistUrl
        else {
            throw PlaylistModifierError.noVideoFile
        }

        // Get video resolution info
        let resolution = videoFile.resolution
        let width = Int(videoFile.width ?? 1920)
        let height = videoFile.height != nil ? Int(videoFile.height!) : resolution?.id ?? 1080
        let bandwidth = estimateBandwidth(for: videoFile)

        // Create a master playlist that references both video and audio
        let masterPlaylist = """
            #EXTM3U
            #EXT-X-VERSION:7
            #EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio",NAME="Default",DEFAULT=YES,AUTOSELECT=YES,URI="\(audioURL)"
            #EXT-X-STREAM-INF:BANDWIDTH=\(bandwidth),RESOLUTION=\(width)x\(height),CODECS="avc1.640028,mp4a.40.2",AUDIO="audio"
            \(videoURL)
            """

        print("🎵   Created master playlist:")
        for (i, line) in masterPlaylist.components(separatedBy: .newlines).enumerated() {
            print("🎵     \(i): \(line)")
        }

        return masterPlaylist.data(using: .utf8) ?? Data()
    }

    private func estimateBandwidth(for videoFile: TubeSDK.VideoFile) -> Int {
        // Estimate bandwidth based on resolution
        if let resolutionId = videoFile.resolution?.id {
            switch resolutionId {
            case 2160: return 25_000_000  // 4K
            case 1440: return 16_000_000  // 1440p
            case 1080: return 8_000_000  // 1080p
            case 720: return 5_000_000  // 720p
            case 480: return 2_500_000  // 480p
            case 360: return 1_000_000  // 360p
            case 240: return 500000  // 240p
            default: return 3_000_000  // Default
            }
        }
        return 3_000_000  // Default bandwidth
    }

    private func addAudioGroup(_ lines: inout [String], audioPlaylistURL: String) async throws {
        print("🎵   Adding audio group with URL: \(audioPlaylistURL)")

        // Check if audio group already exists
        let hasAudioGroup = lines.contains { line in
            line.starts(with: "#EXT-X-MEDIA:TYPE=AUDIO")
        }

        print("🎵     Audio group already exists: \(hasAudioGroup)")

        if !hasAudioGroup {
            // Find the insertion point (after #EXTM3U but before stream definitions)
            var insertIndex = 1  // After #EXTM3U
            for (index, line) in lines.enumerated() {
                if line.starts(with: "#EXT-X-STREAM-INF:") {
                    insertIndex = index
                    break
                }
            }

            print("🎵     Inserting audio group at line \(insertIndex)")

            // Add audio group definition
            let audioGroupLine =
                "#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID=\"audio\",NAME=\"Default\",DEFAULT=YES,AUTOSELECT=YES,URI=\"\(audioPlaylistURL)\""
            lines.insert(audioGroupLine, at: insertIndex)
            print("🎵     Added audio group: \(audioGroupLine)")
        }
    }

    private func updateVideoStreamsWithAudio(_ lines: inout [String]) {
        print("🎵   Updating video streams to reference audio group")

        var updatedCount = 0
        for (index, line) in lines.enumerated() {
            if line.starts(with: "#EXT-X-STREAM-INF:") {
                // Add audio group reference if not present
                if !line.contains("AUDIO=") {
                    let originalLine = lines[index]
                    lines[index] = line + ",AUDIO=\"audio\""
                    print("🎵     Updated stream: \(originalLine) -> \(lines[index])")
                    updatedCount += 1
                } else {
                    print("🎵     Stream already has audio reference: \(line)")
                }
            }
        }
        print("🎵   Updated \(updatedCount) video streams")
    }

    private func makeURLsAbsolute(_ lines: inout [String]) {
        print("🎵   Making URLs absolute")
        var urlCount = 0
        var processedUrls = Set<String>()

        for (index, line) in lines.enumerated() {
            // Handle URI references in media tags
            if let uriRange = line.range(of: "URI=\"([^\"]+)\"", options: .regularExpression) {
                let uriMatch = String(line[uriRange])
                let cleanURI = uriMatch.replacingOccurrences(of: "URI=\"", with: "")
                    .replacingOccurrences(of: "\"", with: "")

                if !processedUrls.contains(cleanURI) {
                    let absoluteURL = makeAbsoluteURL(from: cleanURI)
                    lines[index] = line.replacingOccurrences(
                        of: cleanURI, with: absoluteURL.absoluteString)
                    print("🎵     Made URI absolute: \(cleanURI) -> \(absoluteURL.absoluteString)")
                    urlCount += 1
                    processedUrls.insert(cleanURI)
                }
            }
            // Handle playlist URLs (lines that don't start with #)
            else if !line.starts(with: "#") && !line.isEmpty
                && !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            {
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if !processedUrls.contains(trimmedLine) {
                    let absoluteURL = makeAbsoluteURL(from: trimmedLine)
                    if trimmedLine != absoluteURL.absoluteString {
                        lines[index] = absoluteURL.absoluteString
                        print(
                            "🎵     Made URL absolute: \(trimmedLine) -> \(absoluteURL.absoluteString)"
                        )
                        urlCount += 1
                    }
                    processedUrls.insert(trimmedLine)
                }
            }
        }
        print("🎵   Made \(urlCount) URLs absolute")
    }

    private func makeAbsoluteURL(from string: String) -> URL {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)

        if let url = URL(string: trimmedString), url.host != nil {
            return url
        } else {
            return URL(string: trimmedString, relativeTo: baseURL) ?? baseURL
        }
    }
}

enum PlaylistModifierError: Error {
    case invalidData
    case noVideoFile
    case noAudioFile

    var localizedDescription: String {
        switch self {
        case .invalidData:
            return "Invalid playlist data"
        case .noVideoFile:
            return "No video file provided"
        case .noAudioFile:
            return "No audio file provided"
        }
    }
}
