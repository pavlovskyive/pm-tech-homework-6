//
//  NetworkService.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 16.02.2021.
//

import UIKit
import LocalAuthentication

class AuthService {

    private let kcw = KeychainWrapper()

    public var onLogout: (() -> Void)?

    public var authentified: Bool {
        guard let accessToken = try? kcw.get(forKey: "accessToken"),
              !accessToken.isEmpty else {
            return false
        }

        return true
    }

    public func loginWithBiometrics(completion: @escaping (AuthError?) -> Void) {

        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself"
            context.localizedFallbackTitle = ""

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: reason) { success, _ in
                DispatchQueue.main.async {
                    if success {
                        completion(nil)
                    } else {
                        completion(.biometricsNotRecognized)
                    }
                }
            }
        } else {
            completion(.noBiometrics)
        }
    }

    public func loginWithGitHub(
        navigationController: UINavigationController?,
        completion: @escaping () -> Void) {

        let authVC = AuthViewController()
        authVC.completion = { authCode in
            authVC.dismiss(animated: true)
            self.requestAccessToken(authCode: authCode)
            completion()
        }

        navigationController?.present(authVC, animated: true)
    }

    public func logout() {
        try? kcw.delete(forKey: "accessToken")
        onLogout?()
    }
}

private extension AuthService {
    func requestAccessToken(authCode: String) {

        guard let tokenURL = Bundle.main.infoDictionary?["TOKEN_URL"] as? String,
              let clientID = Bundle.main.infoDictionary?["CLIENT_ID"] as? String,
              let clientSecret = Bundle.main.infoDictionary?["CLIENT_SECRET"] as? String else {
            return
        }

        let parameters: [String: String] = [
            "client_id": clientID,
            "client_secret": clientSecret,
            "code": authCode
        ]

        let headers: [String: String] = [
            "Accept": "application/json"
        ]

        NetworkService.postRequest(urlString: tokenURL,
                               parameters: parameters,
                               headers: headers) { result in
            switch result {
            case .success(let data):
                guard let jsonObject = data.jsonObject(),
                      let token = jsonObject["access_token"] as? String else {
                    return
                }
                self.handleAccessToken(token)
            case .failure:
                return
            }
        }
    }

    func handleAccessToken(_ token: String) {
        do {
            try kcw.set(token, forKey: "accessToken")
        } catch let error as KeychainWrapperError {
            print("Exception setting password: \(error.message ?? "no message")")
        } catch {
            print("An error occurred setting the password.")
        }
    }
}

enum AuthError: Error {
    case noBiometrics
    case biometricsNotRecognized
}
