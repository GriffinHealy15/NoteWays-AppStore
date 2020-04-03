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
    var storyboard_1 = UIStoryboard()
    var original_widthMult: CGFloat = 0.0
    var original_CellHeight: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Locations"
         if #available(iOS 11, *) {
        self.navigationController!.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        }
        performFetch()
        original_widthMult = view.frame.size.width * 2
        original_CellHeight = 67.0
        view.backgroundColor = .white
        //navigationItem.rightBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: #imageLiteral(resourceName: "findlocation"), style: .plain, target: self, action: #selector(findLocation))]
        navigationItem.leftBarButtonItems = [UIBarButtonItem(image: #imageLiteral(resourceName: "about"), style: .plain, target: self, action: #selector(aboutPage)), UIBarButtonItem(image: #imageLiteral(resourceName: "mapgeography"), style: .plain, target: self, action: #selector(mapView))]
//        navigationItem.leftBarButtonItems = [UIBarButtonItem(image: #imageLiteral(resourceName: "about"), style: .plain, target: self, action: #selector(aboutPage)), editButtonItem]
        navigationItem.leftBarButtonItem?.tintColor = .rgb(red: 0, green: 151, blue: 248)
        navigationItem.rightBarButtonItem?.tintColor = .black
        navigationItem.leftBarButtonItems![0].tintColor = .black
        navigationItem.leftBarButtonItems![1].tintColor = .black
        //loadSoundEffect("Click.wav")
        UINavigationBar.appearance().barTintColor = UIColor.white
    }
    
    @objc func findLocation() {
        //loadSoundEffect("map.mp3")
        //playSoundEffect()
        print("Creating location nav...")
        let currentLocationController = CurrentOrSearchController()
        currentLocationController.managedObjectContext = managedObjectContext
        currentLocationController.storyboard_1 = storyboard_1
        let navController = UINavigationController(rootViewController: currentLocationController)
        present(navController, animated: true)
    }
    
    @objc func aboutPage() {
     //loadSoundEffect("tap.mp3")
     //playSoundEffect()
     print("Loading About Page...")
     let aboutController = AboutController()
     aboutController.managedObjectContext = managedObjectContext
     let navController = UINavigationController(rootViewController: aboutController)
     present(navController, animated: true)
    }
    
    @objc func mapView() {
        let storyboard_main = UIStoryboard(name: "Main", bundle: Bundle.main)
        let mapViewController = storyboard_main.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        mapViewController.managedObjectContext = managedObjectContext
        mapViewController.singleLocation = nil
        mapViewController.fromLocationsContrl = true
        navigationController?.pushViewController(mapViewController, animated: true)
    }
    
    func handleConfirmPressed(indexPath:IndexPath) -> (_ alertAction:UIAlertAction) -> () {
        return { alertAction in
            print("Delete Location")
            let location = self.fetchedResultsController.object(at: indexPath)
            // call remove photo file to remove the photo for this location object. removePhotoFile() uses the ID of this specific location object (selected index in row, then we found this object). Then the removePhotoFile() uses the id and finds corresponding location object url. The url is then pointed to and removed
            location.removePhotoFile()
            // tell context to delete that object
            //  This will trigger the NSFetchedResultsController to send a notification to the delegate, which then removes the corresponding row from the table
            self.managedObjectContext.delete(location)
            do {
                try self.managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
        }
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
        //print("Number of objects \(sectionInfo.numberOfObjects)")
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
            // the following code increases cell border only on specified borders
            let bottom_border = CALayer()
            let bottom_padding = CGFloat(0.0)
            bottom_border.borderColor = UIColor.white.cgColor
            bottom_border.frame = CGRect(x: 0, y: original_CellHeight - bottom_padding, width:  cell.frame.size.width, height: original_CellHeight)
            bottom_border.borderWidth = bottom_padding
            
            let right_border = CALayer()
            let right_padding = CGFloat(15.0)
            right_border.borderColor = UIColor.white.cgColor
            right_border.frame = CGRect(x: (original_widthMult/2) - right_padding, y: 0, width: right_padding, height: original_CellHeight)
            right_border.borderWidth = right_padding

            let left_border = CALayer()
            let left_padding = CGFloat(15.0)
            left_border.borderColor = UIColor.white.cgColor
            left_border.frame = CGRect(x: 0, y: 0, width: left_padding, height: original_CellHeight)
            left_border.borderWidth = left_padding

            let top_border = CALayer()
            let top_padding = CGFloat(1.0)
            top_border.borderColor = UIColor.white.cgColor
            top_border.frame = CGRect(x: 0, y: 0, width: cell.frame.size.width, height: top_padding)
            top_border.borderWidth = top_padding
            
            let border_Around_Bordered_Cell = CALayer()
            border_Around_Bordered_Cell.frame = CGRect(x: 15, y: 1, width: (original_widthMult/2) - 30, height: original_CellHeight - 6)
            border_Around_Bordered_Cell.borderWidth = 0.7
            border_Around_Bordered_Cell.borderColor = UIColor.rgb(red: 220, green: 220, blue: 220).cgColor
            border_Around_Bordered_Cell.cornerRadius = 15
            border_Around_Bordered_Cell.borderColor = UIColor.rgb(red: 220, green: 220, blue: 220).cgColor
            
            cell.layer.addSublayer(border_Around_Bordered_Cell)
            cell.layer.addSublayer(bottom_border)
            cell.layer.addSublayer(right_border)
            cell.layer.addSublayer(left_border)
            cell.layer.addSublayer(top_border)
            return cell }
    
    // enable swipe to delete, delete rows of objects that are no longer in the data store
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Delete Location", message: "Are you sure you want to delete this location?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: handleConfirmPressed(indexPath: indexPath)))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            // get location object from row index selected
//            let location = fetchedResultsController.object(at: indexPath)
//            // call remove photo file to remove the photo for this location object. removePhotoFile() uses the ID of this specific location object (selected index in row, then we found this object). Then the removePhotoFile() uses the id and finds corresponding location object url. The url is then pointed to and removed
//            location.removePhotoFile()
//            // tell context to delete that object
//            //  This will trigger the NSFetchedResultsController to send a notification to the delegate, which then removes the corresponding row from the table
//              managedObjectContext.delete(location)
//            do {
//              try managedObjectContext.save()
//            } catch {
//                fatalCoreDataError(error)
//            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //loadSoundEffect("tap.mp3")
        //playSoundEffect()
        let location = fetchedResultsController.object(at: indexPath)
        // give controller the location object (contains that location from an index in array, and it contains its properties)
        let locationsDetailsContrl = CurrentOrSearchDetailController()
        locationsDetailsContrl.locationToEdit = location
        locationsDetailsContrl.managedObjectContext = managedObjectContext
        let locDetailsController = UINavigationController(rootViewController: locationsDetailsContrl)
        present(locDetailsController, animated: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
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
        //print("Section Info: \(sectionInfo.name)")
        return sectionInfo.name.uppercased() // fetchResultsController has attriute name which we save a name key in the initializing of fetchedResultsController
    }
    // This method gets called once for each section in the table view. Here, you create a label for the section name, a 1-pixel high view that functions as a separator line, and a container view to hold these two subviews.
    // replace headers with a view of our own
    override func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView? {
        let labelRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 14,
                               width: (original_widthMult/2) - 30, height: 22)
        let label = UILabel(frame: labelRect)
        label.textAlignment = .center
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 17)
        //label.backgroundColor = .white
        label.backgroundColor = .rgb(red: 0, green: 224, blue: 255)
        // ask the tableView's dataSource (which is this view controller LocationsViewController) for the text for each section, to put in the header were creating
        label.text = tableView.dataSource!.tableView!(
            tableView, titleForHeaderInSection: section)
        label.textColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.9)
        label.layer.cornerRadius = 7
        label.clipsToBounds = true
        //label.backgroundColor = UIColor.white
        let separatorRect = CGRect(
            x: 15, y: tableView.sectionHeaderHeight - 0.5,
            width: tableView.bounds.size.width - 15, height: 0.5)
        let separator = UIView(frame: separatorRect)
        separator.backgroundColor = .clear
        let viewRect = CGRect(x: 0, y: 0,
                              width: tableView.bounds.size.width,
                              height: tableView.sectionHeaderHeight)
        // create a container view to hold the label and the seperator. Add the two views to the container
        let view = UIView(frame: viewRect)
        view.backgroundColor = .white
        view.addSubview(label)
        view.addSubview(separator)
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
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
//    override func prepare(for segue: UIStoryboardSegue,
//                          sender: Any?) { // sender is any, but for "EditLocation" sender is UITableViewCell
//        playSoundEffect()
//        if segue.identifier == "EditLocation" {
//            let controller = segue.destination
//                as! LocationDetailsViewController
//            // give controller (LocationDetailsViewController) the manageObjectContext
//            controller.managedObjectContext = managedObjectContext
//            if let indexPath = tableView.indexPath(for: sender // we know sender is table cell so we look for the indexPath of the tapped cell
//                as! UITableViewCell) {
//                let location = fetchedResultsController.object(at: indexPath)
//                // give controller the location object (contains that location from an index in array, and it contains its properties)
//                controller.locationToEdit = location
//            }
//        } }
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
