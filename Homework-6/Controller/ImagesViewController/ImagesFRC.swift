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
                                    ascending: true, selector: #selector(NSString.caseInsensitiveCompare))

        request.sortDescriptors = [sort]
        let result = ImagesFRC(fetchRequest: request,
                               managedObjectContext: context,
                               sectionNameKeyPath: nil,
                               cacheName: nil)
        return result
    }
}
