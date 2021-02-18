//
//  DataProvider.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 17.02.2021.
//

import CoreData

class DataProvider {

    private let container: NSPersistentContainer
    private let apiService: ApiService

    private var viewContext: NSManagedObjectContext {
        return container.viewContext
    }

    init(persistentContainer: NSPersistentContainer, apiService: ApiService) {
        self.container = persistentContainer
        self.apiService = apiService
    }

    public func clearStorage() {
        let taskContext = container.newBackgroundContext()

        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreImage")
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            _ = try? taskContext.execute(batchDeleteRequest)
        }
    }

    public func fetchImages() {

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

        let taskContext = container.newBackgroundContext()

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
}

private extension DataProvider {

    func removeDifferences(imagesInfos: [ImageInfo]) {
        let taskContext = container.newBackgroundContext()

        let names = imagesInfos.map { $0.name }

        taskContext.performAndWait {
            let differenceImagesRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreImage")
            differenceImagesRequest.predicate = NSPredicate(format: "not (name in %@)", argumentArray: [names])

            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: differenceImagesRequest)
            batchDeleteRequest.resultType = .resultTypeObjectIDs

            do {
                let batchDeleteResult = try taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult

                if let deletedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID] {
                    NSManagedObjectContext.mergeChanges(
                        fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs],
                        into: [self.container.viewContext])
                }
            } catch {
                print("Error: \(error)\nCould not batch delete existing records.")
            }
        }
    }
}
