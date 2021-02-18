//
//  ImagesFRC.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 17.02.2021.
//

import CoreData

class ImagesFRC: NSFetchedResultsController<CoreImage> {

    class func make(at context: NSManagedObjectContext) -> ImagesFRC {

        let request: NSFetchRequest<CoreImage> = CoreImage.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(CoreImage.name),
                                    ascending: true)
        request.sortDescriptors = [sort]
        let result = ImagesFRC(fetchRequest: request,
                               managedObjectContext: context,
                               sectionNameKeyPath: #keyPath(CoreImage.name),
                               cacheName: nil)
        return result
    }
}
