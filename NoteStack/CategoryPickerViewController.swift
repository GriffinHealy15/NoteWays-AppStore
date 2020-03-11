//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by Griffin Healy on 1/23/19.
//  Copyright © 2019 Griffin Healy. All rights reserved.
//

import UIKit
import AudioToolbox
// category tableview
class CategoryPickerViewController: UITableViewController {
    var selectedCategoryName = ""
    var soundID: SystemSoundID = 0
    let categories = [
        "No Category",
        "Apple Store",
        "Bar",
        "Bookstore",
        "Club",
        "Grocery Store",
        "Historic Building",
        "House",
        "Icecream Vendor",
        "Landmark",
        "Park"]
    var selectedIndexPath = IndexPath()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSoundEffect("Click.wav")
        for i in 0..<categories.count {
            if categories[i] == selectedCategoryName {
                // if passed selectedCategoryName equals that array [i] index, then set an indexpath  for that row: i,  for section: 0
                selectedIndexPath = IndexPath(row: i, section: 0)
                break
            } }
    }
    // MARK:- Table View Delegates
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "Cell",
                for: indexPath)
            let categoryName = categories[indexPath.row]
            cell.textLabel!.text = categoryName
            // while creating the cell for every row, if your row has the passed category then set .checkmark to cell accessoryType
            if categoryName == selectedCategoryName {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            let selection = UIView(frame: CGRect.zero)
            selection.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
            // before returning this cell to tableView, we say whenever this cell is selected, use this view (from selectedBackgroundView). The view is put over the cell selected, with a color of white, alpha 0.3 (so the category label is still visible)
            cell.selectedBackgroundView = selection
            return cell }
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        playSoundEffect()
        // was the row selected index.row == to choosen, passed selectedIndexPath.row. If so, this object is what should be set with .none accessoryType
        if indexPath.row != selectedIndexPath.row {
            if let newCell = tableView.cellForRow(at: indexPath) {
                newCell.accessoryType = .checkmark
               print("index path \(indexPath)")
            }
            // the choosen (passed a category) cell, that you tell tableView to uncheck
            if let oldCell = tableView.cellForRow(
                at: selectedIndexPath) {
                oldCell.accessoryType = .none
            }
            // whatever the indexPath (row) selected, make this the newest selectedIndexPath
            selectedIndexPath = indexPath
        }
    }
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        // if button or tap (in this case didSelectRowAt) was pressed, and the segue brings you to LocationDetailsViewController, then if the identifier is "PickedCategory", then we know the controller to be opened wants a category name of the row selected.
        if segue.identifier == "PickedCategory" {
            let cell = sender as! UITableViewCell
            // look in the row that the cell is in, find the index. Locate the corresponding index in categories[] array. So, the name in array i is the same value of name in cell in row i. Set the selectedCategoryName to that Name for array i. Passes in segue transfer.
            if let indexPath = tableView.indexPath(for: cell) {
                selectedCategoryName = categories[indexPath.row]
            }
        } }
    
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
    
}
