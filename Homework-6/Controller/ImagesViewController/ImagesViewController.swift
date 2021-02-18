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
    @IBOutlet weak var layout: UICollectionViewFlowLayout!

    private let context: NSManagedObjectContext = CoreDataStack.shared.container.viewContext
    private var dataSource: ImagesDataSource?
    private var dataProvider: DataProvider?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Images"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .white

        prepareCollectionView()
        prepareDataSource()
        prepareDataProvider()
        setupNavigationBar()
    }
}

private extension ImagesViewController {

    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Log Out", style: .plain, target: self, action: #selector(logOut))
    }

    @objc func logOut() {
        let kcw = KeychainWrapper()
        try? kcw.delete(forKey: "accessToken")
        dataProvider?.clearStorage()

        navigationController?.dismiss(animated: true)
    }

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
        collectionView.delegate = dataSource
        collectionView.reloadData()
    }

    func prepareDataProvider() {
        dataProvider = DataProvider(
            persistentContainer: CoreDataStack.shared.container,
            apiService: ApiService())

        dataProvider?.fetchImages()
    }
}
