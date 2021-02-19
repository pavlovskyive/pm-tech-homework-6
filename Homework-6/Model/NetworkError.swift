//
//  Error.swift
//  Homework-6
//
//  Created by Vsevolod Pavlovskyi on 17.02.2021.
//

import Foundation

enum NetworkError: Error {
    case badStatusCode
    case noToken
    case badUrl
    case networkError(Error)
    case badData
}
