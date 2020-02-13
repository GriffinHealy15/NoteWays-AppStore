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

class EditNoteModalController: LBTAFormController, UITextViewDelegate, UINavigationControllerDelegate {
    
    init(passednoteText: String, passedImage: UIImage?,
         passedNotesArray: [UIImage?], passedLocationsArray: [Int?]) {
        noteText = passednoteText
        noteImage = passedImage
        noteArray = passedNotesArray
        notesLocationArray = passedLocationsArray
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var viewAppearedOnceBool: Bool = false
    var noteToEdit: Notes? 
    // Managed object context
    var managedObjectContext: NSManagedObjectContext!
   // var delegate: EditNoteDelegate?
    var noteText: String
    var noteImage: UIImage?
    var noteImageFromArray: UIImage?
    var noteArray: [UIImage?] = []
    var notesLocationArray: [Int?] = []
    var noteTextField = UITextView(text: "", font: .boldSystemFont(ofSize: 18), textColor: .black, textAlignment: .left)
    var attString: NSAttributedString?
    lazy var saveButton = UIButton(title: "Save Note", titleColor: .black, font: .boldSystemFont(ofSize: 18), backgroundColor: .white, target: self, action: #selector(saveNote))
    
    override func viewDidLoad() {
       super.viewDidLoad()
       noteTextField.delegate = self
       noteTextField.text = noteText
       view.backgroundColor = .rgb(red: 178, green: 253, blue: 254)
       saveButton.layer.cornerRadius = 25
       saveButton.layer.borderColor = UIColor.black.cgColor
       saveButton.layer.borderWidth = 1.0
       noteTextField.autocapitalizationType = .none
       noteTextField.backgroundColor = .rgb(red: 178, green: 253, blue: 254)
       navigationController?.navigationBar.isHidden = false
       title = "Edit Note"
       navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "SaveNote"), style: .plain, target: self, action: #selector(saveNote))
       navigationItem.rightBarButtonItem?.tintColor = .green
       let formView = UIView()
        
       formView.stack(UIView().withHeight(5),
                      noteTextField.withHeight(650),
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
    
    override func viewDidAppear(_ animated: Bool) {
        if (viewAppearedOnceBool == false) {
        if (noteImage != nil) {
            for currentNoteImage in 0...noteArray.count - 1 {
        noteImageFromArray = noteArray[currentNoteImage]
        let attachment = NSTextAttachment()
                attachment.image = noteImageFromArray
        let newImageWidth = (noteTextField.bounds.size.width - 20 )
         let scale = newImageWidth/noteImage!.size.width
         let newImageHeight = noteImage!.size.height * scale
        //resize this
        attachment.bounds = CGRect.init(x: 0, y: 0, width: newImageWidth, height: newImageHeight)
        attString = NSAttributedString(attachment: attachment)
        //add this attributed string to the current position.
        let templocation = notesLocationArray[currentNoteImage]!
        let location = templocation
        noteTextField.textStorage.insert(attString!, at: location)
        viewAppearedOnceBool = true
            }
        }
        }
    }
    
        func textViewDidBeginEditing(_ textView: UITextView) {
    //        noteTextField.text = ""
            noteTextField.textColor = .black
            noteTextField.font = .boldSystemFont(ofSize: 18)
        }

        func textViewDidChange(_ textView: UITextView) {
            noteText = noteTextField.text
            noteTextField.font = .boldSystemFont(ofSize: 18)
        }

}
