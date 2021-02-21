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

    public var authService: AuthService?

    private let context: NSManagedObjectContext = CoreDataStack.shared.container.viewContext
    private var dataSource: ImagesDataSource?
    private var dataProvider: DataProvider?

    lazy private var refreshControl = UIRefreshControl()

    // swiftlint:disable weak_delegate
    lazy private var collectionViewDelegate = ImagesCollectionViewDelegate { [weak self] in
        self?.imageSelected(at: $0)
    }
    // swiftlint:enable weak_delegate

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
            title: "Log Out", style: .plain, target: self, action: #selector(logout))
    }

    func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        refreshControl.backgroundColor = .systemBackground
        collectionView.addSubview(refreshControl)
    }

    @objc func logout() {
        authService?.logout()
        dataProvider?.clearStorage()

        navigationController?.dismiss(animated: true)
    }

    func prepareCollectionView() {

        let identifier = ImageCell.reuseIdOrClassName

        collectionView.delegate = collectionViewDelegate

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

    func imageSelected(at indexPath: IndexPath) {
        guard let coreImage = dataSource?.frc.object(at: indexPath) else {
            return
        }

        let detailedImageVC =
            DetailedImageViewController(nibName: "DetailedImageViewController", bundle: nil)
        detailedImageVC.coreImage = coreImage
        navigationController?.pushViewController(detailedImageVC, animated: true)
    }
}
