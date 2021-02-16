//
//  ImagesViewController.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 16.02.2021.
//

import UIKit

class ImagesViewController: UIViewController {
    override func viewDidLoad() {
        let token = getStoredToken()

        print(token)
        NetworkService().requestImages(token: token) { result in
            print(result)
        }
    }

    func getStoredToken() -> String {
      let kcw = KeychainWrapper()
      if let password = try? kcw.getGenericPasswordFor(
        account: "App",
        service: "accessToken") {
        return password
      }

      return ""
    }
}
