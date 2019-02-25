//
//  FirstViewController.swift
//  MyLocations
//
//  Created by Griffin Healy on 1/21/19.
//  Copyright © 2019 Griffin Healy. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import AudioToolbox

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate, CAAnimationDelegate {
    
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
    var managedObjectContext: NSManagedObjectContext!
    var soundID: SystemSoundID = 0
    var logoVisible = false
    lazy var logoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "Logo"),
                                  for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(getLocation), // when button is pressed, it has the selector method of (getLocation) to try find the coords
                         for: .touchUpInside)
        button.center.x = self.view.bounds.midX
        button.center.y = 220
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // tells nav controller to hide navigation bar while this view is about to appear
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // update labels from initial load
        updateLabels()
        // Do any additional setup after loading the view, typically from a nib.
        loadSoundEffect("Success.wav")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // hide nav bar set to false (show it) when this view exit this view to show Location contrl
        navigationController?.isNavigationBarHidden = false
    }
    // outlets to tell labels something (e.x like to change their text)
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    @IBOutlet weak var latitudeTextLabel: UILabel!
    @IBOutlet weak var longitudeTextLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    // MARK:- Actions
    // button Get Location is pressed and tells this function it was pressed, and to do something
    @IBAction func getLocation() {
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
        if logoVisible {
            hideLogoView()
        }
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
        updateLabels()
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
        print("didUpdateLocations \(newLocation)")
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
            print("LOCATION:\n\n \(newLocation)")
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
                            self.playSoundEffect()
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
    // turns CLPlacemark object into a string
    func string(from placemark: CLPlacemark) -> String {
        var line1 = ""
        line1.add(text: placemark.subThoroughfare) // number of street
        line1.add(text: placemark.thoroughfare, separatedBy: " ") // street name
        var line2 = ""
        line2.add(text: placemark.locality) // city
        line2.add(text: placemark.administrativeArea, // state
                  separatedBy: " ")
        line2.add(text: placemark.postalCode, separatedBy: " ") // zip code
        line1.add(text: line2, separatedBy: "\n")
        return line1
    }
    // configure get button title
    func configureGetButton() {
        let spinnerTag = 1000
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
            if view.viewWithTag(spinnerTag) == nil {
                let spinner = UIActivityIndicatorView(style: .white)
                spinner.center = messageLabel.center
                spinner.center.y += spinner.bounds.size.height/2 + 25
                spinner.startAnimating()
                spinner.tag = spinnerTag
                containerView.addSubview(spinner)
            }
        } else {
            getButton.setTitle("Get My Location", for: .normal)
            if let spinner = view.viewWithTag(spinnerTag) {
                spinner.removeFromSuperview()
            }
        } }
    // function called to update labels
    func updateLabels() {
        // location not nil (found), update text labels
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
            latitudeTextLabel.isHidden = false
            longitudeTextLabel.isHidden = false
            if let placemark = placemark {
                addressLabel.text = string(from: placemark)
                addressLabel.adjustsFontSizeToFitWidth = false
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            latitudeTextLabel.isHidden = true
            longitudeTextLabel.isHidden = true
            
            // messageLabel set based on error/status found in locations search
            let statusMessage: String
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain &&
                    error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
                // user disabled all location services on iphone
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = ""
                // showLogoView() is called to show logo, since no error or coords been found yet
                showLogoView()
            }
            messageLabel.text = statusMessage
        }
        configureGetButton()
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
    // objc func accessable from objective-c. didTimeOut() called after 1 min. Cancels search if any location has not been found. Cancels timer. Stop button also cancels timer too, though.
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
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        // if button that caused segue is identifier "TagLocation", set controller dest as LocationDetailsViewController. Then, pass the coordinates of location, and a possible address (placemark) to the controller. controller = LocationsDetailViewController
        if segue.identifier == "TagLocation" {
            let controller = segue.destination
                as! LocationDetailsViewController
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
            controller.managedObjectContext = managedObjectContext
        }
    }
    // MARK:- Logo Views
    // show logo before coords or stop is pressed
    func showLogoView() {
        // if logo isn't visible, initialized to false at controller initializing
        if !logoVisible {
            logoVisible = true // set to true
            containerView.isHidden = true // hide container view with labels and tag button
            view.addSubview(logoButton) // add the subview with the logo button. when the logo button is pressed, it will disappear (logoButton is a lazy var, so it is just initialized)
        } }
    // remove the logo view, when location coords found
    func hideLogoView() {
        if !logoVisible { return }
        logoVisible = false
        containerView.isHidden = false
        containerView.center.x = view.bounds.size.width * 2
        containerView.center.y = 40 +
            containerView.bounds.size.height / 2
        let centerX = view.bounds.midX
        let panelMover = CABasicAnimation(keyPath: "position")
        panelMover.isRemovedOnCompletion = false
        panelMover.fillMode = CAMediaTimingFillMode.forwards
        panelMover.duration = 0.6
        panelMover.fromValue = NSValue(cgPoint: containerView.center)
        panelMover.toValue = NSValue(cgPoint:
            CGPoint(x: centerX, y: containerView.center.y))
        panelMover.timingFunction = CAMediaTimingFunction(
            name: CAMediaTimingFunctionName.easeOut)
        panelMover.delegate = self
        containerView.layer.add(panelMover, forKey: "panelMover")
        let logoMover = CABasicAnimation(keyPath: "position")
        logoMover.isRemovedOnCompletion = false
        logoMover.fillMode = CAMediaTimingFillMode.forwards
        logoMover.duration = 0.5
        logoMover.fromValue = NSValue(cgPoint: logoButton.center)
        logoMover.toValue = NSValue(cgPoint:
            CGPoint(x: -centerX, y: logoButton.center.y))
        logoMover.timingFunction = CAMediaTimingFunction(
            name: CAMediaTimingFunctionName.easeIn)
        logoButton.layer.add(logoMover, forKey: "logoMover")
        let logoRotator = CABasicAnimation(keyPath:
            "transform.rotation.z")
        logoRotator.isRemovedOnCompletion = false
        logoRotator.fillMode = CAMediaTimingFillMode.forwards
        logoRotator.duration = 0.5
        logoRotator.fromValue = 0.0
        logoRotator.toValue = -2 * Double.pi
        logoRotator.timingFunction = CAMediaTimingFunction(
            name: CAMediaTimingFunctionName.easeIn)
        logoButton.layer.add(logoRotator, forKey: "logoRotator")
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
    // MARK:- Animation Delegate Methods
    func animationDidStop(_ anim: CAAnimation,
                          finished flag: Bool) {
        containerView.layer.removeAllAnimations()
        containerView.center.x = view.bounds.size.width / 2
        containerView.center.y = 40 +
            containerView.bounds.size.height / 2
        logoButton.layer.removeAllAnimations()
        logoButton.removeFromSuperview()
    }
}

