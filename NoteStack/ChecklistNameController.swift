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
    func retrievedChecklistName(checklistNameText: String, checklistIconName: String)
}


protocol EditChecklistNameGroupDelegate {
    func retrievedChecklistName2(checklistNameText: String, checklistIconName: String, checklist: ChecklistsGroup)
}

class ChecklistNameController: LBTAFormController, UINavigationControllerDelegate, UITextFieldDelegate, PickIconDelegate {
    
    // CreateActualNoteController
    var createChecklistsContrll:ChecklistsViewController?

    // Managed object context
    var managedObjectContext: NSManagedObjectContext!
    var checklistToEdit: ChecklistsGroup?
    
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
    
    var checklistNameArray = [String]()
    var checklistIcon: String = "Default"
    
    override func viewDidLoad() {
       super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(saveGroup))
        navigationItem.rightBarButtonItem?.tintColor = .rgb(red: 0, green: 197, blue: 255)
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        if (fromOptionsDisclosure == true) {
            newfolderLabel.text = "Edit Checklist"
            groupNameTextField.text = checklistName
            iconButton.setImage(UIImage.init(named: checklistIconName!), for: .normal)
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
        iconButton.layer.borderWidth = 0.5
        iconButton.layer.borderColor = UIColor.lightGray.cgColor
        iconButton.layer.cornerRadius = 10
        iconButton.layer.backgroundColor = UIColor.white.cgColor
        let formView = UIView()
        formView.stack(UIView().withHeight(10),newfolderLabel.withHeight(30), UIView().withHeight(25),enterfolderLabel.withHeight(30),groupNameTextField.withWidth(100),UIView().withHeight(15), chooseIconLabel.withHeight(30),
                       iconButton.withHeight(70), UIView().withHeight(30)).withMargins(.init(top: 0, left: 10, bottom: 0, right: 10))
       
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
                delegate?.retrievedChecklistName(checklistNameText: groupText!, checklistIconName: checklistIcon)
                self.dismiss(animated: true)
                self.navigationController?.popViewController(animated: true)
            }
            else if (fromOptionsDisclosure == true) {
                let createChecklistViewController = createChecklistsContrll
                createChecklistViewController!.managedObjectContext = managedObjectContext
                self.delegateEdit = createChecklistViewController
                delegateEdit?.retrievedChecklistName2(checklistNameText: groupText!, checklistIconName: checklistIcon, checklist: checklistToEdit!)
                self.dismiss(animated: true)
                self.navigationController?.popViewController(animated: true)
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

