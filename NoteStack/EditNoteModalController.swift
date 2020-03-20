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

protocol EditNoteDelegate {
    func retrievedEditNoteText(NoteGroupNamePassed: String)
}

class EditNoteModalController: LBTAFormController, UITextViewDelegate, UIScrollViewDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate, PhotoOrLocationDelegate2 {
    
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
    
    var singleController = CreateNoteControllerSingle()
    // delegate var for the protocol above
    var delegate: EditNoteDelegate?
    var NoteGroupNamePassed: String = ""
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
    var keyBoardHeightGlobal: CGFloat = 0
    
    var noteTextField1: NSLayoutConstraint?
    var noteTextField2: NSLayoutConstraint?
    
    var date = Date()
    
    var noteImagesArray: [UIImage] = []
    var noteLocationsArray: [Int] = []
    var noteAttributedArray: [NSAttributedString] = []
    var noteLocation: Int = 0
    var attString2: NSAttributedString?
    var attString1: NSAttributedString?
    
    var rgbColorArray: [NSNumber] = []
    var rgbColorArrayFloat: [CGFloat] = []
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    
    override func viewDidLoad() {
       super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(
        self,
        selector: #selector(keyboardWillShow),
        name: UIResponder.keyboardWillShowNotification,
        object: nil)

        let noteColorArray =  noteToEdit?.noteColorArray
        for i in 0...noteColorArray!.count - 1 {
            rgbColorArrayFloat.append(noteColorArray![i] as! CGFloat)
        }
        //print(rgbColorArrayFloat)
        for _ in 0...rgbColorArrayFloat.count - 1 {
            red = rgbColorArrayFloat[0]
            green = rgbColorArrayFloat[1]
            blue = rgbColorArrayFloat[2]
        }
       view.backgroundColor = .rgb(red: red, green: green, blue: blue)
       noteTextField.backgroundColor = .rgb(red: red, green: green, blue: blue)
       noteTextField.delegate = self
       scrollView.delegate = self
       noteTextField.text = noteText
       if ((red + green > 415) || (red + blue > 415) || (blue + green > 415)) {
       noteTextField.textColor = .black
       noteTextField.tintColor = .black
       }
       else {
           noteTextField.textColor = .white
           noteTextField.tintColor = .white
       }
       noteTextField.tintColor = .orange
       //view.backgroundColor = .rgb(red: 0, green: 170, blue: 245)
       
       //view.backgroundColor = UIColor(patternImage: UIImage(named: "whitebackground")!)
       saveButton.layer.cornerRadius = 25
       saveButton.layer.borderColor = UIColor.black.cgColor
       saveButton.layer.borderWidth = 1.0
       noteTextField.autocapitalizationType = .none
       //noteTextField.backgroundColor = .rgb(red: 0, green: 170, blue: 245)
       //noteTextField.backgroundColor = UIColor(patternImage: UIImage(named: "whitebackground")!)
       navigationController?.navigationBar.isHidden = false
       title = "Edit Note"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveNote))
       navigationItem.rightBarButtonItem?.tintColor = .black
       navigationItem.leftBarButtonItems = [UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelNote)), UIBarButtonItem(image: #imageLiteral(resourceName: "cameraicon"), style: .plain, target: self, action: #selector(addSettings(_:)))]
       navigationItem.leftBarButtonItems![1].tintColor = .black
       navigationItem.leftBarButtonItems![0].tintColor = .rgb(red: 0, green: 197, blue: 255)
        
       if (view.frame.size.height == 896) {
       print("iPhone Xr, iPhone Xs Max, iPhone 11, iPhone 11 Pro Max")
       noteTextField1 = noteTextField.heightAnchor.constraint(equalToConstant: view.frame.size.height - (view.frame.size.height * 0.47) - ((self.navigationController?.navigationBar.frame.size.height)!))
       noteTextField2 = noteTextField.heightAnchor.constraint(equalToConstant: view.frame.size.height - 140)
       }
       else if (view.frame.size.height == 812) {
       print("iPhone X, iPhone XS, iPhone 11 Pro")
       noteTextField1 = noteTextField.heightAnchor.constraint(equalToConstant: view.frame.size.height - (view.frame.size.height * 0.50) - ((self.navigationController?.navigationBar.frame.size.height)!))
       noteTextField2 = noteTextField.heightAnchor.constraint(equalToConstant: view.frame.size.height - 140)
       }
       else if (view.frame.size.height == 736) {
       print("iPhone 6s Plus, iPhone 7 Plus, iPhone 8 Plus")
       noteTextField1 = noteTextField.heightAnchor.constraint(equalToConstant: view.frame.size.height - (view.frame.size.height * 0.43) - ((self.navigationController?.navigationBar.frame.size.height)!))
       noteTextField2 = noteTextField.heightAnchor.constraint(equalToConstant: view.frame.size.height - 110)
       }
       else if (view.frame.size.height == 667) {
       print("iPhone 6,iPhone 6s, iPhone 6 Plus ,iPhone 7, iPhone 8")
       noteTextField1 = noteTextField.heightAnchor.constraint(equalToConstant: view.frame.size.height - (view.frame.size.height * 0.46) - ((self.navigationController?.navigationBar.frame.size.height)!))
       noteTextField2 = noteTextField.heightAnchor.constraint(equalToConstant: view.frame.size.height - 100)
       }
       else if (view.frame.size.height == 568) {
       print("iPhone SE")
       noteTextField1 = noteTextField.heightAnchor.constraint(equalToConstant: view.frame.size.height - (view.frame.size.height * 0.53) - ((self.navigationController?.navigationBar.frame.size.height)!))
       noteTextField2 = noteTextField.heightAnchor.constraint(equalToConstant: view.frame.size.height - 100)
       }
       else {
       print("Other iPhone Model")
       print(view.frame.size.height)
       noteTextField1 = noteTextField.heightAnchor.constraint(equalToConstant: view.frame.size.height - (view.frame.size.height * 0.650) - ((self.navigationController?.navigationBar.frame.size.height)!))
       noteTextField2 = noteTextField.heightAnchor.constraint(equalToConstant: view.frame.size.height - 140)
       }

       noteTextField1!.isActive = false
       noteTextField2!.isActive = true
        
       noteTextField.translatesAutoresizingMaskIntoConstraints = false

       let formView = UIView()
        
       formView.stack(UIView().withHeight(5),
                      noteTextField,
                      UIView().withHeight(30),spacing: 16).withMargins(.init(top: 0, left: 10, bottom: 0, right: 10))
       
       // Disable scroll for the main view
       scrollView.isScrollEnabled = false
       formContainerStackView.padBottom(-24)
       formContainerStackView.addArrangedSubview(formView)
       }
    
    @objc func addSettings(_ sender: Any) {
        let vc = SettingsPopupController2()
        vc.managedObjectContext = managedObjectContext
        vc.preferredContentSize = CGSize(width: 85, height: 85)
        vc.modalPresentationStyle = .popover
        vc.scrollView.isScrollEnabled = false
        vc.createEditNoteViewController = self
        let ppc = vc.popoverPresentationController
        ppc?.permittedArrowDirections = .any
        ppc?.delegate = self
        ppc!.sourceView = sender as? UIView
        ppc?.barButtonItem = navigationItem.leftBarButtonItems![1]
        present(vc, animated: true, completion: nil)
    }
    
    func retrievedPhoto(image: UIImage) {
        navigationItem.rightBarButtonItem?.isEnabled = true
        navigationItem.rightBarButtonItem?.tintColor = .black
        noteImage = image
        noteImagesArray.append(noteImage!)
        //imageView.image = noteImage
        let attachment = NSTextAttachment()
        attachment.image = noteImage
        let newImageWidth = (noteTextField.bounds.size.width - 9)
        let scale = newImageWidth/image.size.width
        let newImageHeight = image.size.height * scale
        //resize this
        attachment.bounds = CGRect.init(x: 0, y: 0, width: newImageWidth, height: newImageHeight)
        attString2 = NSAttributedString(attachment: attachment)
        noteAttributedArray.append(attString2!)
        //add this attributed string to the current position.
        noteTextField.textStorage.insert(attString2!, at: noteTextField.selectedRange.location)
        noteLocation = noteTextField.selectedRange.location
        noteLocationsArray.append(noteLocation)
        attString1 = NSAttributedString(string: "\n")
        //noteTextField.textStorage.insert(attString1!, at: noteTextField.selectedRange.location + 1)
        noteTextField.selectedRange.location = noteTextField.selectedRange.location  + 1
        noteTextField.becomeFirstResponder()
    noteTextField.scrollRangeToVisible(NSRange(location:noteTextField.selectedRange.location, length:0))
        if ((red + green > 415) || (red + blue > 415) || (blue + green > 415)) {
        noteTextField.textColor = .black
        noteTextField.tintColor = .black
        }
        else {
            noteTextField.textColor = .white
            noteTextField.tintColor = .white
        }
        noteTextField.font = UIFont(name: "PingFangHK-Regular", size: 20)
        //print(noteTextField.selectedRange.location)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
           return .none
       }
    
    
    @objc func cancelNote() {
        //dismiss(animated: true)
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.popViewController(animated: true)
    }
    
    @objc func saveNote() {
        //loadSoundEffect("swipe.mp3")
        //playSoundEffect()
        let tempNoteIdArray = noteToEdit?.notePhotoIdArray
        //print("Deleting all images before re-saving new images...")
        print("Saving note...")
        noteText = noteTextField.text
        //print(noteText.count)
        //print(noteTextField.selectedRange.location)
        noteToEdit?.noteText = noteText
        noteToEdit?.notePhotoId = nil
        noteToEdit?.date = date
        //print(date)
        noteToEdit?.notePhotoIdArray = []
        noteToEdit?.notePhotoLocation = []
        
        
        
        //--- Start --- EDITED PHOTO - REMOVE SECTION IF ERRORS OCCUR --- START
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
        
        //--- END --- EDITED PHOTO - REMOVE SECTION IF ERRORS OCCUR  --- END
        
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
        //self.navigationController?.dismiss(animated: true)
        // unhide tab bar
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
        
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
        
            let createNoteController = singleController
            createNoteController.managedObjectContext = managedObjectContext
            self.delegate = createNoteController
            delegate?.retrievedEditNoteText(NoteGroupNamePassed: NoteGroupNamePassed)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (viewAppearedOnceBool == false) {
        var count: Int = 0
        if (noteArray != []) {
            for currentNoteImage in 0...noteArray.count - 1 {
        noteImageFromArray = noteArray[currentNoteImage]
        let attachment = NSTextAttachment()
                attachment.image = noteImageFromArray
        let newImageWidth = (noteTextField.bounds.size.width - 9)
         let scale = newImageWidth/noteImage!.size.width
         let newImageHeight = noteImage!.size.height * scale
        //resize this
        attachment.bounds = CGRect.init(x: 0, y: 0, width: newImageWidth, height: newImageHeight)
        attString = NSAttributedString(attachment: attachment)
        //add this attributed string to the current position.
        let templocation = notesLocationArray[currentNoteImage]! + count
        //print(templocation)
        let location = templocation
        //print(location)
        noteTextField.textStorage.insert(attString!, at: location)
        viewAppearedOnceBool = true
        count = count + 1
        //print(count)
        //print(notesLocationArray.count)
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
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            keyBoardHeightGlobal = keyboardHeight
            //print(keyBoardHeightGlobal)
            //print(self.view.frame.height)
        }
    }
    
        func textViewDidBeginEditing(_ textView: UITextView) {
    //        noteTextField.text = ""
            if ((red + green > 415) || (red + blue > 415) || (blue + green > 415)) {
            noteTextField.textColor = .black
            noteTextField.tintColor = .black
            }
            else {
                noteTextField.textColor = .white
                noteTextField.tintColor = .white
            }
            noteTextField.font = UIFont(name: "PingFangHK-Regular", size: 20)
            noteTextField1!.isActive = true
            noteTextField2!.isActive = false
        }

        func textViewDidChange(_ textView: UITextView) {
            //print(noteTextField.selectedRange.location)
            noteTextField1!.isActive = true
            noteTextField2!.isActive = false
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
    
    func textViewDidEndEditing(_ textView: UITextView) {
           noteTextField1!.isActive = false
           noteTextField2!.isActive = true
       }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y < 0) {
            scrollView.keyboardDismissMode = .onDrag
            noteTextField1!.isActive = false
            noteTextField2!.isActive = true
        }
        if (scrollView.contentOffset.y > 0) {
            scrollView.keyboardDismissMode = .none
        }
    }
}
