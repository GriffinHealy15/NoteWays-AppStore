//
//  EditNoteModalController.swift
//  NoteStack
//
//  Created by Griffin Healy on 2/6/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//

import UIKit
import LBTATools
import CoreData

protocol EditeNoteDelegate {
    func retrievedNoteText(noteText: String)
}

class EditNoteModalController: LBTAFormController {
    
    init(passednoteText: String) {
        noteText = passednoteText
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var noteToEdit: Notes? 
    // Managed object context
    var managedObjectContext: NSManagedObjectContext!
   // var delegate: EditNoteDelegate?
    var noteText: String
    var noteTextField = UITextView(text: "", font: .boldSystemFont(ofSize: 18), textColor: .black, textAlignment: .left)
    lazy var saveButton = UIButton(title: "Save Note", titleColor: .black, font: .boldSystemFont(ofSize: 18), backgroundColor: .white, target: self, action: #selector(saveNote))
    
    override func viewDidLoad() {
       super.viewDidLoad()
       noteTextField.text = noteText
       view.backgroundColor = .rgb(red: 178, green: 253, blue: 254)
       saveButton.layer.cornerRadius = 25
       saveButton.layer.borderColor = UIColor.black.cgColor
       saveButton.layer.borderWidth = 1.0
       noteTextField.autocapitalizationType = .none
       noteTextField.backgroundColor = .rgb(red: 178, green: 253, blue: 254)
       navigationController?.navigationBar.isHidden = false
       self.navigationController!.navigationBar.tintColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
       let formView = UIView()
       formView.stack(UIView().withHeight(5),
                      saveButton.withHeight(50),
                      noteTextField.withHeight(500),
                      UIView().withHeight(30),spacing: 16).withMargins(.init(top: 0, left: 10, bottom: 0, right: 10))
       
       formContainerStackView.padBottom(-24)
       formContainerStackView.addArrangedSubview(formView)
       }
    
    @objc func saveNote() {
        print("Saving note...")
        noteText = noteTextField.text
        noteToEdit?.noteText = noteText
         do {
                  try managedObjectContext.save()
                  // error handling for save()
              } catch {
                  // 4
                  // if save fails call below function with error message
                   print("Error saving")
              }
        self.navigationController?.dismiss(animated: true)
    }
}
