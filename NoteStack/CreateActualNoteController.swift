//
//  CreateNoteModalController.swift
//  NoteStack
//
//  Created by Griffin Healy on 2/3/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//

import UIKit
import CoreData
import LBTATools


protocol CreateNoteDelegate {
    func retrievedNoteText(noteText: String)
}

class CreateActualNoteController: LBTAFormController, UITextViewDelegate, UINavigationControllerDelegate {

    // MARK: UI Elements
    
    // Managed object context
    var managedObjectContext: NSManagedObjectContext!
    
    // delegate var for the protocol above
    var delegate: CreateNoteDelegate?
       
    var noteTextField = UITextView(text: "Type some text...", font: .boldSystemFont(ofSize: 18), textColor: .lightGray, textAlignment: .left)
    var noteText = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .rgb(red: 178, green: 253, blue: 254)
        
        noteTextField.autocapitalizationType = .none
        noteTextField.backgroundColor = .rgb(red: 178, green: 253, blue: 254)
        noteTextField.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "SaveNote"), style: .plain, target: self, action: #selector(saveNote))
        
        let formView = UIView()
        formView.stack(noteTextField.withHeight(500))
                  
              formContainerStackView.padBottom(-24)
              formContainerStackView.addArrangedSubview(formView)
    }
    
    @objc func saveNote() {
        print("Saving note...")
        let createNoteController = CreateNoteController()
        createNoteController.managedObjectContext = managedObjectContext
        self.delegate = createNoteController
        delegate?.retrievedNoteText(noteText: noteText)
        
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        noteTextField.text = ""
        noteTextField.textColor = .black
    }
    
    func textViewDidChange(_ textView: UITextView) {
        noteText = noteTextField.text
    }
}
