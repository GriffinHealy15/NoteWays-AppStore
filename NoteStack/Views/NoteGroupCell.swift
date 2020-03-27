//
//  NoteGroupCell.swift
//  NoteStack
//
//  Created by Griffin Healy on 2/26/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//

import UIKit

// our custom subclass for table view cells
class NoteGroupCell: UITableViewCell {
    
    @IBOutlet weak var noteGroupLabel: UILabel!
    
    @IBOutlet weak var noteCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let selection = UIView(frame: CGRect.zero)
        selection.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
    }
    
    // MARK:- Helper Method
    // passed note group object from array of note groups, will put note group oject into table view cell
    func configure(for notegroup: NotesGroup, count: Int) {
        noteCountLabel.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 17)
        noteCountLabel.text = "\(count) Notes"
        if notegroup.groupName.isEmpty {
            noteGroupLabel.text = "(No Group)"
        } else {
            noteGroupLabel.text = notegroup.groupName
//            let trimmedString = noteGroupLabel.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
//            noteGroupLabel.text = trimmedString
            noteGroupLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 17)
        }
    }
}

