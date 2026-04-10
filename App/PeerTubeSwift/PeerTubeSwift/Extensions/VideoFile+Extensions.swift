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
enum VideoFileHelper {
    /// Finds the best video and audio combination for a given video file
    /// - Parameters:
    ///   - videoFiles: Array of available video files
    ///   - targetVideoFile: The selected video file to find audio for
    /// - Returns: Tuple of (primaryFile, audioFile) where primaryFile is the target and audioFile is matching audio
    static func findBestVideoAudioCombination(
        from videoFiles: [TubeSDK.VideoFile],
        targetVideoFile: TubeSDK.VideoFile?
    ) -> (primaryFile: TubeSDK.VideoFile?, audioFile: TubeSDK.VideoFile?) {
        print("🎵 VideoFileHelper: findBestVideoAudioCombination")
        print("🎵   Total files: \(videoFiles.count)")

        guard let targetFile = targetVideoFile else {
            print("❌   No target file provided")
            return (nil, nil)
        }

        let resolution = targetFile.resolution?.label ?? "Unknown"
        let hasAudio = targetFile.hasAudio ?? false
        let hasVideo = targetFile.hasVideo ?? false
        print("🎵   Target file: \(resolution) (A:\(hasAudio) V:\(hasVideo))")

        // If the target file has complete streams, we don't need a separate audio file
        if targetFile.hasCompleteStreams {
            print("🎵   Target file has complete streams, no separate audio needed")
            return (targetFile, nil)
        }

        // Find matching audio file
        let audioFile = findMatchingAudioFile(
            for: targetFile,
            from: videoFiles
        )

        if let audioFile = audioFile {
            let audioRes = audioFile.resolution?.label ?? "Unknown"
            print("🎵   Found matching audio file: \(audioRes)")
        } else {
            print("⚠️   No matching audio file found")
        }

        return (targetFile, audioFile)
    }

    /// Finds an audio file that best matches the given video file
    private static func findMatchingAudioFile(
        for videoFile: TubeSDK.VideoFile,
        from videoFiles: [TubeSDK.VideoFile]
    ) -> TubeSDK.VideoFile? {
        print("🎵   findMatchingAudioFile:")

        // Filter files that have audio streams
        let audioFiles = videoFiles.filter { $0.hasAudio == true }
        print("🎵     Found \(audioFiles.count) files with audio")

        guard !audioFiles.isEmpty else {
            print("❌     No audio files available")
            return nil
        }

        // Debug log all audio files
        for (i, file) in audioFiles.enumerated() {
            let res = file.resolution?.label ?? "Unknown"
            let audioOnly = file.isAudioOnly ? "audio-only" : "complete"
            print("🎵     Audio file \(i): \(res) (\(audioOnly))")
        }

        // Prefer audio-only files over complete files
        let audioOnlyFiles = audioFiles.filter { $0.isAudioOnly }
        let candidateFiles = audioOnlyFiles.isEmpty ? audioFiles : audioOnlyFiles

        print(
            "🎵     Using \(candidateFiles.count) candidate files (prefer audio-only: \(!audioOnlyFiles.isEmpty))"
        )

        // Try to find audio with same resolution preference
        if let videoResolution = videoFile.resolution {
            print("🎵     Looking for matching resolution: \(videoResolution.label ?? "Unknown")")
            let matchingResolution = candidateFiles.first {
                $0.resolution?.id == videoResolution.id
            }
            if let match = matchingResolution {
                print("🎵     Found exact resolution match: \(match.resolution?.label ?? "Unknown")")
                return match
            } else {
                print("🎵     No exact resolution match found")
            }
        } else {
            print("🎵     Video file has no resolution info")
        }

        // Fall back to first available audio file (preserving original order)
        let fallback = candidateFiles.first
        if let fallback = fallback {
            print("🎵     Using fallback audio file: \(fallback.resolution?.label ?? "Unknown")")
        } else {
            print("❌     No fallback audio file available")
        }
        return fallback
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
