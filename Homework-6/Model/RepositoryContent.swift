//
//  RepositoryContent.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 16.02.2021.
//

import Foundation

// MARK: - RepositoryContent

struct RepositoryContent: Codable {
    let type: String
    let name: String
    let downloadURL: String?

    enum CodingKeys: String, CodingKey {
        case type, name
        case downloadURL = "download_url"
    }
}
