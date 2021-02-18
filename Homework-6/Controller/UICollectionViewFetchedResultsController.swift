//
//  UICollectionViewFetchedResultsController.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 17.02.2021.
//

import UIKit
import CoreData

private protocol UICollectionViewFetchedResultsControllable: NSFetchedResultsControllerDelegate {

    associatedtype EntityType: NSFetchRequestResult

    var collectionView: UICollectionView { get }

    var frc: NSFetchedResultsController<EntityType> { get }
}

class UICollectionViewFetchedResultsController<T: NSFetchRequestResult>: NSObject,
                                                                         UICollectionViewFetchedResultsControllable {
    typealias EntityType = T
    private(set) var collectionView: UICollectionView
    private(set) var frc: NSFetchedResultsController<T>

    init(with collectionView: UICollectionView, and frc: NSFetchedResultsController<T>) {
        self.collectionView = collectionView
        self.frc = frc
        super.init()
        self.frc.delegate = self
    }

    // MARK: - CRUD

    private lazy var sectionChanges = [
        (type: NSFetchedResultsChangeType, sectionIndex: Int)
    ]()

    private lazy var objectChanges = [
        (type: NSFetchedResultsChangeType,
         indexPath: IndexPath?,
         newIndexPath: IndexPath?)
    ]()

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        cleanupChangeLog()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        sectionChanges.append((type, sectionIndex))
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        objectChanges.append((type, indexPath, newIndexPath))
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        // ios11 crash fix
        guard collectionView.window != nil else {
            collectionView.reloadData()
            cleanupChangeLog()
            return
        }

        collectionView.performBatchUpdates({

            sectionChanges.forEach {
                switch $0.type {
                case .insert:
                    collectionView.insertSections([$0.sectionIndex])
                case .delete:
                    collectionView.deleteSections([$0.sectionIndex])
                default: break
                }
            }

            objectChanges.forEach {
                switch $0.type {
                case .insert:
                    collectionView.insertItems(at: [$0.newIndexPath!])
                case .delete:
                    collectionView.deleteItems(at: [$0.indexPath!])
                case .update:
                    collectionView.reloadItems(at: [$0.indexPath!])
                case .move:
                    collectionView.deleteItems(at: [$0.indexPath!])
                    collectionView.insertItems(at: [$0.newIndexPath!])
                default:
                    break
                }
            }

            cleanupChangeLog()
        })
    }

    private func cleanupChangeLog () {

        sectionChanges.removeAll()
        objectChanges.removeAll()
    }
}
