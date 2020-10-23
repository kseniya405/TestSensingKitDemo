//
//  PersistentContainer.swift
//  CoreLocationTest
//
//  Created by Ксения Шкуренко on 17.10.2020.
//

import Foundation
import CoreData

protocol PersistentContainerProtocol {
    var persistentContainer: NSPersistentContainer { get }
    var viewContext: NSManagedObjectContext { get }
    func saveContext()
}

final class PersistentContainer: PersistentContainerProtocol {

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataExample")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    lazy var viewContext: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()

}

