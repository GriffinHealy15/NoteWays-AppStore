//
//  Items+CoreDataProperties.swift
//  NoteStack
//
//  Created by Griffin Healy on 3/30/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//
//

import Foundation
import CoreData

extension Items {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Items> {
        return NSFetchRequest<Items>(entityName: "Items")
    }

    @NSManaged public var date: Date?
    @NSManaged public var itemName: String
    @NSManaged public var remindMe: Bool
    @NSManaged public var dueDate: Date?
    @NSManaged public var itemChecked: Bool
    @NSManaged public var itemsChecklist: ChecklistsGroup?

}
