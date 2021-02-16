//
//  NetworkService.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 16.02.2021.
//

import Alamofire
import Foundation

class NetworkService {
    public func requestAccessToken(authCode: String, completion: @escaping (Result<String, Error>) -> Void) {

        let headers: HTTPHeaders = [
            .accept("application/json")
        ]

        let parameters: [String: String] =
            [
                "client_id": GithubConstants.clientID,
                "client_secret": GithubConstants.clientSecret,
                "code": authCode
            ]

        AF.request(GithubConstants.tokenURL, method: .post, parameters: parameters, headers: headers)
            .validate(contentType: ["application/json"])
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success(let result):
                    if let result = result as? [String: Any],
                       let token = result["access_token"] as? String {
                        completion(.success(token))
                    }

                    completion(.failure(NetworkError.badResult))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}

enum NetworkError: Error {
    case badResult
}