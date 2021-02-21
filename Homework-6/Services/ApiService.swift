//
//  ApiService.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 17.02.2021.
//

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

        let urlString = imageInfo.downloadURL

        guard let token = token else {
            completion(.failure(.noToken))
            return
        }

        let headers = [
            "Authorization": "Bearer \(token)"
        ]

        NetworkService.getRequest(urlString: urlString, headers: headers) { result in
            switch result {
            case .success(let data):
                let imageData = ImageData(name: imageInfo.name, data: data, sha: imageInfo.sha)
                completion(.success(imageData))
            case .failure(let error):
                completion(.failure(.networkError(error)))
            }

        }
    }

    public func getImagesInfo(completion: @escaping (Result<[ImageInfo], NetworkError>) -> Void) {

        guard let token = token else {
            completion(.failure(.noToken))
            return
        }

        guard let urlString =
                Bundle.main.infoDictionary?["REPO_URL"] as? String else {

            completion(.failure(.badUrl))
            return
        }

        let headers: [String: String] = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
        ]

        NetworkService.getRequest(urlString: urlString, headers: headers) { result in
            switch result {
            case .success(let data):
                data.decode(type: [RepositoryContent].self) { result in
                    switch result {
                    case .success(let contents):

                        let supportedImageFormats = [
                            "tiff",
                            "jpg", "jpeg",
                            "gif",
                            "bmp",
                            "ico",
                            "cur",
                            "xbm",
                            "png"
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
                            return ImageInfo(name: content.name, downloadURL: downloadURL, sha: content.sha)
                        }

                        completion(.success(imageData))
                    case .failure(let error):
                        completion(.failure(.networkError(error)))
                    }
                }
            case .failure(let error):
                completion(.failure(.networkError(error)))
            }
        }
    }
}
