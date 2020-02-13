//
//  Notes+CoreDataClass.swift
//  NoteStack
//
//  Created by Griffin Healy on 2/4/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

@objc(Notes)
public class Notes: NSManagedObject {

    // determines if location object has a photo associated with it
    var hasPhoto: Bool {
        return notePhotoId != nil // if photoID is true (has value), then return hasPhoto to be true
    }
    // call photoURL if photoID exists for the location object
    var photoURL: URL {
        assert(notePhotoId != nil, "No photo ID set") // assert used to make sure photoID is true
        // computes full url for the jpg file using the photo-ID (ID is passed here)
        let filename = "Photo-\(notePhotoId!.intValue).jpg"
        // find documents directory with the appending filename (i.e documents/Photo-123.jpg
        return applicationDocumentsDirectory.appendingPathComponent(filename)
    }
    // return ui image if the the photoURl brings back an actual path. It goes to photo url path, and brings back the contents (the photo itself). Then we set UIImage var object instance as that photo retieved from the file system (path in the documents folder)
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoURL.path)
    }
    // class func so we can call this from anywhere, location object isn't needed to call this
    // userDefaults used to save id, so we can increment id + 1 for next time
    class func noteNextPhotoID() -> Int {
        let userDefaults = UserDefaults.standard
        // create user default with key PhotoID, value is currentID + 1
        let currentID = userDefaults.integer(forKey: "PhotoID") + 1
        // set the new value
        userDefaults.set(currentID, forKey: "PhotoID")
        userDefaults.synchronize()
        return currentID
    }
    // remove the photo (image) from the filemanager. The photo is removed from the at: photoURL (the place where this specific location object was saved) i.e.
    func removePhotoFile() {
        if hasPhoto {
            do {
                // remove the file at location photoURL.
                try FileManager.default.removeItem(at: photoURL)
                print("removed ")
            } catch {
                print("Error removing file: \(error)")
            }
        } }
}
