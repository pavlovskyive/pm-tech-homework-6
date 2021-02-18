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
        //        apiService.fetchImages { result in
        //            switch result {
        //            case .success(let images):
        //                let taskContext = self.persistentContainer.newBackgroundContext()
        //                taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        //                taskContext.undoManager = nil
        //
        //                completion(nil)
        //
        //            case .failure(let error):
        //                completion(error)
        //            }
        //        }

        apiService.getImagesInfo { result in
            switch result {
            case .success(let imagesInfos):
                print(imagesInfos)
                self.removeDifferences(imagesInfos: imagesInfos)
                self.fetchImagesFromApi(imagesInfos: imagesInfos)
            case .failure(let error):
                print(error)
            }
        }
    }

    private func fetchImagesFromApi(imagesInfos: [ImageInfo]) {

        let taskContext = persistentContainer.newBackgroundContext()

        var remainingImagesInfos = [ImageInfo]()

        taskContext.performAndWait {
            let currentImagesRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreImage")

            do {
                guard let currentImages = try taskContext.fetch(currentImagesRequest) as? [CoreImage] else {
                    return
                }

                let currentNames = currentImages.compactMap { $0.name }
                remainingImagesInfos = imagesInfos.filter { !currentNames.contains($0.name) }

            } catch {
                print("Error: \(error)\nCould not read existing records.")
            }
        }

        for imageInfo in remainingImagesInfos {
            apiService.fetchImage(with: imageInfo) { result in
                switch result {
                case .success(let imageData):
                    ImageFactory.makeImage(with: imageData)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    private func removeDifferences(imagesInfos: [ImageInfo]) {
        let taskContext = persistentContainer.newBackgroundContext()

        let names = imagesInfos.map { $0.name }

        taskContext.performAndWait {
            let differenceImagesRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreImage")
            differenceImagesRequest.predicate = NSPredicate(format: "not (name in %@)", argumentArray: [names])

            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: differenceImagesRequest)
            batchDeleteRequest.resultType = .resultTypeObjectIDs

            // Execute the request to de batch delete and merge the changes to viewContext, which triggers the UI update
            do {
                let batchDeleteResult = try taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult

                if let deletedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID] {
                    NSManagedObjectContext.mergeChanges(
                        fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs],
                        into: [self.persistentContainer.viewContext])
                }
            } catch {
                print("Error: \(error)\nCould not batch delete existing records.")
            }
        }
    }
}
