//
//  GroupNameController.swift
//  NoteStack
//
//  Created by Griffin Healy on 2/25/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//


import UIKit
import LBTATools
import CoreData

protocol CreateNoteGroupDelegate {
    func retrievedGroupName(groupNameText: String)
}

class GroupNameController: LBTAFormController, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // CreateActualNoteController
    var createGroupNameContrll:CreateNoteGroupController?

    // Managed object context
    var managedObjectContext: NSManagedObjectContext!
    
    // delegate var for the protocol above
    var delegate: CreateNoteGroupDelegate?
    
    var newfolderLabel = UILabel(text: "New Folder", font: UIFont(name: "PingFangTC-Semibold", size: 18)!, textColor: .black, textAlignment: .center, numberOfLines: 0)
    
    var enterfolderLabel = UILabel(text: "Enter a name for this folder", font: UIFont(name: "PingFangTC-Semibold", size: 14)!, textColor: .darkGray, textAlignment: .center, numberOfLines: 0)
    
    var groupNameTextField = IndentedTextField(placeholder: "Group Name", padding: 24, cornerRadius: 25)
    
    lazy var saveGroupButton = UIButton(title: "Save", titleColor: .white, font: UIFont(name: "PingFangTC-Semibold", size: 16)!, backgroundColor: .rgb(red: 0, green: 172, blue: 237), target: self, action: #selector(saveGroup))
    
    lazy var cancelGroupButton = UIButton(title: "Cancel", titleColor: .yellow, font: UIFont(name: "PingFangTC-Semibold", size: 16)!, backgroundColor: .lightGray, target: self, action: #selector(cancelGroup))
    
    var notesGroupArray = [String]()
    
    override func viewDidLoad() {
       super.viewDidLoad()
        view.backgroundColor = .rgb(red: 242, green: 242, blue: 242)
        enterfolderLabel.textColor = .black
        groupNameTextField.textColor = .black
        groupNameTextField.attributedPlaceholder = NSAttributedString(string: "Group Name",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        groupNameTextField.delegate = self
        self.scrollView.isScrollEnabled = false
        saveGroupButton.layer.cornerRadius = 10
        cancelGroupButton.layer.cornerRadius = 10
        groupNameTextField.backgroundColor = .white
        groupNameTextField.layer.borderWidth = 0.3
        groupNameTextField.layer.borderColor = UIColor.lightGray.cgColor
        groupNameTextField.layer.cornerRadius = 10
        groupNameTextField.withHeight(30)
        saveGroupButton.isEnabled = false
        saveGroupButton.backgroundColor = .darkGray
        let formView = UIView()
        formView.stack(UIView().withHeight(50),newfolderLabel.withHeight(30), UIView().withHeight(25),enterfolderLabel.withHeight(30),groupNameTextField.withWidth(100),UIView().withHeight(40),formView.hstack(cancelGroupButton.withWidth(117), UIView().withWidth(10),
            saveGroupButton)).withMargins(.init(top: 0, left: 10, bottom: 0, right: 10))
       
       formContainerStackView.padBottom(0)
       formContainerStackView.addArrangedSubview(formView)
        
       }
    
        func fetchAndPrintEachNoteGroup() {
            notesGroupArray = []
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
            //print(notesGroupArray)
        }
    
        @objc func saveGroup() {
            print("Save group")
            let groupText = groupNameTextField.text
            var tempMatch: String = ""
            fetchAndPrintEachNoteGroup()
            for i in notesGroupArray {
                if i == groupText {
                    tempMatch = i
                }
            }
            if (tempMatch != "") {
                print("This Group Name Exists Aleady")
                let alert = UIAlertController(title: "Group Name Taken", message: "Please choose another group name.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                let createNoteGroupController = CreateNoteGroupController()
                createNoteGroupController.managedObjectContext = managedObjectContext
                self.delegate = createNoteGroupController
                delegate?.retrievedGroupName(groupNameText: groupText!)
                self.dismiss(animated: true)
            }
        }
        
        @objc func cancelGroup() {
            print("Cancel Group")
            self.dismiss(animated: true)
        }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (groupNameTextField.text != "") {
            saveGroupButton.backgroundColor = .rgb(red: 0, green: 172, blue: 237)
            saveGroupButton.isEnabled = true
        }
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if (groupNameTextField.text != "") {
            saveGroupButton.backgroundColor = .rgb(red: 0, green: 172, blue: 237)
            saveGroupButton.isEnabled = true
        }
        
        if (groupNameTextField.text == "") {
            saveGroupButton.backgroundColor = .darkGray
            saveGroupButton.isEnabled = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if (groupNameTextField.text != "") {
            saveGroupButton.backgroundColor = .rgb(red: 0, green: 172, blue: 237)
            saveGroupButton.isEnabled = true
        }
        
        if (groupNameTextField.text == "") {
            saveGroupButton.backgroundColor = .darkGray
            saveGroupButton.isEnabled = false
        }
    }
}

