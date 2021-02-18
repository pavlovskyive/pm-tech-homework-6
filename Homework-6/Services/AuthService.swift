//
//  NetworkService.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 16.02.2021.
//

import Alamofire
import UIKit

class AuthService {

    public func requestAccessToken(authCode: String, completion: @escaping (Result<String, Error>) -> Void) {

        guard let tokenURL = Bundle.main.infoDictionary?["TOKEN_URL"] as? String,
              let clientID = Bundle.main.infoDictionary?["CLIENT_ID"] as? String,
              let clientSecret = Bundle.main.infoDictionary?["CLIENT_SECRET"] as? String else {
            return
        }

        let headers: HTTPHeaders = [
            .accept("application/json")
        ]

        let parameters: [String: String] = [
            "client_id": clientID,
            "client_secret": clientSecret,
            "code": authCode
        ]

        AF.request(tokenURL, method: .post, parameters: parameters, headers: headers)
            .validate(contentType: ["application/json"])
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success(let data):
                    if let data = data as? [String: Any],
                       let token = data["access_token"] as? String {
                        completion(.success(token))
                    }

                    completion(.failure(NetworkError.badResult))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
