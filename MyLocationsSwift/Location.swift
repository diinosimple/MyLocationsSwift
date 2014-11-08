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

class Location: NSManagedObject {

    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var date: NSDate
    @NSManaged var locationDesctiption: String
    @NSManaged var category: String
    @NSManaged var placemark: CLPlacemark?

}
