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

    @IBOutlet weak var biometricsLoginButton: UIButton?
    private let context = LAContext()

    lazy private var authService: AuthService = {
        let authService = AuthService()
        authService.onLogout = { [weak self] in
            self?.logout()
        }

        return authService
    }()

    override func viewWillAppear(_ animated: Bool) {
        setupButton()
    }

    @IBAction func handleBiometricsLogInButton(_ sender: UIButton) {
        loginWithBiometrics()
    }

    @IBAction func handleGitHubLogInButton(_ sender: UIButton) {
        loginWithGitHub()
    }

    public func logout() {
        setupButton()
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

    func setupButton() {
        var error: NSError?

        guard !accessToken.isEmpty,
              context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            biometricsLoginButton?.removeFromSuperview()
            return
        }

        switch context.biometryType {
        case .faceID:
            biometricsLoginButton?.setTitle("Log In with FaceID", for: .normal)
        case .touchID:
            biometricsLoginButton?.setTitle("Log In with TouchID", for: .normal)
            biometricsLoginButton?.setImage(UIImage(systemName: "touchid"), for: .normal)
        default:
            break
        }
    }

    func loginWithBiometrics() {

        authService.loginWithBiometrics { [weak self] error in
            guard error != nil else {
                self?.navigateToMain()
                return
            }

            let alertController: UIAlertController

            switch error {
            case .noBiometrics:
                alertController = UIAlertController(
                    title: "Biometric identification is not available",
                    message: "Your device is not configured for Face ID or Touch ID.", preferredStyle: .actionSheet)
            case .biometricsNotRecognized:
                alertController = UIAlertController(
                    title: "Authentication failed",
                    message: "You can try again or login with GitHub", preferredStyle: .alert)
            default:
                return
            }

            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alertController, animated: true)
        }
    }

    func loginWithGitHub() {
        authService.loginWithGitHub(navigationController: navigationController) { [weak self] in
            self?.loginWithBiometrics()
        }
    }

    func navigateToMain() {
        let imagesVC = ImagesViewController(nibName: "ImagesViewController", bundle: nil)
        imagesVC.authService = authService
        let imagesNavigationController = UINavigationController(rootViewController: imagesVC)

        imagesNavigationController.modalPresentationStyle = .overFullScreen

        present(imagesNavigationController, animated: true)
    }
}
