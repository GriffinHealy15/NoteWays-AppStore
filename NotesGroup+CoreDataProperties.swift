//
//  NotesGroup+CoreDataProperties.swift
//  NoteStack
//
//  Created by Griffin Healy on 2/26/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//
//

import Foundation
import CoreData


extension NotesGroup {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotesGroup> {
        return NSFetchRequest<NotesGroup>(entityName: "NotesGroup")
    }

    @NSManaged public var groupName: String
    @NSManaged public var groupnotes: NSOrderedSet?
    @NSManaged var date: Date

}

// MARK: Generated accessors for notes
extension NotesGroup {

    @objc(insertObject:inNotesAtIndex:)
    @NSManaged public func insertIntoNotes(_ value: Notes, at idx: Int)

    @objc(removeObjectFromNotesAtIndex:)
    @NSManaged public func removeFromNotes(at idx: Int)

    @objc(insertNotes:atIndexes:)
    @NSManaged public func insertIntoNotes(_ values: [Notes], at indexes: NSIndexSet)

    @objc(removeNotesAtIndexes:)
    @NSManaged public func removeFromNotes(at indexes: NSIndexSet)

    @objc(replaceObjectInNotesAtIndex:withObject:)
    @NSManaged public func replaceNotes(at idx: Int, with value: Notes)

    @objc(replaceNotesAtIndexes:withNotes:)
    @NSManaged public func replaceNotes(at indexes: NSIndexSet, with values: [Notes])

    @objc(addNotesObject:)
    @NSManaged public func addToNotes(_ value: Notes)

    @objc(removeNotesObject:)
    @NSManaged public func removeFromNotes(_ value: Notes)

    @objc(addNotes:)
    @NSManaged public func addToNotes(_ values: NSOrderedSet)

    @objc(removeNotes:)
    @NSManaged public func removeFromNotes(_ values: NSOrderedSet)

}

