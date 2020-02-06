//
//  Functions.swift
//  MyLocations
//
//  Created by Griffin Healy on 1/24/19.
//  Copyright © 2019 Griffin Healy. All rights reserved.
//

import Foundation
func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds,execute: run)
}
// global, As before, you’re using a closure to provide the code that initializes this constant
let applicationDocumentsDirectory: URL = {
    // finds path to documents directory, and returns it to us. Global let (constant) so, applicationsDocumentDirectory can be called globally (anywhere)
    let paths = FileManager.default.urls(for: .documentDirectory,in: .userDomainMask)
                                         return paths[0]
}()

// global func to handle core data errors
let CoreDataSaveFailedNotification =
    Notification.Name(rawValue: "CoreDataSaveFailedNotification")
func fatalCoreDataError(_ error: Error) {
    // prints error, first
    print("*** Fatal error: \(error)")
    // sends notification to the center (app delegate has function which is registered with the center). The app delegate is listening for notifications
    NotificationCenter.default.post(
            name: CoreDataSaveFailedNotification, object: nil)
}
