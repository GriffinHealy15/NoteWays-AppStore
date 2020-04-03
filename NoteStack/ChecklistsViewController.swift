//
//  ChecklistsViewController.swift
//  NoteStack
//
//  Created by Griffin Healy on 3/30/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import AudioToolbox

class ChecklistsViewController: UITableViewController, UIPopoverPresentationControllerDelegate, CreateChecklistNameGroupDelegate, OptionButtonsDelegate, EditChecklistNameGroupDelegate, ItemsRefreshProtocol {
    
    var managedObjectContext: NSManagedObjectContext!
    var checklistgroup: ChecklistsGroup?
    var currentItemsGroup: ChecklistsGroup?
    var currentItems: [Any]?
    var remainingItems: Int?
    var count = 0
    
    lazy var fetchedResultsController:
           NSFetchedResultsController<ChecklistsGroup> = {
               // set up ns fetch results to tell it that were going to fetch locations object
               let fetchRequest = NSFetchRequest<ChecklistsGroup>()
               let entity = ChecklistsGroup.entity()
               // the fetchRequest entity is  Location
               fetchRequest.entity = entity
               let sort1 = NSSortDescriptor(key: "checklistIcon", ascending: true)
               let sort2 = NSSortDescriptor(key: "date", ascending: true)
               fetchRequest.sortDescriptors = [sort1, sort2]
               fetchRequest.fetchBatchSize = 5
               let fetchedResultsController = NSFetchedResultsController(
                   fetchRequest: fetchRequest,
                   managedObjectContext: self.managedObjectContext,
                   sectionNameKeyPath: "checklistIcon", cacheName: "ChecklistsGrouping")
               fetchedResultsController.delegate = self
               return fetchedResultsController
       }()
    
    var date = Date()
    var original_widthMult: CGFloat = 0.0
    var original_CellHeight: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Checklists"
        if #available(iOS 11, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        }
 
        original_widthMult = view.frame.size.width * 2
        original_CellHeight = 58.0
        performFetch()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "checklistAdd"), style: .plain, target: self, action:  #selector(createChecklistsGroup))
        navigationItem.rightBarButtonItem?.isEnabled = true
        navigationItem.rightBarButtonItem?.tintColor = .rgb(red: 0, green: 150, blue: 255)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    @objc func createChecklistsGroup() {
        print("Creating Checklists Group")
        let vc = ChecklistNameController()
        vc.managedObjectContext = managedObjectContext
        vc.createChecklistsContrll = self

        //self.tabBarController?.tabBar.isHidden = true
               if #available(iOS 11, *) {
            self.navigationController!.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.clear]
        }
        
        let delayInSeconds = 0.05
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
         self.navigationController?.pushViewController(vc, animated: true)
        }
//        vc.preferredContentSize = CGSize(width: 275, height: 360)
//        vc.modalPresentationStyle = .popover
//        vc.popoverPresentationController?.delegate = self
//        let ppc = vc.popoverPresentationController
//        ppc?.permittedArrowDirections = .init(rawValue: 0)
//        ppc?.delegate = self
//        ppc!.sourceView = self.view
//        ppc?.passthroughViews = nil
//        ppc?.sourceRect =  CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY - 80, width: 0, height: 0)
//        present(vc, animated: true)
    }
    
    func refreshItemsRemainingCount() {
        self.tableView.reloadData()
    }
    
    func retrievedChecklistName2(checklistNameText: String, checklistIconName: String, checklist: ChecklistsGroup) {
        checklist.checklistName = checklistNameText
        checklist.checklistIcon = checklistIconName
        //checklist.date = date
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
     
    func retrievedChecklistName(checklistNameText: String, checklistIconName: String) {
        checklistgroup = ChecklistsGroup(context: managedObjectContext)
        checklistgroup!.checklistName = checklistNameText
        checklistgroup!.checklistIcon = checklistIconName
        checklistgroup?.date = date
        
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
    
    func fetchGroup(ChecklistGroupNamePassed: String) -> Int {
        var totalCount = 0
        let fetchGroupRequest = NSFetchRequest<ChecklistsGroup>(entityName: "ChecklistsGroup")
        fetchGroupRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(ChecklistsGroup.checklistName),
        ChecklistGroupNamePassed)
        do {
          let results = try managedObjectContext.fetch(fetchGroupRequest) // do the actual fetch
          if results.count > 0 {
            let results1 = results.first
            let currentItems = results1?.checklistitems
            totalCount = currentItems?.count ?? 0
          }
        } catch let error as NSError {
          print("Fetch error: \(error) description: \(error.userInfo)")
        }
        return totalCount
    }
    
    func fetchRemainingItems(ChecklistGroupNamePassed: String) -> [Any] {
        let fetchGroupRequest = NSFetchRequest<ChecklistsGroup>(entityName: "ChecklistsGroup")
        fetchGroupRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(ChecklistsGroup.checklistName),
        ChecklistGroupNamePassed)
        do {
          let results = try managedObjectContext.fetch(fetchGroupRequest) // do the actual fetch
          if results.count > 0 {
            currentItemsGroup = results.first
            let sortByDate = NSSortDescriptor(key: "date", ascending: false)
            currentItems = currentItemsGroup?.checklistitems?.sortedArray(using: [sortByDate])
          }
        } catch let error as NSError {
          print("Fetch error: \(error) description: \(error.userInfo)")
        }
        return currentItems!
    }
    
    func handleConfirmPressed(indexPath:IndexPath) -> (_ alertAction:UIAlertAction) -> () {
        return { alertAction in
            let notegroup = self.fetchedResultsController.object(at: indexPath)
            self.managedObjectContext.delete(notegroup)
            do {
                try self.managedObjectContext.save()
                //self.fetchGroup(ChecklistGroupNamePassed: <#String#>)
                self.view.isUserInteractionEnabled = false
                let delayInSeconds = 0.5
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                    self.tableView.reloadData()
                    self.view.isUserInteractionEnabled = true
                }
            } catch {
                fatalCoreDataError(error)
            }
        }
    }
    
    func detailChecklistEdit(at index: IndexPath) {
        print("Editing Checklists Group")
        let vc = ChecklistNameController()
        vc.managedObjectContext = managedObjectContext
        vc.createChecklistsContrll = self
        vc.fromOptionsDisclosure = true
        let checklistgroup = fetchedResultsController.object(at: index)
        vc.checklistName = checklistgroup.checklistName
        vc.checklistIconName = checklistgroup.checklistIcon
        vc.checklistToEdit = checklistgroup
        //self.tabBarController?.tabBar.isHidden = true
               if #available(iOS 11, *) {
            self.navigationController!.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.clear]
        }
        
        let delayInSeconds = 0.05
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
         self.navigationController?.pushViewController(vc, animated: true)
        }
    }
      
    
    // MARK: - Table View Delegates

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        // ask fetchResultsController for number of sections, and for all sections, we find the number of objects in the section
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    // tableView asks controller for a cell for each of the rows
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
            var countOf = 0
            remainingItems = 0
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ChecklistCell",
                for: indexPath) as! ChecklistCell
            // ask fetch results for the location object at indexPath i, then return that object
            let checklistgroup = fetchedResultsController.object(at: indexPath)
            let totalItems = fetchGroup(ChecklistGroupNamePassed: checklistgroup.checklistName)
            let totalItems1 = fetchRemainingItems(ChecklistGroupNamePassed: checklistgroup.checklistName)
            if ((totalItems > 0) && (totalItems1.count > 0)) {
            for i in 0...totalItems - 1 {
            let item = totalItems1[i] as? Items
                if (item?.itemChecked == true) {
                    countOf = countOf + 1
                }
            }
            remainingItems = totalItems - countOf
            }

            cell.delegate = self
            cell.indexPath = indexPath
            // configure cell for the location object
            cell.configure(for: checklistgroup, remainingItems: remainingItems ?? 0, totalItems: totalItems)
            
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
            border_Around_Bordered_Cell.cornerRadius = 9
            
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
                let alert = UIAlertController(title: "Delete Checklist", message: "Are you sure you want to delete this checklist?", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: handleConfirmPressed(indexPath: indexPath)))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }

        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            //loadSoundEffect("navtap.mp3")
            //playSoundEffect()
            let checklistItems = fetchedResultsController.object(at: indexPath)
            let storyboard_main = UIStoryboard(name: "Main", bundle: Bundle.main)
            let checklistItemContrll = storyboard_main.instantiateViewController(withIdentifier: "ChecklistItemController") as! ChecklistItemController
            checklistItemContrll.InitialChecklistGroupNamePassed = checklistItems.checklistName
            checklistItemContrll.managedObjectContext = managedObjectContext
            checklistItemContrll.singleGroupController = self
            navigationController?.pushViewController(checklistItemContrll, animated: true)
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
    
    override func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView? {
        let labelRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 14,
                               width: (original_widthMult/2) - 30, height: 22)
        let label = UILabel(frame: labelRect)
        label.textAlignment = .center
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 17)
        //label.backgroundColor = .white
        label.backgroundColor = .rgb(red: 46, green: 205, blue: 187)
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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK:- NSFetchedResultsController Delegate Extension
extension ChecklistsViewController:
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



