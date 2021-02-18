//
//  ImageCell.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 17.02.2021.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var label: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        image = nil
        text = nil
    }

    var text: String? {
        didSet {
            label.text = text
        }
    }

    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
}
