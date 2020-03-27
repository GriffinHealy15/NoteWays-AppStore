//
//  CreateNoteGroupController.swift
//  NoteStack
//
//  Created by Griffin Healy on 2/25/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//
//
import UIKit
import CoreData
import LBTATools
import AudioToolbox

class CreateNoteGroupController: UITableViewController, UIPopoverPresentationControllerDelegate, CreateNoteGroupDelegate,
NoteRefreshProtocol{
    
    var managedObjectContext: NSManagedObjectContext!
    var notesGroupArray = [String]()
    var notesgroup: NotesGroup?
    lazy var fetchedResultsController:
           NSFetchedResultsController<NotesGroup> = {
               // set up ns fetch results to tell it that were going to fetch locations object
               let fetchRequest = NSFetchRequest<NotesGroup>()
//            fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(NotesGroup.groupName),
//            dogName)
               let entity = NotesGroup.entity()
               // the fetchRequest entity is  Location
               fetchRequest.entity = entity
               let sort1 = NSSortDescriptor(key: "date", ascending: false)
               fetchRequest.sortDescriptors = [sort1]
               fetchRequest.fetchBatchSize = 5
               let fetchedResultsController = NSFetchedResultsController(
                   fetchRequest: fetchRequest,
                   managedObjectContext: self.managedObjectContext,
                   sectionNameKeyPath: "groupName", cacheName: "NotesGroup")
               fetchedResultsController.delegate = self
               return fetchedResultsController
       }()

    var soundID: SystemSoundID = 0
    
    var date = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .rgb(red: 242, green: 242, blue: 242)
        tableView.backgroundColor = .white
        performFetch()
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem?.tintColor = .rgb(red: 0, green: 151, blue: 248)
        navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    func retrievedGroupName(groupNameText: String) {
          notesgroup = NotesGroup(context: managedObjectContext)
          notesgroup!.groupName = groupNameText
          notesgroup?.date = date
        
        do {
            try managedObjectContext.save()
            // error handling for save()
        } catch {
            // 4
            // if save fails call below function with error message
             print("Error saving")
        }
         performFetch()
         tableView.reloadData()
      }
    
        func fetchAndPrintEachNoteGroup() {
            let fetchRequest = NSFetchRequest<NotesGroup>(entityName: "NotesGroup")
            do {
                let fetchedResults = try managedObjectContext!.fetch(fetchRequest)
                for item in fetchedResults {
                    notesGroupArray.append(item.value(forKey: "groupName")! as! String)
                }
            } catch let error as NSError {
                // something went wrong, print the error.
                print(error.description)
            }
//            print(notesGroupArray)
        }


    // MARK:- Actions
    @IBAction func createNoteGroup() {
        print("Create Notes Group")
        //loadSoundEffect("bubble.mp3")
        //playSoundEffect()
        
        let vc = GroupNameController()
        vc.managedObjectContext = managedObjectContext
        vc.preferredContentSize = CGSize(width: 275, height: 260)
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.delegate = self
        vc.createGroupNameContrll = self
        let ppc = vc.popoverPresentationController
        ppc?.permittedArrowDirections = .init(rawValue: 0)
        ppc?.delegate = self
        ppc!.sourceView = self.view
        ppc?.passthroughViews = nil
        ppc?.sourceRect =  CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY - 80, width: 0, height: 0)
        present(vc, animated: true)
        }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
           return .none
       }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return false
    }

    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
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
    
    func refreshGroupCount() {
        self.tableView.reloadData()
    }

    func fetchGroup(NoteGroupNamePassed: String) -> Int {
        var totalCount = 0
        let fetchGroupRequest = NSFetchRequest<NotesGroup>(entityName: "NotesGroup")
        fetchGroupRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(NotesGroup.groupName),
        NoteGroupNamePassed)
        do {
          let results = try managedObjectContext.fetch(fetchGroupRequest) // do the actual fetch
          if results.count > 0 {
            let results1 = results.first
            let currentNotes = results1?.groupnotes
            totalCount = currentNotes?.count ?? 0
          }
        } catch let error as NSError {
          print("Fetch error: \(error) description: \(error.userInfo)")
        }
        return totalCount
    }
    
    func handleConfirmPressed(indexPath:IndexPath) -> (_ alertAction:UIAlertAction) -> () {
        return { alertAction in
            print("Delete Item")
            let notegroup = self.fetchedResultsController.object(at: indexPath)
            self.managedObjectContext.delete(notegroup)
            do {
                try self.managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
        }
    }
    // MARK: - Table View Delegates

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        // ask fetchResultsController for number of sections, and for all sections, we find the number of objects in the section
        let sectionInfo = fetchedResultsController.sections![section]
        //print("Number of objects \(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
    }
    // tableView asks controller for a cell for each of the rows
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "NoteGroupCell",
                for: indexPath) as! NoteGroupCell
            // ask fetch results for the location object at indexPath i, then return that object
            let notegroup = fetchedResultsController.object(at: indexPath)
            let totalNotes = fetchGroup(NoteGroupNamePassed: notegroup.groupName)
            // print("Location: \(location)\n")
            // configure cell for the location object
            cell.configure(for: notegroup, count: totalNotes)
            
            // the following code increases cell border only on specified borders
            let bottom_border = CALayer()
            let bottom_padding = CGFloat(5.0)
            bottom_border.borderColor = UIColor.white.cgColor
            bottom_border.frame = CGRect(x: 0, y: cell.frame.size.height - bottom_padding, width:  cell.frame.size.width, height: cell.frame.size.height)
            bottom_border.borderWidth = bottom_padding

            let right_border = CALayer()
            let right_padding = CGFloat(15.0)
            right_border.borderColor = UIColor.white.cgColor
            right_border.frame = CGRect(x: cell.frame.size.width - right_padding, y: 0, width: right_padding, height: cell.frame.size.height)
            right_border.borderWidth = right_padding

            let left_border = CALayer()
            let left_padding = CGFloat(15.0)
            left_border.borderColor = UIColor.white.cgColor
            left_border.frame = CGRect(x: 0, y: 0, width: left_padding, height: cell.frame.size.height)
            left_border.borderWidth = left_padding

            let top_border = CALayer()
            let top_padding = CGFloat(3.0)
            top_border.borderColor = UIColor.white.cgColor
            top_border.frame = CGRect(x: 0, y: 0, width: cell.frame.size.width, height: top_padding)
            top_border.borderWidth = top_padding
            
            let border_Around_Bordered_Cell = CALayer()
            border_Around_Bordered_Cell.frame = CGRect(x: 15, y: 3, width: cell.frame.size.width - 30, height: cell.frame.size.height - 8)
            border_Around_Bordered_Cell.borderWidth = 0.7
            border_Around_Bordered_Cell.borderColor = UIColor.rgb(red: 220, green: 220, blue: 220).cgColor
            border_Around_Bordered_Cell.cornerRadius = 15
            
            cell.layer.addSublayer(border_Around_Bordered_Cell)
            cell.layer.addSublayer(bottom_border)
            cell.layer.addSublayer(right_border)
            cell.layer.addSublayer(left_border)
            cell.layer.addSublayer(top_border)
            
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            
            return cell }

    // enable swipe to delete, delete rows of objects that are no longer in the data store
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Delete Group", message: "Are you sure you want to delete this group?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: handleConfirmPressed(indexPath: indexPath)))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            // get note group object from row index selected
//            let notegroup = fetchedResultsController.object(at: indexPath)
//              managedObjectContext.delete(notegroup)
//            do {
//              try managedObjectContext.save()
//            } catch {
//                fatalCoreDataError(error)
//            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //loadSoundEffect("navtap.mp3")
        //playSoundEffect()
        let noteGroupNotes = fetchedResultsController.object(at: indexPath)
        let storyboard_main = UIStoryboard(name: "Main", bundle: Bundle.main)
        let createNoteContrll = storyboard_main.instantiateViewController(withIdentifier: "CreateNoteControllerSingle") as! CreateNoteControllerSingle
        createNoteContrll.NoteGroupNamePassed = noteGroupNotes.groupName
        createNoteContrll.managedObjectContext = managedObjectContext
        createNoteContrll.singleGroupController = self
        navigationController?.pushViewController(createNoteContrll, animated: true)
    }

    // find the number of sections
    override func numberOfSections(in tableView: UITableView)
        -> Int {
            //print("Sections: \(fetchedResultsController.sections!)")
            return fetchedResultsController.sections!.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}

// MARK:- NSFetchedResultsController Delegate Extension
extension CreateNoteGroupController:
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



