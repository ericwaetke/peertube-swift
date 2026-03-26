//
//  VideoPlayer.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 22.12.25.
//

import AVKit
import ObjectiveC
import SwiftUI
import TubeSDK

struct SeekRequest: Equatable {
    let time: Int
    let id = UUID()
}

struct VideoPlayerView: UIViewControllerRepresentable {
    var onTimeUpdate: ((Int) -> Void)? = nil
    let videoFiles: [TubeSDK.VideoFile]
    let selectedVideoFile: TubeSDK.VideoFile?
    var startTime: Int? = nil
    var seekRequest: SeekRequest? = nil
    var videoTitle: String? = nil
    var channelName: String? = nil
    var thumbnailPath: String? = nil

    // Legacy initializer for single URL (backwards compatibility)
    init(videoURL: URL) {
        // Create a temporary VideoFile from URL for backwards compatibility
        let tempVideoFile = TubeSDK.VideoFile(
            playlistUrl: videoURL.absoluteString,
            hasAudio: true,
            hasVideo: true
        )
        self.videoFiles = [tempVideoFile]
        self.selectedVideoFile = tempVideoFile
        self.startTime = nil
        self.seekRequest = nil
        self.videoTitle = nil
        self.channelName = nil
        self.thumbnailPath = nil
    }

    // New initializer for VideoFile arrays with quality selection
    init(
        onTimeUpdate: ((Int) -> Void)? = nil, 
        videoFiles: [TubeSDK.VideoFile], 
        selectedVideoFile: TubeSDK.VideoFile?, 
        startTime: Int? = nil,
        seekRequest: SeekRequest? = nil,
        videoTitle: String? = nil,
        channelName: String? = nil,
        thumbnailPath: String? = nil
    ) {
        self.onTimeUpdate = onTimeUpdate
        self.videoFiles = videoFiles
        self.selectedVideoFile = selectedVideoFile
        self.startTime = startTime
        self.seekRequest = seekRequest
        self.videoTitle = videoTitle
        self.channelName = channelName
        self.thumbnailPath = thumbnailPath
    }

    
    class Coordinator: NSObject {
        var parent: VideoPlayerView
        var timeObserver: Any?
        var player: AVPlayer?
        var statusObservation: NSKeyValueObservation?
        var initialSeekPerformed = false
        var lastSeekRequestId: UUID?

        init(_ parent: VideoPlayerView) {
            self.parent = parent
        }

        func addObserver(to player: AVPlayer) {
            removeObserver()
            self.player = player
            
            print("🎬 addObserver: parent.startTime = \(String(describing: parent.startTime)), initialSeekPerformed = \(initialSeekPerformed)")
            
            if !initialSeekPerformed, let startTime = parent.startTime, startTime > 0 {
                print("🎬 addObserver: Calling performSeekWhenReady with startTime \(startTime)")
                performSeekWhenReady(time: CMTime(seconds: Double(startTime), preferredTimescale: 600))
                initialSeekPerformed = true
            }
            
            let interval = CMTime(seconds: 5.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
                self?.parent.onTimeUpdate?(Int(time.seconds))
            }
        }
        
        func performSeekWhenReady(time: CMTime) {
            guard let player = self.player, let item = player.currentItem else { 
                print("🎬 performSeekWhenReady: No player or currentItem")
                return 
            }
            
            print("🎬 performSeekWhenReady: Requested seek to \(time.seconds)s, status: \(item.status.rawValue)")
            
            let seekBlock = {
                print("🎬 performSeekWhenReady: Executing seek to \(time.seconds)s")
                player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { finished in
                    print("🎬 performSeekWhenReady: Seek finished=\(finished)")
                    player.play() // ensure it keeps playing if it was auto-played
                }
            }
            
            if item.status == .readyToPlay {
                print("🎬 performSeekWhenReady: Already ready, seeking immediately")
                seekBlock()
            } else {
                print("🎬 performSeekWhenReady: Waiting for readyToPlay...")
                statusObservation?.invalidate()
                statusObservation = item.observe(\.status) { [weak self] observedItem, _ in
                    print("🎬 performSeekWhenReady: Status changed to \(observedItem.status.rawValue)")
                    if observedItem.status == .readyToPlay {
                        seekBlock()
                        self?.statusObservation?.invalidate()
                        self?.statusObservation = nil
                    }
                }
            }
        }

        func removeObserver() {
            if let observer = timeObserver, let player = player {
                player.removeTimeObserver(observer)
                timeObserver = nil
            }
            statusObservation?.invalidate()
            statusObservation = nil
        }

        deinit {
            removeObserver()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .moviePlayback)
        try? session.setActive(true)

        let playerViewController = AVPlayerViewController()

        // Create player with combined streams if needed
        if let player = createPlayerWithCombinedStreams() {
            playerViewController.player = player
            context.coordinator.addObserver(to: player)
        }

        #if targetEnvironment(preview)
        #else
            // Auto-play can be enabled here if desired
            playerViewController.player?.play()
        #endif

        return playerViewController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        context.coordinator.parent = self
        print("🎬 VideoPlayer: updateUIViewController called")

        // Handle seek requests explicitly first
        if let req = self.seekRequest, context.coordinator.lastSeekRequestId != req.id {
            print("🎬 VideoPlayer: Handling new seek request for \(req.time)s")
            context.coordinator.lastSeekRequestId = req.id
            context.coordinator.performSeekWhenReady(time: CMTime(seconds: Double(req.time), preferredTimescale: 600))
        }

        // Check if we need to update the player
        guard let selectedFile = selectedVideoFile,
            let selectedURL = selectedFile.bestPlaybackURL
        else {
            print("❌ VideoPlayer: No selected file or URL")
            return
        }

        print("🎬 VideoPlayer: Selected file: \(selectedFile.resolution?.label ?? "Unknown")")
        print(
            "🎬   hasAudio: \(selectedFile.hasAudio ?? false), hasVideo: \(selectedFile.hasVideo ?? false)"
        )
        print("🎬   URL: \(selectedURL)")

        // Compare current URL with selected URL
        if let currentItem = uiViewController.player?.currentItem,
            let currentURL = (currentItem.asset as? AVURLAsset)?.url
        {
            print("🎬 VideoPlayer: Current URL: \(currentURL)")

            // For custom scheme URLs, compare the original URL stored in the delegate
            let currentOriginalURL = getOriginalURL(from: currentURL)

            if currentOriginalURL?.absoluteString == selectedURL.absoluteString {
                print("🎬 VideoPlayer: Same URL, no update needed")
                // Still try to seek if we haven't performed initial seek yet!
                if !context.coordinator.initialSeekPerformed, let startTime = self.startTime, startTime > 0 {
                    print("🎬 updateUIViewController: Trying initial seek from update")
                    context.coordinator.performSeekWhenReady(time: CMTime(seconds: Double(startTime), preferredTimescale: 600))
                    context.coordinator.initialSeekPerformed = true
                }
                return
            }
        }

        print("🎬 VideoPlayer: URL changed, updating player...")

        // Store current playback state
        let currentTime = uiViewController.player?.currentTime()
        let wasPlaying = uiViewController.player?.rate != 0

        print("🎬   Current time: \(currentTime?.seconds ?? 0)s, was playing: \(wasPlaying)")

        // CRITICAL: Stop and clean up current player to prevent multiple audio streams
        if let currentPlayer = uiViewController.player {
            print("🎬   Stopping current player")
            currentPlayer.pause()
            currentPlayer.replaceCurrentItem(with: nil)

            // Clean up any resource loader delegates
            if let currentItem = currentPlayer.currentItem,
                let currentAsset = currentItem.asset as? AVURLAsset
            {
                currentAsset.resourceLoader.setDelegate(nil, queue: nil)
                print("🎬   Cleaned up resource loader delegate")
            }
        }

        // Create new player
        if let newPlayer = createPlayerWithCombinedStreams() {
            print("🎬 VideoPlayer: Created new player successfully")
            uiViewController.player = newPlayer
            context.coordinator.addObserver(to: newPlayer)

            // Restore playback state
            if let currentTime = currentTime {
                print("🎬   Seeking to: \(currentTime.seconds)s")
                context.coordinator.performSeekWhenReady(time: currentTime)
            }
            if wasPlaying {
                print("🎬   Resuming playback")
                newPlayer.play()
            }
        } else {
            print("❌ VideoPlayer: Failed to create new player")
        }
    }

    private func getOriginalURL(from url: URL) -> URL? {
        // If it's our custom scheme, we need to get the original URL from the delegate
        if url.scheme == "peertube-hls" {
            // Try to find the delegate associated with the current player item
            // This is a simplified approach - in practice you might want to store this differently
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.scheme = url.host == "localhost" ? "http" : "https"
            return components?.url
        }
        return url
    }

    private func applyMetadata(to playerItem: AVPlayerItem) {
        var metadataItems: [AVMetadataItem] = []
        
        if let title = videoTitle {
            let titleItem = AVMutableMetadataItem()
            titleItem.identifier = .commonIdentifierTitle
            titleItem.value = title as NSString
            titleItem.extendedLanguageTag = "und"
            metadataItems.append(titleItem)
        }
        
        if let channel = channelName {
            let artistItem = AVMutableMetadataItem()
            artistItem.identifier = .commonIdentifierArtist
            artistItem.value = channel as NSString
            artistItem.extendedLanguageTag = "und"
            metadataItems.append(artistItem)
        }
        
        // Asynchronously load thumbnail if available
        if let path = thumbnailPath, let url = URL(string: path) {
            // Because thumbnailPath might just be a path, let's try to construct a full URL if it's not absolute.
            // Ideally it should be fully resolved by the caller or we use a base URL, but let's do a best effort.
            var absoluteUrl = url
            if url.host == nil {
                // We don't easily have the instance URL here, so if it's a relative path, this might fail unless it's full.
                // Assuming it's passed as a full URL, or at least a path we can try.
            }
            
            // To properly resolve, we could just use URLSession
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: absoluteUrl)
                    if let image = UIImage(data: data) {
                        let artworkItem = AVMutableMetadataItem()
                        artworkItem.identifier = .commonIdentifierArtwork
                        if let pngData = image.pngData() {
                            artworkItem.value = pngData as NSData
                            artworkItem.dataType = "public.png"
                            artworkItem.extendedLanguageTag = "und"
                            
                            // Update player item on main thread
                            await MainActor.run {
                                var currentMetadata = playerItem.externalMetadata
                                currentMetadata.append(artworkItem)
                                playerItem.externalMetadata = currentMetadata
                            }
                        }
                    }
                } catch {
                    print("🎬 Failed to load thumbnail for metadata: \(error)")
                }
            }
        }
        
        playerItem.externalMetadata = metadataItems
    }

    private func createPlayerWithCombinedStreams() -> AVPlayer? {
        guard let selectedFile = selectedVideoFile else {
            return nil
        }

        // Find the best video/audio combination
        let (primaryFile, audioFile) = VideoFileHelper.findBestVideoAudioCombination(
            from: videoFiles,
            targetVideoFile: selectedFile
        )

        guard let primary = primaryFile,
            let playbackURL = primary.bestPlaybackURL
        else {
            return nil
        }

        // If the primary file has complete streams (both audio and video), use it directly
        if primary.hasCompleteStreams || audioFile == nil {
            let playerItem = AVPlayerItem(url: playbackURL)
            applyMetadata(to: playerItem)
            return AVPlayer(playerItem: playerItem)
        }

        // If we have separate video and audio streams, use our custom loader
        return createPlayerWithResourceLoader(
            videoURL: playbackURL,
            videoFile: primary,
            audioFile: audioFile
        )
    }

    private func createPlayerWithResourceLoader(
        videoURL: URL,
        videoFile: TubeSDK.VideoFile,
        audioFile: TubeSDK.VideoFile?
    ) -> AVPlayer? {

        // Create the resource loader delegate
        let delegate = PlaylistLoaderDelegate(
            videoURL,
            videoFile: videoFile,
            audioFile: audioFile
        )

        // Create asset with custom scheme to trigger our delegate
        let playerAsset = AVURLAsset(url: delegate.customSchemeURL)
        playerAsset.resourceLoader.setDelegate(delegate, queue: .main)

        // Store delegate reference to prevent deallocation
        // We'll use the asset's associated object to keep it alive
        objc_setAssociatedObject(
            playerAsset,
            "PlaylistLoaderDelegate",
            delegate,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        let playerItem = AVPlayerItem(asset: playerAsset)
        applyMetadata(to: playerItem)
        return AVPlayer(playerItem: playerItem)
    }
}

// MARK: - SwiftUI Preview Support

#if DEBUG
    extension VideoPlayerView {
        static var preview: VideoPlayerView {
            let sampleVideoFile = TubeSDK.VideoFile(
                id: 1,
                resolution: TubeSDK.VideoResolutionConstant(id: 1, label: "720p"),
                fileUrl: "https://sample-videos.com/zip/10/mp4/720/mp4/SampleVideo_720x480_1mb.mp4",
                playlistUrl:
                    "https://sample-videos.com/zip/10/mp4/720/mp4/SampleVideo_720x480_1mb.mp4",
                hasAudio: true,
                hasVideo: true
            )

            return VideoPlayerView(
                videoFiles: [sampleVideoFile],
                selectedVideoFile: sampleVideoFile
            )
        }
    }
#endif
