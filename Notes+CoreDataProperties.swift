//
//  Notes+CoreDataProperties.swift
//  NoteStack
//
//  Created by Griffin Healy on 2/4/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//
//

import Foundation
import CoreData


extension Notes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Notes> {
        return NSFetchRequest<Notes>(entityName: "Notes")
    }

    @NSManaged public var noteText: String
    @NSManaged public var noteColorArray: [NSNumber]
    @NSManaged public var notePhotoId: NSNumber? // int 32, but NSNUmber is how objc handles numbers
    @NSManaged public var notePhotoIdArray: [NSNumber]
    @NSManaged public var notePhotoLocation: [NSNumber]
    @NSManaged public var notesgroup: NotesGroup?
    @NSManaged var date: Date
    
}
