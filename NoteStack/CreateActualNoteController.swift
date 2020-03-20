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
import AudioToolbox


private let dateFormatter: DateFormatter = {
    // create a dateFormatter object
    let formatter = DateFormatter()
    // give the object a date and time style
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    // return the formatter to dateFormatter
    //print("**Date Formatter Executed")
    return formatter
}()

protocol CreateNoteDelegate {
    func retrievedNoteText(onlyNoteText: String, NoteGroupNamePassed: String, noteText: String, noteImage: UIImage?, noteImagesArray: [UIImage?],
                           noteLocationsArray: [Int?])
}

class CreateActualNoteController: LBTAFormController, UIPopoverPresentationControllerDelegate, UITextViewDelegate, UIScrollViewDelegate, UINavigationControllerDelegate, PhotoOrLocationDelegate {
    

    // MARK: UI Elements
    
    // Managed object context
    var managedObjectContext: NSManagedObjectContext!
    
    var currentNotesGroup: NotesGroup?
    
    var NoteGroupNamePassed: String = ""
    
    var singleController = CreateNoteControllerSingle()
    
    // delegate var for the protocol above
    var delegate: CreateNoteDelegate?
       
    var noteTextField = UITextView(text: "", font: UIFont(name: "PingFangHK-Regular", size: 20), textColor: .lightGray, textAlignment: .left)
    var noteText = ""
    var onlyNoteText = ""
    lazy var addPhotoButton = UIButton(image: #imageLiteral(resourceName: "photo"), tintColor: .black, target: self, action: #selector(addPhoto))
    
    lazy var addlocationButton = UIButton(image: #imageLiteral(resourceName: "location"), tintColor: .black, target: self, action: #selector(addLocation))
    
    let fill_view = UIView(backgroundColor: .purple)
    let fill_view1 = UIView(backgroundColor: .green)
    
    let imageView = UIImageView(frame: CGRect(x: 50, y: 50, width: 1, height: 1))
    
    var noteImage: UIImage? = nil
        
    var noteImagesArray: [UIImage] = []
    var noteLocationsArray: [Int] = []
    var noteAttributedArray: [NSAttributedString] = []
    var noteLocation: Int = 0
    var attString: NSAttributedString?
    var attString1: NSAttributedString?
        
    var soundID: SystemSoundID = 0
    
    var noteTextField1: NSLayoutConstraint?
    var noteTextField2: NSLayoutConstraint?
    
    var date = Date()
        
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var rgbColorArray: [CGFloat] = []
        
    {
        didSet
        {
            imageView.contentMode = .scaleAspectFill
            imageView.autoresizingMask = .flexibleHeight
            imageView.autoresizingMask = .flexibleWidth
            imageView.withHeight(15)
            imageView.withWidth(10)
            imageView.image = noteImage
            imageView.frame = CGRect(x: 10, y: 10, width: 1, height: 1)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0...2 {
        let randomNumber = Int.random(in: 0 ... 255)
            if i == 0 {
                red = CGFloat(randomNumber)
                rgbColorArray.append(red)
            }
            else if i == 1 {
                green = CGFloat(randomNumber)
                rgbColorArray.append(green)
            }
            else if i == 2 {
                blue = CGFloat(randomNumber)
                rgbColorArray.append(blue)
            }
        }
        
        view.backgroundColor = .rgb(red: red, green: green, blue: blue)
        noteTextField.backgroundColor = .rgb(red: red, green: green, blue: blue)
        //view.backgroundColor = .rgb(red: 0, green: 197, blue: 255)
        //noteTextField.backgroundColor = .rgb(red: 0, green: 197, blue: 255)
        fill_view.withHeight(50)
        fill_view1.withHeight(100)
        addPhotoButton.layer.cornerRadius = 25
        addPhotoButton.layer.borderColor = UIColor.black.cgColor
        addPhotoButton.layer.borderWidth = 1.0
        addPhotoButton.withHeight(75)
        addlocationButton.layer.cornerRadius = 25
        addlocationButton.layer.borderColor = UIColor.black.cgColor
        addlocationButton.layer.borderWidth = 1.0
        addlocationButton.withHeight(200)
        noteTextField.translatesAutoresizingMaskIntoConstraints = false
        noteTextField.autocapitalizationType = .none
        //noteTextField.backgroundColor = .rgb(red: 0, green: 170, blue: 245)
        //noteTextField.backgroundColor = UIColor(patternImage: UIImage(named: "temp")!)
        noteTextField.delegate = self
        scrollView.delegate = self
        noteTextField.font = UIFont(name: "PingFangHK-Regular", size: 20)
        //noteTextField.tintColor = .orange
        navigationController?.navigationBar.isHidden = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveNote))
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.tintColor = .darkGray
        navigationItem.leftBarButtonItems = [UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelNote)),UIBarButtonItem(image: #imageLiteral(resourceName: "cameraicon"), style: .plain, target: self, action: #selector(addSettings(_:)))]
        navigationItem.leftBarButtonItems![1].tintColor = .black
        navigationItem.leftBarButtonItems![0].tintColor = .rgb(red: 0, green: 197, blue: 255)
        title = "Create Note"
        let formView = UIView()
        
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
        
        formView.stack(UIView().withHeight(5),
        noteTextField, spacing: 16).withMargins(.init(top: 0, left: 10, bottom: 0, right: 10))
        
        // Disable scroll for the main view
        scrollView.isScrollEnabled = false
        formContainerStackView.padBottom(-24)
        formContainerStackView.addArrangedSubview(formView)

    }
    
    @objc func cancelNote() {
        //dismiss(animated: true)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func saveNote() {
        print("Saving note...")
        if noteText.count == 0 {
            noteText = noteTextField.text
            //print(noteText)
        }
//        if (noteText.count < noteTextField.selectedRange.location) {
//            let addToEnd = String(repeating: " ", count: noteTextField.selectedRange.location)
//            noteText = noteTextField.text + addToEnd
//        }
//        else {
        noteText = noteTextField.text
       // }
        
        //print(noteTextField.selectedRange.location)
        //print(noteText.count)
        //loadSoundEffect("swipe.mp3")
        //playSoundEffect()
        
        //let dateFound = format(date: date)
        
        let note: Notes
         note = Notes(context: managedObjectContext)
         note.noteText = noteText
         note.notePhotoId = nil
         note.date = date
        
        // Add each color (red, green, blue) to the note object attribute
        for i in 0...rgbColorArray.count - 1 {
            print(i)
            let colorAtEachIndex: CGFloat = rgbColorArray[i]
            let color: NSNumber = colorAtEachIndex as NSNumber
            note.noteColorArray.append(color)
        }
        
         // Save image
         if noteImage != nil && noteImagesArray.count > 0 {
             if !note.hasPhoto {
                 for imageInArray in 0...noteImagesArray.count - 1 {
                     note.notePhotoId = Notes.noteNextPhotoID() as NSNumber
                     note.notePhotoIdArray.append(note.notePhotoId!)
                    note.notePhotoLocation.append(noteLocationsArray[imageInArray] as NSNumber)
                    if let data = noteImagesArray[imageInArray].jpegData(compressionQuality: 0.5) {
                         // 3
                         do {
                             try data.write(to: note.photoURL, options: .atomic)
                         } catch {
                             print("Error writing file: \(error)")
                         }
                     }
                 }
             }
         }
         
         let fetchGroupRequest = NSFetchRequest<NotesGroup>(entityName: "NotesGroup")
         fetchGroupRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(NotesGroup.groupName),
         NoteGroupNamePassed)
         do {
           let results = try managedObjectContext.fetch(fetchGroupRequest) // do the actual fetch
           if results.count > 0 {
             currentNotesGroup = results.first
           }
         } catch let error as NSError {
           print("Fetch error: \(error) description: \(error.userInfo)")
         }
         
         if let group = currentNotesGroup,
             let notes = group.groupnotes?.mutableCopy()
             as? NSMutableOrderedSet {
           notes.add(note) // walks is currentDogs all walks. Add the newest walk to the set of all walks
             group.groupnotes = notes
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

        let createNoteController = singleController
        createNoteController.managedObjectContext = managedObjectContext
        self.delegate = createNoteController
        delegate?.retrievedNoteText(onlyNoteText: onlyNoteText, NoteGroupNamePassed: NoteGroupNamePassed, noteText: noteText, noteImage: noteImage, noteImagesArray: noteImagesArray, noteLocationsArray: noteLocationsArray)
        
        //self.navigationController?.dismiss(animated: true)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
        //print("dismissed")
    }
    
    // MARK:- Help Methods
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
    
    func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    @objc func addPhoto() {
        print("Adding photo...")
    }

    @objc func addSettings(_ sender: Any) {
           let vc = SettingsPopupController()
           vc.managedObjectContext = managedObjectContext
           vc.preferredContentSize = CGSize(width: 85, height: 85)
           vc.modalPresentationStyle = .popover
           vc.scrollView.isScrollEnabled = false
           vc.createActualNoteViewController = self
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
        imageView.image = noteImage
        let attachment = NSTextAttachment()
        attachment.image = noteImage
        let newImageWidth = (noteTextField.bounds.size.width - 10)
        let scale = newImageWidth/image.size.width
        let newImageHeight = image.size.height * scale
        //resize this
        attachment.bounds = CGRect.init(x: 0, y: 0, width: newImageWidth, height: newImageHeight)
        attString = NSAttributedString(attachment: attachment)
        noteAttributedArray.append(attString!)
        //add this attributed string to the current position.
        noteTextField.textStorage.insert(attString!, at: noteTextField.selectedRange.location)
        noteLocation = noteTextField.selectedRange.location
        noteLocationsArray.append(noteLocation)
        //attString1 = NSAttributedString(string: "")
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
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
           return .none
       }
    
    @objc func addLocation() {
        print("Adding location...")
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
//        navigationItem.rightBarButtonItem?.isEnabled = true
//        navigationItem.rightBarButtonItem?.tintColor = .black
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
        if noteTextField.text != "" {
        navigationItem.rightBarButtonItem?.isEnabled = true
        navigationItem.rightBarButtonItem?.tintColor = .black
        }
        if noteTextField.text == "" {
            navigationItem.rightBarButtonItem?.isEnabled = false
            navigationItem.rightBarButtonItem?.tintColor = .darkGray
        }
        noteTextField1!.isActive = true
        noteTextField2!.isActive = false
        noteImagesArray = []
        noteLocationsArray = []
        noteText = noteTextField.text
        noteTextField.font = UIFont(name: "PingFangHK-Regular", size: 20)
        noteTextField.attributedText.enumerateAttribute(NSAttributedString.Key.attachment, in: NSRange(location: 0, length: noteTextField.attributedText.length), options: []) { (value, range, stop) in

            if (value is NSTextAttachment){
                
              let attachment: NSTextAttachment? = (value as? NSTextAttachment)

                if ((attachment?.image) != nil) {
                    noteImagesArray.append(attachment!.image!)
                    noteLocationsArray.append(range.location)
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
        }
        if (scrollView.contentOffset.y > 0) {
                scrollView.keyboardDismissMode = .none
        }
    }
}


