//
//  CDPost+CoreDataProperties.swift
//  
//
//  Created by Kartik Gupta on 28/08/24.
//
//

import Foundation
import CoreData


extension CDPost {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDPost> {
        return NSFetchRequest<CDPost>(entityName: "CDPost")
    }

    @NSManaged public var userId: Int64
    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var body: String?
    @NSManaged public var isFavourite: Bool

}
