//
//  ApiService.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 17.02.2021.
//

import Alamofire
import UIKit

class ApiService {

    public func fetchImages(
        token: String,
        completion: @escaping (Result<[UIImage], Error>) -> Void) {

        getImagesData(token: token) { result in
            switch result {
            case .success(let imageData):
                print(imageData)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func getImagesData(
        token: String,
        completion: @escaping (Result<[ImageData], Error>) -> Void) {

        let headers: HTTPHeaders = [
            .authorization(bearerToken: token),
            .accept("application/json")
        ]

        AF.request(GithubConstants.repoURL, headers: headers)
            .validate(statusCode: 200..<300)
            .validate()
            .responseDecodable(of: [RepositoryContent].self) { response in
                guard let contents = response.value else {
                    completion(.failure(NetworkError.badResult))
                    return
                }

                let supportedImageFormats = [
                    "tiff",
                    "jpg", "jpeg",
                    "gif",
                    "bmp",
                    "ico",
                    "cur",
                    "xbm"
                ]

                let imageData = contents.filter { content in
                    if content.type == "file",
                       let ext = content.name.split(separator: ".").last,
                       supportedImageFormats.contains(String(ext)) {
                        return true
                    }

                    return false
                }.map { ImageData(name: $0.name, downloadURL: $0.downloadURL) }

                completion(.success(imageData))
                return
            }
    }
}
