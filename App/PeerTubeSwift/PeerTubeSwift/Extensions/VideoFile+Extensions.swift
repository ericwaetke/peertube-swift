//
//  VideoFile+Extensions.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 22.12.25.
//

import Foundation
import TubeSDK

extension TubeSDK.VideoFile {
    /// Returns true if this VideoFile has only video (no audio)
    var isVideoOnly: Bool {
        return hasVideo == true && hasAudio == false
    }

    /// Returns true if this VideoFile has only audio (no video)
    var isAudioOnly: Bool {
        return hasAudio == true && hasVideo == false
    }

    /// Returns true if this VideoFile has both audio and video
    var hasCompleteStreams: Bool {
        return hasAudio == true && hasVideo == true
    }

    /// Returns the best URL to use for playback (playlist preferred over direct file)
    var bestPlaybackURL: URL? {
        if let playlistUrl = playlistUrl, let url = URL(string: playlistUrl) {
            return url
        }
        if let fileUrl = fileUrl, let url = URL(string: fileUrl) {
            return url
        }
        return nil
    }
}

/// Helper for managing VideoFile collections and finding matching streams
struct VideoFileHelper {

    /// Finds the best video and audio combination for a given video file
    /// - Parameters:
    ///   - videoFiles: Array of available video files
    ///   - targetVideoFile: The selected video file to find audio for
    /// - Returns: Tuple of (primaryFile, audioFile) where primaryFile is the target and audioFile is matching audio
    static func findBestVideoAudioCombination(
        from videoFiles: [TubeSDK.VideoFile],
        targetVideoFile: TubeSDK.VideoFile?
    ) -> (primaryFile: TubeSDK.VideoFile?, audioFile: TubeSDK.VideoFile?) {

        guard let targetFile = targetVideoFile else {
            return (nil, nil)
        }

        // If the target file has complete streams, we don't need a separate audio file
        if targetFile.hasCompleteStreams {
            return (targetFile, nil)
        }

        // Find matching audio file
        let audioFile = findMatchingAudioFile(
            for: targetFile,
            from: videoFiles
        )

        return (targetFile, audioFile)
    }

    /// Finds an audio file that best matches the given video file
    private static func findMatchingAudioFile(
        for videoFile: TubeSDK.VideoFile,
        from videoFiles: [TubeSDK.VideoFile]
    ) -> TubeSDK.VideoFile? {

        // Filter files that have audio streams
        let audioFiles = videoFiles.filter { $0.hasAudio == true }

        guard !audioFiles.isEmpty else {
            return nil
        }

        // Prefer audio-only files over complete files
        let audioOnlyFiles = audioFiles.filter { $0.isAudioOnly }
        let candidateFiles = audioOnlyFiles.isEmpty ? audioFiles : audioOnlyFiles

        // Try to find audio with same resolution preference
        if let videoResolution = videoFile.resolution {
            let matchingResolution = candidateFiles.first {
                $0.resolution?.id == videoResolution.id
            }
            if let match = matchingResolution {
                return match
            }
        }

        // Fall back to first available audio file (preserving original order)
        return candidateFiles.first
    }

    /// Returns files with video streams, preserving original order
    static func videoFiles(from files: [TubeSDK.VideoFile]) -> [TubeSDK.VideoFile] {
        return files.filter { $0.hasVideo == true }
    }

    /// Returns files with audio streams, preserving original order
    static func audioFiles(from files: [TubeSDK.VideoFile]) -> [TubeSDK.VideoFile] {
        return files.filter { $0.hasAudio == true }
    }

    /// Returns files with complete streams (both audio and video), preserving original order
    static func completeFiles(from files: [TubeSDK.VideoFile]) -> [TubeSDK.VideoFile] {
        return files.filter { $0.hasCompleteStreams }
    }

    /// Returns files with video-only streams, preserving original order
    static func videoOnlyFiles(from files: [TubeSDK.VideoFile]) -> [TubeSDK.VideoFile] {
        return files.filter { $0.isVideoOnly }
    }

    /// Returns files with audio-only streams, preserving original order
    static func audioOnlyFiles(from files: [TubeSDK.VideoFile]) -> [TubeSDK.VideoFile] {
        return files.filter { $0.isAudioOnly }
    }
}
