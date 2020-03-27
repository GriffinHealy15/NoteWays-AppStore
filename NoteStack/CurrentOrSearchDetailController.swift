//
//  CurrentOrSearchDetailController.swift
//  NoteStack
//
//  Created by Griffin Healy on 2/14/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import AudioToolbox
import LBTATools
import MapKit

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


protocol SavedDetailsDelegate {
    func savedDetails()
}

class CurrentOrSearchDetailController: LBTAFormController, UITextViewDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, CAAnimationDelegate, PickCategoryDelegate {
    
//    init(passedLatitude: String) {
//        latitudeText.text = passedLatitude
//        super.init()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

    var currentOrSearchCntrl = CurrentOrSearchController()
    // delegate var for the protocol above
    var delegate: SavedDetailsDelegate?
    var window: UIWindow?
    // managed object context variable
    var managedObjectContext: NSManagedObjectContext!
    var coordinate = CLLocationCoordinate2D(latitude: 0,longitude: 0)
    var placemark: CLPlacemark?
    var locationName: String?
    var date = Date()
    var locationToEdit: Location? { // optional, in add mode this value is nil
        didSet {
            if let location = locationToEdit {
                descriptionTextField.text = location.locationDescription
                categoryText.text = location.category
                date = location.date
                coordinate = CLLocationCoordinate2DMake(
                    location.latitude, location.longitude)
                placemark = location.placemark
                locationName = location.locationName
            } }
    }
    
    var image: UIImage?
    var finalLocationCategory: String = ""
    
    var latitudeLabel = UILabel(text: "Latitude", font: UIFont(name: "AppleSDGothicNeo-Bold", size: 20), textColor: .white, textAlignment: .center, numberOfLines: 0)
    
    var longitudeLabel = UILabel(text: "Longitude", font: UIFont(name: "AppleSDGothicNeo-Bold", size: 20), textColor: .white, textAlignment: .center, numberOfLines: 0)
    
    var addressLabel = UILabel(text: "Address", font: UIFont(name: "AppleSDGothicNeo-Bold", size: 20), textColor: .white, textAlignment: .center, numberOfLines: 0)
    
    var dateLabel = UILabel(text: "Date", font: UIFont(name: "AppleSDGothicNeo-Bold", size: 20), textColor: .white, textAlignment: .center, numberOfLines: 0)
    
    var dateText = UILabel(text: "Date", font: UIFont(name: "AppleSDGothicNeo-Regular", size: 20), textColor: .black, textAlignment: .center, numberOfLines: 0)
    
    var latitudeText = UILabel(text: "", font: UIFont(name: "AppleSDGothicNeo-Regular", size: 20), textColor: .black, textAlignment: .center, numberOfLines: 0)

    var longitudeText = UILabel(text: "", font: UIFont(name: "AppleSDGothicNeo-Regular", size: 20), textColor: .black, textAlignment: .center, numberOfLines: 0)
    
    var addressText = UILabel(text: "", font: UIFont(name: "AppleSDGothicNeo-Bold", size: 20), textColor: .black, textAlignment: .center, numberOfLines: 0)
    
    var descriptionTextField = UITextView(text: "", font: UIFont(name: "AppleSDGothicNeo-Regular", size: 18), textColor: .black, textAlignment: .left)
    
    var descriptionLabel = UILabel(text: "Description", font: UIFont(name: "AppleSDGothicNeo-Bold", size: 20), textColor: .white, textAlignment: .center, numberOfLines: 0)
    
    lazy var categoryButton = UIButton(title: "Category (Tap to Change)", titleColor: .white, font: UIFont(name: "AppleSDGothicNeo-Bold", size: 18)!, backgroundColor: .rgb(red: 0, green: 197, blue: 255), target: self, action: #selector(addCategory))
    
    var categoryText = UILabel(text: "No Category", font: UIFont(name: "AppleSDGothicNeo-Bold", size: 22), textColor: .black, textAlignment: .center, numberOfLines: 0)
    
    var locationNameLabel = UILabel(text: "Location", font: UIFont(name: "AppleSDGothicNeo-Bold", size: 20), textColor: .white, textAlignment: .center, numberOfLines: 0)
    
    var locationNameText = UILabel(text: "", font: UIFont(name: "AppleSDGothicNeo-Bold", size: 20), textColor: .black, textAlignment: .center, numberOfLines: 0)
    
    var openInMapView = UIButton(title: "Open Destination in Map", titleColor: .white, font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)!, backgroundColor: .rgb(red: 6, green: 101, blue: 209), target: self, action: #selector(openMapView))
    
    var openGetDirections = UIButton(title: "Get Directions", titleColor: .white, font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)!, backgroundColor: .rgb(red: 6, green: 101, blue: 209), target: self, action: #selector(getDirections))
    
    var detailsLabel = UILabel(text: "Geolocation Details", font: UIFont(name: "AppleSDGothicNeo-Bold", size: 18), textColor: .white, textAlignment: .center, numberOfLines: 0)
    
    var soundID: SystemSoundID = 0
    
    var addPhotoButton = UIButton(title: "Add Photo (Tap to Change)", titleColor: .white, font: UIFont(name: "AppleSDGothicNeo-Bold", size: 18)!, backgroundColor: .rgb(red: 0, green: 197, blue: 255), target: self, action: #selector(addPhoto))
    
    var constraintWithNoPhoto: NSLayoutConstraint?
    var constraintWithPhoto: NSLayoutConstraint?
    
    override func viewWillAppear(_ animated: Bool) {
        print("Appear")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        constraintWithNoPhoto = addPhotoButton.heightAnchor.constraint(equalToConstant: 190)
        
        constraintWithPhoto = addPhotoButton.heightAnchor.constraint(equalToConstant: 250)
        
        latitudeLabel.backgroundColor = .rgb(red: 37, green: 199, blue: 255)
        longitudeLabel.backgroundColor = .rgb(red: 37, green: 199, blue: 255)
        addressLabel.backgroundColor = .rgb(red: 37, green: 199, blue: 255)
        locationNameLabel.backgroundColor = .rgb(red: 37, green: 199, blue: 255)
        dateLabel.backgroundColor = .rgb(red: 37, green: 199, blue: 255)
        descriptionLabel.backgroundColor = .rgb(red: 37, green: 199, blue: 255)
        latitudeLabel.layer.cornerRadius = 7
        latitudeLabel.clipsToBounds = true
        longitudeLabel.layer.cornerRadius = 7
        longitudeLabel.clipsToBounds = true
        addressLabel.layer.cornerRadius = 7
        addressLabel.clipsToBounds = true
        locationNameLabel.layer.cornerRadius = 7
        locationNameLabel.clipsToBounds = true
        dateLabel.layer.cornerRadius = 7
        dateLabel.clipsToBounds = true
        descriptionLabel.layer.cornerRadius = 7
        descriptionLabel.clipsToBounds = true
        
        descriptionTextField.delegate = self
        descriptionTextField.backgroundColor = .white
        descriptionTextField.layer.borderWidth = 0.7
        //descriptionTextField.layer.borderColor = UIColor.rgb(red: 2, green: 226, blue: 242).cgColor
        descriptionTextField.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTextField.layer.cornerRadius = 10
        descriptionTextField.textContainerInset = UIEdgeInsets(top: 7,left: 10,bottom: 3,right: 10)
        categoryButton.contentHorizontalAlignment = .left
        categoryButton.layer.cornerRadius = 10
        categoryButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        categoryButton.withWidth(150)
        addPhotoButton.contentHorizontalAlignment = .left
//        addPhotoButton.layer.borderWidth = 0.7
//        addPhotoButton.layer.borderColor = UIColor.black.cgColor
        addPhotoButton.layer.cornerRadius = 6
        addPhotoButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        latitudeText.text = String(format: "%.8f",
        coordinate.latitude)
        
        longitudeText.text = String(format: "%.8f",
        coordinate.longitude)
        
        locationNameText.text = locationName
        openInMapView.layer.cornerRadius = 10
        openInMapView.isEnabled = false
        openInMapView.isHidden = true
        
        detailsLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20)
        detailsLabel.backgroundColor = .rgb(red: 2, green: 227, blue: 141)
        
        openGetDirections.layer.cornerRadius = 10
        openGetDirections.isEnabled = false
        openGetDirections.isHidden = true
        if let placemark = placemark {
            addressText.text = string(from: placemark)
        } else {
            addressText.text = "No Address Found"
        }
        
        dateText.text = format(date: date)
        title = "Create Location"
        
        // Edit Existing Location
        if let location = locationToEdit {
            title = "Edit Location"
            openInMapView.isEnabled = true
            openInMapView.isHidden = false
            openGetDirections.isEnabled = true
            openGetDirections.isHidden = false
            // New code block, if location object has image (has a photoID value) then we set the imageView with the image using show. it puts 260x260 image in the 260x26 imageview. Remember, we changed imageview height constraint to 260 when there's image
            // everytime we load the details view controller, we want to see if the location object has a photo id. If if does that means there is a photoImage with the name Photo-ID that the location object stores. So a location objects photoID matches the ID of that picture. So ID = 5 for location object 5 has a photo with name Photo-5.jpg.
            if location.hasPhoto {
                if let theImage = location.photoImage {
                    constraintWithNoPhoto?.isActive = false
                    constraintWithPhoto?.isActive = true
                    show(image: theImage)
                }
                else {
                constraintWithNoPhoto?.isActive = true
                constraintWithPhoto?.isActive = false
                }
            }
                // Location has no photo
            else {
                constraintWithNoPhoto?.isActive = true
                constraintWithPhoto?.isActive = false
            }
            // End of new code
        }
            
        // New Location
        else {
            constraintWithNoPhoto?.isActive = true
            constraintWithPhoto?.isActive = false
        }
        
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveLocation))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelLocation))
        navigationItem.leftBarButtonItem?.tintColor = .rgb(red: 0, green: 197, blue: 255)
        navigationItem.rightBarButtonItem?.tintColor = .black
        
        if openInMapView.isEnabled == true {
            openInMapView.withHeight(50).withWidth(130)
        }
        else {
             openInMapView.withHeight(0).withWidth(0)
        }
        
        if openGetDirections.isEnabled == true {
            openGetDirections.withHeight(50).withWidth(130)
        }
        else {
            openGetDirections.withHeight(0).withWidth(0)
        }
        
        let formView = UIView(backgroundColor: .rgb(red: 240, green: 240, blue: 240))
        let formView2 = UIView(backgroundColor: .white)
        let formView3 = UIView(backgroundColor: .rgb(red: 240, green: 240, blue: 240))
        formView.layer.cornerRadius = 30
        formView.clipsToBounds = true
        formView2.layer.cornerRadius = 30
        formView2.clipsToBounds = true
        
        formView3.stack(UIView().withHeight(10), locationNameLabel.withHeight(33), UIView().withHeight(5),
        formView.hstack(locationNameText), UIView().withHeight(10), addressLabel.withHeight(33), UIView().withHeight(5),
        formView.hstack(addressText), UIView().withHeight(10), formView.hstack(UIView().withWidth(10),openInMapView,UIView().withWidth(10)), UIView().withHeight(9), formView.hstack(UIView().withWidth(10),openGetDirections,UIView().withWidth(10)), UIView().withHeight(17),
                        descriptionLabel.withHeight(33), UIView().withHeight(5),descriptionTextField.withHeight(120), UIView().withHeight(15),categoryButton.withHeight(33),UIView().withHeight(5) ,formView.hstack(categoryText),UIView().withHeight(20), addPhotoButton,
                        UIView().withHeight(30), latitudeLabel.withHeight(33),UIView().withHeight(5), formView.hstack(latitudeText),UIView().withHeight(20), longitudeLabel.withHeight(33),UIView().withHeight(5), formView.hstack(longitudeText), UIView().withHeight(20), dateLabel.withHeight(33), UIView().withHeight(5), formView.hstack( dateText),UIView().withHeight(20)).withMargins(.init(top: 5, left: 20, bottom: 5, right: 20))
        
        formView.stack(detailsLabel.withHeight(45),formView3).withMargins(.init(top: 0, left: 0, bottom: 0, right: 0))
        
        formView2.stack(UIView().withHeight(15),formView2.hstack(UIView(backgroundColor: .white).withWidth(0),formView, UIView(backgroundColor: .white).withWidth(0))).withMargins(.init(top: 0, left: 20, bottom: 0, right: 20))
               
               formContainerStackView.addArrangedSubview(formView2)
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
    
    // MARK:- Helper Methods
    func string(from placemark: CLPlacemark) -> String {
        var line = ""
        line.add(text: placemark.subThoroughfare) // number of adress
        line.add(text: placemark.thoroughfare, separatedBy: " ") // street name
        line.add(text: placemark.locality, separatedBy: ", ") // city
        line.add(text: placemark.administrativeArea, // state
                 separatedBy: ", ")
        line.add(text: placemark.postalCode, separatedBy: " ") // zip code
        line.add(text: placemark.country, separatedBy: ", ") // country
        return line
    }
    
    func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    @objc func getDirections(){
        print("Get Directions")
        let location = locationToEdit
        guard let locPlacemark = location!.placemark else { return }
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: locPlacemark.location!.coordinate))
        //let mapItem = MKMapItem(placemark: locPlacemark as! MKPlacemark)
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        //loadSoundEffect("tap.mp3")
        //playSoundEffect()
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    @objc func openMapView() {
        //loadSoundEffect("tap.mp3")
        //playSoundEffect()
        let storyboard_main = UIStoryboard(name: "Main", bundle: Bundle.main)
        let mapViewController = storyboard_main.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        mapViewController.managedObjectContext = managedObjectContext
        mapViewController.singleLocation = locationToEdit
        navigationController?.pushViewController(mapViewController, animated: true)

//                // access root view contoller, which is tab bar view controller
//                let tabController = window!.rootViewController
//                    as! UITabBarController
//        print(tabController)
//                // find the first view controller of tab bar which is navigation controller
//
//                if let tabViewControllers = tabController.viewControllers {
//                    let navController = tabViewControllers[1] as! UINavigationController
//                    let controller3 = navController.viewControllers.first
//                        as! MapViewController
//                    controller3.managedObjectContext = managedObjectContext
//                    present(controller3, animated: true)
//                }
        
    }
    
    @objc func cancelLocation() {
        dismiss(animated: true)
        delegate?.savedDetails()
        navigationController?.popViewController(animated: true)
    }
    
    @objc func saveLocation() {
        print("Saving location details...")
        //loadSoundEffect("success.mp3")
        //playSoundEffect()
        descriptionTextField.resignFirstResponder()
        
        let location: Location
        if let temp = locationToEdit {
            // if location to edit has value, then we are just updating existing location
            location = temp
            // otherwise we create a new location object
        } else {
            // only new location objects get a nil photoID. Old objects retain their id so they can find the url with the image
            location = Location(context: managedObjectContext)
            location.photoID = nil
        }
        location.locationDescription = descriptionTextField.text
        location.category = categoryText.text ?? "No Category"
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        location.locationName = locationName ?? ""
               
               // Save image
               // if image has a value, we continue with saving the image
               if let image = image {
                   // 1
                   // if location object doesn't have a previous photo then we find a new photoID and set the location object to has a photoID attribute of the photoID we just set
                   // when location.hasPhoto is true, that means this is an location object that has been edited and that we don't need a new id and to create a new url with that id.
                   // Give Location Object a photoID
                   // if a location object is new, then we give it an id, and url with that id (i.e Photo-5) and then we save the image (as data blob) to the url.
                   if !location.hasPhoto {location.photoID = Location.nextPhotoID() as NSNumber
                   }
                   //print("location photo ID: \(String(describing: location.photoID))")
                   // 2
                   //  The image.jpegData(compressionQuality: 0.5) call converts the UIImage to JPEG format and returns a Data object. Data is an object that represents a blob of binary data, usually the contents of a file.
                   if let data = image.jpegData(compressionQuality: 0.5) {
                       // 3
                       do { // You save the Data object to the path given by the photoURL property (saves data, which is the image, to the documents directory)
                           try data.write(to: location.photoURL, options: .atomic)
                       } catch {
                           print("Error writing file: \(error)")
                           
                       }
                   } }
               
               // 3
               do {
                   // Saving takes any objects that were added to the context, or any managed objects that had their contents changed, and permanently writes these changes to the data store
                   try managedObjectContext.save()
                   // error handling for save()
               } catch {
                   // 4
                   // if save fails call below function with error message
                   fatalCoreDataError(error)
               }
        dismiss(animated: true)
        self.delegate = currentOrSearchCntrl
        print("current")
        print(currentOrSearchCntrl)
        delegate?.savedDetails()
        navigationController?.popViewController(animated: true)
    }
    
    @objc func addPhoto() {
        //loadSoundEffect("pin_low2.mp3")
        //playSoundEffect()
        pickPhoto()
    }
    
    @objc func addCategory() {
        //loadSoundEffect("pin_low2.mp3")
        //playSoundEffect()
        let vc = CategoryPopoverController()
        vc.managedObjectContext = managedObjectContext
        vc.createCategoryController = self
        let navController = UINavigationController(rootViewController: vc)
        present(navController, animated: true)
    }
    
    func retrievedCategory(locationCategory: String) {
        self.finalLocationCategory = locationCategory
        self.categoryText.text = finalLocationCategory
    }
    
    func show(image: UIImage) {
        constraintWithNoPhoto?.isActive = false
        constraintWithPhoto?.isActive = true
        //addPhotoButton.withHeight(250)
        addPhotoButton.layer.borderWidth = 0.55
        addPhotoButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        addPhotoButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        addPhotoButton.layer.borderColor = UIColor.init(displayP3Red: 255, green: 255, blue: 255, alpha: 1).cgColor
        addPhotoButton.clipsToBounds = true
        addPhotoButton.layer.cornerRadius = 30
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.becomeFirstResponder()
    }
}

extension CurrentOrSearchDetailController:
    UIImagePickerControllerDelegate {
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
