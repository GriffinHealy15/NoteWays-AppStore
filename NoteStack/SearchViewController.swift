//
//  SearchViewController.swift
//  MyLocations
//
//  Created by Griffin Healy on 2/6/19.
//  Copyright © 2019 Griffin Healy. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import AudioToolbox

class SearchViewController: UITableViewController, SearchCellDelegate {
    
    @IBOutlet weak var addressTextToDisplay : UILabel!
    @IBOutlet weak var TagLocationButton: UIBarButtonItem!
    var finalCoords: CLLocationCoordinate2D? = nil
    var location : CLLocation?
    var managedObjectContext: NSManagedObjectContext!
    var addressToPassSegue: CLPlacemark?
    var soundID: SystemSoundID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TagLocationButton.isEnabled = false
        loadSoundEffect("Success.wav")
            
         }
    

    // MARK:- Table View Delegates
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
            // table view is asking us for a cell, we give the custom cell SearchSell, which it has an indentifier for (meaning it can find the cell)
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "SearchCell",
                for: indexPath) as! SearchCell
            // controller declares itself a delegate to the custom cell (SearchCell)
            cell.delegate = self
            return cell }
    
    // disable table view selection
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        print(textView.text)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    
    
    //MARK:- SearchCell Delegate Methods
    // we declared us the delegate of searchCell, and so, we implement this function below (custom cell passes foundText to us, as long as we implement the func below)
    func retrievedSearchedText(cell: SearchCell, foundText: String) {
        // GeoCode your address, so it turns the address into coordinates
        let geocoder = CLGeocoder()
        let addressForGeocoding = foundText
        //let address = "8787 Snouffer School Rd, Montgomery Village, MD 20879"
        geocoder.geocodeAddressString(addressForGeocoding, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                print("Error", error ?? "")
            }
            if let placemark = placemarks?.first {
                self.addressToPassSegue = placemark
                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                self.finalCoords = coordinates
                print("Latitutde: \(self.finalCoords!.latitude) -- Longitude: \(self.finalCoords!.longitude)")
                
                let Coordinates = "Coordinates: "
                let comma = ", "
                self.addressTextToDisplay.text = (Coordinates)
                let stringCoordsLat: String!  = ("\(String(describing: self.finalCoords!.latitude))")
                let stringCoordsLon: String!  = ("\(String(describing: self.finalCoords!.longitude)) ")
                self.addressTextToDisplay.text!.append(stringCoordsLat!)
                self.addressTextToDisplay.text!.append(comma)
                self.addressTextToDisplay.text!.append(stringCoordsLon!)
                
                let getLat: CLLocationDegrees = coordinates.latitude
                let getLon: CLLocationDegrees = coordinates.longitude
                self.location = CLLocation(latitude: getLat, longitude: getLon)
                
                if (self.location != nil)
                {
                    self.TagLocationButton.isEnabled = true
                    // call playsound effect
                    self.playSoundEffect()
                }
                //print("Search Location \(self.location)")
                
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
    
    // MARK:- Navigation
    // preparing to segue to LocationsDetailViewController
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        // if button that caused segue is identifier "TagLocation", set controller dest as LocationDetailsViewController. Then, pass the coordinates of location, and a possible address (placemark) to the controller. controller = LocationsDetailViewController
        if segue.identifier == "TagFutureLocation" {
            let controller = segue.destination
                as! LocationDetailsViewController
            // controller is LocationsViewController (we set its coordinate, placemark, and managedObjectContexts vars with this controllers matching vars
            controller.coordinate = location!.coordinate
            controller.placemark = addressToPassSegue
            controller.managedObjectContext = managedObjectContext
        }
    }
}
