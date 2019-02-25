//
//  LocationCell.swift
//  MyLocations
//
//  Created by Griffin Healy on 1/25/19.
//  Copyright © 2019 Griffin Healy. All rights reserved.
//

import UIKit

// our custom subclass for table view cells
class LocationCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        let selection = UIView(frame: CGRect.zero)
        selection.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        // selectedBackgroundView, the view used as the background of the cell when it is selected
        selectedBackgroundView = selection
        // Rounded corners for images
        photoImageView.layer.cornerRadius =
            photoImageView.bounds.size.width / 2
        photoImageView.clipsToBounds = true
        separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0,
                                      right: 0)
        //descriptionLabel.backgroundColor = UIColor.purple
        //addressLabel.backgroundColor = UIColor.purple
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK:- Helper Method
    // passed location object from array of locations, will put location oject into table view cell
    func configure(for location: Location) {
        if location.locationDescription.isEmpty {
            descriptionLabel.text = "(No Description)"
        } else {
            // find attribute or property locationDescription and label to that value
            descriptionLabel.text = location.locationDescription
        }
          if let placemark = location.placemark {
                var text = ""
                text.add(text: placemark.subThoroughfare)
                text.add(text: placemark.thoroughfare, separatedBy: " " )
                text.add(text: placemark.locality, separatedBy: ", ")
                addressLabel.text = text
        } else {
            addressLabel.text = String(format:
                "Lat: %.8f, Long: %.8f", location.latitude, location.longitude)
        }
        // call thumbnail with the passed locaiton object. Set the photoImageView image to the image retrieved. We tell photoImageView outlet (linked to in storyboard) to set its new image
        photoImageView.image = thumbnail(for: location)
    }
    // put the image for the location object in a thumbnail displayed in LocationsViewController
    func thumbnail(for location: Location) -> UIImage {
        var _: Int = 5
          // if location oject hasPhoto (photo id has value of not nil), then we find the image for this location object by looking up the url using photo - id . jpg
        if location.hasPhoto, let image = location.photoImage {
            return image.resized(withBounds: CGSize(width: 52,
                                                    height: 52), aspectFit: false)
        }
        // if location object has no image, we give the object a placeholder image
        return UIImage(named: "No Photo")!
    }
}
