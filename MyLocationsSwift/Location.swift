//
//  Location.swift
//  MyLocationsSwift
//
//  Created by Iino Daisuke on 2014/11/08.
//  Copyright (c) 2014年 Iino Daisuke. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import MapKit

class Location: NSManagedObject, MKAnnotation {

    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var date: NSDate
    @NSManaged var locationDesctiption: String
    @NSManaged var category: String
    @NSManaged var placemark: CLPlacemark?
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    var title: String! {
        if locationDesctiption.isEmpty {
            return "(No Description)"
        } else {
            return locationDesctiption
        }
    }
    
    var subtitle: String! {
        return category
    }

}
