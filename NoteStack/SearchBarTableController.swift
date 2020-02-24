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

protocol HandleAddressSelectDelegate {
    func handleAddress(address: String, selectedName: String)
}

class SearchBarTableController: UITableViewController {
    
    var matchingItems: [MKMapItem] = []
    
    var storyboard_1 = UIStoryboard()
    
    let locationManager = CLLocationManager()
    
    var resultSearchController: UISearchController!
    
    var address: String = ""
    
    var delegate: HandleAddressSelectDelegate?
    
    // CreateActualNoteController
    var currentOrSearchController:CurrentOrSearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("In search bar/tableview")
        view.backgroundColor = .clear
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        resultSearchController = UISearchController(searchResultsController: self)
        resultSearchController.searchResultsUpdater = self
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places.."
        navigationItem.titleView = resultSearchController?.searchBar
        navigationItem.titleView?.backgroundColor = .white
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
    
}

extension SearchBarTableController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        //mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
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
            self.tableView.frame = CGRect(x: 20, y: 150, width: 334, height: 350)
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
        delegate?.handleAddress(address: address, selectedName: selectedItem.name ?? "No Name")
        dismiss(animated: true)
    }
}
