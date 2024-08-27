//
//  PostModel.swift
//  postsByRxSwift
//
//  Created by Kartik Gupta on 26/08/24.
//

import Foundation

// MARK: - Post
struct Post: Codable {
    let userId, id: Int
    let title, body: String

    enum CodingKeys: String, CodingKey {
        case userId, id, title, body
    }
}

typealias Posts = [Post]
