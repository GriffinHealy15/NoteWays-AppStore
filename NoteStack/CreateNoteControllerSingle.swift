//
//  CreateNoteControllerSingle.swift
//  NoteStack
//
//  Created by Griffin Healy on 2/26/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//

import UIKit
import CoreData
import LBTATools
import AudioToolbox

protocol NoteRefreshProtocol {
    func refreshGroupCount()
}


class CreateNoteControllerSingle: UITableViewController, CreateNoteDelegate, EditNoteDelegate {
    
    var managedObjectContext: NSManagedObjectContext!
    var NoteGroupNamePassed: String = ""
    var noteTextFieldSet = ""
    var notesArray = [String]()
    var notesPassedArray: [UIImage] = []
    var notesLocationPassedArray: [Int] = []
    let notebox = UIView(backgroundColor: .yellow)
    var noteImage: UIImage? = nil
    var currentNotesGroup: NotesGroup?
    var currentNotes: [Any]?
    var noteGroupPassedAgain: String = ""
    var onlyNoteTextPassToNoteCell = ""
    var singleGroupController = CreateNoteGroupController()
    
    lazy var fetchedResultsController1:
        NSFetchedResultsController<NotesGroup> = {
            // set up ns fetch results to tell it that were going to fetch locations object
            let fetchRequest = NSFetchRequest<NotesGroup>()
            fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(NotesGroup.groupName),
            NoteGroupNamePassed)
            let entity = NotesGroup.entity()
            // the fetchRequest entity is  Location
            fetchRequest.entity = entity
            let sort1 = NSSortDescriptor(key: "groupName", ascending: false)
            fetchRequest.sortDescriptors = [sort1]
            fetchRequest.fetchBatchSize = 5
            let fetchedResultsController1 = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: self.managedObjectContext,
                sectionNameKeyPath: "groupName", cacheName: "NotesGroup")
            //fetchedResultsController1.delegate = self
            return fetchedResultsController1
    }()
    
    var soundID: SystemSoundID = 0
    
    // delegate var for the protocol above
    var delegate: NoteRefreshProtocol?
    
   
    @IBOutlet weak var tableViewSource: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .rgb(red: 242, green: 242, blue: 242)
        tableView.backgroundColor = .white
        performFetch()
        //fetchAndPrintEachNote()
        fetchGroup()
        title = ("\(NoteGroupNamePassed) Notes")
        navigationItem.leftBarButtonItems = [UIBarButtonItem(image: #imageLiteral(resourceName: "backbutton"), style: .plain, target: self, action: #selector(backToGroup)), editButtonItem]
        navigationItem.leftBarButtonItems![1].tintColor = .rgb(red: 0, green: 151, blue: 248)
        tableView.delegate = self
        navigationItem.leftBarButtonItems![0].tintColor =  .black
        //navigationItem.rightBarButtonItem?.tintColor = .rgb(red: 3, green: 254, blue: 147)
    }
    
    // MARK:- Actions
    @objc func backToGroup() {
        let createNoteGroupController = singleGroupController
        createNoteGroupController.managedObjectContext = managedObjectContext
        self.delegate = createNoteGroupController
        delegate?.refreshGroupCount()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createNote() {
        handleCreateNote()
        loadSoundEffect("bubble.mp3")
        playSoundEffect()
    }
    
    @objc func handleCreateNote() {
        print("Creating note...")
        let noteActualController = CreateActualNoteController()
        noteActualController.managedObjectContext = managedObjectContext
        noteActualController.NoteGroupNamePassed = NoteGroupNamePassed
        noteActualController.singleController = self
        //navigationController?.pushViewController(noteActualController, animated: true)

        let navController = UINavigationController(rootViewController: noteActualController)
        present(navController, animated: true)
    }
    
    func retrievedEditNoteText(NoteGroupNamePassed: String) {
        let fetchGroupRequest = NSFetchRequest<NotesGroup>(entityName: "NotesGroup")
        fetchGroupRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(NotesGroup.groupName),
        NoteGroupNamePassed)
        do {
          let results = try managedObjectContext.fetch(fetchGroupRequest) // do the actual fetch
          if results.count > 0 {
            currentNotesGroup = results.first
            let sortByDate = NSSortDescriptor(key: "date", ascending: false)
            currentNotes = currentNotesGroup?.groupnotes?.sortedArray(using: [sortByDate])
            //print(currentNotes)
          }
        } catch let error as NSError {
          print("Fetch error: \(error) description: \(error.userInfo)")
        }
        // reload the tableView
        self.tableView.reloadData()
    }
    
    func retrievedNoteText(onlyNoteText: String, NoteGroupNamePassed: String, noteText: String, noteImage: UIImage?, noteImagesArray: [UIImage?], noteLocationsArray: [Int?]) {
        onlyNoteTextPassToNoteCell = onlyNoteText
        let fetchGroupRequest = NSFetchRequest<NotesGroup>(entityName: "NotesGroup")
        fetchGroupRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(NotesGroup.groupName),
        NoteGroupNamePassed)
        do {
          let results = try managedObjectContext.fetch(fetchGroupRequest) // do the actual fetch
          if results.count > 0 {
            currentNotesGroup = results.first
            let sortByDate = NSSortDescriptor(key: "date", ascending: false)
            currentNotes = currentNotesGroup?.groupnotes?.sortedArray(using: [sortByDate])
            //print(currentNotes)
          }
        } catch let error as NSError {
          print("Fetch error: \(error) description: \(error.userInfo)")
        }
        //let trimmedString = onlyNoteText.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        //print(trimmedString)
        // reload the tableView
        self.tableView.reloadData()

    }
    
    func performFetch() {
        do {
            try fetchedResultsController1.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    func fetchGroup() {
        let fetchGroupRequest = NSFetchRequest<NotesGroup>(entityName: "NotesGroup")
        fetchGroupRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(NotesGroup.groupName),
        NoteGroupNamePassed)
        do {
          let results = try managedObjectContext.fetch(fetchGroupRequest) // do the actual fetch
          if results.count > 0 {
            currentNotesGroup = results.first
            let sortByDate = NSSortDescriptor(key: "date", ascending: false)
            currentNotes = currentNotesGroup?.groupnotes?.sortedArray(using: [sortByDate])
          }
        } catch let error as NSError {
          print("Fetch error: \(error) description: \(error.userInfo)")
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
        //let sectionInfo = fetchedResultsController1.sections![section]
        //fetchGroup()
        return currentNotesGroup?.groupnotes?.count ?? 0
    }

    // tableView asks controller for a cell for each of the rows
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
            //fetchGroup()
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "NoteCell_ForGroup",
                for: indexPath) as! NoteCell_ForGroup
            //let note = currentNotesGroup?.groupnotes?[indexPath.row] as? Notes
            let note = currentNotes?[indexPath.row] as? Notes
            // configure cell for the location object
            //cell.onlyNoteText = onlyNoteTextPassToNoteCell
            cell.configure(for: note!)
            return cell
    }

    // enable swipe to delete, delete rows of objects that are no longer in the data store
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // get location object from row index selected
            //let note = fetchedResultsController1.object(at: indexPath)
            guard let note = currentNotes?[indexPath.row] as? Notes, editingStyle == .delete else {
                return
            }
            // call remove photo file to remove the photo for this location object. removePhotoFile() uses the ID of this specific location object (selected index in row, then we found this object). Then the removePhotoFile() uses the id and finds corresponding location object url. The url is then pointed to and removed
            // tell context to delete that object
            //  This will trigger the NSFetchedResultsController to send a notification to the delegate, which then removes the corresponding row from the table
              note.removePhotoFile()
              managedObjectContext.delete(note)
            do {
              try managedObjectContext.save()
                
              tableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                fatalCoreDataError(error)
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           loadSoundEffect("navtap.mp3")
           playSoundEffect()
           notesPassedArray = []
           notesLocationPassedArray = []
           //let noteTextToEdit = fetchedResultsController.object(at: indexPath).noteText

           //let note = fetchedResultsController.object(at: indexPath)
        
            let note = currentNotes?[indexPath.row] as? Notes
            let noteTextToEdit = note?.noteText
        
        if note!.hasPhoto {
            if let theNoteImage = note?.photoImage {
                   noteImage = theNoteImage
                let noteIdArray = note?.notePhotoIdArray
                let noteLocationArray = note?.notePhotoLocation
                for i in 0...noteIdArray!.count - 1 {
                    note!.notePhotoId = noteIdArray![i]
                    notesPassedArray.append((note?.photoImage!)!)
                    notesLocationPassedArray.append(noteLocationArray![i] as! Int)
                   }
               }
           }
           else {
                   noteImage = nil
           }
        let editNoteModal = EditNoteModalController(passednoteText: noteTextToEdit!, passedImage: noteImage, passedNotesArray: notesPassedArray, passedLocationsArray: notesLocationPassedArray)
           editNoteModal.noteToEdit = note
           editNoteModal.NoteGroupNamePassed = NoteGroupNamePassed
           editNoteModal.managedObjectContext = managedObjectContext
           editNoteModal.singleController = self
//           let navEditNoteController = UINavigationController(rootViewController: editNoteModal)
//           present(navEditNoteController, animated: true)
//
        // hide tab bar
        self.tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(editNoteModal, animated: true)
        fetchGroup()
        //print("reloaded")
       }
       

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}


