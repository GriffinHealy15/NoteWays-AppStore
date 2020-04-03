//
//  ChecklistItemCell.swift
//  NoteStack
//
//  Created by Griffin Healy on 4/1/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//

import UIKit

protocol OptionItemButtonsDelegate{
    func detailChecklistItemEdit(at index:IndexPath)
}

// our custom subclass for table view cells
class ChecklistItemCell: UITableViewCell {
    
    
    @IBOutlet weak var checklistItemLabel: UILabel!
    
    @IBOutlet weak var checklistChecked: UIImageView!
    
    var delegateItemEdit:OptionItemButtonsDelegate!
    @IBOutlet weak var checklistItemEditButton: UIButton!
    var indexPath:IndexPath!
    @IBAction func detailChecklistItemEditAction(_ sender: UIButton) {
        self.delegateItemEdit?.detailChecklistItemEdit(at: indexPath)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let selection = UIView(frame: CGRect.zero)
        selection.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK:- Helper Method
    // passed location object from array of locations, will put location oject into table view cell
    func configure(for checklistitems: Items) {
            //noteCountLabel.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 17)
            //noteCountLabel.text = "\(count) Notes"
        if checklistitems.itemName.isEmpty {
                checklistItemLabel.text = "(No Item)"
            } else {
            if (checklistitems.itemChecked == false) {
                checklistChecked.image = nil
            }
            else if (checklistitems.itemChecked == true) {
                checklistChecked.image = #imageLiteral(resourceName: "checkmark-1")
            }
                checklistItemLabel.textColor = .black
                checklistItemLabel.text = checklistitems.itemName
                //checklistIconImage.image = UIImage(imageLiteralResourceName: checklist.checklistIcon ?? "Default")
                //checklistEditButton.setImage(UIImage(imageLiteralResourceName: "Edit"), for: .normal)
    //            let trimmedString = noteGroupLabel.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    //            noteGroupLabel.text = trimmedString
                checklistItemLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 17)
            }
        }
}

