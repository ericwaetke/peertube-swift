//
//  PeerTubeSwiftTests.swift
//  PeerTubeSwiftTests
//
//  Created on 2024-12-17.
//

import XCTest

@testable import PeerTubeSwift

final class PeerTubeSwiftTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Library Tests

    func testLibraryVersion() throws {
        XCTAssertEqual(PeerTubeSwift.version, "0.1.0")
    }

    func testSharedContainer() throws {
        XCTAssertNotNil(PeerTubeSwift.container)
        XCTAssertTrue(PeerTubeSwift.container === DependencyContainer.shared)
    }

    // MARK: - Dependency Container Tests

    func testDependencyContainerSingleton() throws {
        let container1 = DependencyContainer.shared
        let container2 = DependencyContainer.shared

        XCTAssertTrue(container1 === container2)
    }

    func testCoreDataStackResolution() throws {
        let container = DependencyContainer.shared
        let coreDataStack = container.resolve(CoreDataStack.self)

        XCTAssertNotNil(coreDataStack)
        XCTAssertTrue(coreDataStack === CoreDataStack.shared)
    }

    func testNetworkingFoundationResolution() throws {
        let container = DependencyContainer.shared
        let networking = container.resolve(NetworkingFoundation.self)

        XCTAssertNotNil(networking)
        XCTAssertTrue(networking === NetworkingFoundation.shared)
    }

    func testServiceRegistration() throws {
        let container = DependencyContainer()

        // Test protocol registration
        protocol TestService {
            var name: String { get }
        }

        struct TestImplementation: TestService {
            let name = "test"
        }

        container.register(TestService.self) {
            TestImplementation()
        }

        let service = container.resolve(TestService.self)
        XCTAssertEqual(service.name, "test")
    }

    func testSingletonRegistration() throws {
        let container = DependencyContainer()

        class TestCounter {
            static var instanceCount = 0

            init() {
                TestCounter.instanceCount += 1
            }
        }

        TestCounter.instanceCount = 0

        container.registerSingleton(TestCounter.self) {
            TestCounter()
        }

        let instance1 = container.resolve(TestCounter.self)
        let instance2 = container.resolve(TestCounter.self)

        XCTAssertTrue(instance1 === instance2)
        XCTAssertEqual(TestCounter.instanceCount, 1)
    }

    // MARK: - Core Data Tests

    func testCoreDataStackInitialization() throws {
        let stack = CoreDataStack.shared

        XCTAssertNotNil(stack.mainContext)
        XCTAssertNotNil(stack.backgroundContext)

        XCTAssertEqual(stack.mainContext.concurrencyType, .mainQueueConcurrencyType)
        XCTAssertEqual(stack.backgroundContext.concurrencyType, .privateQueueConcurrencyType)
    }

    func testCoreDataModelCreation() throws {
        let model = PeerTubeDataModel.createModel()

        XCTAssertEqual(model.entities.count, 4)

        let entityNames = Set(model.entities.compactMap { $0.name })
        let expectedNames: Set<String> = ["Channel", "Video", "Subscription", "Instance"]

        XCTAssertEqual(entityNames, expectedNames)
    }

    func testManagedObjectContextSaveIfNeeded() throws {
        let stack = CoreDataStack.shared
        let context = stack.mainContext

        // Should not throw when there are no changes
        XCTAssertNoThrow(try context.saveIfNeeded())

        // Context should not have changes initially
        XCTAssertFalse(context.hasChanges)
    }

    // MARK: - Networking Tests

    func testNetworkingFoundationInitialization() throws {
        let networking = NetworkingFoundation.shared

        XCTAssertNotNil(networking.urlSession)
        XCTAssertNotNil(networking.jsonDecoder)
        XCTAssertNotNil(networking.jsonEncoder)
    }

    func testJSONDecoderConfiguration() throws {
        let networking = NetworkingFoundation.shared
        let decoder = networking.jsonDecoder

        XCTAssertEqual(decoder.dateDecodingStrategy, .iso8601)
        XCTAssertEqual(decoder.keyDecodingStrategy, .convertFromSnakeCase)
    }

    func testJSONEncoderConfiguration() throws {
        let networking = NetworkingFoundation.shared
        let encoder = networking.jsonEncoder

        XCTAssertEqual(encoder.dateEncodingStrategy, .iso8601)
        XCTAssertEqual(encoder.keyEncodingStrategy, .convertToSnakeCase)
    }

    func testURLExtensions() throws {
        let baseURL = URL(string: "https://example.com/api")!
        let queryItems = [
            URLQueryItem(name: "page", value: 1),
            URLQueryItem(name: "limit", value: 10),
            URLQueryItem(name: "enabled", value: true),
        ]

        let urlWithQuery = baseURL.appending(queryItems: queryItems)

        XCTAssertNotNil(urlWithQuery)
        XCTAssertTrue(urlWithQuery!.absoluteString.contains("page=1"))
        XCTAssertTrue(urlWithQuery!.absoluteString.contains("limit=10"))
        XCTAssertTrue(urlWithQuery!.absoluteString.contains("enabled=true"))
    }

    // MARK: - Property Wrapper Tests

    func testInjectedPropertyWrapper() throws {
        class TestClass {
            @Injected(CoreDataStack.self) var coreDataStack: CoreDataStack
        }

        let testInstance = TestClass()
        XCTAssertNotNil(testInstance.coreDataStack)
        XCTAssertTrue(testInstance.coreDataStack === CoreDataStack.shared)
    }

    // MARK: - Service Locator Tests

    func testServiceLocator() throws {
        let coreDataStack = ServiceLocator.resolve(CoreDataStack.self)
        XCTAssertNotNil(coreDataStack)
        XCTAssertTrue(coreDataStack === CoreDataStack.shared)

        let optionalStack = ServiceLocator.resolveOptional(CoreDataStack.self)
        XCTAssertNotNil(optionalStack)
        XCTAssertTrue(optionalStack === CoreDataStack.shared)
    }

    // MARK: - Performance Tests

    func testDependencyResolutionPerformance() throws {
        let container = DependencyContainer.shared

        measure {
            for _ in 0 ..< 1000 {
                _ = container.resolve(CoreDataStack.self)
            }
        }
    }
}
