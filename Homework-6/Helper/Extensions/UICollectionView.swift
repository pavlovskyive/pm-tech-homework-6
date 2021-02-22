//
//  UICollectionView.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 21.02.2021.
//

import UIKit

extension UICollectionView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(
            frame: CGRect(x: 0, y: 0, width: self.bounds.size.width * 0.8, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .label
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
    }

    func restore() {
        self.backgroundView = nil
    }
}
