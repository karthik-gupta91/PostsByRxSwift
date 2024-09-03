//
//  DatabaseManager.swift
//  postsByRxSwift
//
//  Created by Kartik Gupta on 03/09/24.
//

import Foundation
import RealmSwift

class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let realm = try! Realm()
    
    func savePostInRealm(_ post: RPost) {
        try! realm.write {
            realm.add(post, update: .modified)
        }
    }
    
    func getPost(from id: Int) -> RPost? {
        let predicate = NSPredicate(format: "id = %i", id)
        let result = realm.objects(RPost.self).filter(predicate)
        guard result.count > 0 else {return nil}
        return result[0]
    }

    func getAllPostsFromRealm() -> Results<RPost>? {
        let result = realm.objects(RPost.self)
        guard result.count > 0 else {return nil}
        return result
    }
    
    func getAllFavoritePost() -> Results<RPost>? {
        let predicate = NSPredicate(format: "isFavourite == %@", NSNumber(value: true))
        let result = realm.objects(RPost.self).filter(predicate)
        guard result.count > 0 else {return nil}
        return result
    }
    
    func updateFavouriteStatus(_ id: Int, _ isFavourite: Bool) {
        if let post = getPost(from: id) {
            try! realm.write {
                post.isFavourite = isFavourite
            }
        }
    }
    
}
