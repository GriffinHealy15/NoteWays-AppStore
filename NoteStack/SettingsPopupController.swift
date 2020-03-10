//
//  SettingsPopupController.swift
//  NoteStack
//
//  Created by Griffin Healy on 2/7/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//

import UIKit
import LBTATools
import CoreData

protocol PhotoOrLocationDelegate {
    func retrievedPhoto(image: UIImage)
}


class SettingsPopupController: LBTAFormController {
    
    
    // CreateActualNoteController
    var createActualNoteViewController:CreateActualNoteController?
    
    // delegate var for the protocol above
    var delegate: PhotoOrLocationDelegate?
    
    var image: UIImage?
    
    var noteToEdit: Notes?
    // Managed object context
    var managedObjectContext: NSManagedObjectContext!
   // var delegate: EditNoteDelegate?
   
    var noteTextField = UITextView(text: "", font: .boldSystemFont(ofSize: 18), textColor: .black, textAlignment: .left)
    
    lazy var addPhotoButton = UIButton(image: #imageLiteral(resourceName: "cameraicon"), tintColor: .black, target: self, action: #selector(addPhoto))
    
    lazy var addLocationButton = UIButton(image: #imageLiteral(resourceName: "location"), tintColor: .black, target: self, action: #selector(addLocation))
    
    let imageView = UIImageView(frame: CGRect(x: 42.5, y: 42.5, width: 20, height: 20))

    override func viewDidLoad() {
       super.viewDidLoad()

       view.backgroundColor = .white
       addPhotoButton.layer.borderColor = UIColor.black.cgColor
       addPhotoButton.layer.borderWidth = 0.3
       addPhotoButton.withHeight(85)
       addLocationButton.layer.borderColor = UIColor.black.cgColor
       addLocationButton.layer.borderWidth = 0.3
       addLocationButton.withHeight(100)
        self.scrollView.isScrollEnabled = false
        
        let formView = UIView().withHeight(85)
       formView.stack(addPhotoButton)
       
       formContainerStackView.padBottom(0)
       formContainerStackView.addArrangedSubview(formView)
       }
    
    @objc func addPhoto() {
        pickPhoto()
    }
    
    @objc func addLocation() {
        print("Add location here...")
    }
    
    func show(image: UIImage) {
        imageView.image = image
        let createNoteController = createActualNoteViewController
        createNoteController?.managedObjectContext = managedObjectContext
        self.delegate = createNoteController
        delegate?.retrievedPhoto(image: image)
        dismiss(animated: true)
    }
}


extension SettingsPopupController:
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
