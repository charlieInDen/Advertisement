//
//  CoreDataSyncCordinator.swift
//  Advertisement
//
//  Created by Nishant Sharma on 3/1/19.
//  Copyright © 2019 Personal. All rights reserved.
//
/* Summary:  This class responsibility is to act as Sync Coordinator to fetch data using the Service and store the data to the Core Data Store. It accepts NSPersistent container as the initializer parameters and store it inside the instance variable. It also exposes a public variable for the View NSManagedObjectContext that uses the NSPersistetContainer View Context.
 */
import CoreData
protocol CoreDataSync {
     func fetchedRealEstateData(_ result:[Item], completion: @escaping(Error?) -> Void)
}
class CoreDataSyncCordinator: CoreDataSync {
    
    private let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    func fetchedRealEstateData(_ result:[Item], completion: @escaping(Error?) -> Void) {

        let taskContext = self.persistentContainer.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        taskContext.undoManager = nil
        _ = self.sync(result: result, taskContext: taskContext)
        completion(nil)

    }
    
    private func sync(result: [Item], taskContext: NSManagedObjectContext) -> Bool {
        var successfull = false
        
        taskContext.performAndWait {
            let matchingRealEstateRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RealEstate")
            let realEstates = result.map { $0.id }.compactMap { $0 }
            matchingRealEstateRequest.predicate = NSPredicate(format: "id in %@", argumentArray: [realEstates])
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: matchingRealEstateRequest)
            batchDeleteRequest.resultType = .resultTypeObjectIDs
            
            // Execute the request to de batch delete and merge the changes to viewContext, which triggers the UI update
            do {
                let batchDeleteResult = try taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
                
                if let deletedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID] {
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs],
                                                        into: [self.persistentContainer.viewContext])
                }
            } catch {
                print("Error: \(error)\nCould not batch delete existing records.")
                return
            }
            
            // Create new records.
            for item in result {
                
                guard let estate = NSEntityDescription.insertNewObject(forEntityName: "RealEstate", into: taskContext) as? RealEstate else {
                    print("Error: Failed to create a new object!")
                    return
                }
                estate.update(with: item)
            }
            
            // Save all the changes just made and reset the taskContext to free the cache.
            if taskContext.hasChanges {
                do {
                    try taskContext.save()
                } catch {
                    print("Error: \(error)\nCould not save Core Data context.")
                }
                taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
            }
            successfull = true
        }
        return successfull
    }
}
