//
//  NSManagedObject+Extension.swift
//  postsByRxSwift
//
//  Created by Kartik Gupta on 28/08/24.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    static func newObjectEntity<T : NSManagedObject>(in context : NSManagedObjectContext) -> T {
        let entityName = String(describing: T.self)
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! T
    }
    
    func toDict(isRelationshipMet : Bool = true, parentEntity: NSEntityDescription? = nil) -> [String:Any] {
        var keys = Array(entity.attributesByName.keys) + (isRelationshipMet ? Array(entity.relationshipsByName.keys) : [])
        if let parent = parentEntity {
            for related in entity.relationships(forDestination: parent) {
                if keys.contains(related.name) {
                    keys = keys.filter { $0 != related.name }
                }
            }
        }
        
        var dict = dictionaryWithValues(forKeys: keys)
        for (key , value) in dict
        {
            if let objects = value as? NSSet
            {
                let parsedDictArray = objects.compactMap { (object : Any) -> Any? in
                    return (object as? NSManagedObject)?.toDict(parentEntity: self.entity)
                }
                dict[key] = parsedDictArray
            } else if value is NSManagedObject {
                dict[key] = (value as! NSManagedObject).toDict(parentEntity: self.entity)
            }
        }
        return dict
    }
    
    static func deleteObject(in context: NSManagedObjectContext, predicateID: [String]? = nil, predicateValue: [String]? = nil) {
        typealias T = NSManagedObject
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: self))
        fetchRequest.includesPropertyValues = false // Only fetch the managedObjectID (not the full object structure)
        if let predicateID = predicateID, let predicateValue = predicateValue {
            for i in 0..<predicateID.count {
                fetchRequest.predicate = NSPredicate(format: "\(predicateID[i]) = %@", predicateValue[i])
            }
        }
        
        do {
            let fetchResults = try context.fetch(fetchRequest)
            for result in fetchResults {
                context.delete(result)
            }
        } catch  {
            
        }
    }
}
