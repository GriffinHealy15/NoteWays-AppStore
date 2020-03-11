//
//  HomeController.swift
//  NoteStack
//
//  Created by Griffin Healy on 2/1/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//

import UIKit
import CoreData
import LBTATools
import AudioToolbox

class CreateNoteController: UITableViewController, CreateNoteDelegate {

    var managedObjectContext: NSManagedObjectContext!
    var NoteGroupNamePassed: String = ""
    var noteTextFieldSet = ""
    var notesArray = [String]()
    var notesPassedArray: [UIImage] = []
    var notesLocationPassedArray: [Int] = []
    let notebox = UIView(backgroundColor: .yellow)
    var noteImage: UIImage? = nil
    var onlyNoteTextPassToNoteCell = ""
    lazy var fetchedResultsController:
           NSFetchedResultsController<Notes> = {
               // set up ns fetch results to tell it that were going to fetch locations object
               let fetchRequest = NSFetchRequest<Notes>()
               let entity = Notes.entity()
               // the fetchRequest entity is  Location
               fetchRequest.entity = entity
               let sort1 = NSSortDescriptor(key: "noteText", ascending: false)
               fetchRequest.sortDescriptors = [sort1]
               fetchRequest.fetchBatchSize = 5
               let fetchedResultsController = NSFetchedResultsController(
                   fetchRequest: fetchRequest,
                   managedObjectContext: self.managedObjectContext,
                   sectionNameKeyPath: "noteText", cacheName: "Notes")
               fetchedResultsController.delegate = self
               return fetchedResultsController
       }()
    
    var soundID: SystemSoundID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .rgb(red: 242, green: 242, blue: 242)
        performFetch()
        fetchAndPrintEachNote()
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    // MARK:- Actions
    @IBAction func createNote() {
        handleCreateNote()
        loadSoundEffect("bubble.mp3")
        playSoundEffect()
    }
    
    @objc func handleCreateNote() {
        print("Creating note...")
        let noteActualController = CreateActualNoteController()
        noteActualController.managedObjectContext = managedObjectContext
        //navigationController?.pushViewController(noteActualController, animated: true)

        let navController = UINavigationController(rootViewController: noteActualController)
        present(navController, animated: true)
    }
    
    func retrievedNoteText(onlyNoteText: String, NoteGroupNamePassed: String, noteText: String, noteImage: UIImage?, noteImagesArray: [UIImage?], noteLocationsArray: [Int?]) {
        let note: Notes
        note = Notes(context: managedObjectContext)
        note.noteText = noteText
        note.notePhotoId = nil
        onlyNoteTextPassToNoteCell = onlyNoteText
        // Save image
        if noteImage != nil && noteImagesArray.count > 0 {
            if !note.hasPhoto {
                for imageInArray in 0...noteImagesArray.count - 1 {
                    note.notePhotoId = Notes.noteNextPhotoID() as NSNumber
                    note.notePhotoIdArray.append(note.notePhotoId!)
                    note.notePhotoLocation.append(noteLocationsArray[imageInArray]! as NSNumber)
                    if let data = noteImagesArray[imageInArray]!.jpegData(compressionQuality: 0.5) {
                        // 3
                        do {
                            try data.write(to: note.photoURL, options: .atomic)
                        } catch {
                            print("Error writing file: \(error)")
                        }
                    }
                }
            }
        }
        do {
           try managedObjectContext.save()
           // error handling for save()
       } catch {
           // 4
           // if save fails call below function with error message
            print("Error saving")
       }
        performFetch()
        fetchAndPrintEachNote()
        tableView.reloadData()
    }
    
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    func fetchAndPrintEachNote() {
        let fetchRequest = NSFetchRequest<Notes>(entityName: "Notes")
        do {
            let fetchedResults = try managedObjectContext!.fetch(fetchRequest)
            for item in fetchedResults {
                notesArray.append(item.value(forKey: "noteText")! as! String)
            }
        } catch let error as NSError {
            // something went wrong, print the error.
            print(error.description)
        }
//        print(notesArray)
    }
    
    // MARK:- Sound effects
    func loadSoundEffect(_ name: String) {
        if let path = Bundle.main.path(forResource: name,
                                       ofType: nil) {
            let fileURL = URL(fileURLWithPath: path, isDirectory: false)
            let error = AudioServicesCreateSystemSoundID(
                fileURL as CFURL, &soundID)
            if error != kAudioServicesNoError {
                print("Error code \(error) loading sound: \(path)")
            }
        } }
    func unloadSoundEffect() {
        AudioServicesDisposeSystemSoundID(soundID)
        soundID = 0 }
    func playSoundEffect() {
        AudioServicesPlaySystemSound(soundID)
    }
    
    
    // MARK: - Table View Delegates
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        // ask fetchResultsController for number of sections, and for all sections, we find the number of objects in the section
        let sectionInfo = fetchedResultsController.sections![section]
        print("Number of objects regular \(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
    }
    // tableView asks controller for a cell for each of the rows
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "NoteCell",
                for: indexPath) as! NoteCell
            // ask fetch results for the location object at indexPath i, then return that object
            let note = fetchedResultsController.object(at: indexPath)
            // print("Location: \(location)\n")
            // configure cell for the location object
            
            cell.configure(for: note)
            return cell }
    
    // enable swipe to delete, delete rows of objects that are no longer in the data store
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // get location object from row index selected
            let note = fetchedResultsController.object(at: indexPath)
            // call remove photo file to remove the photo for this location object. removePhotoFile() uses the ID of this specific location object (selected index in row, then we found this object). Then the removePhotoFile() uses the id and finds corresponding location object url. The url is then pointed to and removed
            // tell context to delete that object
            //  This will trigger the NSFetchedResultsController to send a notification to the delegate, which then removes the corresponding row from the table
              note.removePhotoFile()
              managedObjectContext.delete(note)
            do {
              try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        loadSoundEffect("select.mp3")
        playSoundEffect()
        notesPassedArray = []
        notesLocationPassedArray = []
        let noteTextToEdit = fetchedResultsController.object(at: indexPath).noteText
        let note = fetchedResultsController.object(at: indexPath)
        if note.hasPhoto {
            if let theNoteImage = note.photoImage {
                noteImage = theNoteImage
                let noteIdArray = fetchedResultsController.object(at: indexPath).notePhotoIdArray
                let noteLocationArray = fetchedResultsController.object(at: indexPath).notePhotoLocation
                for i in 0...noteIdArray.count - 1 {
                    note.notePhotoId = noteIdArray[i]
                    notesPassedArray.append(note.photoImage!)
                    notesLocationPassedArray.append(noteLocationArray[i] as! Int)
                }
            }
        }
        else {
                noteImage = nil
        }
        let editNoteModal = EditNoteModalController(passednoteText: noteTextToEdit, passedImage: noteImage, passedNotesArray: notesPassedArray, passedLocationsArray: notesLocationPassedArray)
        editNoteModal.noteToEdit = note
        editNoteModal.managedObjectContext = managedObjectContext
        let navEditNoteController = UINavigationController(rootViewController: editNoteModal)
        present(navEditNoteController, animated: true)
    }
    
    // find the number of sections
    override func numberOfSections(in tableView: UITableView)
        -> Int {
            //print("Sections: \(fetchedResultsController.sections!)")
            return fetchedResultsController.sections!.count
    }
    // add a title with the section name for each section
//    override func tableView(_ tableView: UITableView,
//                            titleForHeaderInSection section: Int) -> String? {
//        let sectionInfo = fetchedResultsController.sections![section]
//        //print("Section Info: \(sectionInfo.name)")
//        return sectionInfo.name.uppercased() // fetchResultsController has attriute name which we save a name key in the initializing of fetchedResultsController
//    }
    // This method gets called once for each section in the table view. Here, you create a label for the section name, a 1-pixel high view that functions as a separator line, and a container view to hold these two subviews.
    // replace headers with a view of our own
//    override func tableView(_ tableView: UITableView,
//                            viewForHeaderInSection section: Int) -> UIView? {
//        let labelRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 14,
//                               width: 300, height: 14)
//        let label = UILabel(frame: labelRect)
//        label.font = UIFont.boldSystemFont(ofSize: 15)
//        // ask the tableView's dataSource (which is this view controller LocationsViewController) for the text for each section, to put in the header were creating
//        label.text = tableView.dataSource!.tableView!(
//            tableView, titleForHeaderInSection: section)
//        label.textColor = UIColor(white: 1.0, alpha: 0.6)
//        label.backgroundColor = UIColor.clear
//        let separatorRect = CGRect(
//            x: 15, y: tableView.sectionHeaderHeight - 0.5,
//            width: tableView.bounds.size.width - 15, height: 0.5)
//        let separator = UIView(frame: separatorRect)
//        separator.backgroundColor = tableView.separatorColor
//        let viewRect = CGRect(x: 0, y: 0,
//                              width: tableView.bounds.size.width,
//                              height: tableView.sectionHeaderHeight)
//        // create a container view to hold the label and the seperator. Add the two views to the container
//        let view = UIView(frame: viewRect)
//        view.backgroundColor = UIColor(white: 0, alpha: 0.85)
//        view.addSubview(label)
//        view.addSubview(separator)
//        return view
//    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK:- NSFetchedResultsController Delegate Extension
extension CreateNoteController:
NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    func controller(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (object)")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            print("*** NSFetchedResultsChangeDelete (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            print("*** NSFetchedResultsChangeUpdate (object)")
        if let cell = tableView.cellForRow(at: indexPath!)
            as? LocationCell {
            let location = controller.object(at: indexPath!)
                as! Location
            cell.configure(for: location)
            }
        case .move:
            print("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        @unknown default:
            fatalError()
        } }
    func controller(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (section)")
            tableView.insertSections(IndexSet(integer: sectionIndex),
                                     with: .fade)
        case .delete:
            print("*** NSFetchedResultsChangeDelete (section)")
            tableView.deleteSections(IndexSet(integer: sectionIndex),
                                     with: .fade)
        case .update:
            print("*** NSFetchedResultsChangeUpdate (section)")
        case .move:
            print("*** NSFetchedResultsChangeMove (section)")
        @unknown default:
            fatalError()
        }
    }
    func controllerDidChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
}




