//
//  CoreDataManager.swift
//  TestSensingKit
//
//  Created by Kseniia Shkurenko on 19.10.2020.
//

import Foundation
import CoreData

final class CoreDataManager {
    // MARK: - Properties

    private let modelName: String

    // MARK: - Initialization

    init(modelName: String) {
        self.modelName = modelName
    }
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel? = {
        guard let modelURL = Bundle.main.url(forResource: "SensorsDataModel", withExtension: "momd") else { return nil }
        return NSManagedObjectModel(contentsOf: modelURL)
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        guard let managedObjectModel =  self.managedObjectModel else { return nil }
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }

        return coordinator
    }()
}
