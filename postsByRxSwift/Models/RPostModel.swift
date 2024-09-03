//
//  RPostModel.swift
//  postsByRxSwift
//
//  Created by Kartik Gupta on 03/09/24.
//

import Foundation
import RealmSwift

class RPost: Object, Codable {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var userId: Int
    @Persisted var title: String
    @Persisted var body: String
    @Persisted var isFavourite: Bool
    
    
    // MARK: Codable support
    enum CodingKeys: String, CodingKey {
        case userId, title
        case id
        case body, isFavourite
    }
    
    convenience required init(from decoder: any Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(Int.self, forKey: .userId)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.body = try container.decode(String.self, forKey: .body)
        self.isFavourite = try container.decodeIfPresent(Bool.self, forKey: .isFavourite) ?? false
    }
    
}
