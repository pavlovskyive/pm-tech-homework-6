//
//  DataProvider.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 17.02.2021.
//

import CoreData

class DataProvider {

    private let persistentContainer: NSPersistentContainer
    private let apiService: ApiService

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    init(persistentContainer: NSPersistentContainer, apiService: ApiService) {
        self.persistentContainer = persistentContainer
        self.apiService = apiService
    }

    public func fetchImages(completion: @escaping (Error?) -> Void) {
        apiService.fetchImages { result in
            switch result {
            case .success(let images):
                let taskContext = self.persistentContainer.newBackgroundContext()
                taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                taskContext.undoManager = nil

                _ = self.syncImages(images: images, taskContext: taskContext)

                completion(nil)

            case .failure(let error):
                completion(error)
            }
        }
    }

    private func syncImages(images: [ImageData], taskContext: NSManagedObjectContext) -> Bool {

        var isSuccessful = false

        taskContext.performAndWait {
            let matchingImagesRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreImage")
            let imageNames = images.map { $0.name }
            matchingImagesRequest.predicate = NSPredicate(format: "name in %@", argumentArray: [imageNames])

            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: matchingImagesRequest)
            batchDeleteRequest.resultType = .resultTypeObjectIDs

            do {
//                let batchDeleteResult = try taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
//
//                if let deletedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID] {
//                    NSManagedObjectContext.mergeChanges(
//                        fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs],
//                        into: [self.viewContext])
//                }
            } catch {
                print("Error: \(error)\nCould not batch delete existing records.")
                return

            }

            for image in images {

                guard let coreImage = NSEntityDescription
                        .insertNewObject(forEntityName: "CoreImage", into: taskContext) as? CoreImage else {
                    print("Error: Failed to create a new CoreImage object!")
                    return
                }

                do {
                    try coreImage.update(with: image)
                } catch {
                    print("Error: \(error)\nThe Image object will be deleted.")
                    taskContext.delete(coreImage)
                }
            }

            if taskContext.hasChanges {

                do {
                    try taskContext.save()
                } catch {
                    print("Error: \(error)\nCould not save Core Data context.")
                }

                taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
            }

            isSuccessful = true
        }

        return isSuccessful
    }
}
