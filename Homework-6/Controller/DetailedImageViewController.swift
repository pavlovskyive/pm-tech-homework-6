//
//  DetailedImageViewController.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 21.02.2021.
//

import UIKit

class DetailedImageViewController: UIViewController {

    @IBOutlet weak private var imageView: UIImageView!

    public var coreImage: CoreImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = coreImage?.image
        title = coreImage?.name
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.navigationBar.largeTitleTextAttributes = nil
    }
}
