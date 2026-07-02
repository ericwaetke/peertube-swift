//
//  NotificationBell.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 02.07.26.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct NotificationBellFeature {
    @ObservableState
    struct State: Equatable {
        var channelId: Optional<String>
        var isOn: Bool = false
        var hadInteraction = false
        @Presents var alert: AlertState<AlertAction>?
    }
    
    enum Action {
        case setChannelId(String)
        case tapped
        case toggleDidSucceed(Bool)
        case setToggleState(Bool)
        case showPermissionDeniedAlert
        case dismissAlert
        case alert(PresentationAction<AlertAction>)
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case notificationStateChanged(channelId: String, isOn: Bool)
        }
    }
    
    enum AlertAction {
        case openSettings
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .setChannelId(let newChannelId):
                state.channelId = newChannelId
                return .none
            case .tapped:
                state.hadInteraction = true
                let newState = !state.isOn
                return .run { send in
                    let status = await checkNotificationPermission()
                    switch status {
                    case .notDetermined:
                        let granted = await requestNotificationPermission()
                        if (granted) {
                            await send(.toggleDidSucceed(newState))
                        }
                    case .allowed:
                        await send(.toggleDidSucceed(newState))
                    case .denied:
                        await send(.showPermissionDeniedAlert)
                    }
                }
            case let .toggleDidSucceed(isOn):
                guard let channelId = state.channelId else {
                    print("this did not go as planned. No channel ID")
                    return .none
                }
                return .run { send in
                    await send(.setToggleState(isOn))
                    try? await saveNotificationPreference(channelId: channelId, notify: isOn)
                    await send(.delegate(.notificationStateChanged(channelId: channelId, isOn: isOn)))
                }
                
            case let .setToggleState(isOn):
                state.isOn = isOn
                return .none
                
            case .showPermissionDeniedAlert:
                state.alert = AlertState {
                    TextState("Notification Disabled")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                    ButtonState(action: .openSettings) {
                        TextState("Open Settings")
                    }
                } message: {
                    TextState("Enable notifications in Settings to receive alerts when this channel posts new videos.")
                }
                return .none
                
            case .dismissAlert:
                state.alert = nil
                return .none
                
            case .alert(.presented(.openSettings)):
                return .run { _ in
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        @Dependency(\.openURL) var openURL
                        await openURL(url)
                    }
                }
                
            case .alert(.dismiss):
                state.alert = nil
                return .none
                
            case .delegate:
                return .none
            }
            
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

struct NotificationBell: View {
    @Bindable var store: StoreOf<NotificationBellFeature>
    
    var body: some View {
        Button {
            store.send(.tapped)
        } label: {
            Image(systemName: store.isOn ? "bell.fill" : "bell")
                .symbolEffect(.wiggle, options: .nonRepeating, isActive: store.isOn && store.hadInteraction)
                .sensoryFeedback(.success, trigger: store.isOn) { old, new in
                    return old == false && new == true && store.hadInteraction
                }
                .sensoryFeedback(.decrease, trigger: store.isOn) { old, new in
                    return old == true && new == false && store.hadInteraction
                }
        }
        .buttonStyle(.bordered)
        .foregroundStyle(.primary)
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}

#Preview {
    NotificationBell(
        store: Store(
            initialState: NotificationBellFeature.State(channelId: nil)
        ) {
            NotificationBellFeature()
        }
    )
}
