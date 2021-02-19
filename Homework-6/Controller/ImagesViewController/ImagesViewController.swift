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

    lazy private var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Images"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .white

        prepareCollectionView()
        prepareDataSource()
        prepareDataProvider()
        setupNavigationBar()
        setupRefreshControl()

        reloadData()
    }
}

private extension ImagesViewController {

    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Log Out", style: .plain, target: self, action: #selector(logOut))
    }

    func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        refreshControl.backgroundColor = .systemBackground
        collectionView.addSubview(refreshControl)
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
    }

    @objc func reloadData() {
        refreshControl.beginRefreshing()
        dataProvider?.fetchImages()
        refreshControl.endRefreshing()
    }
}
