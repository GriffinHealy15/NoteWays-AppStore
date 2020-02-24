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
import AudioToolbox

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
    var noteTextField = UITextView(text: "", font: UIFont(name: "PingFangHK-Regular", size: 20), textColor: .lightGray, textAlignment: .left)
    var attString: NSAttributedString?
    lazy var saveButton = UIButton(title: "Save Note", titleColor: .black, font: .boldSystemFont(ofSize: 18), backgroundColor: .white, target: self, action: #selector(saveNote))
    var tempNotePhotoID: NSNumber?
    
    var soundID: SystemSoundID = 0
    
    override func viewDidLoad() {
       super.viewDidLoad()
       noteTextField.delegate = self
       noteTextField.text = noteText
       noteTextField.textColor = .white
       view.backgroundColor = .rgb(red: 0, green: 170, blue: 245)
       saveButton.layer.cornerRadius = 25
       saveButton.layer.borderColor = UIColor.black.cgColor
       saveButton.layer.borderWidth = 1.0
       noteTextField.autocapitalizationType = .none
       noteTextField.backgroundColor = .rgb(red: 0, green: 170, blue: 245)
       navigationController?.navigationBar.isHidden = false
       title = "Edit Note"
       navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "SaveNote"), style: .plain, target: self, action: #selector(saveNote))
       navigationItem.rightBarButtonItem?.tintColor = .green
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelNote))
       let formView = UIView()
        
       formView.stack(UIView().withHeight(5),
                      noteTextField.withHeight(650),
                      UIView().withHeight(30),spacing: 16).withMargins(.init(top: 0, left: 10, bottom: 0, right: 10))
       
       formContainerStackView.padBottom(-24)
       formContainerStackView.addArrangedSubview(formView)
       }
    
    @objc func cancelNote() {
        dismiss(animated: true)
    }
    
    @objc func saveNote() {
        loadSoundEffect("swipe.mp3")
        playSoundEffect()
        let tempNoteIdArray = noteToEdit?.notePhotoIdArray
        print("Deleting all images before re-saving new images...")
        
        print("Saving note...")
        noteText = noteTextField.text
        noteToEdit?.noteText = noteText
        noteToEdit?.notePhotoId = nil
        noteToEdit?.notePhotoIdArray = []
        noteToEdit?.notePhotoLocation = []
        // Save image
        if noteArray != [] {
            if !noteToEdit!.hasPhoto {
                for imageInArray in 0...noteArray.count - 1 {
                    noteToEdit!.notePhotoId = Notes.noteNextPhotoID() as NSNumber
                    tempNotePhotoID = noteToEdit!.notePhotoId!
                    noteToEdit!.notePhotoIdArray.append(noteToEdit!.notePhotoId!)
                    noteToEdit!.notePhotoLocation.append(notesLocationArray[imageInArray]! as NSNumber)
                    if let data = noteArray[imageInArray]!.jpegData(compressionQuality: 0.5) {
                        // 3
                        do {
                            try data.write(to: noteToEdit!.photoURL, options: .atomic)
                        } catch {
                            print("Error writing file: \(error)")
                        }
                    }
                }
            }
        }
        
         do {
                  try managedObjectContext.save()
                  // error handling for save()
              } catch {
                  // 4
                  // if save fails call below function with error message
                   print("Error saving")
              }
        self.navigationController?.dismiss(animated: true)
        
                 if tempNoteIdArray != [] {
                    for noteToDelete in tempNoteIdArray! {
                        noteToEdit?.notePhotoId = noteToDelete
                        do {
                            // remove the file at location photoURL.
                            try FileManager.default.removeItem(at: noteToEdit!.photoURL)
                            print("removed")
                        } catch {
                            print("Error removing file: \(error)")
                        }
                    }
                }
        
                    noteToEdit?.notePhotoId = tempNotePhotoID
                        do {
                            try managedObjectContext.save()
                            // error handling for save()
                        } catch {
                            // 4
                            // if save fails call below function with error message
                             print("Error saving")
                        }
//
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (viewAppearedOnceBool == false) {
        var count: Int = 0
        if (noteArray != []) {
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
        let templocation = notesLocationArray[currentNoteImage]! + count
        let location = templocation
        noteTextField.textStorage.insert(attString!, at: location)
        viewAppearedOnceBool = true
        count = count + 1
        print(count)
        print(notesLocationArray.count)
            }
        }
        }
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
    
        func textViewDidBeginEditing(_ textView: UITextView) {
    //        noteTextField.text = ""
            noteTextField.textColor = .white
            noteTextField.font = UIFont(name: "PingFangHK-Regular", size: 20)
        }

        func textViewDidChange(_ textView: UITextView) {
            noteText = noteTextField.text
            noteTextField.font = .boldSystemFont(ofSize: 18)
            
            noteArray = []
            notesLocationArray = []
            noteText = noteTextField.text
            noteTextField.font = UIFont(name: "PingFangHK-Regular", size: 20)
            noteTextField.attributedText.enumerateAttribute(NSAttributedString.Key.attachment, in: NSRange(location: 0, length: noteTextField.attributedText.length), options: []) { (value, range, stop) in

                if (value is NSTextAttachment){
                    
                  let attachment: NSTextAttachment? = (value as? NSTextAttachment)

                    if ((attachment?.image) != nil) {
                        noteArray.append(attachment!.image!)
                        notesLocationArray.append(range.location)
                    }else{
                        print("No image attched")
                    }
                }
            }
        }

}
