//
//  NetworkService.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 18.02.2021.
//

import Foundation

class NetworkService {

    static func getRequest(
        urlString: String,
        headers: [String: String]? = nil,
        completion: @escaping (Result<Data, NetworkError>) -> Void) {

        guard let url = URL(string: urlString) else {
            completion(.failure(.badUrl))
            return
        }

        var request = URLRequest(url: url)

        if let headers = headers {
            request.allHTTPHeaderFields = headers
        }

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {

                completion(.failure(.badStatusCode))
                return
            }

            guard let data = data else {
                completion(.failure(.badData))
                return
            }

            completion(.success(data))
        }

        task.resume()
    }

    static func postRequest(
        urlString: String,
        parameters: [String: String]? = nil,
        headers: [String: String]? = nil,
        completion: @escaping (Result<Data, NetworkError>) -> Void) {

        var urlComponents = URLComponents(string: urlString)

        if let parameters = parameters {
            var queryItems = [URLQueryItem]()
            parameters.forEach {
                let queryItem = URLQueryItem(name: $0.key, value: $0.value)
                queryItems.append(queryItem)
            }

            urlComponents?.queryItems = queryItems
        }

        guard let url = urlComponents?.url else {
            completion(.failure(.badUrl))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        if let headers = headers {
            request.allHTTPHeaderFields = headers
        }

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {

                completion(.failure(.badStatusCode))
                return
            }

            guard let data = data else {
                completion(.failure(.badData))
                return
            }

            completion(.success(data))
        }

        task.resume()
    }
}
