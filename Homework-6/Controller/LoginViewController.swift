//
//  ViewController.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 16.02.2021.
//

import UIKit
import WebKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        logIn()
    }

    @IBAction func handleLogInButton(_ sender: UIButton) {
        authenticate()
    }
}

private extension LoginViewController {

    var accessToken: String {
        let kcw = KeychainWrapper()
        if let accessToken = try? kcw.get(forKey: "accessToken") {
            return accessToken
        }

        return ""
    }

    func logIn() {
        guard !accessToken.isEmpty else {
            return
        }

        navigateToMain()
    }

    func authenticate() {

        let authVC = AuthViewController()
        authVC.delegate = self

        self.present(UINavigationController(rootViewController: authVC),
                     animated: true,
                     completion: nil)
    }

    func navigateToMain() {
        let imagesVC = ImagesViewController(nibName: "ImagesViewController", bundle: nil)
        let imagesNavigationController = UINavigationController(rootViewController: imagesVC)

        imagesNavigationController.modalPresentationStyle = .overFullScreen

        present(imagesNavigationController, animated: true)
    }
}

extension LoginViewController: AuthDelegate {

    func handleAccessToken(accessToken: String) {

        let kcw = KeychainWrapper()
        do {
            navigateToMain()
            try kcw.set(accessToken, forKey: "accessToken")
        } catch let error as KeychainWrapperError {
            print("Exception setting password: \(error.message ?? "no message")")
        } catch {
            print("An error occurred setting the password.")
        }
    }
}
