//
//  AuthViewController.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 16.02.2021.
//

import UIKit
import WebKit

class AuthViewController: UIViewController {

    var completion: ((String) -> Void)?

    lazy private var uuid = UUID().uuidString
    lazy private var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        // We don't want webview to store credentials.
        // First time user authenticated, he will login by biometrics.
        configuration.websiteDataStore = .nonPersistent()

        let webView = WKWebView(frame: .zero, configuration: configuration)

        return webView
    }()

    override func viewDidLoad() {
        setup()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        webView.stopLoading()
        webView.navigationDelegate = nil
    }
}

private extension AuthViewController {

    func setup() {

        view.addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        webView.navigationDelegate = self

        guard let clientID = Bundle.main.infoDictionary?["CLIENT_ID"] as? String,
              let redirectURL = Bundle.main.infoDictionary?["REDIRECT_URL"] as? String else {
            return
        }

        let scope = "read:user,user:email,repo"

        let authURLFull =
            "https://github.com/login/oauth/authorize?client_id=" + clientID +
            "&scope=" + scope +
            "&redirect_uri=" + redirectURL +
            "&state=" + uuid

        guard let url = URL(string: authURLFull) else {
            return
        }

        let urlRequest = URLRequest(url: url)

        webView.load(urlRequest)
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

        completion?(authCode)
    }
}
