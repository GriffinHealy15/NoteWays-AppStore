//
//  NoteCell_ForGroup.swift
//  NoteStack
//
//  Created by Griffin Healy on 2/27/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//

import UIKit

// our custom subclass for table view cells
class NoteCell_ForGroup: UITableViewCell {
    
    var onlyNoteText = ""
    
    @IBOutlet weak var noteLabel_1: UILabel!
    
    @IBOutlet weak var photoImage: UIImageView!
    
    @IBOutlet weak var arrowImage: UIImageView!
    
    @IBOutlet weak var placeholderNoteImage: UIImageView!
    
    var rgbColorArrayFloat: [CGFloat] = []
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let selection = UIView(frame: CGRect.zero)
        selection.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        photoImage.layer.cornerRadius = 15
        photoImage.clipsToBounds = true
        photoImage.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK:- Helper Method
    // passed location object from array of locations, will put location oject into table view cell
    func configure(for note: Notes) {
        if note.noteText.isEmpty {
            noteLabel_1.text = "(No Text)"
        } else {
            
            // find attribute or property locationDescription and label to that value
            let trimmedString = note.noteText.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        onlyNoteText = ""
        var trimmed: String = ""
        trimmed = trimmedString.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if trimmed.contains("\n") {
        let myStringArr = trimmed.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: false)
            let range = myStringArr[0].rangeOfCharacter(from: CharacterSet.alphanumerics)
            if (range != nil) {
                // note doesn't start with image
                onlyNoteText = onlyNoteText + myStringArr[0] + " " + myStringArr[1]
                noteLabel_1.text = onlyNoteText
                noteLabel_1.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 17)
            }
            else {
                // note starts with image
                onlyNoteText = onlyNoteText + myStringArr[1]
                let trimmedString2 = onlyNoteText.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                let trimmedString3 = parseString(trimmedString2: trimmedString2)
                let range = trimmedString3.rangeOfCharacter(from: CharacterSet.alphanumerics)
                if (range == nil) {
                    noteLabel_1.text = "(No Text)"
                    noteLabel_1.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 17)
                }
                else {
                noteLabel_1.text = trimmedString3
                noteLabel_1.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 17)
                }
            }
        }
        else {
            onlyNoteText = ""
            let range = note.noteText.rangeOfCharacter(from: CharacterSet.alphanumerics)
            if (range == nil) {
                noteLabel_1.text = "(No Text)"
                noteLabel_1.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 17)
            }
            else {
            noteLabel_1.text = trimmedString
            noteLabel_1.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 17)
            }
        }
        }
        rgbColorArrayFloat = []
        let noteColorArray =  note.noteColorArray
        for i in 0...noteColorArray.count - 1 {
            rgbColorArrayFloat.append(noteColorArray[i] as! CGFloat)
        }
        for _ in 0...rgbColorArrayFloat.count - 1 {
            red = rgbColorArrayFloat[0]
            green = rgbColorArrayFloat[1]
            blue = rgbColorArrayFloat[2]
        }
        
        if ((red + green > 415) || (red + blue > 415) || (blue + green > 415)) {
        noteLabel_1.textColor = .black
        noteLabel_1.tintColor = .black
        if (note.hasPhoto == false) {
            placeholderNoteImage.image = UIImage(imageLiteralResourceName: "notedark.png")
            photoImage.image = nil
        }
        else if (note.hasPhoto == true) {
            photoImage.image = thumbnail(for: note)
            placeholderNoteImage.image = nil
        }
        arrowImage.image = UIImage(imageLiteralResourceName: "forward2.png")
        arrowImage.tintColor = .black
        }
        else {
            noteLabel_1.textColor = .white
            noteLabel_1.tintColor = .white
            if (note.hasPhoto == false) {
                placeholderNoteImage.image = UIImage(imageLiteralResourceName: "notelight.png")
                photoImage.image = nil
            }
            else if (note.hasPhoto == true) {
                photoImage.image = thumbnail(for: note)
                placeholderNoteImage.image = nil
            }
            arrowImage.image = UIImage(imageLiteralResourceName: "forwardwhite.png")
            arrowImage.tintColor = .white
        }
        
        //backgroundColor = .white
    }
    
    // recursive function to parse string from texts with multiple images before text
    func parseString(trimmedString2: String) -> String {
        if trimmedString2.contains("\n") {
        let myStringArr = trimmedString2.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: false)
                   let range = myStringArr[0].rangeOfCharacter(from: CharacterSet.alphanumerics)
            if range != nil {
                return trimmedString2
            }
            else {
                let myParsed = parseString(trimmedString2: String(myStringArr[1]))
                return myParsed
            }
        }
        return trimmedString2
    }
    
    func thumbnail(for note: Notes) -> UIImage {
        var _: Int = 5
          // if location oject hasPhoto (photo id has value of not nil), then we find the image for this location object by looking up the url using photo - id . jpg
        if note.hasPhoto, let image = note.photoImage {
            return image.resized(withBounds: CGSize(width: 50,
                                                    height: 50), aspectFit: false)
        }
        else {
            let image = UIImage(imageLiteralResourceName: "Shopping.png")
            return image
        }
        // if location object has no image, we give the object a placeholder image
        //return UIImage(named: "No Photo")!
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
