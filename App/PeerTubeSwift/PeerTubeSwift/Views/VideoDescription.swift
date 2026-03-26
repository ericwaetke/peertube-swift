import ComposableArchitecture
import SwiftUI
import TubeSDK

@Reducer
struct VideoDescriptionFeature {
    @ObservableState
    struct State: Equatable {
        var descriptionVisible = true
        var videoDetails: TubeSDK.VideoDetails?
    }

    enum Action {
        case descriptionVisibleChanged(Bool)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .descriptionVisibleChanged:
                state.descriptionVisible.toggle()
                return .none
            }
        }
    }
}

struct VideoDescriptionView: View {
    @Bindable var store: StoreOf<VideoDescriptionFeature>

    var body: some View {
        if let description = store.state.videoDetails?.description {
            Divider()
            DisclosureGroup(
                isExpanded: $store.descriptionVisible.sending(\.descriptionVisibleChanged)
            ) {
                HStack {
                    Text(description)
                    Spacer()
                }
            } label: {
                Text("Description")
                    .foregroundStyle(.primary)
                    .fontWeight(.bold)
            }
        }
    }
}
