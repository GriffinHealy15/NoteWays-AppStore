//
//   MapViewController.swift
//  MyLocations
//
//  Created by Griffin Healy on 1/29/19.
//  Copyright © 2019 Griffin Healy. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import AudioToolbox

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    var managedObjectContext: NSManagedObjectContext! {
        //  didSet block tells the NotificationCenter to add an observer for the NSManagedObjectContextObjectsDidChange notification
        didSet {    NotificationCenter.default.addObserver(forName:
            Notification.Name.NSManagedObjectContextObjectsDidChange,
             object: managedObjectContext,
             queue: OperationQueue.main) { notification in
               /* if let dictionary = notification.userInfo {
                    print("Dictionary inserted: \(dictionary[NSInsertedObjectsKey] as Any)")
                    print("Dictionary updated: \(dictionary[NSUpdatedObjectsKey] as Any)")
                    print("Dictionary deleted: \(dictionary[NSDeletedObjectsKey] as Any)") 
                } */
                // updateLocations if the mapView is loaded, only loaded when in map view tab
            if self.isViewLoaded {
                // in response, if we got a new update, then we call updateLocations() which will update the map viw with the newest annotations
               self.updateLocations()
            }
            } }
    }
    var locations = [Location]()
    var soundID: SystemSoundID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // first fetches locations context object (from datastore), then add locations objects as annotations objects
        updateLocations()
        // if there are existing locations, call show locations
        if !locations.isEmpty {
            showLocations()
        }
        loadSoundEffect("Pin.wav")
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
    @IBAction func showUser() {
        let region = MKCoordinateRegion(
            center: mapView.userLocation.coordinate,
            latitudinalMeters: 1000,longitudinalMeters: 1000)
        mapView.setRegion(mapView.regionThatFits(region),    animated: true)
    }
    // called through storyboard when Locations button presseed, button tells this func that it was pressed and that their linked. showLocations (IBAction then says, Ok I saw you were pressed, I will run this func now)
    @IBAction func showLocations() {
        // calls region func with parameter of locations object (that conforms to MKAnnotations protocol) this func finds the bounds of all annotations (to show all on the map)
        let theRegion = region(for: locations)
        // after finding bounds of annotations on the map, we tell the mapView outlet to be set with right region
        mapView.setRegion(theRegion, animated: true)
    }
    
    // perform manual segue
    @objc func showLocationDetails(_ sender: UIButton) {
        print("Clicked")
        self.playSoundEffect()
        //performSegue(withIdentifier: "EditLocation", sender: sender)
        
        let location = locations[sender.tag]
        // give controller the location object (contains that location from an index in array, and it contains its properties)
        let locationsDetailsContrl = CurrentOrSearchDetailController()
        locationsDetailsContrl.locationToEdit = location
        locationsDetailsContrl.managedObjectContext = managedObjectContext
        let locDetailsController = UINavigationController(rootViewController: locationsDetailsContrl)
        present(locDetailsController, animated: true)
    }
    
    // MARK:- Navigation
//    override func prepare(for segue: UIStoryboardSegue,
//                          sender: Any?) {
//        // the segue that is about to be triggered is "EditLocation" (because that is what showLocationDetails said that identifiers segue should go to happens)
//        if segue.identifier == "EditLocation" {
//            // set controller dest as Locations Details
//            let controller = segue.destination
//                as! LocationDetailsViewController
//            // pass the context object to destination controller
//            controller.managedObjectContext = managedObjectContext
//            let button = sender as! UIButton
//            // retrieve the button tag (the number assigned to the annotation, which corresponds to the index of the locations array
//            let location = locations[button.tag]
//            // pass that location object to Locations Details, so to edit the location
//            controller.locationToEdit = location
//        } }
    
    // MARK:- Helper methods
    // add annotations
    func updateLocations() {
        mapView.removeAnnotations(locations as [MKAnnotation])
        let entity = Location.entity()
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = entity
        locations = try! managedObjectContext.fetch(fetchRequest)
        // add annotations to all the locations objects coords (pretending to be MKAnnotations objects)
        mapView.addAnnotations(locations as [MKAnnotation]) // locations is pretending to be an annotation, does this by implementing the protocol methods of MKAnnotation, locations is not a delegate for MKAnnotations
    
    }
    
    func region(for annotations: [MKAnnotation]) ->
        MKCoordinateRegion {
            let region: MKCoordinateRegion
            switch annotations.count {
                // no annotations, center map on on user
            case 0:
                region = MKCoordinateRegion(
                    center: mapView.userLocation.coordinate,
                    latitudinalMeters: 1000, longitudinalMeters: 1000)
                // one annotation, center map on users one annotation
            case 1:
                // go to annotations index 0, to center on only annotation
                let annotation = annotations[annotations.count - 1]
                region = MKCoordinateRegion(
                    center: annotation.coordinate,
                    latitudinalMeters: 1000, longitudinalMeters: 1000)
                // two or more annotations
            default:
                var topLeft = CLLocationCoordinate2D(latitude: -90,
                                                     longitude: 180)
                var bottomRight = CLLocationCoordinate2D(latitude: 90,
                                                         longitude: -180)
                
                for annotation in annotations {
                    topLeft.latitude = max(topLeft.latitude,
                                           annotation.coordinate.latitude)
                    topLeft.longitude = min(topLeft.longitude,
                                            annotation.coordinate.longitude)
                    bottomRight.latitude = min(bottomRight.latitude,
                                               annotation.coordinate.latitude)
                    bottomRight.longitude = max(bottomRight.longitude,
                                                annotation.coordinate.longitude)
                }
                let center = CLLocationCoordinate2D(
                    latitude: topLeft.latitude -
                        (topLeft.latitude - bottomRight.latitude) / 2,
                    longitude: topLeft.longitude -
                        (topLeft.longitude - bottomRight.longitude) / 2)
                let extraSpace = 1.1
                let span = MKCoordinateSpan(
                    latitudeDelta: abs(topLeft.latitude -
                        bottomRight.latitude) * extraSpace,
                    longitudeDelta: abs(topLeft.longitude -
                        bottomRight.longitude) * extraSpace)
                region = MKCoordinateRegion(center: center, span: span)
            }
            return mapView.regionThatFits(region)
    }
    }


extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) ->
        MKAnnotationView? {
            // 1
            // have to guard for other possible annotations that are not Location objects
            guard annotation is Location else {
                return nil
            }
            
            // 2
            let identifier = "Location"
            // similar to tableView cellForAt, ask mapView to reuse an annotation view object
            var annotationView = mapView.dequeueReusableAnnotationView(
                withIdentifier: identifier)
            // create annotations using MKPinAnnotationView
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                if annotationView == nil {
                // 3
                // set properties of pinView
                pinView.isEnabled = true
                self.playSoundEffect()
                pinView.canShowCallout = true
                pinView.animatesDrop = false
                pinView.pinTintColor = UIColor(red: 0.32, green: 0.82,
                blue: 0.4, alpha: 1)
                pinView.tintColor = UIColor(white: 0.0, alpha: 0.5)
                // 4
                // Create a new UIButton object that looks like a detail disclosure button
                let rightButton = UIButton(type: .detailDisclosure)
                //target-action pattern to hook up the button’s “Touch Up Inside” event with a method showLocationDetails(). calls LocationsDetailsViewController
                rightButton.addTarget(self,
                action: #selector(showLocationDetails(_:)), for: .touchUpInside)
                // add the button to the annotation view’s accessory view.
                pinView.rightCalloutAccessoryView = rightButton
                annotationView = pinView
                }
                if let annotationView = annotationView {
                annotationView.annotation = annotation
                // 5
                //obtain a reference to that detail disclosure button again and set its tag to the index of the Location object in the locations array. That way, you can find the Location object later in showLocationDetails() when the button is pressed.
                let button = annotationView.rightCalloutAccessoryView
                    as! UIButton
                    // find the location object index in the locations array
                if let index = locations.index(of: annotation as! Location) {
                    button.tag = index
            }
    }
            return annotationView
    }
}
