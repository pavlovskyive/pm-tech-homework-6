//
//  ApiService.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 17.02.2021.
//

import Alamofire
import UIKit

class ApiService {

    private var token: String? {
        let kcw = KeychainWrapper()
        if let accessToken = try? kcw.get(forKey: "accessToken") {
            return accessToken
        }

        return nil
    }

    public func fetchImage(with imageInfo: ImageInfo, completion: @escaping (Result<ImageData, NetworkError>) -> Void) {

        guard let token = token else {
            completion(.failure(.noToken))
            return
        }

        let headers: HTTPHeaders = [
            .authorization(bearerToken: token),
            .accept("application/json")
        ]

        AF.request(imageInfo.downloadURL, headers: headers)
            .response { response in
                switch response.result {
                case .success(let data):
                    guard let data = data else {
                        completion(.failure(.badResult))
                        return
                    }
                    completion(.success(ImageData(name: imageInfo.name, data: data)))
                case .failure(let error):
                    completion(.failure(.networkError(error)))
                }
            }
    }

    public func getImagesInfo(completion: @escaping (Result<[ImageInfo], Error>) -> Void) {

        guard let token = token,
              let repoURL = Bundle.main.infoDictionary?["REPO_URL"] as? String else {
            completion(.failure(NetworkError.noToken))
            return
        }

        let headers: HTTPHeaders = [
            .authorization(bearerToken: token),
            .accept("application/json")
        ]

        AF.request(repoURL, headers: headers)
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
                }.compactMap { content -> ImageInfo? in
                    guard let downloadURL = content.downloadURL else {
                        return nil
                    }
                    return ImageInfo(name: content.name, downloadURL: downloadURL)
                }

                completion(.success(imageData))
                return
            }
    }
}
