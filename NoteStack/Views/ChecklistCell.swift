//
//  ChecklistCell.swift
//  NoteStack
//
//  Created by Griffin Healy on 3/31/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//

import UIKit

protocol OptionButtonsDelegate{
    func detailChecklistEdit(at index:IndexPath)
}

// our custom subclass for table view cells
class ChecklistCell: UITableViewCell {
    
    @IBOutlet weak var checklistGroupLabel: UILabel!
    
    @IBOutlet weak var checklistLabel1: UILabel!
    
    @IBOutlet weak var checklistIconImage: UIImageView!
    
    @IBOutlet weak var remainingItemsLabel: UILabel!
    
    var delegate:OptionButtonsDelegate!
    @IBOutlet weak var checklistEditButton: UIButton!
    var indexPath:IndexPath!
    @IBAction func detailChecklistEditAction(_ sender: UIButton) {
        self.delegate?.detailChecklistEdit(at: indexPath)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let selection = UIView(frame: CGRect.zero)
        selection.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
    }

    // MARK:- Helper Method
    func configure(for checklist: ChecklistsGroup, remainingItems: Int, totalItems: Int) {
        //noteCountLabel.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 17)
        //noteCountLabel.text = "\(count) Notes"
        if checklist.checklistName.isEmpty {
            checklistLabel1.text = "(No Group)"
        } else {
            if (remainingItems == 0) {
                remainingItemsLabel.backgroundColor = .rgb(red: 0, green: 222, blue: 143)
                remainingItemsLabel.textColor = .white
                remainingItemsLabel.layer.cornerRadius = 5
                remainingItemsLabel.layer.masksToBounds = true
                remainingItemsLabel.text = " Completed Checklist"
            }
            if (totalItems == 0) {
                remainingItemsLabel.backgroundColor = .white
                remainingItemsLabel.textColor = .black
                remainingItemsLabel.layer.cornerRadius = 0
                remainingItemsLabel.layer.masksToBounds = false
                remainingItemsLabel.text = "Empty Checklist"
            }
            if (remainingItems > 0) {
                remainingItemsLabel.backgroundColor = .white
                remainingItemsLabel.textColor = .black
                remainingItemsLabel.layer.cornerRadius = 0
                remainingItemsLabel.layer.masksToBounds = false
                remainingItemsLabel.text = "\(remainingItems) Items Remaining"
            }
            checklistLabel1.textColor = .black
            checklistLabel1.text = checklist.checklistName
            checklistIconImage.image = UIImage(imageLiteralResourceName: checklist.checklistIcon ?? "Default")
            //checklistEditButton.setImage(UIImage(imageLiteralResourceName: "Edit"), for: .normal)
//            let trimmedString = noteGroupLabel.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
//            noteGroupLabel.text = trimmedString
            checklistLabel1.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 17)
        }
    }
}
