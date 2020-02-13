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
    func retrievedNoteText(noteText: String, noteImage: UIImage?, noteImagesArray: [UIImage?],
                           noteLocationsArray: [Int?])
}

class CreateActualNoteController: LBTAFormController, UIPopoverPresentationControllerDelegate, UITextViewDelegate, UINavigationControllerDelegate, PhotoOrLocationDelegate {
    

    // MARK: UI Elements
    
    // Managed object context
    var managedObjectContext: NSManagedObjectContext!
    
    // delegate var for the protocol above
    var delegate: CreateNoteDelegate?
       
    var noteTextField = UITextView(text: "", font: .boldSystemFont(ofSize: 18), textColor: .lightGray, textAlignment: .left)
    var noteText = ""
    
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
        
        view.backgroundColor = .rgb(red: 178, green: 253, blue: 254)
        
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
        noteTextField.backgroundColor = .rgb(red: 178, green: 253, blue: 254)
        noteTextField.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "SaveNote"), style: .plain, target: self, action: #selector(saveNote))
        navigationItem.rightBarButtonItem?.tintColor = .green
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "threedots"), style: .plain, target: self, action: #selector(addSettings(_:)))
        navigationItem.leftBarButtonItem?.tintColor = .green
        title = "Create Note"
        let formView = UIView()
        
        formView.stack(UIView().withHeight(5),
        noteTextField.withHeight(650),
        UIView().withHeight(30),spacing: 16).withMargins(.init(top: 0, left: 10, bottom: 0, right: 10))
        
              formContainerStackView.padBottom(-24)
        formContainerStackView.addArrangedSubview(formView)
    }
    
    @objc func saveNote() {
        print("Saving note...")
        let createNoteController = CreateNoteController()
        createNoteController.managedObjectContext = managedObjectContext
        self.delegate = createNoteController
        delegate?.retrievedNoteText(noteText: noteText, noteImage: noteImage, noteImagesArray: noteImagesArray, noteLocationsArray: noteLocationsArray)
        self.navigationController?.dismiss(animated: true)
    }
    
    @objc func addPhoto() {
        print("Adding photo...")
    }
    
    @objc func addSettings(_ sender: Any) {
           let vc = SettingsPopupController()
           vc.managedObjectContext = managedObjectContext
           vc.preferredContentSize = CGSize(width: 200, height: 200)
           vc.modalPresentationStyle = .popover
           vc.createActualNoteViewController = self
           let ppc = vc.popoverPresentationController
           ppc?.permittedArrowDirections = .any
           ppc?.delegate = self
           ppc!.sourceView = sender as? UIView
           ppc?.barButtonItem = navigationItem.leftBarButtonItem
           present(vc, animated: true, completion: nil)
       }
    
    func retrievedPhoto(image: UIImage) {
        noteImage = image
        noteImagesArray.append(noteImage!)
        imageView.image = noteImage
        let attachment = NSTextAttachment()
        attachment.image = noteImage
        let newImageWidth = (noteTextField.bounds.size.width - 20 )
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
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
           return .none
       }
    
    @objc func addLocation() {
        print("Adding location...")
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
//        noteTextField.text = ""
        noteTextField.textColor = .black
        noteTextField.font = .boldSystemFont(ofSize: 18)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        noteImagesArray = []
        noteLocationsArray = []
        noteText = noteTextField.text
        noteTextField.font = .boldSystemFont(ofSize: 18)
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
}


