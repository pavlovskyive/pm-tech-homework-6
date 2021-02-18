//
//  CoreImage+CoreDataClass.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 17.02.2021.
//
//

import UIKit
import CoreData

@objc(CoreImage)
public class CoreImage: NSManagedObject {

}

extension CoreImage {
    var image: UIImage? {

        guard let data = data else {
            return nil
        }

        return UIImage(data: data)
    }
}
