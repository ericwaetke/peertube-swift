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
        guard let requestURL = loadingRequest.request.url,
            let scheme = requestURL.scheme,
            scheme == "peertube-hls"
        else {
            return false
        }

        let originalURL = self.url
        let videoFile = self.videoFile
        let audioFile = self.audioFile

        Task {
            do {
                if let contentInformationRequest = loadingRequest.contentInformationRequest {
                    let (data, response) = try await URLSession.shared.data(from: originalURL)

                    contentInformationRequest.contentType = response.mimeType
                    contentInformationRequest.contentLength = Int64(data.count)
                    contentInformationRequest.isByteRangeAccessSupported = false
                    contentInformationRequest.isEntireLengthAvailableOnDemand = true
                    contentInformationRequest.renewalDate = nil
                }

                if let dataRequest = loadingRequest.dataRequest {
                    let (data, _) = try await URLSession.shared.data(from: originalURL)

                    let modifier = PlaylistModifier(baseURL: originalURL)
                    let modifiedData = try await modifier.combineVideoAndAudio(
                        playlistData: data,
                        videoFile: videoFile,
                        audioFile: audioFile
                    )

                    dataRequest.respond(with: modifiedData)
                }

                loadingRequest.finishLoading()
            } catch {
                print(
                    "Error while processing playlist loading request: \(error.localizedDescription)"
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
        guard let playlistString = String(data: playlistData, encoding: .utf8) else {
            throw PlaylistModifierError.invalidData
        }

        var lines = playlistString.components(separatedBy: .newlines)

        // If we have both video and audio files, combine them
        if let videoFile = videoFile,
            let audioFile = audioFile,
            let videoPlaylistURL = videoFile.playlistUrl,
            let audioPlaylistURL = audioFile.playlistUrl
        {

            // Add audio media group if not present
            try await addAudioGroup(&lines, audioPlaylistURL: audioPlaylistURL)

            // Update video streams to reference audio group
            updateVideoStreamsWithAudio(&lines)
        }

        // Make all URLs absolute
        makeURLsAbsolute(&lines)

        let modifiedPlaylist = lines.joined(separator: "\n")
        return modifiedPlaylist.data(using: .utf8) ?? playlistData
    }

    private func addAudioGroup(_ lines: inout [String], audioPlaylistURL: String) async throws {
        // Check if audio group already exists
        let hasAudioGroup = lines.contains { line in
            line.starts(with: "#EXT-X-MEDIA:TYPE=AUDIO")
        }

        if !hasAudioGroup {
            // Find the insertion point (after #EXTM3U but before stream definitions)
            var insertIndex = 1  // After #EXTM3U
            for (index, line) in lines.enumerated() {
                if line.starts(with: "#EXT-X-STREAM-INF:") {
                    insertIndex = index
                    break
                }
            }

            // Add audio group definition
            let audioGroupLine =
                "#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID=\"audio\",NAME=\"Default\",DEFAULT=YES,AUTOSELECT=YES,URI=\"\(audioPlaylistURL)\""
            lines.insert(audioGroupLine, at: insertIndex)
        }
    }

    private func updateVideoStreamsWithAudio(_ lines: inout [String]) {
        for (index, line) in lines.enumerated() {
            if line.starts(with: "#EXT-X-STREAM-INF:") {
                // Add audio group reference if not present
                if !line.contains("AUDIO=") {
                    lines[index] = line + ",AUDIO=\"audio\""
                }
            }
        }
    }

    private func makeURLsAbsolute(_ lines: inout [String]) {
        for (index, line) in lines.enumerated() {
            // Handle URI references in media tags
            if let uriMatch = line.range(of: "URI=\"([^\"]+)\"", options: .regularExpression) {
                let uriValue = String(line[uriMatch])
                let cleanURI = uriValue.replacingOccurrences(of: "URI=\"", with: "")
                    .replacingOccurrences(of: "\"", with: "")
                let absoluteURL = makeAbsoluteURL(from: cleanURI)
                lines[index] = line.replacingOccurrences(
                    of: cleanURI, with: absoluteURL.absoluteString)
            }
            // Handle playlist URLs (lines that don't start with #)
            else if !line.starts(with: "#") && !line.isEmpty {
                let absoluteURL = makeAbsoluteURL(from: line)
                lines[index] = absoluteURL.absoluteString
            }
        }
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
