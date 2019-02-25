//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by Griffin Healy on 1/25/19.
//  Copyright © 2019 Griffin Healy. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import AudioToolbox

// LocationsViewController is the controller, linked, in charge of storyboard scene with custom class LocationsViewController
class LocationsViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext!
    
    // closure
    // The fetched results controller keeps an eye on any changes that you make to the data store and notifies its delegate in response
    lazy var fetchedResultsController:
        NSFetchedResultsController<Location> = {
            // set up ns fetch results to tell it that were going to fetch locations object
            let fetchRequest = NSFetchRequest<Location>()
            let entity = Location.entity()
            // the fetchRequest entity is  Location
            fetchRequest.entity = entity
            // way that were sorting, first by category then inside each category we sort by date
            let sort1 = NSSortDescriptor(key: "category", ascending: true)
            let sort2 = NSSortDescriptor(key: "date", ascending: true)
            fetchRequest.sortDescriptors = [sort1, sort2]
            fetchRequest.fetchBatchSize = 20
            let fetchedResultsController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: self.managedObjectContext,
                // fetched results controller will group the search results based on the value of the category attribute
                sectionNameKeyPath: "category", cacheName: "Locations") // sectionNameKeyPath = name
            fetchedResultsController.delegate = self
            return fetchedResultsController
    }()
    
    var soundID: SystemSoundID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performFetch()
        navigationItem.rightBarButtonItem = editButtonItem
        loadSoundEffect("Click.wav")
    }
    // MARK:- Helper methods
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    deinit {
        fetchedResultsController.delegate = nil
    }
    
    
    // MARK: - Table View Delegates
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        // ask fetchResultsController for number of sections, and for all sections, we find the number of objects in the section
        let sectionInfo = fetchedResultsController.sections![section]
        // print("Number of objects \(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
    }
    // tableView asks controller for a cell for each of the rows
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "LocationCell",
                for: indexPath) as! LocationCell
            // ask fetch results for the location object at indexPath i, then return that object
            let location = fetchedResultsController.object(at: indexPath)
            // print("Location: \(location)\n")
            // configure cell for the location object
            cell.configure(for: location)
            return cell }
    
    // enable swipe to delete, delete rows of objects that are no longer in the data store
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // get location object from row index selected
            let location = fetchedResultsController.object(at: indexPath)
            // call remove photo file to remove the photo for this location object. removePhotoFile() uses the ID of this specific location object (selected index in row, then we found this object). Then the removePhotoFile() uses the id and finds corresponding location object url. The url is then pointed to and removed
            location.removePhotoFile()
            // tell context to delete that object
            //  This will trigger the NSFetchedResultsController to send a notification to the delegate, which then removes the corresponding row from the table
              managedObjectContext.delete(location)
            do {
              try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
        }
    }
    
    // find the number of sections
    override func numberOfSections(in tableView: UITableView)
        -> Int {
            //print("Sections: \(fetchedResultsController.sections!)")
            return fetchedResultsController.sections!.count
    }
    // add a title with the section name for each section
    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        print("Section Info: \(sectionInfo.name)")
        return sectionInfo.name.uppercased() // fetchResultsController has attriute name which we save a name key in the initializing of fetchedResultsController
    }
    // This method gets called once for each section in the table view. Here, you create a label for the section name, a 1-pixel high view that functions as a separator line, and a container view to hold these two subviews.
    // replace headers with a view of our own
    override func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView? {
        let labelRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 14,
                               width: 300, height: 14)
        let label = UILabel(frame: labelRect)
        label.font = UIFont.boldSystemFont(ofSize: 15)
        // ask the tableView's dataSource (which is this view controller LocationsViewController) for the text for each section, to put in the header were creating
        label.text = tableView.dataSource!.tableView!(
            tableView, titleForHeaderInSection: section)
        label.textColor = UIColor(white: 1.0, alpha: 0.6)
        label.backgroundColor = UIColor.clear
        let separatorRect = CGRect(
            x: 15, y: tableView.sectionHeaderHeight - 0.5,
            width: tableView.bounds.size.width - 15, height: 0.5)
        let separator = UIView(frame: separatorRect)
        separator.backgroundColor = tableView.separatorColor
        let viewRect = CGRect(x: 0, y: 0,
                              width: tableView.bounds.size.width,
                              height: tableView.sectionHeaderHeight)
        // create a container view to hold the label and the seperator. Add the two views to the container
        let view = UIView(frame: viewRect)
        view.backgroundColor = UIColor(white: 0, alpha: 0.85)
        view.addSubview(label)
        view.addSubview(separator)
        return view
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
    
 
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) { // sender is any, but for "EditLocation" sender is UITableViewCell
        playSoundEffect()
        if segue.identifier == "EditLocation" {
            let controller = segue.destination
                as! LocationDetailsViewController
            // give controller (LocationDetailsViewController) the manageObjectContext
            controller.managedObjectContext = managedObjectContext
            if let indexPath = tableView.indexPath(for: sender // we know sender is table cell so we look for the indexPath of the tapped cell
                as! UITableViewCell) {
                let location = fetchedResultsController.object(at: indexPath)
                // give controller the location object (contains that location from an index in array, and it contains its properties)
                controller.locationToEdit = location
            }
        } }
}


/*
NSFetchedResultsController will invoke these methods (below in the extension) to let you know that certain objects were inserted, removed, or just updated.
*/

// MARK:- NSFetchedResultsController Delegate Extension
extension LocationsViewController:
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
        }
    }
    func controllerDidChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
}
