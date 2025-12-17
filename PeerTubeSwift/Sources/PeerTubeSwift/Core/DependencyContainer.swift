//
//  DependencyContainer.swift
//  PeerTubeSwift
//
//  Created on 2024-12-17.
//

import CoreData
import Foundation

/// Protocol for dependency injection container
public protocol DependencyContainerProtocol {
	var coreDataStack: CoreDataStack { get }
	var networkingFoundation: NetworkingFoundation { get }
}

/// Dependency injection container for managing app services
public class DependencyContainer: DependencyContainerProtocol {

	// MARK: - Properties

	/// Shared instance of the dependency container
	public static let shared = DependencyContainer()

	/// Core Data stack for local storage
	public lazy var coreDataStack: CoreDataStack = {
		CoreDataStack.shared
	}()

	/// Networking foundation for API communication
	public lazy var networkingFoundation: NetworkingFoundation = {
		NetworkingFoundation.shared
	}()

	// MARK: - Private Properties

	/// Dictionary to store registered services
	private var services: [String: Any] = [:]

	/// Lock for thread-safe access to services
	private let servicesLock = NSLock()

	// MARK: - Initialization

	private init() {
		registerDefaultServices()
	}

	// MARK: - Service Registration

	/// Register a service with the container
	public func register<T>(_ serviceType: T.Type, factory: @escaping () -> T) {
		let key = String(describing: serviceType)
		servicesLock.lock()
		defer { servicesLock.unlock() }
		services[key] = factory
	}

	/// Register a singleton service with the container
	public func registerSingleton<T>(_ serviceType: T.Type, factory: @escaping () -> T) {
		let key = String(describing: serviceType)
		servicesLock.lock()
		defer { servicesLock.unlock() }

		// Create a lazy singleton wrapper
		var instance: T?
		services[key] = {
			if let existingInstance = instance {
				return existingInstance
			}
			let newInstance = factory()
			instance = newInstance
			return newInstance
		}
	}

	/// Register an existing instance as a singleton
	public func registerInstance<T>(_ serviceType: T.Type, instance: T) {
		let key = String(describing: serviceType)
		servicesLock.lock()
		defer { servicesLock.unlock() }
		services[key] = { instance }
	}

	// MARK: - Service Resolution

	/// Resolve a service from the container
	public func resolve<T>(_ serviceType: T.Type) -> T {
		let key = String(describing: serviceType)
		servicesLock.lock()
		defer { servicesLock.unlock() }

		guard let factory = services[key] else {
			fatalError("Service \(serviceType) is not registered")
		}

		if let serviceFactory = factory as? () -> T {
			return serviceFactory()
		} else {
			fatalError("Service \(serviceType) factory has wrong type")
		}
	}

	/// Resolve a service from the container (optional)
	public func resolveOptional<T>(_ serviceType: T.Type) -> T? {
		let key = String(describing: serviceType)
		servicesLock.lock()
		defer { servicesLock.unlock() }

		guard let factory = services[key] else {
			return nil
		}

		if let serviceFactory = factory as? () -> T {
			return serviceFactory()
		} else {
			return nil
		}
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
		servicesLock.lock()
		defer { servicesLock.unlock() }
		services.removeAll()
		registerDefaultServices()
	}

	/// Check if a service is registered
	public func isRegistered<T>(_ serviceType: T.Type) -> Bool {
		let key = String(describing: serviceType)
		servicesLock.lock()
		defer { servicesLock.unlock() }
		return services[key] != nil
	}
}

// MARK: - Property Wrapper for Dependency Injection

/// Property wrapper for automatic dependency injection
@propertyWrapper
public struct Injected<T> {
	private let serviceType: T.Type
	private var container: DependencyContainer

	public var wrappedValue: T {
		container.resolve(serviceType)
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
		return resolve(serviceType)
	}
}

// MARK: - Service Locator Pattern Support

/// Global service locator for convenience
public enum ServiceLocator {
	/// Resolve a service using the shared container
	public static func resolve<T>(_ serviceType: T.Type) -> T {
		return DependencyContainer.shared.resolve(serviceType)
	}

	/// Resolve a service optionally using the shared container
	public static func resolveOptional<T>(_ serviceType: T.Type) -> T? {
		return DependencyContainer.shared.resolveOptional(serviceType)
	}
}
