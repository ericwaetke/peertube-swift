//
//  DependencyContainer.swift
//  PeerTubeSwift
//
//  Created on 2024-12-17.
//

import CoreData
import Foundation

/// Protocol for dependency injection container
public protocol DependencyContainerProtocol: Sendable {
	var coreDataStack: CoreDataStack { get }
	var networkingFoundation: NetworkingFoundation { get }
}

/// Dependency injection container for managing app services
public final class DependencyContainer: DependencyContainerProtocol, @unchecked Sendable {
	// MARK: - Properties

	/// Shared instance of the dependency container
	public static let shared = DependencyContainer()

	/// Core Data stack for local storage
	public lazy var coreDataStack: CoreDataStack = .shared

	/// Networking foundation for API communication
	public lazy var networkingFoundation: NetworkingFoundation = .shared

	// MARK: - Private Properties

	/// Actor to manage services thread-safely
	private let servicesManager = ServicesManager()

	// MARK: - Initialization

	private init() {
		registerDefaultServices()
	}

	// MARK: - Service Registration

	/// Register a service with the container
	public func register<T>(_ serviceType: T.Type, factory: @escaping @Sendable () -> T) {
		Task {
			await servicesManager.register(serviceType, factory: factory)
		}
	}

	/// Register a singleton service with the container
	public func registerSingleton<T>(_ serviceType: T.Type, factory: @escaping @Sendable () -> T) {
		Task {
			await servicesManager.registerSingleton(serviceType, factory: factory)
		}
	}

	/// Register an existing instance as a singleton
	public func registerInstance<T: Sendable>(_ serviceType: T.Type, instance: T) {
		Task {
			await servicesManager.registerInstance(serviceType, instance: instance)
		}
	}

	// MARK: - Service Resolution

	/// Resolve a service from the container
	public func resolve<T: Sendable>(_ serviceType: T.Type) async -> T {
		await servicesManager.resolve(serviceType)
	}

	/// Resolve a service from the container (optional)
	public func resolveOptional<T: Sendable>(_ serviceType: T.Type) async -> T? {
		await servicesManager.resolveOptional(serviceType)
	}

	// MARK: - Private Methods

	private func registerDefaultServices() {
		// Register core services as singletons
		registerInstance(CoreDataStack.self, instance: coreDataStack)
		registerInstance(NetworkingFoundation.self, instance: networkingFoundation)
	}

	// MARK: - Testing Support

	/// Reset all registered services (for testing)
	public func reset() {
		Task {
			await servicesManager.reset()
			registerDefaultServices()
		}
	}

	/// Check if a service is registered
	public func isRegistered<T>(_ serviceType: T.Type) async -> Bool {
		await servicesManager.isRegistered(serviceType)
	}
}

// MARK: - Services Manager Actor

/// Actor to manage services in a thread-safe manner
private actor ServicesManager {
	private enum ServiceType {
		case transient(() -> Any)
		case singleton(() -> Any)
	}

	private var services: [String: ServiceType] = [:]
	private var singletonInstances: [String: Any] = [:]

	func register<T>(_ serviceType: T.Type, factory: @escaping @Sendable () -> T) {
		let key = String(describing: serviceType)
		services[key] = .transient(factory)
	}

	func registerSingleton<T>(_ serviceType: T.Type, factory: @escaping @Sendable () -> T) {
		let key = String(describing: serviceType)
		services[key] = .singleton(factory)
	}

	func registerInstance<T: Sendable>(_ serviceType: T.Type, instance: T) {
		let key = String(describing: serviceType)
		services[key] = .transient({ instance })
		singletonInstances[key] = instance
	}

	func resolve<T: Sendable>(_ serviceType: T.Type) -> T {
		let key = String(describing: serviceType)

		guard let service = services[key] else {
			fatalError("Service \(serviceType) is not registered")
		}

		switch service {
		case .transient(let factory):
			guard let typedFactory = factory as? () -> T else {
				fatalError("Service \(serviceType) has incorrect type")
			}
			return typedFactory()

		case .singleton(let factory):
			if let instance = singletonInstances[key] as? T {
				return instance
			}

			guard let typedFactory = factory as? () -> T else {
				fatalError("Service \(serviceType) has incorrect type")
			}

			let newInstance = typedFactory()
			singletonInstances[key] = newInstance
			return newInstance
		}
	}

	func resolveSync<T>(_ serviceType: T.Type) -> T {
		return resolve(serviceType)
	}

	func resolveOptional<T: Sendable>(_ serviceType: T.Type) -> T? {
		let key = String(describing: serviceType)

		guard let service = services[key] else {
			return nil
		}

		switch service {
		case .transient(let factory):
			guard let typedFactory = factory as? () -> T else {
				return nil
			}
			return typedFactory()

		case .singleton(let factory):
			if let instance = singletonInstances[key] as? T {
				return instance
			}

			guard let typedFactory = factory as? () -> T else {
				return nil
			}

			let newInstance = typedFactory()
			singletonInstances[key] = newInstance
			return newInstance
		}
	}

	func reset() {
		services.removeAll()
		singletonInstances.removeAll()
	}

	func isRegistered<T>(_ serviceType: T.Type) -> Bool {
		let key = String(describing: serviceType)
		return services[key] != nil
	}
}

// MARK: - Property Wrapper for Dependency Injection

/// Property wrapper for automatic dependency injection
@propertyWrapper
public struct Injected<T>: @unchecked Sendable {
	private let serviceType: T.Type
	private var container: DependencyContainer

	public var wrappedValue: T {
		// For now, use a simple synchronous resolution
		// This will need to be refactored for proper async support
		_ = String(describing: serviceType)

		// Handle core services that are always available
		if serviceType == CoreDataStack.self {
			return container.coreDataStack as! T
		} else if serviceType == NetworkingFoundation.self {
			return container.networkingFoundation as! T
		}

		fatalError(
			"Service \(serviceType) cannot be resolved synchronously. Use async resolution instead."
		)
	}

	public init(_ serviceType: T.Type, container: DependencyContainer = .shared) {
		self.serviceType = serviceType
		self.container = container
	}
}

// MARK: - Extensions

extension DependencyContainer {
	/// Convenience method for resolving services with a more fluent API
	public subscript<T>(_ serviceType: T.Type) -> T {
		get async {
			await resolve(serviceType)
		}
	}
}

// MARK: - Service Locator Pattern Support

/// Global service locator for convenience
public enum ServiceLocator {
	/// Resolve a service using the shared container
	public static func resolve<T>(_ serviceType: T.Type) async -> T {
		return await DependencyContainer.shared.resolve(serviceType)
	}

	/// Resolve a service optionally using the shared container
	public static func resolveOptional<T>(_ serviceType: T.Type) async -> T? {
		return await DependencyContainer.shared.resolveOptional(serviceType)
	}
}
