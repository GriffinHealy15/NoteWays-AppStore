//
//  SearchCell.swift
//  MyLocations
//
//  Created by Griffin Healy on 2/6/19.
//  Copyright © 2019 Griffin Healy. All rights reserved.
//

import UIKit

protocol SearchCellDelegate {
    func retrievedSearchedText(cell: SearchCell, foundText: String)
}

class SearchCell: UITableViewCell {
    
    // outlet to the search bar text
     @IBOutlet weak var findSearchedText: UITextField!
    
    // delegate var for the protocol above
    var delegate: SearchCellDelegate?
    var foundSearchedText = ""
    
    @IBAction func searchButton(_ sender: UIButton) {
        // retrieve the text in the text (findSearchedText)
        foundSearchedText = findSearchedText.text!
        //print("searched text \(foundSearchedText)") // foundText is identifier, foundSearchedText is value
        // look to see if there is a delegate to to implement our methods in this custom cell (this custom cell will pass information in its methods)
        // 1. look for delegate?, someone who declared self delegate for SearchCellDeleate protocol
        // 2. we want delegate for us to implement retrievedSearchedText method (custom cell will pass foundSearchedText in the method)
        // 3. SearchViewController who conforms to the protocol, and delcares itself a delegate using cell.delegate = self (custom cell.delegate = self (search view controller))
        // 4. Once search view controller says it is the custom cells delegate, and conforms to delegate protocol, it runs the methods of the protocol (in this case, just findSearchedText)
        // 5. Now once we run the method in search view controller, the foundSearchedText parameter is passed through using the line below, and we can retrieve the text
        delegate?.retrievedSearchedText(cell: self, foundText: foundSearchedText)
        // hide keyboard when Search button is pressed
        findSearchedText.resignFirstResponder()
    }
}
