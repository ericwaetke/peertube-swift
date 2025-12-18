//
//  CoreDataStack.swift
//  PeerTubeSwift
//
//  Created on 2024-12-17.
//

import CoreData
import Foundation

/// Core Data stack for managing local storage in PeerTubeSwift
public final class CoreDataStack: @unchecked Sendable {
	// MARK: - Properties

	/// Shared instance of the Core Data stack
	public static let shared = CoreDataStack()

	/// The name of the Core Data model
	private let modelName = "PeerTubeModel"

	/// Main managed object context for UI operations (main queue)
	public lazy var mainContext: NSManagedObjectContext = {
		let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		context.persistentStoreCoordinator = persistentStoreCoordinator
		context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		return context
	}()

	/// Background context for data operations (private queue)
	public lazy var backgroundContext: NSManagedObjectContext = {
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = persistentStoreCoordinator
		context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

		// Automatically merge changes from background context to main context
		NotificationCenter.default.addObserver(
			forName: .NSManagedObjectContextDidSave,
			object: context,
			queue: .main
		) { [weak self] notification in
			self?.mainContext.mergeChanges(fromContextDidSave: notification)
		}

		return context
	}()

	/// Persistent store coordinator
	private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

		let storeURL = storeURL

		do {
			try coordinator.addPersistentStore(
				ofType: NSSQLiteStoreType,
				configurationName: nil,
				at: storeURL,
				options: [
					NSMigratePersistentStoresAutomaticallyOption: true,
					NSInferMappingModelAutomaticallyOption: true,
				]
			)
		} catch {
			fatalError("Failed to create persistent store: \(error)")
		}

		return coordinator
	}()

	/// Managed object model
	private lazy var managedObjectModel: NSManagedObjectModel = PeerTubeDataModel.createModel()

	/// URL for the persistent store
	private var storeURL: URL {
		let documentsDirectory = FileManager.default.urls(
			for: .documentDirectory, in: .userDomainMask
		).first!
		return documentsDirectory.appendingPathComponent("\(modelName).sqlite")
	}

	// MARK: - Initialization

	private init() {}

	// MARK: - Public Methods

	/// Save the main context
	public func saveMainContext() {
		guard mainContext.hasChanges else { return }

		do {
			try mainContext.save()
		} catch {
			print("Failed to save main context: \(error)")
		}
	}

	/// Save the background context
	public func saveBackgroundContext() {
		guard backgroundContext.hasChanges else { return }

		backgroundContext.perform {
			do {
				try self.backgroundContext.save()
			} catch {
				print("Failed to save background context: \(error)")
			}
		}
	}

	/// Perform a background task with automatic context management
	public func performBackgroundTask<T>(
		_ block: @escaping @Sendable (NSManagedObjectContext) throws -> T
	)
		async throws -> T
	{
		return try await withCheckedThrowingContinuation { continuation in
			backgroundContext.perform {
				do {
					let result = try block(self.backgroundContext)

					if self.backgroundContext.hasChanges {
						try self.backgroundContext.save()
					}

					continuation.resume(returning: result)
				} catch {
					continuation.resume(throwing: error)
				}
			}
		}
	}

	/// Create a new background context for batch operations
	public func newBackgroundContext() -> NSManagedObjectContext {
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = persistentStoreCoordinator
		context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		return context
	}

	/// Reset all data (for testing or data cleanup)
	public func resetStore() {
		let coordinator = persistentStoreCoordinator

		do {
			// Remove all persistent stores
			for store in coordinator.persistentStores {
				try coordinator.remove(store)
			}

			// Delete the store file
			let storeURL = self.storeURL
			if FileManager.default.fileExists(atPath: storeURL.path) {
				try FileManager.default.removeItem(at: storeURL)
			}

			// Re-add the store
			try coordinator.addPersistentStore(
				ofType: NSSQLiteStoreType,
				configurationName: nil,
				at: storeURL,
				options: [
					NSMigratePersistentStoresAutomaticallyOption: true,
					NSInferMappingModelAutomaticallyOption: true,
				]
			)

		} catch {
			fatalError("Failed to reset Core Data store: \(error)")
		}
	}
}

// MARK: - Extensions

extension NSManagedObjectContext {
	/// Convenience method to save context if it has changes
	public func saveIfNeeded() throws {
		guard hasChanges else { return }
		try save()
	}
}
