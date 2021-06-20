//
//  CoreDataStack.swift
//  DogWalkCoreDataP3
//
//  Created by Mac on 20.06.2021.
//

import Foundation
import CoreData

class CoreDataStack {
    private let modelName: String
    
    init(modelName:String) {
        self.modelName = modelName
    }
    
    lazy var managedContext: NSManagedObjectContext = {
        storeContainer.viewContext
    }()
    
    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { _, error in
            if let error = error {
                print(error)
            }
        }
        return container
    }()
    
    func saveContext() {
        guard managedContext.hasChanges else { return }
        
        do {
            try managedContext.save()
        } catch let error {
            print(error)
        }
    }
}
