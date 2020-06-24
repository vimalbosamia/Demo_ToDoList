//
//  CoreDataHelper.swift
//  Demo_ToDoList
//
//  Created by Vimal on 23/06/20.
//  Copyright © 2020 Vimal. All rights reserved.
//

import UIKit
import CoreData

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



class CoreDataHelper: NSObject {
    
    static var instance:CoreDataHelper?
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.ibm.mobilefirst.travel.wqe" in the application's documents Application Support directory.
        // return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.iosbucket.newsworld")!
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return URL(fileURLWithPath: documentsPath)
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        //TODO: ADD DATABASE
        let modelURL = Bundle.main.url(forResource: "ToDoList", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        //TODO: ADD NAME
        let url = self.applicationDocumentsDirectory.appendingPathComponent("ToDoList.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            let options = [ NSInferMappingModelAutomaticallyOption : true,
                            NSMigratePersistentStoresAutomaticallyOption : true]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    class func sharedInstance() -> CoreDataHelper
    {
        if CoreDataHelper.instance == nil{
            
            CoreDataHelper.instance = CoreDataHelper()
        }
        return CoreDataHelper.instance!
    }
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                // abort()
            }
        }
    }
    
    func createEntityWithName(_ entityName:String ,uniqueKey primaryKey:String? ,value keyValue:String?) -> NSManagedObject
    {
        if let key = primaryKey ,let value = keyValue
        {
            let  predicate =  NSPredicate(format: "\(key) == %@", value)
            
            let arrayRecords =   CoreDataHelper.sharedInstance().getListOfEntityWithName(entityName, withPredicate:predicate , sortKey: nil, isAscending: true)
            if arrayRecords?.count > 0
            {
                return arrayRecords![0] as! NSManagedObject
            }
        }
        let entity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: managedObjectContext)
        return entity
    }
    
    func getListOfEntityWithName(_ entityName:String, withPredicate predicate:NSPredicate?, sortKey key:String? , isAscending asc:Bool) -> [AnyObject]?
    {
        let  request:NSFetchRequest = self.getFetchRequest(entityName)
        
        if let strPredicate = predicate
        {
            request.predicate = strPredicate
        }
        
        
        if let sortKey = key
        {
            let sortDescriptor = NSSortDescriptor(key: sortKey, ascending: asc)
            request.sortDescriptors = [sortDescriptor]
            
        }
        
        var result:[AnyObject]?
        
        do
        {
            try result = managedObjectContext.fetch(request)
            
            
        }catch
        {
            NSLog("Error occured in fetching the data")
        }
        
        guard let data = result else
        {
            return nil
        }
        
        return data
        
    }
    
    func getListOfEntityWithFetchRequest(_ entityName:String, withPredicate predicate:NSPredicate?, sortKey key:String? , isAscending asc:Bool) -> [AnyObject]?
    {
        
        let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
        fetchRequest.entity = entity
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToGroupBy = ["alertDate"]
        fetchRequest.propertiesToFetch = ["alertDate"]
        let  request:NSFetchRequest = fetchRequest
        
        if let strPredicate = predicate
        {
            request.predicate = strPredicate
        }
        
        
        if let sortKey = key
        {
            let sortDescriptor = NSSortDescriptor(key: sortKey, ascending: asc)
            request.sortDescriptors = [sortDescriptor]
            
        }
        
        var result:[AnyObject]?
        
        do
        {
            try result = managedObjectContext.fetch(request)
            
            
        }catch
        {
            NSLog("Error occured in fetching the data")
        }
        
        guard let data = result else
        {
            return nil
        }
        
        return data
        
    }
    
    
    func getFetchRequest(_ entityName:String) -> NSFetchRequest<NSFetchRequestResult>
    {
        let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
        fetchRequest.entity = entity
        return fetchRequest
    }
    
    func deleteObject(_ managedObject : NSManagedObject)
    {
        self.managedObjectContext.delete(managedObject)
        self.saveContext()
    }
    
    func resetDatabase()
    {
        let store = self.persistentStoreCoordinator.persistentStores.last
        
        do
        {
            try self.persistentStoreCoordinator.remove(store!)
            try FileManager.default.removeItem(at: (store?.url)!)
            
            try self.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: store?.url, options: nil)
            
        }catch
        {
            NSLog("Error occured in fetching the data")
        }
    }
    
    func rollBackContext () {
        if managedObjectContext.hasChanges {
            managedObjectContext.rollback()
        }
    }
}
