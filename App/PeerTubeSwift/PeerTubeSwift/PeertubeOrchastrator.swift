//
//  PeertubeOrchastrator.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 25.12.25.
//

import Foundation
import TubeSDK
import SwiftUI

struct PeertubeDependency {

}

import Dependencies

extension PeertubeDependency: DependencyKey {
    static let liveValue = Self(

    )
}


extension DependencyValues {
    var peertubeDependency: PeertubeDependency {
        get { self[PeertubeDependency.self] }
        set { self[PeertubeDependency.self] = newValue }
    }
}
