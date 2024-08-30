//
//  CDPost+CoreDataClass.swift
//  
//
//  Created by Kartik Gupta on 28/08/24.
//
//

import Foundation
import CoreData

@objc(CDPost)
public class CDPost: NSManagedObject {
    
    static func getNewObject() -> CDPost {
        return newObjectEntity(in: CoreDataManager.manager.manageObjectcontext) as CDPost
    }
    
    func savePostInCD(post: Post) {
        self.id = Int64(post.id)
        self.userId = Int64(post.userId)
        self.title = post.title
        self.body = post.body
        self.isFavourite = false
        
        CoreDataManager.manager.saveContext()
    }
    
    static func updatePostInCD(post: Post) {
        if let cdPost = getPost(from: post.id) {
            cdPost.setValue(post.userId, forKey: "userId")
            cdPost.setValue(post.title, forKey: "title")
            cdPost.setValue(post.body, forKey: "body")
        } else {
            let cdPost = CDPost.getNewObject()
            cdPost.savePostInCD(post: post)
        }
    }
    
    static func updateFavouriteStatus(_ id: Int, _ isFavourite: Bool) {
        if let cdPost = getPost(from: id) {
            cdPost.setValue(isFavourite, forKey: "isFavourite")
            CoreDataManager.manager.saveContext()
        }
    }
    
    static func getPost(from id: Int) -> CDPost? {
        let fetchReq: NSFetchRequest<CDPost> = CDPost.fetchRequest()
        let context = CoreDataManager.manager.manageObjectcontext
        fetchReq.predicate = NSPredicate(format: "id == %i", id)
        do {
            let result = try context.fetch(fetchReq)
            return result.isEmpty ? nil : result[0]
        } catch {
            debugPrint(error)
        }
        return nil
    }
    
    static func getAllPostsFromCD() -> [CDPost]? {
        let fetchReq: NSFetchRequest<CDPost> = CDPost.fetchRequest()
        let context = CoreDataManager.manager.manageObjectcontext
        do {
            let result = try context.fetch(fetchReq)
            return result.isEmpty ? nil : result
        } catch {
            debugPrint(error)
        }
        return nil
    }
    
    static func getAllFavoritePost() -> [CDPost]? {
        let fetchReq: NSFetchRequest<CDPost> = CDPost.fetchRequest()
        let context = CoreDataManager.manager.manageObjectcontext
        fetchReq.predicate = NSPredicate(format: "isFavourite == %@", NSNumber(value: true))
        do {
            let result = try context.fetch(fetchReq)
            return result.isEmpty ? nil : result
        } catch {
            debugPrint(error)
        }
        return nil
    }
    
    
    
}
