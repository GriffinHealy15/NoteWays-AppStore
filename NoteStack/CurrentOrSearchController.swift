//
//  CurrentOrSearchController.swift
//  NoteStack
//
//  Created by Griffin Healy on 2/13/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//

import UIKit
import CoreData
import LBTATools
import CoreLocation
import AudioToolbox

class CurrentOrSearchController: LBTAFormController ,UITextViewDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, CAAnimationDelegate, HandleAddressSelectDelegate, SavedDetailsDelegate {
    
    // Managed object context
    var managedObjectContext: NSManagedObjectContext!
    
    // -- START OF LOCATION VARS --
    let locationManager = CLLocationManager() // location manager object
   var location: CLLocation? // location ? optional because nil from beginning (could be nil later)
   // location holds the found coordinates that manager has found
   var updatingLocation = false // looking for location is initially false (not looking)
   var lastLocationError: Error? // optional error
   let geocoder = CLGeocoder() // geocoder is the object that performs geocoding
   var placemark: CLPlacemark? // placemark is object that contains the address results
   var performingReverseGeocoding = false // set to false, set to true when geocoding is happening
   var lastGeocodingError: Error? // optional error, contains error object if something occurs
   var timer: Timer?
   var finalCoords: CLLocationCoordinate2D? = nil
   var locationName: String = ""
   // -- END OF LOCATION VARS -- 
    
    var latitudeLabel = UILabel(text: "", font: .boldSystemFont(ofSize: 17), textColor: .black, textAlignment: .left, numberOfLines: 0)
    
    var longitudeLabel = UILabel(text: "", font: .boldSystemFont(ofSize: 17), textColor: .black, textAlignment: .left, numberOfLines: 0)
    
    var detailsLabel = UILabel(text: "Geolocation Details", font: .boldSystemFont(ofSize: 17), textColor: .white, textAlignment: .center, numberOfLines: 0)
    
    var theAddressLabel = UILabel(text: "Address", font: .boldSystemFont(ofSize: 17), textColor: .rgb(red: 240, green: 240, blue: 240), textAlignment: .center, numberOfLines: 0)
    
    var theLocationLabel = UILabel(text: "Location", font: .boldSystemFont(ofSize: 17), textColor: .rgb(red: 240, green: 240, blue: 240), textAlignment: .center, numberOfLines: 0)

    var latitudeText = UILabel(text: "", font: UIFont(name: "PingFangHK-Regular", size: 15), textColor: .black, textAlignment: .left, numberOfLines: 0)

    var longitudeText = UILabel(text: "", font: UIFont(name: "PingFangHK-Regular", size: 15), textColor: .black, textAlignment: .left, numberOfLines: 0)
    
    var tagMyLocationButton = UIButton(title: "Get My Location", titleColor: .white, font: .boldSystemFont(ofSize: 18), backgroundColor: .rgb(red: 0, green: 197, blue: 255), target: self, action: #selector(getMyLocation))
    
    var searchLocationText = UITextView(text: "Search for locations", font: UIFont(name: "PingFangHK-Regular", size: 15), textColor: .lightGray, textAlignment: .left)
    var searchLocationButton = UIButton(title: "Search", titleColor: .white, font: .boldSystemFont(ofSize: 17), backgroundColor: .darkGray, target: self, action: #selector(searchLocation))
    
    var orText = UILabel(text: "or find my current location", font: UIFont(name: "PingFangHK-Regular", size: 13.5), textColor: .darkGray, textAlignment: .center, numberOfLines: 0)
    
    var addressLabel = UILabel(text: "Address & Location", font: UIFont(name: "PingFangHK-Regular", size: 20), textColor: .darkGray, textAlignment: .center, numberOfLines: 0)
    
    var locationLabel = UILabel(text: "", font: UIFont(name: "PingFangHK-Regular", size: 20), textColor: .black, textAlignment: .center, numberOfLines: 0)
    
    var soundID: SystemSoundID = 0
    
    var resultSearchController: UISearchController!

    var storyboard_1 = UIStoryboard()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Continue", style: .done, target: self, action: #selector(saveLocation))
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelController))
        navigationItem.leftBarButtonItem?.tintColor = .rgb(red: 0, green: 197, blue: 255)
        navigationItem.rightBarButtonItem?.tintColor = .black
        view.backgroundColor = .white
        title = "Tag Location"
        let formView = UIView()
        let formView2 = UIView()
        detailsLabel.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        detailsLabel.backgroundColor = .rgb(red: 2, green: 227, blue: 141)
        theAddressLabel.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        theAddressLabel.backgroundColor = .rgb(red: 240, green: 240, blue: 240)
        theLocationLabel.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        theLocationLabel.backgroundColor = .rgb(red: 240, green: 240, blue: 240)
        latitudeLabel.backgroundColor = .rgb(red: 240, green: 240, blue: 240)
        latitudeLabel.layer.cornerRadius = 25
        longitudeLabel.backgroundColor = .rgb(red: 240, green: 240, blue: 240)
        longitudeLabel.layer.cornerRadius = 25
        latitudeText.backgroundColor = .rgb(red: 240, green: 240, blue: 240)
        longitudeText.backgroundColor = .rgb(red: 240, green: 240, blue: 240)
        addressLabel.backgroundColor = .rgb(red: 240, green: 240, blue: 240)
        locationLabel.backgroundColor = .rgb(red: 240, green: 240, blue: 240)
        searchLocationText.layer.borderColor = UIColor.black.cgColor
        searchLocationText.layer.borderWidth = 0.5
        searchLocationText.layer.cornerRadius = 20
        searchLocationText.delegate = self
        searchLocationButton.layer.cornerRadius = 20
        searchLocationButton.isUserInteractionEnabled = false
        searchLocationText.textContainerInset = UIEdgeInsets(top: 10,left: 20,bottom: 5,right: 5)
        tagMyLocationButton.layer.cornerRadius = 20
        formView2.stack(detailsLabel.withHeight(35),formView.hstack(latitudeLabel.withHeight(50).withWidth(100),latitudeText), formView.hstack(longitudeLabel.withHeight(50).withWidth(100),longitudeText), theAddressLabel.withHeight(25),
                        addressLabel.withHeight(60).withWidth(150),
        UIView(backgroundColor: .rgb(red: 240, green: 240, blue: 240)).withHeight(5),theLocationLabel.withHeight(25),
            locationLabel.withHeight(70).withWidth(100))
        
        formView2.layer.cornerRadius = 20
        formView2.clipsToBounds = true
        
        //let storyboard_main = UIStoryboard(name: "Main", bundle: Bundle.main)
        let navContrl = storyboard_1.instantiateViewController(withIdentifier: "NavControllerSearch") as! UINavigationController
        let searchbarcontrl = navContrl.viewControllers.first as! SearchBarTableController
        searchbarcontrl.storyboard_1 = storyboard_1
        searchbarcontrl.currentOrSearchController = self
//        searchbarcontrl.tableView.frame = CGRect(x: 20, y: 150, width: 334, height: 700)
           formView.stack(UIView().withHeight(10), navContrl.view.withHeight(50),
//           formView.hstack(searchLocationText.withHeight(40).withWidth(250), UIView().withWidth(10).withHeight(50), searchLocationButton.withHeight(50)),
//           UIView(backgroundColor: .white).withHeight(120),
           orText.withHeight(20),
           tagMyLocationButton.withHeight(40),
           UIView(backgroundColor: .white).withHeight(35),formView2,
            UIView(backgroundColor: .white).withHeight(45),
        UIView().withHeight(30),spacing: 16).withMargins(.init(top: 0, left: 20, bottom: 0, right: 20))
        
        formContainerStackView.padBottom(-24)
        formContainerStackView.addArrangedSubview(formView)
    }
    
    func handleAddress(address: String, selectedName: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
                if((error) != nil){
                    print("Error", error ?? "")
                }
            if let placemark = placemarks?.first {
                //self.addressLabel.font = .boldSystemFont(ofSize: 20)
                self.addressLabel.text = self.string(from: placemark)
                self.addressLabel.textColor = .black
                self.addressLabel.font = UIFont(name: "PingFangTC-Semibold", size: 17)
                //self.locationLabel.font = .boldSystemFont(ofSize: 20)
                self.latitudeLabel.text = "  Latitude:"
                self.longitudeLabel.text = "  Longitude:"
                self.theAddressLabel.backgroundColor = .rgb(red: 37, green: 199, blue: 255)
                self.theLocationLabel.backgroundColor = .rgb(red: 37, green: 199, blue: 255)
                self.theAddressLabel.textColor = .white
                self.theLocationLabel.textColor = .white
                    
                self.locationName = selectedName
                self.locationLabel.text = self.locationName
                self.locationLabel.font = UIFont(name: "PingFangTC-Semibold", size: 20)
                  let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                  self.finalCoords = coordinates
                  let stringCoordsLat: String!  = ("\(String(describing: self.finalCoords!.latitude))")
                  let stringCoordsLon: String!  = ("\(String(describing: self.finalCoords!.longitude)) ")
                  self.latitudeText.text = stringCoordsLat
                  self.longitudeText.text = stringCoordsLon
                let getLat: CLLocationDegrees = coordinates.latitude
                let getLon: CLLocationDegrees = coordinates.longitude
                self.location = CLLocation(latitude: getLat, longitude: getLon)
                self.placemark = placemarks?.first
                if (self.location != nil)
                {
                     self.navigationItem.rightBarButtonItem?.isEnabled = true
                }
                }
            })
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
    
    @objc func cancelController() {
        dismiss(animated: true)
    }
    
    @objc func getMyLocation() {
        print("Get my location...")
        //loadSoundEffect("pin_high.mp3")
        //playSoundEffect()
        // request authorization
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        // if the logo view is visible (now we are trying to find location coords), hide the logo
//        if logoVisible {
//            hideLogoView()
//        }
        // if updatingLocation set to true (set true in startLocationManager) stop searching
        if updatingLocation {
            stopLocationManager()
            // if not currently updatingLocation (set to false) start searching method (startLocationManager)
        } else {
            // clean slate of nil for vars
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        // update labels for possible locations found (or other possible scenarios)
        latitudeLabel.text = "  Latitude:"
        longitudeLabel.text = "  Longitude:"
        theAddressLabel.backgroundColor = .rgb(red: 37, green: 199, blue: 255)
        theLocationLabel.backgroundColor = .rgb(red: 37, green: 199, blue: 255)
        theAddressLabel.textColor = .white
        theLocationLabel.textColor = .white
        locationLabel.text = "My Current Location"
        locationLabel.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        locationName = "My Current Location"
        updateLabels()
    }
    
    @objc func searchLocation() {
        //loadSoundEffect("pin_high.mp3")
        //playSoundEffect()
        print("Search a location...")
        searchLocationText.resignFirstResponder()
        // GeoCode your address, so it turns the address into coordinates
        let geocoder = CLGeocoder()
        let addressForGeocoding = searchLocationText.text
        //let address = "8787 Snouffer School Rd, Montgomery Village, MD 20879"
        geocoder.geocodeAddressString(addressForGeocoding!, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                print("Error", error ?? "")
            }
            if let placemark = placemarks?.first {
                  //self.addressLabel.font = .boldSystemFont(ofSize: 20)
                  self.addressLabel.text = self.string(from: placemark)
                  self.addressLabel.textColor = .black
                  self.latitudeLabel.text = "  Latitude:"
                  self.longitudeLabel.text = "  Longitude:"
                  self.theAddressLabel.backgroundColor = .rgb(red: 37, green: 199, blue: 255)
                  self.theLocationLabel.backgroundColor = .rgb(red: 37, green: 199, blue: 255)
                  self.theAddressLabel.textColor = .white
                  self.theLocationLabel.textColor = .white
                  let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                  self.finalCoords = coordinates
                  //print("Latitude: \(self.finalCoords!.latitude) -- Longitude: \(self.finalCoords!.longitude)")

//                  let Coordinates = "Coordinates: "
//                let comma = ", "
//                self.addressTextToDisplay.text = (Coordinates)
                  let stringCoordsLat: String!  = ("\(String(describing: self.finalCoords!.latitude))")
                  let stringCoordsLon: String!  = ("\(String(describing: self.finalCoords!.longitude)) ")
                  self.latitudeText.text = stringCoordsLat
                  self.longitudeText.text = stringCoordsLon
//                self.addressTextToDisplay.text!.append(stringCoordsLat!)
//                self.addressTextToDisplay.text!.append(comma)
//                self.addressTextToDisplay.text!.append(stringCoordsLon!)
//
                let getLat: CLLocationDegrees = coordinates.latitude
                let getLon: CLLocationDegrees = coordinates.longitude
                self.location = CLLocation(latitude: getLat, longitude: getLon)
                self.placemark = placemarks?.first
                if (self.location != nil)
                {
                     self.navigationItem.rightBarButtonItem?.isEnabled = true
                }
            }
        })
    }
    
    @objc func saveLocation() {
        print("Save location.....")
        print("Creating location detail nav...")
        let currentDetailLocationController = CurrentOrSearchDetailController()
        currentDetailLocationController.currentOrSearchCntrl = self
        currentDetailLocationController.coordinate = location!.coordinate
        currentDetailLocationController.placemark = placemark
        currentDetailLocationController.locationName = locationName
        currentDetailLocationController.managedObjectContext = managedObjectContext
        let navController = UINavigationController(rootViewController: currentDetailLocationController)
        present(navController, animated: true)
    }
    
    func savedDetails() {
        dismiss(animated: true)
        navigationController?.popViewController(animated: true)
    }
    
    // function called to update labels
    func updateLabels() {
        // location not nil (found), update text labels
        if let location = location {
            latitudeText.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeText.text = String(format: "%.8f", location.coordinate.longitude)
            //tagButton.isHidden = false
            //messageLabel.text = ""
            latitudeText.isHidden = false
            longitudeText.isHidden = false
            if let placemark = placemark {
                addressLabel.font = UIFont(name: "PingFangTC-Semibold", size: 17)
                addressLabel.text = string(from: placemark)
                latitudeLabel.text = "  Latitude:"
                longitudeLabel.text = "  Longitude:"
                locationLabel.text = "My Current Location"
                self.addressLabel.textColor = .black
                addressLabel.adjustsFontSizeToFitWidth = false
            } else if performingReverseGeocoding {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                print("no place")
                addressLabel.text = "Searching for Address..."
                locationLabel.text = "Searching..."
            } else if lastGeocodingError != nil {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                addressLabel.text = "Error Finding Address"
                locationLabel.text = "Error Finding Location"
            } else {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                addressLabel.text = "No Address Found"
                locationLabel.text = "No Location Found"
            }
        } else {
            //latitudeLabel.text = ""
            //longitudeLabel.text = ""
            addressLabel.text = ""
            locationLabel.text = ""
            //tagButton.isHidden = true
            latitudeText.isHidden = true
            longitudeText.isHidden = true
            
            // messageLabel set based on error/status found in locations search
            let statusMessage: String
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain &&
                    error.code == CLError.denied.rawValue {
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                    statusMessage = "Location Services Disabled"
                } else {
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                    statusMessage = "Error Getting Location"
                }
                // user disabled all location services on iphone
            } else if !CLLocationManager.locationServicesEnabled() {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                statusMessage = "Searching..."
            } else {
                statusMessage = ""
                // showLogoView() is called to show logo, since no error or coords been found yet
                //showLogoView()
            }
            addressLabel.text = statusMessage
            locationLabel.text = statusMessage
        }
        //configureGetButton()
        if (self.location != nil && self.placemark != nil)
           {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
           }
    }
    
    // turns CLPlacemark object into a string
    func string(from placemark: CLPlacemark) -> String {
        var line1 = ""
        line1.add(text: placemark.subThoroughfare) // number of street
        line1.add(text: placemark.thoroughfare, separatedBy: " ") // street name
        var line2 = ""
        line2.add(text: placemark.locality) // city
        line2.add(text: placemark.administrativeArea, // state
                  separatedBy: ", ")
        line2.add(text: placemark.postalCode, separatedBy: " ") // zip code
        line1.add(text: line2, separatedBy: "\n")
        return line1
    }
    
    // MARK:- Helper Methods
    // show user an alert message if the location services is currently disabled
    func showLocationServicesDeniedAlert() {
        // alerts user of disabled locations services for this app
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services for this app in Settings.",
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default,
                                     handler: nil)
        present(alert, animated: true, completion: nil)
        alert.addAction(okAction)
    }
    
    // MARK: - CLLocationManagerDelegate
    // error delegate func called locationManager (this controller is delegate for mananger)
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("didFailWithError \(error.localizedDescription)")
        if (error as NSError).code ==
            CLError.locationUnknown.rawValue {
            return
        }
        lastLocationError = error
        stopLocationManager()
        updateLabels()
    }
    // updatingLocations delegate func called locationManager
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        //print("didUpdateLocations \(newLocation)")
        // 1
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        // 2
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        // compares distance of last or prev with newest distance. use greatest magintude if no prev distance. used to find if location updates are still improving
        var distance = CLLocationDistance(
            Double.greatestFiniteMagnitude)
        if let location = location {
            distance = newLocation.distance(from: location)
        }
        
        // 3 greater location accuracy is acctually opposite of what you would think (i.e 100 meters of acc > 10 meters of acc)
        if location == nil || location!.horizontalAccuracy >
            newLocation.horizontalAccuracy {
            // 4
            lastLocationError = nil
            location = newLocation
            //print("LOCATION:\n\n \(newLocation)")
            // 5
            if newLocation.horizontalAccuracy <=
                locationManager.desiredAccuracy {
                //print("*** We're done!")
                stopLocationManager()
                // forces geocoding for final location, even if app is geocoding now
                if distance > 0 {
                    performingReverseGeocoding = false
                }
            }
            updateLabels()
            // if not currently reverse geocoding, get state to (performingReverseGecoding = true)
            // start geocoding in line geocoder.reverGeocodeLocation...
            if !performingReverseGeocoding {
                //print("*** Going to geocode")
                performingReverseGeocoding = true
                // geocode closure which uses completionHandler. Geocode object tells handler to do code in block (placemarks, error) when done geocoding
                geocoder.reverseGeocodeLocation(newLocation,completionHandler: {
                                                placemarks, error in
                    // geocoder envokes this {block} code after geocoder found address, or error in case
                    self.lastGeocodingError = error
                    if error == nil, let p = placemarks, !p.isEmpty {
                        // if there is no placemark, play the sound effect
                        if self.placemark == nil {
                            //print("FIRST TIME!")
                            //self.playSoundEffect()
                        }
                     // set the placemark if it has a real value
                        self.placemark = p.last!
                        //var placemark1 : CLPlacemark?
                        //placemark1 = self.placemark
                        //print("\n\nPLACEMARK:\n\n \(placemark1!)\n\n")
                    } else {
                        self.placemark = nil
                    }
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                }) }
        }
            // looks to see if distance between prev location (location) and newLocation is less than 1 and if it has been 10 seconds or more. If so, then it forces to update the label with location (not getting better results with any newLocation coordinates)
        else if distance < 1 {
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            if timeInterval > 10 {
                //print("*** Force done!")
                stopLocationManager()
                updateLabels()
            }
    }
    }
    
    // func that start searching for location and controller declares itself delegate
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy =
            kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            // time object that is sent out after 60 seconds, with the contents of selector method
            timer = Timer.scheduledTimer(timeInterval: 7, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
        }
    }
    // func that stops searching for location and controller declares itself nil delegate
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            if let timer = timer {
                timer.invalidate()
            }
        } }
    
    @objc func didTimeOut() {
        //print("*** Time out")
        if location == nil {
            stopLocationManager()
            // error can't come from kCLErrorDomain
            lastLocationError = NSError(domain: "MyLocationsErrorDomain",
                                        code: 1, userInfo: nil)
            // updates labels, including NSError.
            updateLabels()
        }
    }
    
        func textViewDidBeginEditing(_ textView: UITextView) {
            textView.becomeFirstResponder()
            searchLocationText.text = ""
            searchLocationText.textColor = .black
            searchLocationText.textContainerInset = UIEdgeInsets(top: 10,left: 20,bottom: 5,right: 5)
        }
    
        func textViewDidChange(_ textView: UITextView) {
            searchLocationButton.isUserInteractionEnabled = true
            searchLocationButton.backgroundColor = .rgb(red: 0, green: 172, blue: 237)
            //searchLocation()
            
            if (searchLocationText.text == "") {
                searchLocationButton.isUserInteractionEnabled = false
                searchLocationButton.backgroundColor = .darkGray
            }
        }
}
