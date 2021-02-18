//
//  UIResponder.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 17.02.2021.
//

import UIKit

extension UIResponder {

    class var reuseIdOrClassName: String {
        String(describing: self)
    }
}
