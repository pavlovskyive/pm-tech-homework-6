//
//  ViewController.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 16.02.2021.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func githubAuthVC() {

        let authVC = AuthViewController()
        authVC.delegate = self

        self.present(UINavigationController(rootViewController: authVC),
                     animated: true,
                     completion: nil)
    }

    @IBAction func handleLogInButton(_ sender: UIButton) {
        githubAuthVC()
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

extension ViewController: LoginDelegate {

    func handleLoggedIn(accessToken: String) {

        let kcw = KeychainWrapper()
        do {
          try kcw.storeGenericPasswordFor(
            account: "App",
            service: "accessToken",
            password: accessToken)
        } catch let error as KeychainWrapperError {
          print("Exception setting password: \(error.message ?? "no message")")
        } catch {
          print("An error occurred setting the password.")
        }

        print("User Successfully Logged In")
        print(getStoredToken())

    }
}
