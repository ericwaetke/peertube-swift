//
//  BaseSuite.swift
//  PeerTubeSwiftTests
//

import DependenciesTestSupport
import Testing

@testable import PeerTubeSwift

/// Shared traits for feature-level tests. Traits do not inherit global actors,
/// so suites extending this one must still declare `@MainActor` where needed.
@Suite(.serialized, .dependencies { try! $0.bootstrapDatabase() })
struct BaseSuite {}
