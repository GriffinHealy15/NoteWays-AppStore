//
//  ChecklistItemController.swift
//  NoteStack
//
//  Created by Griffin Healy on 4/1/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//

import UIKit
import CoreData
import LBTATools
import AudioToolbox


protocol ItemsRefreshProtocol {
    func refreshItemsRemainingCount()
}

class ChecklistItemController: UITableViewController, CancelNoteDelegate, CreateChecklistItemDelegate, OptionItemButtonsDelegate {
 
    var managedObjectContext: NSManagedObjectContext!
    var InitialChecklistGroupNamePassed: String = ""
    var noteTextFieldSet = ""
    var itemsArray = [String]()
    var notesPassedArray: [UIImage] = []
    var notesLocationPassedArray: [Int] = []
    let notebox = UIView(backgroundColor: .yellow)
    var noteImage: UIImage? = nil
    var currentItemsGroup: ChecklistsGroup?
    var currentItems: [Any]?
    var noteGroupPassedAgain: String = ""
    var onlyNoteTextPassToNoteCell = ""
    var singleGroupController = ChecklistsViewController()
    var rgbColorArrayFloat: [CGFloat?] = []
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var count: Int = 0
    var timer = Timer()
    var counter: Int = 0
    var onlyItemTextPassToNoteCell = ""
    
    
    @IBOutlet weak var tableViewMySource: UITableView!
    
    lazy var fetchedResultsController1:
        NSFetchedResultsController<ChecklistsGroup> = {
            // set up ns fetch results to tell it that were going to fetch locations object
            let fetchRequest = NSFetchRequest<ChecklistsGroup>()
            let entity = ChecklistsGroup.entity()
            // the fetchRequest entity is  Location
            fetchRequest.entity = entity
            let sort1 = NSSortDescriptor(key: "checklistName", ascending: true)
            let sort2 = NSSortDescriptor(key: "date", ascending: true)
            fetchRequest.sortDescriptors = [sort1, sort2]
            fetchRequest.fetchBatchSize = 5
            let fetchedResultsController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: self.managedObjectContext,
                sectionNameKeyPath: "checklistName", cacheName: "ChecklistsGroup")
            //fetchedResultsController.delegate = self
            return fetchedResultsController
    }()
    
    var soundID: SystemSoundID = 0
    
    // delegate var for the protocol above
    var delegate: ItemsRefreshProtocol?
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "checklistAdd"), style: .plain, target: self, action:  #selector(createChecklistItem))
        navigationItem.rightBarButtonItem?.isEnabled = true
        navigationItem.rightBarButtonItem?.tintColor = .rgb(red: 0, green: 150, blue: 255)
        view.backgroundColor = .rgb(red: 242, green: 242, blue: 242)
        tableView.backgroundColor = .white
        
//        if #available(iOS 11, *) {
//            self.navigationController!.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
//            self.navigationController?.navigationBar.prefersLargeTitles = true
//            self.navigationController?.navigationItem.largeTitleDisplayMode = .always
//        }
        
        performFetch()
        //fetchAndPrintEachNote()
        fetchGroup()
        title = ("\(InitialChecklistGroupNamePassed) Items")
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
        delegate?.refreshItemsRemainingCount()
        navigationController?.popViewController(animated: true)
    }
    
    @objc func createChecklistItem() {
        let itemActualController = ChecklistActualItemController()
        itemActualController.managedObjectContext = managedObjectContext
        itemActualController.ChecklistGroupNamePassed = InitialChecklistGroupNamePassed
        itemActualController.createChecklistsContrll = self

//        let navController = UINavigationController(rootViewController: noteActualController)
//        present(navController, animated: true)
  //      self.tabBarController?.tabBar.isHidden = true
        if #available(iOS 11, *) {
            self.navigationController!.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.clear]
        }
       let delayInSeconds = 0.05
       DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
        self.navigationController?.pushViewController(itemActualController, animated: true)
       }
    }
    
    func retrievedChecklistItemName(checklistItemText: String, ChecklistGroupPassed: String) {
        onlyItemTextPassToNoteCell = checklistItemText
        let fetchGroupRequest = NSFetchRequest<ChecklistsGroup>(entityName: "ChecklistsGroup")
        fetchGroupRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(ChecklistsGroup.checklistName),
        ChecklistGroupPassed)
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
        //let trimmedString = onlyNoteText.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        //print(trimmedString)
        // reload the tableView
        self.tableView.reloadData()
    }
    
    
    func retrievedEditNoteText(NoteGroupNamePassed: String) {
        if #available(iOS 11, *) {
            self.navigationController!.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
              self.navigationController?.navigationBar.prefersLargeTitles = true
              self.navigationController?.navigationItem.largeTitleDisplayMode = .always
            }
                
        let fetchGroupRequest = NSFetchRequest<ChecklistsGroup>(entityName: "ChecklistsGroup")
        fetchGroupRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(ChecklistsGroup.checklistName),
        NoteGroupNamePassed)
        do {
          let results = try managedObjectContext.fetch(fetchGroupRequest) // do the actual fetch
          if results.count > 0 {
            currentItemsGroup = results.first
            let sortByDate = NSSortDescriptor(key: "date", ascending: false)
            currentItems = currentItemsGroup?.checklistitems?.sortedArray(using: [sortByDate])
            //print(currentItems)
          }
        } catch let error as NSError {
          print("Fetch error: \(error) description: \(error.userInfo)")
        }
        // reload the tableView
        self.tableView.reloadData()
    }
    
    
    func cancelNote() {
        if #available(iOS 11, *) {
           self.navigationController!.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
             self.navigationController?.navigationBar.prefersLargeTitles = true
             self.navigationController?.navigationItem.largeTitleDisplayMode = .always
           }
    }
    
    func performFetch() {
        do {
            try fetchedResultsController1.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    func fetchGroup() {
        let fetchGroupRequest = NSFetchRequest<ChecklistsGroup>(entityName: "ChecklistsGroup")
        fetchGroupRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(ChecklistsGroup.checklistName),
        InitialChecklistGroupNamePassed)
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
    }
    
    func fetchAndPrintEachNote() {
        let fetchRequest = NSFetchRequest<Items>(entityName: "Items")
        do {
            let fetchedResults = try managedObjectContext!.fetch(fetchRequest)
            for item in fetchedResults {
                itemsArray.append(item.value(forKey: "itemName")! as! String)
            }
        } catch let error as NSError {
            // something went wrong, print the error.
            print(error.description)
        }
//        print(itemsArray)
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
    
    func handleConfirmPressed(indexPath:IndexPath) -> (_ alertAction:UIAlertAction) -> () {
        return { alertAction in
            print("Delete Location")
            let note = self.currentItems?[indexPath.row] as? Items

            self.managedObjectContext.delete(note!)
            do {
                try self.managedObjectContext.save()
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.fetchGroup()
                //self.tableView.reloadData()
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
    
    func detailChecklistItemEdit(at index: IndexPath) {
        //fetchGroup()
        //self.tableView.reloadData()
        let vc = ChecklistActualItemController()
        vc.managedObjectContext = managedObjectContext
        vc.createChecklistsContrll = self
        vc.fromOptionsDisclosure = true
        let checklistgroupitem = currentItems?[index.row] as? Items
        vc.checklistItemName = checklistgroupitem?.itemName
        vc.remindMe = checklistgroupitem!.remindMe
        vc.ChecklistGroupNamePassed = InitialChecklistGroupNamePassed
        vc.passedDate = checklistgroupitem!.dueDate!
        vc.checklistItemToEdit = checklistgroupitem
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
        //let sectionInfo = fetchedResultsController1.sections![section]
        //fetchGroup()
        return currentItemsGroup?.checklistitems?.count ?? 0
    }

    // tableView asks controller for a cell for each of the rows
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
            //fetchGroup()
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ChecklistItemCell",
                for: indexPath) as! ChecklistItemCell
            let item = currentItems?[indexPath.row] as? Items
            // configure cell for the location object
            //cell.onlyNoteText = onlyNoteTextPassToNoteCell
            cell.delegateItemEdit = self
            cell.indexPath = indexPath
            cell.configure(for: item!)
            
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
            border_Around_Bordered_Cell.zPosition = -1.0
            border_Around_Bordered_Cell.frame = CGRect(x: 15, y: 3, width: cell.frame.size.width - 30, height: cell.frame.size.height - 8)
            border_Around_Bordered_Cell.borderWidth = 0.7
            
            border_Around_Bordered_Cell.cornerRadius = 15
            border_Around_Bordered_Cell.borderColor = UIColor.rgb(red: 220, green: 220, blue: 220).cgColor
            border_Around_Bordered_Cell.backgroundColor = UIColor.white.cgColor
            //cell.backgroundColor = UIColor.rgb(red: red, green: green, blue: blue)
            cell.layer.addSublayer(border_Around_Bordered_Cell)
            cell.layer.addSublayer(bottom_border)
            cell.layer.addSublayer(right_border)
            cell.layer.addSublayer(left_border)
            cell.layer.addSublayer(top_border)
            
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
 
            return cell
    }

    // enable swipe to delete, delete rows of objects that are no longer in the data store
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Delete Item", message: "Are you sure you want to delete this item?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: handleConfirmPressed(indexPath: indexPath)))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
            if let cell = tableView.cellForRow(at: indexPath) {
              let item = currentItems?[indexPath.row] as? Items
                configureCheckmark(for: cell as! ChecklistItemCell, with: item!)
                
                 item?.itemChecked = !item!.itemChecked
                 let fetchGroupRequest = NSFetchRequest<ChecklistsGroup>(entityName: "ChecklistsGroup")
                fetchGroupRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(ChecklistsGroup.checklistName),
                 InitialChecklistGroupNamePassed)
                 do {
                   let results = try managedObjectContext.fetch(fetchGroupRequest) // do the actual fetch
                   if results.count > 0 {
                     currentItemsGroup = results.first
                   }
                 } catch let error as NSError {
                   print("Fetch error: \(error) description: \(error.userInfo)")
                 }
                 
                 if let checklistgroup = currentItemsGroup,
                    let items = checklistgroup.checklistitems?.mutableCopy()
                     as? NSMutableOrderedSet {
                    items.add(item!) 
                     checklistgroup.checklistitems = items
                 }

                 do {
                    try managedObjectContext.save()
                     print("Saved Successfully")
                    // error handling for save()
                } catch {
                    // 4
                    // if save fails call below function with error message
                     print("Error saving")
                }
            }

        let delayInSeconds = 0.05
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
        }
        fetchGroup()
        
        //print("reloaded")
       }
       
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func configureCheckmark(for cell: ChecklistItemCell, with item: Items) {
        let label = cell.checklistChecked
        if item.itemChecked {
            print("Checked")
            label?.image = nil
      } else {
            print("Note Checked")
            label?.image = #imageLiteral(resourceName: "checkmark-1")
      }
    }

}



