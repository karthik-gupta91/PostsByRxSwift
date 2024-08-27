//
//  ApiError.swift
//  postsByRxSwift
//
//  Created by Kartik Gupta on 27/08/24.
//

import Foundation

enum ApiError: Error {
    case forbidden
    case notFound
    case conflict
    case internalServerError
}
