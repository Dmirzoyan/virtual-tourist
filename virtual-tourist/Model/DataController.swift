//
//  DataController.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/28/19.
//  Copyright © 2019. All rights reserved.
//

import CoreData

final class DataController {
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load() {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil
            else {
                fatalError(error!.localizedDescription)
            }
        }
    }
}
