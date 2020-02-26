//
//  NoteCell.swift
//  NoteStack
//
//  Created by Griffin Healy on 2/5/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//

import UIKit

// our custom subclass for table view cells
class NoteCell: UITableViewCell {
    
    @IBOutlet weak var noteLabel: UILabel!
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
    func configure(for note: Notes) {
        if note.noteText.isEmpty {
            noteLabel.text = "(No Note)"
        } else {
            // find attribute or property locationDescription and label to that value
            let trimmedString = note.noteText.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            print(trimmedString)
            noteLabel.text = trimmedString
            noteLabel.font = UIFont(name: "PingFangHK-Regular", size: 17)
        }
    }
}
