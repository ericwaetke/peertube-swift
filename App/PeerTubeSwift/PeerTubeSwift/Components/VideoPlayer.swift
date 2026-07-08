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

struct VideoPlayerView: View {
    @Binding var isPlayerReady: Bool
    var onTimeUpdate: ((Int) -> Void)?
    let videoFiles: [TubeSDK.VideoFile]
    let selectedVideoFile: TubeSDK.VideoFile?
    var startTime: Int?
    var seekRequest: SeekRequest?
    var videoTitle: String?
    var channelName: String?
    var thumbnailPath: String?
    var pauseTrigger: Int = 0
    var chapters: [TubeSDK.VideoChapter]?
    var videoDuration: Int?
    var onChapterSeek: ((Int) -> Void)?

    @State private var currentPlaybackTime: Int = 0

    // Legacy initializer for single URL (backwards compatibility)
    init(videoURL _: URL) {
        _isPlayerReady = .constant(false)
        videoFiles = []
        selectedVideoFile = nil
        startTime = nil
        seekRequest = nil
        videoTitle = nil
        channelName = nil
        thumbnailPath = nil
        pauseTrigger = 0
        chapters = nil
        videoDuration = nil
        onChapterSeek = nil
    }

    // New initializer for VideoFile arrays with quality selection
    init(
        isPlayerReady: Binding<Bool> = .constant(false),
        onTimeUpdate: ((Int) -> Void)? = nil,
        videoFiles: [TubeSDK.VideoFile],
        selectedVideoFile: TubeSDK.VideoFile?,
        startTime: Int? = nil,
        seekRequest: SeekRequest? = nil,
        videoTitle: String? = nil,
        channelName: String? = nil,
        thumbnailPath: String? = nil,
        pauseTrigger: Int = 0,
        chapters: [TubeSDK.VideoChapter]? = nil,
        videoDuration: Int? = nil,
        onChapterSeek: ((Int) -> Void)? = nil
    ) {
        _isPlayerReady = isPlayerReady
        self.onTimeUpdate = onTimeUpdate
        self.videoFiles = videoFiles
        self.selectedVideoFile = selectedVideoFile
        self.startTime = startTime
        self.seekRequest = seekRequest
        self.videoTitle = videoTitle
        self.channelName = channelName
        self.thumbnailPath = thumbnailPath
        self.pauseTrigger = pauseTrigger
        self.chapters = chapters
        self.videoDuration = videoDuration
        self.onChapterSeek = onChapterSeek
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VideoPlayerViewControllerRepresentable(
                isPlayerReady: $isPlayerReady,
                onTimeUpdate: { time in
                    currentPlaybackTime = time
                    onTimeUpdate?(time)
                },
                videoFiles: videoFiles,
                selectedVideoFile: selectedVideoFile,
                startTime: startTime,
                seekRequest: seekRequest,
                videoTitle: videoTitle,
                channelName: channelName,
                thumbnailPath: thumbnailPath,
                pauseTrigger: pauseTrigger
            )
            .allowsHitTesting(isPlayerReady)

            if !isPlayerReady {
                Color.black
                    .ignoresSafeArea()

                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.2)
            }

            // Chapter bar overlay (always visible when chapters are available)
            if isPlayerReady, let chapters = chapters, let duration = videoDuration, !chapters.isEmpty {
                ChapterBarView(
                    chapters: chapters,
                    duration: duration,
                    currentTime: currentPlaybackTime,
                    onChapterTapped: { timecode in
                        onChapterSeek?(timecode)
                    }
                )
                .padding(.horizontal, 8)
                .padding(.bottom, 4)
            }
        }
    }
}

// MARK: - Chapter Bar View

struct ChapterBarView: View {
    let chapters: [TubeSDK.VideoChapter]
    let duration: Int
    let currentTime: Int
    var onChapterTapped: ((Int) -> Void)?

    private var currentChapterIndex: Int {
        for i in (0 ..< chapters.count).reversed() {
            if currentTime >= chapters[i].timecode {
                return i
            }
        }
        return 0
    }

    var body: some View {
        VStack(spacing: 4) {
            // Chapter title indicator
            if currentChapterIndex < chapters.count {
                Text(chapters[currentChapterIndex].title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
            }

            // Chapter progress bar
            GeometryReader { geometry in
                let totalWidth = geometry.size.width
                let totalDuration = max(Double(duration), 1)

                ZStack(alignment: .leading) {
                    // Background bar
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.25))
                        .frame(height: 6)

                    // Chapter segments
                    HStack(spacing: 0) {
                        ForEach(Array(chapters.enumerated()), id: \.offset) { index, chapter in
                            let chapterStart = Double(chapter.timecode)
                            let chapterEnd: Double = {
                                if index + 1 < chapters.count {
                                    return Double(chapters[index + 1].timecode)
                                }
                                return Double(duration)
                            }()
                            let chapterWidth = max((chapterEnd - chapterStart) / totalDuration * totalWidth, 4)
                            let isActive = index == currentChapterIndex

                            Rectangle()
                                .fill(isActive ? Color.white : Color.white.opacity(0.45))
                                .frame(width: max(chapterWidth - 1, 2))
                                .onTapGesture {
                                    onChapterTapped?(chapter.timecode)
                                }
                        }
                    }

                    // Current position indicator
                    let progress = min(Double(currentTime) / totalDuration, 1.0)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                        .offset(x: max(progress * totalWidth - 4, 0))
                }
                .frame(height: 6)
            }
            .frame(height: 6)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .opacity(0.85)
        }
    }
}

// MARK: - UIViewControllerRepresentable Implementation

private struct VideoPlayerViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var isPlayerReady: Bool
    var onTimeUpdate: ((Int) -> Void)? = nil
    let videoFiles: [TubeSDK.VideoFile]
    let selectedVideoFile: TubeSDK.VideoFile?
    var startTime: Int? = nil
    var seekRequest: SeekRequest? = nil
    var videoTitle: String? = nil
    var channelName: String? = nil
    var thumbnailPath: String? = nil
    var pauseTrigger: Int = 0

    class Coordinator: NSObject {
        var parent: VideoPlayerViewControllerRepresentable
        var timeObserver: Any?
        var player: AVPlayer?
        var statusObservation: NSKeyValueObservation?
        var timeControlObservation: NSKeyValueObservation?
        var initialSeekPerformed = false
        var lastSeekRequestId: UUID?
        var hasNotifiedPlayerReady = false
        var lastPauseTrigger: Int = 0

        init(_ parent: VideoPlayerViewControllerRepresentable) {
            self.parent = parent
        }

        func addObserver(to player: AVPlayer) {
            removeObserver()
            self.player = player

            print("🎬 addObserver: parent.startTime = \(String(describing: parent.startTime)), initialSeekPerformed = \(initialSeekPerformed)")

            // Observe timeControlStatus to detect when player starts playing (first frame ready)
            timeControlObservation = player.observe(\.timeControlStatus) { [weak self] player, _ in
                guard let self = self else { return }
                print("🎬 addObserver: timeControlStatus changed to \(String(describing: player.timeControlStatus))")

                if player.timeControlStatus == .playing, !self.hasNotifiedPlayerReady {
                    print("🎬 addObserver: First frame ready, setting isPlayerReady = true")
                    self.hasNotifiedPlayerReady = true
                    self.parent.isPlayerReady = true

                    // Now that player is ready, perform initial seek if needed
                    if let startTime = self.parent.startTime, startTime > 0, !self.initialSeekPerformed {
                        print("🎬 addObserver: Performing initial seek to \(startTime)s")
                        self.performSeekWhenReady(time: CMTime(seconds: Double(startTime), preferredTimescale: 600))
                        self.initialSeekPerformed = true
                    }
                }
            }

            // If player is already playing, handle it immediately
            if player.timeControlStatus == .playing, !hasNotifiedPlayerReady {
                print("🎬 addObserver: Player already playing on setup")
                hasNotifiedPlayerReady = true
                parent.isPlayerReady = true
            }

            let interval = CMTime(seconds: 5.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
                self?.parent.onTimeUpdate?(Int(time.seconds))
            }
        }

        func performSeekWhenReady(time: CMTime) {
            guard let player = player, let item = player.currentItem else {
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
            timeControlObservation?.invalidate()
            timeControlObservation = nil
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

        // Handle pause trigger
        if pauseTrigger != context.coordinator.lastPauseTrigger {
            context.coordinator.lastPauseTrigger = pauseTrigger
            uiViewController.player?.pause()
            print("🎬 VideoPlayer: Paused due to pauseTrigger change")
        }

        // Handle seek requests explicitly first
        if let req = seekRequest, context.coordinator.lastSeekRequestId != req.id {
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
                if !context.coordinator.initialSeekPerformed, let startTime = startTime, startTime > 0 {
                    print("🎬 updateUIViewController: Trying initial seek from update")
                    context.coordinator.performSeekWhenReady(time: CMTime(seconds: Double(startTime), preferredTimescale: 600))
                    context.coordinator.initialSeekPerformed = true
                }
                return
            }
        }

        print("🎬 VideoPlayer: URL changed, updating player...")

        // Reset player ready state so loading overlay appears during stream change
        context.coordinator.hasNotifiedPlayerReady = false
        isPlayerReady = false

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
