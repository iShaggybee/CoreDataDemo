//
//  StoreManager.swift
//  CoreDataDemo
//
//  Created by Kislov Vadim on 27.06.2022.
//

import Foundation
import CoreData

class StoreManager {
    static let shared = StoreManager()
    
    lazy var context: NSManagedObjectContext = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container.viewContext
    }()
    
    private init() {}
    
    func autoSave() {
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func fetchTasks() throws -> [Task] {
        let fetchRequest = Task.fetchRequest()
    
        return try context.fetch(fetchRequest)
    }
    
    func createTask(with title: String, handler: (Task) -> Void) {
        let task = Task(context: context)
        task.title = title
        
        do {
            try context.save()
            handler(task)
        } catch let error {
            print("Failed to create data", error)
        }
    }
    
    func editTask(_ task: Task, newTitle: String, handler: () -> Void) {
        let prevTitle = task.title
        
        task.title = newTitle
        
        do {
            try context.save()
            handler()
        } catch let error {
            task.title = prevTitle
            
            print("Failed to create data", error)
        }
    }
    
    func removeTask(_ task: Task, handler: () -> Void) {
        context.delete(task)
        
        do {
            try context.save()
            handler()
        } catch let error {
            print("Failed to create data", error)
        }
    }
}
