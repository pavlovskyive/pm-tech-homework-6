//
//  ImagesDataSource.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 17.02.2021.
//

import UIKit
import CoreData

class ImagesDataSource: UICollectionViewFetchedResultsController<CoreImage> {

    private let cellClass: ImageCell.Type
    private let context: NSManagedObjectContext

    init(at context: NSManagedObjectContext,
         for collectionView: UICollectionView,
         displayng cellClass: ImageCell.Type) {

        self.cellClass = cellClass
        self.context = context

        let frc = ImagesFRC.make(at: context)
        super.init(with: collectionView, and: frc)

        do {
            try frc.performFetch()
        } catch {
            print(error)
        }
    }
}

extension ImagesDataSource: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        frc.sections?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        guard let sectionInfo = frc.sections?[section] else {
            return 0
        }

        return sectionInfo.numberOfObjects
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let object = frc.object(at: indexPath)
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: cellClass.reuseIdOrClassName,
                for: indexPath) as? ImageCell else {
            fatalError("Could not cast cell as ImageCell")
        }

        cell.image = object.image

        return cell
    }
}
