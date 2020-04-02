//
//  ChecklistsGroup+CoreDataProperties.swift
//  NoteStack
//
//  Created by Griffin Healy on 3/30/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//
//

import Foundation
import CoreData


extension ChecklistsGroup {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChecklistsGroup> {
        return NSFetchRequest<ChecklistsGroup>(entityName: "ChecklistsGroup")
    }

    @NSManaged public var checklistName: String
    @NSManaged public var date: Date?
    @NSManaged public var checklistIcon: String?
    @NSManaged public var checklistitems: NSOrderedSet?

}
