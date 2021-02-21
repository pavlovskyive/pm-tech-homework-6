//
//  ImageCell.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 17.02.2021.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak private var imageView: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()
        image = nil
    }

    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
}
