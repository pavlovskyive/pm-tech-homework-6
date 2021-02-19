//
//  NetworkService.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 16.02.2021.
//

import UIKit

class AuthService {

    public func requestAccessToken(authCode: String, completion: @escaping (Result<String, NetworkError>) -> Void) {

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
                    completion(.failure(.badData))
                    return
                }
                completion(.success(token))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
