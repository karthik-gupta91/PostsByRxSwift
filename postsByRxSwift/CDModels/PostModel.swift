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
    let isFavourite: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case userId, id, title, body, isFavourite
    }
}

typealias Posts = [Post]
