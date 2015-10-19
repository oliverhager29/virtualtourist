//
//  DeleteLocationCollectionViewController.swift
//  virtualtourist
//
//  Created by OLIVER HAGER on 10/4/15.
//  Copyright © 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

/// DeleteLocationCollectionViewController - map that user to delete a location
class DeleteLocationViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var previousAnnotation : MapLocation?
    @IBAction func doneButtonPressed(sender: UIButton) {
        self.navigationController!.popViewControllerAnimated(true)
    }

    
    /// initialize the alerts and their handlers
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        mapView.delegate = self
        addAnnotations(mapView, locations: LocationRepository.findAll())
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        if let region = appDelegate.region {
            mapView.region = region
        }    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        appDelegate.region = mapView.region
    }
    
    /// add annotations to map
    /// - parameter mapview: map view
    /// :param: locations for which annotations are created
    func addAnnotations(mapView: MKMapView!, locations: [Pin]) {
        for location in locations {
            let mapLocation = MapLocation(title: "Pin",
                locationName: "",
                mediaURL: "",
                coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
            mapView.addAnnotation(mapLocation)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// create/retrieve view with pin and annotation for a location in the map
    /// - parameter mapView: map
    /// :param annotation annotation for the location
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MapLocation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                                view.canShowCallout = false
//                                view.calloutOffset = CGPoint(x: -5, y: 5)
//                                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            }
            view.draggable = false
            return view
        }
        return nil
    }
    
    /// center map around users current location
    /// :param mapView map
    /// - parameter userLocation: user's current location
    func mapView(mapView: MKMapView, didUpdateUserLocation
        userLocation: MKUserLocation) {
            mapView.centerCoordinate = userLocation.location!.coordinate
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let mapLocation = view.annotation as! MapLocation? {
            LocationRepository.remove(mapLocation.coordinate.latitude, longitude: mapLocation.coordinate.longitude)
            mapView.removeAnnotation(mapLocation)
        }
    }
}
