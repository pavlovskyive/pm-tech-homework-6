//
//  RepositoryContent.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 16.02.2021.
//

import Foundation

struct RepositoryContent: Codable {
    let type: String
    let name: String
    let sha: String
    let downloadURL: String?

    enum CodingKeys: String, CodingKey {
        case type, name, sha
        case downloadURL = "download_url"
    }
}
