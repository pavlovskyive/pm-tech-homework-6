//
//  ImagesViewController.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 17.02.2021.
//

import UIKit
import CoreData

class ImagesViewController: UIViewController {

    @IBOutlet weak private var collectionView: UICollectionView!
    private let context: NSManagedObjectContext = CoreDataStack.shared.container.viewContext
    private var dataSource: ImagesDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        prepareCollectionView()
        prepareDataSource()

        DataProvider(persistentContainer: CoreDataStack.shared.container, apiService: ApiService()).fetchImages {_ in}
    }
}

private extension ImagesViewController {

    func prepareCollectionView() {

        let identifier = ImageCell.reuseIdOrClassName

        collectionView.register(
            UINib(nibName: identifier, bundle: .main),
            forCellWithReuseIdentifier: identifier)
    }

    func prepareDataSource() {

        dataSource = ImagesDataSource(
            at: context,
            for: collectionView,
            displayng: ImageCell.self)

        collectionView.dataSource = dataSource
        collectionView.reloadData()
    }
}
