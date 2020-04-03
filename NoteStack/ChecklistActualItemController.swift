//
//  ChecklistActualItemController.swift
//  NoteStack
//
//  Created by Griffin Healy on 4/1/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//

import UIKit
import LBTATools
import CoreData
import UserNotifications

protocol CreateChecklistItemDelegate {
    func retrievedChecklistItemName(checklistItemText: String, ChecklistGroupPassed: String)
}

//
//protocol EditChecklistNameGroupDelegate {
//    func retrievedChecklistName2(checklistNameText: String, checklistIconName: String, checklist: ChecklistsGroup)
//}

class ChecklistActualItemController: LBTAFormController, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // CreateActualNoteController
    var createChecklistsContrll = ChecklistItemController()

    // Managed object context
    var managedObjectContext: NSManagedObjectContext!
    var checklistToEdit: ChecklistsGroup?
    var checklistItemToEdit: Items?
    var checklistItemName: String? = nil
    var remindMe: Bool = false
    var passedDate = Date()
    
    var fromOptionsDisclosure: Bool = false
    var ChecklistGroupNamePassed: String = ""
    var currentChecklistGroup: ChecklistsGroup?
    
    // delegate var for the protocol above
    var createItemDelegate: CreateChecklistItemDelegate?
    
    // delegate var for the protocol above
    //var delegateEdit: EditChecklistNameGroupDelegate?
    
    var checklistName: String? = nil
    var checklistIconName: String? = nil
    
    var newfolderLabel = UILabel(text: "New Checklist Item", font: UIFont(name: "AppleSDGothicNeo-Bold", size: 20)!, textColor: .black, textAlignment: .center, numberOfLines: 0)
    
    var enterfolderLabel = UILabel(text: "Enter a name for this item", font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 15)!, textColor: .black, textAlignment: .center, numberOfLines: 0)
    
    var chooseIconLabel = UILabel(text: "Choose an icon for this checklist", font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 15)!, textColor: .black, textAlignment: .center, numberOfLines: 0)
    
    var itemNameTextField = IndentedTextField(placeholder: "Checklist Item Name", padding: 24, cornerRadius: 25)
    
    lazy var saveGroupButton = UIButton(title: "Save", titleColor: .white, font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 18)!, backgroundColor: .rgb(red: 0, green: 172, blue: 237), target: self, action: #selector(saveGroup))
    
    lazy var cancelGroupButton = UIButton(title: "Cancel", titleColor: .yellow, font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 18)!, backgroundColor: .lightGray, target: self, action: #selector(cancelGroup))
    
    var remindMeLabel = UILabel(text: "Remind Me Later", font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 15)!, textColor: .black, textAlignment: .left, numberOfLines: 0)
    
    var reminderDueDateLabel = UILabel(text: "Reminder Date", font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 15)!, textColor: .black, textAlignment: .left, numberOfLines: 0)
    
    var reminderDateChangedLabel = UILabel(text: "Date", font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 15)!, textColor: .black, textAlignment: .center, numberOfLines: 0)
    
    //var reminderDatePicker: UIDatePicker!
    lazy private var reminderDatePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return dp
    }()
    
    lazy private var dateFormatter: DateFormatter = {
           let df = DateFormatter()
           df.dateStyle = .medium
           df.timeStyle = .short
           return df
       }()
    
    var remindMeSwitch = UISwitch()
    var remindMeSwitchOnorOff: Bool = false
    var datePickerDate = Date()
    
    var checklistNameArray = [String]()
    var checklistIcon: String = "Default"
    var initial_Width: CGFloat = 0.0
    var notificationCount: Int = 0
    
    override func viewDidLoad() {
       super.viewDidLoad()
        
        
        
        
        remindMeSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        
        initial_Width = self.view.frame.width
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(saveGroup))
        navigationItem.rightBarButtonItem?.tintColor = .rgb(red: 0, green: 197, blue: 255)
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        if (fromOptionsDisclosure == true) {
            newfolderLabel.text = "Edit Checklist Item"
            itemNameTextField.text = checklistItemName
            navigationItem.rightBarButtonItem?.isEnabled = true
            reminderDateChangedLabel.text = dateFormatter.string(from: passedDate)
            reminderDatePicker.date = passedDate
            reminderDateChangedLabel.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 15)
            if (remindMe == true) {
                remindMeSwitch.isOn = true
            }
            else if (remindMe == false) {
                remindMeSwitch.isOn = false
            }
        }
        
        else if (fromOptionsDisclosure == false) {
            let dueDate = updateDueDateLabel()
            reminderDateChangedLabel.text = dueDate
            reminderDateChangedLabel.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 15)
        }
        
        if #available(iOS 11, *) {
        self.navigationController!.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
          self.navigationController?.navigationBar.prefersLargeTitles = false
          self.navigationController?.navigationItem.largeTitleDisplayMode = .never
        }
        
        view.backgroundColor = .rgb(red: 242, green: 242, blue: 242)
        itemNameTextField.textColor = .black
        itemNameTextField.attributedPlaceholder = NSAttributedString(string: "Checklist Item Name",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        itemNameTextField.delegate = self
        self.scrollView.isScrollEnabled = false
        saveGroupButton.layer.cornerRadius = 10
        cancelGroupButton.layer.cornerRadius = 10
        itemNameTextField.backgroundColor = .white
        itemNameTextField.layer.borderWidth = 0.3
        itemNameTextField.layer.borderColor = UIColor.lightGray.cgColor
        itemNameTextField.layer.cornerRadius = 10
        itemNameTextField.withHeight(35)
        itemNameTextField.addTarget(self, action: #selector(textFieldDidChangeSelection(_:)), for: UIControl.Event.editingChanged)
        saveGroupButton.isEnabled = false
        saveGroupButton.backgroundColor = .darkGray
        
        let remindmeView = UIView()
        remindmeView.stack(remindMeLabel, UIView().withHeight(10))
        let remindMeSwitchView = UIView()
        remindMeSwitchView.stack(remindMeSwitch).withMargins(.init(top: 0, left: (initial_Width / 2) - 50, bottom: 0, right: 0))
    
        let formView = UIView()
        formView.stack(UIView().withHeight(10),newfolderLabel.withHeight(30), UIView().withHeight(10),enterfolderLabel.withHeight(30),itemNameTextField.withWidth(100),UIView().withHeight(15), formView.hstack(remindmeView, remindMeSwitchView), UIView().withHeight(10), formView.hstack(reminderDueDateLabel, reminderDateChangedLabel), UIView().withHeight(10),
                       reminderDatePicker.withHeight(150)).withMargins(.init(top: 0, left: 10, bottom: 0, right: 10))
       
       formContainerStackView.padBottom(0)
       formContainerStackView.addArrangedSubview(formView)
        
       }
    
    @objc private func datePickerValueChanged(datePicker: UIDatePicker) {
        reminderDateChangedLabel.text = dateFormatter.string(from: datePicker.date)
        datePickerDate = datePicker.date
        passedDate = datePicker.date
    }
    
    func scheduleNotification(notificationId: Int) {
       removeNotification(notificationId: notificationId)
       if remindMe && datePickerDate > Date() {
         let content = UNMutableNotificationContent()
         content.title = "Checklist Reminder:"
        content.body = itemNameTextField.text!
         content.sound = UNNotificationSound.default
         
         let calendar = Calendar(identifier: .gregorian)
         let components = calendar.dateComponents([.month, .day, .hour, .minute], from: datePickerDate)
 
         let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
         let request = UNNotificationRequest(identifier: "\(notificationId)", content: content, trigger: trigger)
         let center = UNUserNotificationCenter.current()
         center.add(request)
         print("Scheduled:: \(request) for itemID: \(notificationId)")
     }
    }
     
     func removeNotification(notificationId: Int) {
       let center = UNUserNotificationCenter.current()
       center.removePendingNotificationRequests(withIdentifiers: ["\(notificationId)"])
     }
    
    override func willMove(toParent parent: UIViewController?) {
        if #available(iOS 11, *) {
        self.navigationController!.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
          self.navigationController?.navigationBar.prefersLargeTitles = true
          self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        }
    }
    
    func updateDueDateLabel() -> String {
      let formatter = DateFormatter()
      formatter.dateStyle = .medium
      formatter.timeStyle = .short
      return formatter.string(from: date)
    }
    
    
        func fetchAndPrintEachNoteGroup() {
            checklistNameArray = []
            let fetchRequest = NSFetchRequest<ChecklistsGroup>(entityName: "ChecklistsGroup")
            do {
                let fetchedResults = try managedObjectContext!.fetch(fetchRequest)
                for item in fetchedResults {
                    checklistNameArray.append(item.value(forKey: "checklistName")! as! String)
                }
            } catch let error as NSError {
                // something went wrong, print the error.
                print(error.description)
            }
            //print(notesGroupArray)
        }
    
       func retrievedIcon(ChecklistIcon: String) {
           self.checklistIcon = ChecklistIcon
       }
    
        let date = Date()
    
        @objc func saveGroup() {
            print("Save group")
            let groupText = itemNameTextField.text
        
            if (fromOptionsDisclosure == false) {
                 //itemID = DataModel.nextChecklistItemID()
                 let item: Items
                 item = Items(context: managedObjectContext)
                 item.itemName = groupText!
                 item.date = date
                 item.remindMe = remindMe
                 item.dueDate = datePickerDate
                 if ((remindMe == true) && (datePickerDate > Date())) {
                 notificationCount = SharedNotificationCount.nextChecklistItemID()
                 item.itemNumber = notificationCount as NSNumber
                    scheduleNotification(notificationId: item.itemNumber as! Int)
                 }
                
                 let fetchGroupRequest = NSFetchRequest<ChecklistsGroup>(entityName: "ChecklistsGroup")
                fetchGroupRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(ChecklistsGroup.checklistName),
                 ChecklistGroupNamePassed)
                 do {
                   let results = try managedObjectContext.fetch(fetchGroupRequest) // do the actual fetch
                   if results.count > 0 {
                     currentChecklistGroup = results.first
                   }
                 } catch let error as NSError {
                   print("Fetch error: \(error) description: \(error.userInfo)")
                 }
                 
                 if let checklistgroup = currentChecklistGroup,
                    let items = checklistgroup.checklistitems?.mutableCopy()
                     as? NSMutableOrderedSet {
                   items.add(item) // walks is currentDogs all walks. Add the newest walk to the set of all walks
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
                
                let createChecklistItemController = createChecklistsContrll
                createChecklistItemController.managedObjectContext = managedObjectContext
                self.createItemDelegate = createChecklistItemController
                createItemDelegate?.retrievedChecklistItemName(checklistItemText: groupText!, ChecklistGroupPassed: ChecklistGroupNamePassed)
                self.dismiss(animated: true)
                self.navigationController?.popViewController(animated: true)
            }
            else if (fromOptionsDisclosure == true) {
                checklistItemToEdit!.itemName = groupText!
                checklistItemToEdit!.remindMe = remindMe
                print(datePickerDate)
                checklistItemToEdit!.dueDate = passedDate
                //checklistItemToEdit!.date = date
                
                if ((remindMe == true) && (datePickerDate > Date())) {
                    notificationCount = checklistItemToEdit?.itemNumber as! Int
                    checklistItemToEdit!.itemNumber = notificationCount as NSNumber
                    scheduleNotification(notificationId: notificationCount)
                }
                
                if (remindMe == false) {
                    notificationCount = checklistItemToEdit?.itemNumber as! Int
                    checklistItemToEdit!.itemNumber = notificationCount as NSNumber
                    removeNotification(notificationId: notificationCount)
                }
                
                 let fetchGroupRequest = NSFetchRequest<ChecklistsGroup>(entityName: "ChecklistsGroup")
                fetchGroupRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(ChecklistsGroup.checklistName),
                 ChecklistGroupNamePassed)
                 do {
                   let results = try managedObjectContext.fetch(fetchGroupRequest) // do the actual fetch
                   if results.count > 0 {
                     currentChecklistGroup = results.first
                   }
                 } catch let error as NSError {
                   print("Fetch error: \(error) description: \(error.userInfo)")
                 }
                 
                 if let checklistgroup = currentChecklistGroup,
                    let items = checklistgroup.checklistitems?.mutableCopy()
                     as? NSMutableOrderedSet {
                    items.add(checklistItemToEdit!) // walks is currentDogs all walks. Add the newest walk to the set of all walks
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
                
                let createChecklistItemController = createChecklistsContrll
                createChecklistItemController.managedObjectContext = managedObjectContext
                self.createItemDelegate = createChecklistItemController
                createItemDelegate?.retrievedChecklistItemName(checklistItemText: groupText!, ChecklistGroupPassed: ChecklistGroupNamePassed)
                self.dismiss(animated: true)
                self.navigationController?.popViewController(animated: true)
                }
        }
    
    @objc func switchChanged(mySwitch: UISwitch) {
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) {
          granted, error in
          // do nothing
        }
        
        let value = mySwitch.isOn
        if (value == true) {
            remindMe = true
            print(remindMe)
        }
        else if (value == false) {
            remindMe = false
            print(remindMe)
        }
    }
        
        @objc func cancelGroup() {
            print("Cancel Checklist")
            self.dismiss(animated: true)
        }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (itemNameTextField.text != "") {
            saveGroupButton.backgroundColor = .rgb(red: 0, green: 172, blue: 237)
            saveGroupButton.isEnabled = true
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if (itemNameTextField.text != "") {
            saveGroupButton.backgroundColor = .rgb(red: 0, green: 172, blue: 237)
            saveGroupButton.isEnabled = true
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        if (itemNameTextField.text == "") {
            saveGroupButton.backgroundColor = .darkGray
            saveGroupButton.isEnabled = false
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if (itemNameTextField.text != "") {
            saveGroupButton.backgroundColor = .rgb(red: 0, green: 172, blue: 237)
            saveGroupButton.isEnabled = true
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        if (itemNameTextField.text == "") {
            saveGroupButton.backgroundColor = .darkGray
            saveGroupButton.isEnabled = false
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
}

