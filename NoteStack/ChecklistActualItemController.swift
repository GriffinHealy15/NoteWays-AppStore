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
    
    var enterfolderLabel = UILabel(text: "Enter a name for this item", font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 15)!, textColor: .darkGray, textAlignment: .center, numberOfLines: 0)
    
    var chooseIconLabel = UILabel(text: "Choose an icon for this checklist", font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 15)!, textColor: .black, textAlignment: .center, numberOfLines: 0)
    
    var groupNameTextField = IndentedTextField(placeholder: "Checklist Name", padding: 24, cornerRadius: 25)
    
    lazy var saveGroupButton = UIButton(title: "Save", titleColor: .white, font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 18)!, backgroundColor: .rgb(red: 0, green: 172, blue: 237), target: self, action: #selector(saveGroup))
    
    lazy var cancelGroupButton = UIButton(title: "Cancel", titleColor: .yellow, font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 18)!, backgroundColor: .lightGray, target: self, action: #selector(cancelGroup))
    
    var checklistNameArray = [String]()
    var checklistIcon: String = "Default"
    
    override func viewDidLoad() {
       super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(saveGroup))
        navigationItem.rightBarButtonItem?.tintColor = .rgb(red: 0, green: 197, blue: 255)
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        if (fromOptionsDisclosure == true) {
            groupNameTextField.text = checklistName
            navigationItem.rightBarButtonItem?.isEnabled = true
            checklistIcon = checklistIconName!
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
    
        let formView = UIView()
        formView.stack(UIView().withHeight(10),newfolderLabel.withHeight(30), UIView().withHeight(25),enterfolderLabel.withHeight(30),groupNameTextField.withWidth(100),UIView().withHeight(15), UIView().withHeight(30)).withMargins(.init(top: 0, left: 10, bottom: 0, right: 10))
       
       formContainerStackView.padBottom(0)
       formContainerStackView.addArrangedSubview(formView)
        
       }
    
    override func willMove(toParent parent: UIViewController?) {
        if #available(iOS 11, *) {
        self.navigationController!.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
          self.navigationController?.navigationBar.prefersLargeTitles = true
          self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        }
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
            let groupText = groupNameTextField.text
        
            if (fromOptionsDisclosure == false) {
                
                let item: Items
                 item = Items(context: managedObjectContext)
                 item.itemName = groupText!
                 item.date = date
                
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
//                let createChecklistViewController = ChecklistsViewController()
//                createChecklistViewController.managedObjectContext = managedObjectContext
//                self.delegateEdit = createChecklistViewController
//                delegateEdit?.retrievedChecklistName2(checklistNameText: groupText!, checklistIconName: checklistIcon, checklist: checklistToEdit!)
//                self.dismiss(animated: true)
//                self.navigationController?.popViewController(animated: true)
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

