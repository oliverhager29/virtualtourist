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
    /// reference to map view
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// if done button has been pressed go back to previous screen
    @IBAction func doneButtonPressed(sender: UIButton) {
        self.navigationController!.popViewControllerAnimated(true)
    }

    
    /// initialize the alerts and their handlers
    /// setup view port of map as in the previous screen
    /// :param: animated true if animated, false otherwise
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        mapView.delegate = self
        addAnnotations(mapView, locations: LocationRepository.findAll())
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        if let region = appDelegate.region {
            mapView.region = region
        }    }
    
    /// initialize the alerts and their handlers
    /// remember view port by persisting it
    /// :param: animated true if animated, false otherwise
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        appDelegate.region = mapView.region
    }
    
    /// add annotations to map
    /// :param: mapview map view
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
    /// :param: mapView map view
    /// :param: annotation annotation for the location
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
            }
            view.draggable = false
            return view
        }
        return nil
    }
    
    /// center map around users current location
    /// :param: mapView map view
    /// :param: userLocation user's current location
    func mapView(mapView: MKMapView, didUpdateUserLocation
        userLocation: MKUserLocation) {
            mapView.centerCoordinate = userLocation.location!.coordinate
    }
    
    /// pin has been selected and is deleted
    /// :param: mapView map view
    /// :param: didSelectAnnotationView annotation view
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let mapLocation = view.annotation as! MapLocation? {
            LocationRepository.remove(mapLocation.coordinate.latitude, longitude: mapLocation.coordinate.longitude)
            mapView.removeAnnotation(mapLocation)
        }
    }
}
