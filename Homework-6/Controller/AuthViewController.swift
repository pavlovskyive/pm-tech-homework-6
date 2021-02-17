//
//  AuthViewController.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 16.02.2021.
//

import UIKit
import WebKit

protocol LoginDelegate: AnyObject {
    func handleLoggedIn(accessToken: String)
}

class AuthViewController: UIViewController {

    weak var delegate: LoginDelegate?

    lazy var uuid = UUID().uuidString
    lazy var webView = WKWebView()

    override func viewDidLoad() {
        setup()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        webView.stopLoading()
        webView.navigationDelegate = nil
    }

    private func setup() {
        view.addSubview(webView)
        webView.frame = view.bounds

        webView.navigationDelegate = self

        let authURLFull =
            "https://github.com/login/oauth/authorize?client_id=" + GithubConstants.clientID +
            "&scope=" + GithubConstants.scope +
            "&redirect_uri=" + GithubConstants.redirectURI +
            "&state=" + uuid

        guard let url = URL(string: authURLFull) else {
            return
        }
        let urlRequest = URLRequest(url: url)

        webView.load(urlRequest)

        let cancelButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(self.cancelAction))

        navigationItem.leftBarButtonItem = cancelButton

        let refreshButton = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(self.refreshAction))

        navigationItem.rightBarButtonItem = refreshButton

        navigationItem.title = "github.com"
    }

    @objc func cancelAction() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func refreshAction() {
        self.webView.reload()
    }
}

extension AuthViewController: WKNavigationDelegate {

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        self.requestForCallbackURL(request: navigationAction.request)
        decisionHandler(.allow)
    }

    func requestForCallbackURL(request: URLRequest) {
        guard let url = request.url,
              let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let authCode = urlComponents.queryItems?.first(where: { $0.name == "code" })?.value
        else { return }

        AuthService().requestAccessToken(authCode: authCode) { [weak self] result in
            switch result {
            case .success(let token):
                self?.dismiss(animated: true) {
                    self?.delegate?.handleLoggedIn(accessToken: token)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
