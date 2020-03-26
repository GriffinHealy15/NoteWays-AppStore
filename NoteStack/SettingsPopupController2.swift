//
//  SettingsPopupController2.swift
//  NoteStack
//
//  Created by Griffin Healy on 3/5/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//

import UIKit
import LBTATools
import CoreData

protocol PhotoOrLocationDelegate2 {
    func retrievedPhoto(image: UIImage)
}

protocol ColorDelegate2 {
    func retrievedColorPick(red: Int, green: Int, blue: Int)
}

class SettingsPopupController2: LBTAFormController, PickColorDelegate, UIPopoverPresentationControllerDelegate {
    
    // CreateActualNoteController
    var editNoteViewController:EditNoteModalController?
    
    // delegate var for the protocol above
    var delegate: PhotoOrLocationDelegate2?
    
    // delegate var for the protocol above
    var delegateColor: ColorDelegate2?
    
    var image: UIImage?
    
    var noteToEdit: Notes?
    // Managed object context
    var managedObjectContext: NSManagedObjectContext!
   // var delegate: EditNoteDelegate?
   
    var noteTextField = UITextView(text: "", font: .boldSystemFont(ofSize: 18), textColor: .black, textAlignment: .left)
    
    lazy var addPhotoButton = UIButton(image: #imageLiteral(resourceName: "cameraicon"), tintColor: .black, target: self, action: #selector(addPhoto))
    
    lazy var changeColorButton = UIButton(image: #imageLiteral(resourceName: "colorWheel").withRenderingMode(.alwaysOriginal), tintColor: .none, target: self, action: #selector(changeColor))
    
    let imageView = UIImageView(frame: CGRect(x: 42.5, y: 42.5, width: 20, height: 20))

    override func viewDidLoad() {
       super.viewDidLoad()

       view.backgroundColor = .white
       addPhotoButton.layer.borderColor = UIColor.black.cgColor
       addPhotoButton.layer.borderWidth = 0.3
       addPhotoButton.withHeight(85)
       changeColorButton.layer.borderColor = UIColor.black.cgColor
       changeColorButton.layer.borderWidth = 0.3
       changeColorButton.withHeight(85)
        self.scrollView.isScrollEnabled = false
        
        let formView = UIView().withHeight(170)
       formView.stack(addPhotoButton, changeColorButton)
       
       formContainerStackView.padBottom(0)
       formContainerStackView.addArrangedSubview(formView)
       }
    
    @objc func addPhoto() {
        pickPhoto()
    }
    
    @objc func changeColor() {
        let vc = ChangeColorController()
        vc.managedObjectContext = managedObjectContext
        vc.preferredContentSize = CGSize(width: 300, height: 300)
        vc.modalPresentationStyle = .popover
        vc.scrollView.isScrollEnabled = false
        vc.settingsViewController2 = self
        let ppc = vc.popoverPresentationController
        ppc?.permittedArrowDirections = .init(rawValue: 0)
        ppc?.delegate = self
        ppc!.sourceView = editNoteViewController!.view
        ppc?.passthroughViews = nil
        print(self.view.bounds.midX)
        ppc?.sourceRect =  CGRect(x: editNoteViewController!.view.bounds.midX, y: editNoteViewController!.view.bounds.midY - 80, width: 0, height: 0)
        present(vc, animated: true, completion: nil)
    }
    
    func retrievedColor(red: Int, green: Int, blue: Int) {
        let editNoteController = editNoteViewController
        editNoteController?.managedObjectContext = managedObjectContext
        self.delegateColor = editNoteController
        delegateColor?.retrievedColorPick(red: red, green: green, blue: blue)
        dismiss(animated: true)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
             return .none
         }
    
    func show(image: UIImage) {
        imageView.image = image
        let editNoteController = editNoteViewController
        editNoteController?.managedObjectContext = managedObjectContext
        self.delegate = editNoteController
        delegate?.retrievedPhoto(image: image)
        dismiss(animated: true)
    }
}


extension SettingsPopupController2:
    UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK:- Image Helper Methods
    func takePhotoWithCamera() {
        // picker controller instance
        // MyImagePickerController is a subclass of the standard UIImagePickerController
        let imagePicker = MyImagePickerController() // still UIImagePickerController(), but we override status bar to light color
        imagePicker.view.tintColor = view.tintColor
        imagePicker.sourceType = .camera
        // its delegate is this controller
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        // present the imagePicker
        present(imagePicker, animated: true, completion: nil)
    }
    func choosePhotoFromLibrary() {
        // MyImagePickerController is a subclass of the standard UIImagePickerController
        let imagePicker = MyImagePickerController()
        // same as above method, but this uses sourceType = .photoLibrary
        imagePicker.view.tintColor = view.tintColor
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func pickPhoto() {
        // check if camera for image picker is .camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // this means that user can choose to take photo from camera or use photo library
            showPhotoMenu()
        } else {
            // no camera available, so user chooses photo from photo library
            choosePhotoFromLibrary()
        }
    }
    // this is called when the user has an available camera and photo library. We show alert that allows user to choose to take a photo or choose an existing photo from their library
    func showPhotoMenu() {
        let alert = UIAlertController(title: nil, message: nil,
                                      preferredStyle: .actionSheet)
        // style cancel show cancel bold at the bottom
        let actCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actCancel)
        // .default means a normal action
        let actPhoto = UIAlertAction(title: "Take Photo",
                                     style: .default, handler: { _ in // closure which calls the corresponding method from the extension, In this case it calls takePhotoWithCamera method (method is in extension, shown above)
                                        self.takePhotoWithCamera()
        })
        alert.addAction(actPhoto)
        
        let actLibrary = UIAlertAction(title: "Choose From Library",
                                       style: .default, handler: { _ in // same as actPhoto alert, but this lets user choose photos from library
                                        self.choosePhotoFromLibrary()
        })
        alert.addAction(actLibrary)
        // alert has all the actions with the closures that run methods in the extension
        // now we present alert to user
        present(alert, animated: true, completion: nil)
    }
    // MARK:- Image Picker Delegates
    // must conform to the delegate methods
    
    // This is the delegate method that gets called when the user has selected a photo in the image picker.
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info:
        [UIImagePickerController.InfoKey : Any]) { // the UIImagePickerController.InfoKey.editedImage key to retrieve a UIImage object that contains the final image after the user moved and/or scaled it

        // once we have photo, we store it in the image UIImage instance variable
        image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage

        if let theImage = image {
            // puts the image in add photo cell, does this by calling show(theImage), show() then says ok thanks for passing me theImage. I will tell the IBOutlet to set imageLabel as the theImage you passed to me
            show(image: theImage)
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker:
        UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

