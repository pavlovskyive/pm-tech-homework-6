//
//  ApiService.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 17.02.2021.
//

import Alamofire
import UIKit

class ApiService {

    var token: String? {
        let kcw = KeychainWrapper()
        if let password = try? kcw.getGenericPasswordFor(
            account: "App",
            service: "accessToken") {
            return password
        }

        return nil
    }

    public func fetchImages(completion: @escaping (Result<[ImageData], Error>) -> Void) {

        guard let token = token else {
            completion(.failure(NetworkError.noToken))
            return
        }

        let headers: HTTPHeaders = [
            .authorization(bearerToken: token),
            .accept("application/json")
        ]

        getImagesInfo { result in
            switch result {
            case .success(let imageInfos):
                print(imageInfos)

                var images = [ImageData]()

                let group = DispatchGroup()

                for imageInfo in imageInfos {

                    guard let downloadURL = imageInfo.downloadURL else {
                        return
                    }

                    group.enter()

                    AF.request(downloadURL, headers: headers)
                        .response { response in
                            switch response.result {
                            case .success(let data):
                                guard let data = data else {
                                    group.leave()
                                    return
                                }
                                images.append(ImageData(name: imageInfo.name, data: data))

                            case .failure(let error):
                                print(error)
                            }
                            group.leave()
                        }

                }

                group.notify(queue: DispatchQueue.global()) {
                    completion(.success(images))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func getImagesInfo(completion: @escaping (Result<[ImageInfo], Error>) -> Void) {

        guard let token = token else {
            completion(.failure(NetworkError.noToken))
            return
        }

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
                }.map { ImageInfo(name: $0.name, downloadURL: $0.downloadURL) }

                completion(.success(imageData))
                return
            }
    }
}
