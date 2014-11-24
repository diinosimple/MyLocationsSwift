//
//  LocationCell.swift
//  MyLocationsSwift
//
//  Created by Iino Daisuke on 2014/11/09.
//  Copyright (c) 2014年 Iino Daisuke. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    
    func configureForLocation(location: Location) {
        
        if location.locationDesctiption.isEmpty {
            descriptionLabel.text = "(No Description)"
        } else {
            descriptionLabel.text = location.locationDesctiption
        }
        
        if let placemark = location.placemark {
            var text = ""
            text.addText(placemark.subThoroughfare)
            text.addText(placemark.thoroughfare, withSeparator: " ")
            text.addText(placemark.locality, withSeparator: ", ")
            addressLabel.text = text
            
        } else {
            addressLabel.text = String(format: "Lat: %.8f, Long: %.8f", location.latitude, location.longitude)
        }
        
        photoImageView.image = imageForLocation(location)
    }
    
    //This returns either the image from the Location or an empty placeholder image.
    func imageForLocation(location:Location) -> UIImage {
        if location.hasPhoto {
            if let image = location.photoImage {
                return image.resizedImageWithBounds(CGSize(width: 52, height: 52))
            }
        }
        return UIImage(named: "No Photo")!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.blackColor()
        descriptionLabel.textColor = UIColor.whiteColor()
        descriptionLabel.highlightedTextColor = descriptionLabel.textColor
        addressLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        addressLabel.highlightedTextColor = addressLabel.textColor
        
        let selectionView = UIView(frame: CGRect.zeroRect)
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        selectedBackgroundView = selectionView
        
        //This gives the image view rounded corners with a radius that is equal to half the width of the image, which makes it a perfect circle.
        photoImageView.layer.cornerRadius = photoImageView.bounds.size.width / 2
        //The clipsToBounds setting makes sure that the image view respects these rounded corners and does not draw outside them.
        photoImageView.clipsToBounds = true
        //The separatorInset moves the separator lines between the cells a bit to the right so there are no lines between the thumbnail images.
        separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0)
        
    }
    
    /*
    UIKit calls layoutSubviews() just before it makes the cell visible. Here you resize the frames of the labels to take up all the remaining space in the cell, with 10 points margin on the right.
    */
    override func layoutSubviews() {
        super.layoutSubviews()
        if let sv = superview {
            descriptionLabel.frame.size.width = sv.frame.size.width - descriptionLabel.frame.origin.x - 10
            addressLabel.frame.size.width = sv.frame.size.width - addressLabel.frame.origin.x - 10
        }
    }

}