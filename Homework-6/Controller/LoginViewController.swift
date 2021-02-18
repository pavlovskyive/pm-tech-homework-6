//
//  ViewController.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 16.02.2021.
//

import UIKit
import WebKit
import LocalAuthentication

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

    func loginWithBiometrics() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: reason) { [weak self] success, _ in
                DispatchQueue.main.async {
                    if success {
                        self?.navigateToMain()
                    } else {
                        let alertController = UIAlertController(
                            title: "Authentication failed",
                            message: "You can try again or login with GitHub", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(alertController, animated: true)
                    }
                }
            }
        } else {
            let alertController = UIAlertController(
                title: "Biometric identification is not available",
                message: "Your device is not configured for Face ID or Touch ID.", preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            present(alertController, animated: true)
        }
    }

    func logIn() {
        guard !accessToken.isEmpty else {
            authenticate()
            return
        }

        loginWithBiometrics()
//        navigateToMain()
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
