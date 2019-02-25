//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Griffin Healy on 1/23/19.
//  Copyright © 2019 Griffin Healy. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import AudioToolbox

// closure. object isn't created until dateFormatter global is used in app. This occurs inside format(date: Date()) method
private let dateFormatter: DateFormatter = {
    // create a dateFormatter object
    let formatter = DateFormatter()
    // give the object a date and time style
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    // return the formatter to dateFormatter
    print("**Date Formatter Executed")
    return formatter
}()

var soundID: SystemSoundID = 0

class LocationDetailsViewController: UITableViewController {
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    // this outlet is linked to the imageView's height constraint, we can now tell it to change its constraint at runtime, if we want
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    var image: UIImage? {
        didSet {
            /// Exercise 712 Dynamic table view cell height from image aspect ratio.
            imageView.image = image
            imageView.isHidden = false
            // Height computed var
            var height: Double {
                let width = imageView.image!.size.width
                //print("the width \(width)")
                let height = imageView.image!.size.height
                //print("the height \(height)")
                let ratio = Double(width / height)
                //print("the ratio \(ratio)")
                return 260 / ratio
            }
            
            imageView.frame = CGRect(x: 10, y: 10,
                                     width: 260, height: height) // dynamic height
            addPhotoLabel.isHidden = true
        }
    }
    
    var coordinate = CLLocationCoordinate2D(latitude: 0,longitude: 0)
    var placemark: CLPlacemark?
    var categoryName = "No Category"
    var managedObjectContext: NSManagedObjectContext! // context object to be passed to controller
    var date = Date() // date object
    var locationToEdit: Location? { // optional, in add mode this value is nil
        didSet {
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                coordinate = CLLocationCoordinate2DMake(
                    location.latitude, location.longitude)
                placemark = location.placemark
            } }
    }
    var descriptionText = ""
    var observer: Any!
    
    
    
    /* -  Main idea of how photos are saved, and later retrieved - */
    
    /*SAVING PHOTOS: New location objects are given a photoID = nil. When a photo is selected and when the user presses done(), then we look if image is not nil (has a value), then we look to see if the photoID = nil. Since new location objects are given nil, we then give the location object a new ID, then we create a URL with the same ID just created. (i.e. photoID 5 = Photo-5.jpg (url). Then we save the image (formatted as a data blob) to the URL just created. */
    /*LOADING PHOTOS: When the location details controller is loaded, we try to load the image for that location object (if it has one). We look to see if the object has an ID. If so, we use that ID to find the matching url, photoID 5 = Photo-5.jpg. Then we load the contents of Photo-5.jpg. Now that we have the image, we call show(image: theImage) and the image of size, usually, 260x260 pixels is loaded into the imageView of size 260x260x pixels.
     */
    
    /* - End of how photos are saved, and later retrieved - */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // if we passed a loationToEdit value, that means we want to edit, set title 'Edit Location'
        if let location = locationToEdit {
            title = "Edit Location"
            // New code block, if location object has image (has a photoID value) then we set the imageView with the image using show. it puts 260x260 image in the 260x26 imageview. Remember, we changed imageview height constraint to 260 when there's image
            // everytime we load the details view controller, we want to see if the location object has a photo id. If if does that means there is a photoImage with the name Photo-ID that the location object stores. So a location objects photoID matches the ID of that picture. So ID = 5 for location object 5 has a photo with name Photo-5.jpg.
            if location.hasPhoto {
                if let theImage = location.photoImage {
                    show(image: theImage)
                }
            }
            // End of new code
        }
        loadSoundEffect("Click.wav")
        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName
        latitudeLabel.text = String(format: "%.8f",
                                    coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f",
                                     coordinate.longitude)
        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        // calls format which -> returns with dateFormatter (this is called) (a global closure to be executed at that time
        dateLabel.text = format(date: date) //date object initalized in properties init
        // Hide keyboard
        let gestureRecognizer = UITapGestureRecognizer(target: self,
                                                      // selectors use objc functions
                                                       action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        // for tapp in tableView, gestureRecognizer looks for the tap, and does action hideKeyboard
        tableView.addGestureRecognizer(gestureRecognizer)
        
        listenForBackgroundNotification()
    }
    
    // objc func because of #selector calling it
    // gestureRecognizer passes reference to where it was tapped
    @objc func hideKeyboard(_ gestureRecognizer:
        UIGestureRecognizer) {
        // gestureRecognizer says, I was tapped in this cg location in tableView
        let point = gestureRecognizer.location(in: tableView)
        // tableView uses cg point of tap, then finds the index that is in the tableView
        let indexPath = tableView.indexPathForRow(at: point)
        // if that index is a value (could be nil if not tappped any cell at all) and is not in section 0,  return
        if indexPath != nil && indexPath!.section == 0
                                && indexPath!.row == 0 {
            return
    }
        // set textView keyboard to be closed if taps happens in any other cell other than first
        descriptionTextView.resignFirstResponder()
    }
    
    // this sets the imageHeight constraint. Tells imageView to stretch 260 points, the same dimensions as we want the image to be. The image can now fill up 260 by 260 (size set for imageView)
    func show(image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
        addPhotoLabel.text = ""
        // tell imageHeight of its new height (we have an outlet link so we can tell it to change)
        imageHeight.constant = 260
        // refresh table view to show new height
        tableView.reloadData()
    }
    // This adds an observer for UIApplication.didEnterBackgroundNotification. When this notification is received, NotificationCenter will call the closure
    func listenForBackgroundNotification() {
        observer = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil, queue: OperationQueue.main) { [weak self] _ in  // weak self is the capture list for the closure. closure's variable self will still be captured, but as a weak reference, closure won't keep view controller alive when it is to be destroyed
                if let weakSelf = self { // weakSelf optional since it could of been destroyed
                    // if view controller has a value, modal has  a value
                    if weakSelf.presentedViewController != nil {
                        // we dismiss the action sheet
                        weakSelf.dismiss(animated: false, completion: nil)
                    }
                    weakSelf.descriptionTextView.resignFirstResponder()
                }
        } }
    // deinit called when controller is popped and another controller is in view
    deinit {
        // self can be destroyed because it is a weak var
        // print self, which prints '*** deinit' when this view controller is destroyed or deinit
        print("*** deinit \(self)")
        // remove 'observer' which means we no longer are observers (listeners) to the app telling us it has enterered the background
        NotificationCenter.default.removeObserver(observer)
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
    
    // MARK:- Actions
    @IBAction func done() {
        loadSoundEffect("Success.wav")
        playSoundEffect()
        let hudView = HudView.hud(inView: navigationController!.view,
                                  animated: true)
        let location: Location
        // if locationToEdit was passed a location object, then that data is filled in this screen above, and right here.. we can tell the hud that we are editing a location object
        if let temp = locationToEdit {
            // if location to edit has value, then we are just updating existing location
            hudView.text = "Updated"
            location = temp
            // otherwise we create a new location object
        } else {
            // only new location objects get a nil photoID. Old objects retain their id so they can find the url with the image
            hudView.text = "Tagged"
            location = Location(context: managedObjectContext)
            location.photoID = nil
        }
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
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
            print("location photo ID: \(String(describing: location.photoID))")
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
            // show 0.3 seconds after initial animation
            afterDelay(0.3) {
                hudView.show(animated: false)
            }
            // show 0.6 seconds after initial animation to hide hud and pop controller
            afterDelay(0.6) {
                hudView.hide()
                self.navigationController?.popViewController(animated: true)
            }
            // error handling for save()
        } catch {
            // 4
            // if save fails call below function with error message
            fatalCoreDataError(error)
        }
    }
    
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func categoryPickerDidPickCategory(
        // retrieved from segue, it's using a reverse segue
        _ segue: UIStoryboardSegue) {
        //
        let controller = segue.source as! CategoryPickerViewController
        // this source controller, retreives selectedCategoryName from dest (CategoryPickerController)
        categoryName = controller.selectedCategoryName
        // set categoryLabel text to the retrieved categoryName
        categoryLabel.text = categoryName
    }
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        // if button or click that caused the segue has identifier "PickCategory", then set the controller dest as ! implicit cast CategoryPickerViewController.
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as!
            CategoryPickerViewController
            // pass the controller - the dest - (CategoryPickerViewController) the categoryName
            // i.e. category = No Category
            controller.selectedCategoryName = categoryName
        }
    }
    // MARK:- Table View Delegates
    override func tableView(_ tableView: UITableView,
                            willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // allow taps only on first two sections, 0 & 1
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        } }
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        self.playSoundEffect()
        // if a tap happens in section 0, row 1, make the textView active now
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }
       // if a tap happens in section 1, row 1, then we know the "Choose Photo" row was selected. That means the user wants to take a picture. So we load takePhotoWithCamera(), so now the user activates the UIImagePickerController() and we create an instance of that and the camera is loaded successfully
        else if indexPath.section == 1 && indexPath.row == 0 {
            // this function looks for available camera, if one is available we ask the user if they want to use camera or photo library. If no camera, the user uses the photo library, as it is always available
            tableView.deselectRow(at: indexPath, animated: true)
            pickPhoto()
        }
    }
    override func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        let selection = UIView(frame: CGRect.zero)
        selection.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        cell.selectedBackgroundView = selection
    }
}

// extension to take photos with the camera. The info.plist will look for the permission to use camera, then user will click Ok, to allow camera to be used

// extract conceptually related methods — such as everything that has to do with picking photos — and place them together in their own extension.
extension LocationDetailsViewController:
    UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
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

// end of extension here
