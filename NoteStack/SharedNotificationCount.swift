//
//  SharedNotificationCount.swift
//  NoteStack
//
//  Created by Griffin Healy on 4/2/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//

import Foundation

class SharedNotificationCount {

  class func nextChecklistItemID() -> Int {
    let userDefaults = UserDefaults.standard
    let itemID = userDefaults.integer(forKey: "ChecklistItemID")
    userDefaults.set(itemID + 1, forKey: "ChecklistItemID")
    userDefaults.synchronize()
    return itemID
  }
}
