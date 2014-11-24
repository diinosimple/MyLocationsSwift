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
    @NSManaged var photoID: NSNumber?
    
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
    
    //This determines whether the Location object has a photo associated with it or not.
    var hasPhoto: Bool {
        return photoID != nil
    }
    
    //This property computes the full path to the JPEG file for the photo. You’ll save these files inside the app’s Documents directory.
    var photoPath: String {
        /*
        The use of assert() to make sure the photoID is not nil. An assertion is a special debugging tool that is used to check that your code always does something valid. If not, the app will crash with a helpful error message. 
        */
        assert(photoID != nil, "No photo ID set")
        let filename = "Photo-\(photoID!.integerValue).jpg"
        return applicationDocumentsDirectory.stringByAppendingPathComponent(filename)
    }
    
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoPath)
    }
    
    class func nextPhotoID() -> Int {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let currentID = userDefaults.integerForKey("PhotoID")
        userDefaults.setInteger(currentID + 1, forKey: "PhotoID")
        userDefaults.synchronize()
        return currentID
    }
    
    func removePhotoFile() {
        if hasPhoto {
            let path = photoPath
            let fileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath(path) {
                var error: NSError?
                if !fileManager.removeItemAtPath(path, error: &error){
                    println("Error removing file: \(error)")
                }
            }
        }
    }
    

}
