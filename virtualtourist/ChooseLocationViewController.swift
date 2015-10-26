//
//  ChooseLocationViewController.swift
//  virtualtourist
//
//  Created by OLIVER HAGER on 9/30/15.
//  Copyright © 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

/// ChooseLocationViewController - map that allows user to select location
class ChooseLocationViewController: UIViewController, MKMapViewDelegate {
    /// error alert when having no images are available for a location
    var noImagesAlert: UIAlertController!
    var errorRetrievingImagesAlert: UIAlertController!
    
    /// navigation item to enhance for a second right button
    @IBOutlet weak var myNavigationItem: UINavigationItem!
  
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    var previousAnnotation : MapLocation?
    
    @IBAction func editButtonPressed(sender: UIButton) {
    }
    
    /// initialize the alerts and their handlers
    /// :param: animated true if animated, false otheriwse
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.noImagesAlert = UIAlertController(title: "Error", message: "No images available", preferredStyle: UIAlertControllerStyle.Alert)
        self.noImagesAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.errorRetrievingImagesAlert = UIAlertController(title: "Error", message: "Failed to retrieve images", preferredStyle: UIAlertControllerStyle.Alert)
        self.errorRetrievingImagesAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "addAnnotation:")
        longPressGesture.minimumPressDuration = 1.0
        mapView.delegate = self
        mapView.addGestureRecognizer(longPressGesture)
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        if let region = appDelegate.region {
            mapView.region = region
        }
        mapView.removeAnnotations(mapView.annotations)
        addAnnotations(mapView, locations: LocationRepository.findAll())
    }
    
    /// remember center and span of map view
    /// :param: animated true if animated, false otheriwse
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        appDelegate.region = mapView.region
    }
    
    /// add annotation when long press gesture has been recognized
    /// :param: gestureRecognizer gesture recognizer to detect long press on map
    func addAnnotation(gestureRecognizer:UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Ended {
            if let newCoordinate = self.previousAnnotation?.coordinate {
                LocationRepository.add(newCoordinate.latitude, longitude: newCoordinate.longitude)
            }
            self.previousAnnotation = nil
        }
        else {
            let touchPoint = gestureRecognizer.locationInView(mapView)
            let newCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            if let toDeleteAnnotation = self.previousAnnotation {
                self.mapView.removeAnnotation(toDeleteAnnotation)
            }
            let annotation = MapLocation(title: "Location", locationName: "Flickr Location", mediaURL: "http://www.flickr.com", coordinate: newCoordinate)
            self.mapView.addAnnotation(annotation)
            self.previousAnnotation = annotation
        }
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
            }
            view.draggable = true
            view.animatesDrop = true
            view.dragState = .Starting
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
    
    /// if annotation is selected then open new view with map zooomed to the location and showing a collection of associated Flickr images
    /// - parameter mapView: map
    /// - parameter view: annotation view
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let mapLocation = view.annotation as! MapLocation? {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("DeletePhotoCollectionViewController") as! DeletePhototCollectionViewController
            controller.mapLocation = mapLocation
            let pins = LocationRepository.find(mapLocation.coordinate.latitude, longitude: mapLocation.coordinate.longitude)
            if !pins.isEmpty {
                controller.pin = pins[0]
                
                self.navigationController!.pushViewController(controller, animated: true)
            }
        }
    }
}
