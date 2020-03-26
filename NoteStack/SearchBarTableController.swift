//
//  SearchBarTableController.swift
//  NoteStack
//
//  Created by Griffin Healy on 2/20/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AudioToolbox

protocol HandleAddressSelectDelegate {
    func handleAddress(address: String, selectedName: String)
}

class SearchBarTableController: UITableViewController, UISearchBarDelegate {
    
    var matchingItems: [MKMapItem] = []
    
    var storyboard_1 = UIStoryboard()
    
    let locationManager = CLLocationManager()
    
    var resultSearchController: UISearchController!
    
    var address: String = ""
    
    var delegate: HandleAddressSelectDelegate?
    
    // CreateActualNoteController
    var currentOrSearchController:CurrentOrSearchController?
    
    var soundID: SystemSoundID = 0
    var keyBoardHeightGlobal: CGFloat = 0
    
    var searchBar: UISearchBar?
    
    var extraYHeight: CGFloat = 0.0
    
    override func viewWillAppear(_ animated: Bool) {
        
        if (view.frame.size.height == 896) {
        print("iPhone Xr, iPhone Xs Max, iPhone 11, iPhone 11 Pro Max")
                }
        else if (view.frame.size.height == 812) {
        print("iPhone X, iPhone XS, iPhone 11 Pro")
        
        }
        else if (view.frame.size.height == 736) {
        print("iPhone 6s Plus, iPhone 7 Plus, iPhone 8 Plus")
        
        }
        else if (view.frame.size.height == 667) {
        print("iPhone 6,iPhone 6s, iPhone 6 Plus ,iPhone 7, iPhone 8")
        extraYHeight = 7
        }
        else if (view.frame.size.height == 568) {
        print("iPhone SE")
        extraYHeight = 7
        }
        else {
        print("Another iPhone Model")
        print(view.frame.size.height)
        }
        
        //self.tableView.frame = CGRect(x: 20, y: 150, width: 334, height: 315)
        self.tableView.frame = CGRect(x: (self.currentOrSearchController?.view.frame.width)! - ((self.currentOrSearchController?.view.frame.width)!/1.05) , y: 105 + extraYHeight, width: (self.currentOrSearchController?.view.frame.width)! - ((self.currentOrSearchController?.view.frame.width)!/6.5), height: (self.currentOrSearchController?.view.frame.height)! - (self.keyBoardHeightGlobal + 110))

    }
    
    override func viewDidLayoutSubviews() {
        var searchBarFrame = self.searchBar!.frame
        searchBarFrame.size.width = currentOrSearchController!.view.frame.size.width
        self.searchBar!.frame = searchBarFrame
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        NotificationCenter.default.addObserver(
        self,
        selector: #selector(keyboardWillShow),
        name: UIResponder.keyboardWillShowNotification,
        object: nil)
        
        print("In search bar/tableview")
        view.backgroundColor = .clear
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        resultSearchController = UISearchController(searchResultsController: self)
        resultSearchController.searchResultsUpdater = self
        resultSearchController.obscuresBackgroundDuringPresentation = false
        searchBar = resultSearchController!.searchBar
        searchBar!.delegate = self
        searchBar!.sizeToFit()
        searchBar!.placeholder = "Search for places..."
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        navigationItem.titleView = resultSearchController?.searchBar
        navigationItem.titleView?.backgroundColor = .rgb(red: 0, green: 220, blue: 254)
        navigationItem.titleView?.tintColor = .black
        
        if let textFieldInsideSearchBar  = searchBar!.value(forKey: "searchField") as? UITextField {
            textFieldInsideSearchBar.textColor = .black
            textFieldInsideSearchBar.backgroundColor = UIColor.white
        }
        resultSearchController.hidesNavigationBarDuringPresentation = false
    }
    
    
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil &&
                            selectedItem.thoroughfare != nil) ? " " : ""
        
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) &&
                    (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil &&
                            selectedItem.administrativeArea != nil) ? " " : ""
        
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        address = addressLine
        return addressLine
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
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            keyBoardHeightGlobal = keyboardHeight
        }
    }
    
}

extension SearchBarTableController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //guard let location = locations.first else { return }
        //let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        //let region = MKCoordinateRegion(center: location.coordinate, span: span)
        //mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("Searching...")
    }

}

extension SearchBarTableController : UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        //guard let mapView = mapView,
        guard let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        //request.region = mapView.region
        let search = MKLocalSearch(request: request)
        
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            //self.tableView.frame = CGRect(x: 20, y: self.view.frame.size.height / 2.0, width: 334, height: 300)
            //self.tableView.frame = CGRect(x: 20, y: 150, width: 334, height: 315)
            self.tableView.frame = CGRect(x: (self.currentOrSearchController?.view.frame.width)! - ((self.currentOrSearchController?.view.frame.width)!/1.05) , y: 105 + self.extraYHeight, width: (self.currentOrSearchController?.view.frame.width)! - ((self.currentOrSearchController?.view.frame.width)!/6.5), height: (self.currentOrSearchController?.view.frame.height)! - (self.keyBoardHeightGlobal + 110))
            
            self.tableView.reloadData()
//            var frame = self.tableView.frame
//            frame.size.height = self.tableView.contentSize.height - 100
//            self.tableView.frame = frame
        }
        
    }
    
}

extension SearchBarTableController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
    }
}

extension SearchBarTableController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        //handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        dismiss(animated: true, completion: nil)
        let currentSearchController = currentOrSearchController
        self.delegate = currentSearchController
        let parsedAddress = parseAddress(selectedItem: selectedItem)
        //loadSoundEffect("navtap.mp3")
        //playSoundEffect()
        delegate?.handleAddress(address: parsedAddress, selectedName: selectedItem.name ?? "No Name")
        dismiss(animated: true)
    }
}
