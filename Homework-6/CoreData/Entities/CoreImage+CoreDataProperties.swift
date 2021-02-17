//
//  CoreImage+CoreDataProperties.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 17.02.2021.
//
//

import Foundation
import CoreData

extension CoreImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreImage> {
        return NSFetchRequest<CoreImage>(entityName: "CoreImage")
    }

    @NSManaged public var data: Data?
    @NSManaged public var name: String?

}

extension CoreImage: Identifiable {

}
