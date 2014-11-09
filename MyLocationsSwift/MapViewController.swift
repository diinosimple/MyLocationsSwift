//
//  MapViewController.swift
//  MyLocationsSwift
//
//  Created by Iino Daisuke on 2014/11/09.
//  Copyright (c) 2014年 Iino Daisuke. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    var managedObjectContext: NSManagedObjectContext!
    
    @IBAction func showUser() {
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    @IBAction func showLocations() {
    }
}

extension MapViewController: MKMapViewDelegate {

}