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
    
    
    func configureForLocation(location: Location) {
        
        if location.locationDesctiption.isEmpty {
            descriptionLabel.text = "(No Description)"
        } else {
            descriptionLabel.text = location.locationDesctiption
        }
        
        if let placemark = location.placemark {
            addressLabel.text = "\(placemark.subThoroughfare) \(placemark.thoroughfare)," + "\(placemark.locality)"
        } else {
            addressLabel.text = String(format: "Lat: %.8f, Long: %.8f", location.latitude, location.longitude)
        }
    }

}