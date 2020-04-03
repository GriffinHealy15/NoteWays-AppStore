//
//  ChecklistNameController.swift
//  NoteStack
//
//  Created by Griffin Healy on 3/30/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//

import UIKit
import LBTATools
import CoreData

protocol CreateChecklistNameGroupDelegate {
    func retrievedChecklistName(checklistNameText: String, checklistIconName: String, remindMe: Bool, passedDate: Date, itemNumber: NSNumber)
}


protocol EditChecklistNameGroupDelegate {
    func retrievedChecklistName2(checklistNameText: String, checklistIconName: String, checklist: ChecklistsGroup, remindMe: Bool, passedDate: Date, itemNumber: NSNumber)
}

class ChecklistNameController: LBTAFormController, UINavigationControllerDelegate, UITextFieldDelegate, PickIconDelegate {
    
    // CreateActualNoteController
    var createChecklistsContrll:ChecklistsViewController?

    // Managed object context
    var managedObjectContext: NSManagedObjectContext!
    var checklistToEdit: ChecklistsGroup?
    var remindMe: Bool = false
    var passedDate = Date()
    var itemNumber: NSNumber?
    
    var fromOptionsDisclosure: Bool = false
    
    // delegate var for the protocol above
    var delegate: CreateChecklistNameGroupDelegate?
    
    // delegate var for the protocol above
    var delegateEdit: EditChecklistNameGroupDelegate?
    
    var checklistName: String? = nil
    var checklistIconName: String? = nil
    
    var newfolderLabel = UILabel(text: "New Checklist", font: UIFont(name: "AppleSDGothicNeo-Bold", size: 20)!, textColor: .black, textAlignment: .center, numberOfLines: 0)
    
    var enterfolderLabel = UILabel(text: "Enter a name for this checklist", font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 15)!, textColor: .black, textAlignment: .center, numberOfLines: 0)
    
    var chooseIconLabel = UILabel(text: "Choose an icon for this checklist", font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 15)!, textColor: .black, textAlignment: .center, numberOfLines: 0)
    
    var groupNameTextField = IndentedTextField(placeholder: "Checklist Name", padding: 24, cornerRadius: 25)
    
    var iconButton = UIButton(image: #imageLiteral(resourceName: "Default"), tintColor: .rgb(red: 0, green: 135, blue: 239), target: self, action: #selector(chooseIcon))
    
    lazy var saveGroupButton = UIButton(title: "Save", titleColor: .white, font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 18)!, backgroundColor: .rgb(red: 0, green: 172, blue: 237), target: self, action: #selector(saveGroup))
    
    lazy var cancelGroupButton = UIButton(title: "Cancel", titleColor: .yellow, font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 18)!, backgroundColor: .lightGray, target: self, action: #selector(cancelGroup))
    
    var remindMeLabel = UILabel(text: "Remind Me Later", font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 15)!, textColor: .black, textAlignment: .left, numberOfLines: 0)
     
     var reminderDueDateLabel = UILabel(text: "Reminder Date", font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 15)!, textColor: .black, textAlignment: .left, numberOfLines: 0)
     
     var reminderDateChangedLabel = UILabel(text: "Date", font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16.5)!, textColor: .black, textAlignment: .center, numberOfLines: 0)
     
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
     var notificationCount: Int = 0
    
    var checklistNameArray = [String]()
    var checklistIcon: String = "Default"
    var initial_Width: CGFloat = 0.0
    
    override func viewDidLoad() {
       super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(saveGroup))
        navigationItem.rightBarButtonItem?.tintColor = .rgb(red: 0, green: 197, blue: 255)
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        remindMeSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        
        initial_Width = self.view.frame.width
        
        if (fromOptionsDisclosure == true) {
            newfolderLabel.text = "Edit Checklist"
            groupNameTextField.text = checklistName
            iconButton.setImage(UIImage.init(named: checklistIconName!), for: .normal)
            navigationItem.rightBarButtonItem?.isEnabled = true
            checklistIcon = checklistIconName!
            reminderDateChangedLabel.text = dateFormatter.string(from: passedDate)
            reminderDatePicker.date = passedDate
            
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
            reminderDateChangedLabel.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16.5)
        }
        
        if #available(iOS 11, *) {
        self.navigationController!.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
          self.navigationController?.navigationBar.prefersLargeTitles = false
          self.navigationController?.navigationItem.largeTitleDisplayMode = .never
        }
        
        view.backgroundColor = .rgb(red: 242, green: 242, blue: 242)
        groupNameTextField.textColor = .black
        groupNameTextField.attributedPlaceholder = NSAttributedString(string: "Checklist Name",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        groupNameTextField.delegate = self
        self.scrollView.isScrollEnabled = false
        saveGroupButton.layer.cornerRadius = 10
        cancelGroupButton.layer.cornerRadius = 10
        groupNameTextField.backgroundColor = .white
        groupNameTextField.layer.borderWidth = 0.3
        groupNameTextField.layer.borderColor = UIColor.lightGray.cgColor
        groupNameTextField.layer.cornerRadius = 10
        groupNameTextField.withHeight(35)
        groupNameTextField.addTarget(self, action: #selector(textFieldDidChangeSelection(_:)), for: UIControl.Event.editingChanged)
        saveGroupButton.isEnabled = false
        saveGroupButton.backgroundColor = .darkGray
        iconButton.layer.borderWidth = 0.5
        iconButton.layer.borderColor = UIColor.lightGray.cgColor
        iconButton.layer.cornerRadius = 10
        iconButton.layer.backgroundColor = UIColor.white.cgColor
        
        let remindmeView = UIView()
        remindmeView.stack(remindMeLabel, UIView().withHeight(10))
        let remindMeSwitchView = UIView()
        remindMeSwitchView.stack(remindMeSwitch).withMargins(.init(top: 0, left: (initial_Width / 2) - 50, bottom: 0, right: 0))
        
        let formView = UIView()
        formView.stack(UIView().withHeight(5),newfolderLabel.withHeight(30), UIView().withHeight(5),enterfolderLabel.withHeight(30),groupNameTextField.withWidth(100),UIView().withHeight(5), chooseIconLabel.withHeight(30),
                       iconButton.withHeight(50), UIView().withHeight(5),
                       formView.hstack(remindmeView, remindMeSwitchView), UIView().withHeight(10), formView.hstack(reminderDueDateLabel, reminderDateChangedLabel), UIView().withHeight(5),
                       reminderDatePicker.withHeight(185)
                       ).withMargins(.init(top: 0, left: 10, bottom: 0, right: 10))
       
       formContainerStackView.padBottom(0)
       formContainerStackView.addArrangedSubview(formView)
        
       }
    
    @objc private func datePickerValueChanged(datePicker: UIDatePicker) {
        reminderDateChangedLabel.text = dateFormatter.string(from: datePicker.date)
        datePickerDate = datePicker.date
        passedDate = datePicker.date
    }
    
    override func willMove(toParent parent: UIViewController?) {
        if #available(iOS 11, *) {
        self.navigationController!.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
          self.navigationController?.navigationBar.prefersLargeTitles = true
          self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        }
    }
    
    let date = Date()
    
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
        
        @objc func chooseIcon() {
            print("Choose Icon...")
            let vc = ChecklistIconController()
            vc.managedObjectContext = managedObjectContext
            vc.checklistNameController = self
            let navController = UINavigationController(rootViewController: vc)
            present(navController, animated: true)
        }
    
       func retrievedIcon(ChecklistIcon: String) {
           iconButton.setImage(UIImage.init(named: ChecklistIcon), for: .normal)
           self.checklistIcon = ChecklistIcon
       }
    
    func scheduleNotification(notificationId: Int) {
          removeNotification(notificationId: notificationId)
          if remindMe && datePickerDate > Date() {
            let content = UNMutableNotificationContent()
            content.title = "Checklist Reminder:"
            content.body = groupNameTextField.text!
            content.sound = UNNotificationSound.default
            
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.month, .day, .hour, .minute], from: datePickerDate)
    
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "\(notificationId)", content: content, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            center.add(request)
            print("Scheduled Checklist: \(request) for itemID: \(notificationId)")
        }
       }
        
        func removeNotification(notificationId: Int) {
          let center = UNUserNotificationCenter.current()
          center.removePendingNotificationRequests(withIdentifiers: ["\(notificationId)"])
          print("Remove Scheduled Checklist for itemID: \(notificationId)")
        }
    
        @objc func saveGroup() {
            print("Save group")
            let groupText = groupNameTextField.text
            var tempMatch: String = ""
            fetchAndPrintEachNoteGroup()
            for i in checklistNameArray {
                if i == groupText {
                    tempMatch = i
                }
            }
            if (fromOptionsDisclosure == false) {
                if (tempMatch != "") {
                    print("This Checklist Name Exists Aleady")
                    let alert = UIAlertController(title: "Checklist Name Taken", message: "Please choose another checklist name.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    }
            }

            if (fromOptionsDisclosure == false) {
                let createChecklistViewController = createChecklistsContrll
                createChecklistViewController!.managedObjectContext = managedObjectContext
                self.delegate = createChecklistViewController
                
                if ((remindMe == true) && (datePickerDate > Date())) {
                notificationCount = SharedNotificationCount.nextChecklistItemID()
                itemNumber = notificationCount as NSNumber
                scheduleNotification(notificationId: itemNumber as! Int)
                }
                
                else {
                itemNumber = 0 as NSNumber
                }
                
                delegate?.retrievedChecklistName(checklistNameText: groupText!, checklistIconName: checklistIcon, remindMe: remindMe, passedDate: datePickerDate, itemNumber: itemNumber!)
                self.dismiss(animated: true)
                self.navigationController?.popViewController(animated: true)
            }
            else if (fromOptionsDisclosure == true) {
                let createChecklistViewController = createChecklistsContrll
                createChecklistViewController!.managedObjectContext = managedObjectContext
                self.delegateEdit = createChecklistViewController
                
                if ((remindMe == true) && (datePickerDate > Date())) {
                    notificationCount = itemNumber as! Int
                    itemNumber = notificationCount as NSNumber
                    scheduleNotification(notificationId: notificationCount)
                }
                
                if (remindMe == false) {
                    notificationCount = itemNumber as! Int
                    itemNumber = notificationCount as NSNumber
                    removeNotification(notificationId: notificationCount)
                }
                
                delegateEdit?.retrievedChecklistName2(checklistNameText: groupText!, checklistIconName: checklistIcon, checklist: checklistToEdit!, remindMe: remindMe, passedDate: passedDate, itemNumber: itemNumber!)
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
        
        groupNameTextField.resignFirstResponder()
        let value = mySwitch.isOn
        if (value == true) {
            remindMe = true
        }
        else if (value == false) {
            remindMe = false
        }
    }
        
        @objc func cancelGroup() {
            print("Cancel Checklist")
            self.dismiss(animated: true)
        }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (groupNameTextField.text != "") {
            saveGroupButton.backgroundColor = .rgb(red: 0, green: 172, blue: 237)
            saveGroupButton.isEnabled = true
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if (groupNameTextField.text != "") {
            saveGroupButton.backgroundColor = .rgb(red: 0, green: 172, blue: 237)
            saveGroupButton.isEnabled = true
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        if (groupNameTextField.text == "") {
            saveGroupButton.backgroundColor = .darkGray
            saveGroupButton.isEnabled = false
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if (groupNameTextField.text != "") {
            saveGroupButton.backgroundColor = .rgb(red: 0, green: 172, blue: 237)
            saveGroupButton.isEnabled = true
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        if (groupNameTextField.text == "") {
            saveGroupButton.backgroundColor = .darkGray
            saveGroupButton.isEnabled = false
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
}

