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

/// ChooseLocationViewController - map that user to select location
class ChooseLocationViewController: UIViewController, MKMapViewDelegate {
    
    /// navigation item to enhance for a second right button
    @IBOutlet weak var myNavigationItem: UINavigationItem!
  
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "checkPostLocation")
    }
    var previousAnnotation : MapLocation?
    
    @IBAction func editButtonPressed(sender: UIButton) {
    }
    
    /// initialize the alerts and their handlers
    /// :param: animated true if animated, false otheriwse
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "addAnnotation:")
        longPressGesture.minimumPressDuration = 2.0
        mapView.delegate = self
        mapView.addGestureRecognizer(longPressGesture)
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        if let region = appDelegate.region {
            mapView.region = region
        }
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
            self.previousAnnotation = nil
        }
        else {
            let touchPoint = gestureRecognizer.locationInView(mapView)
            let newCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            if let toDeleteAnnotation = self.previousAnnotation {
                LocationRepository.remove(toDeleteAnnotation.coordinate.latitude, longitude: toDeleteAnnotation.coordinate.longitude)
                self.mapView.removeAnnotation(toDeleteAnnotation)
            }
            let annotation = MapLocation(title: "test tilte", locationName: "test", mediaURL: "http://www.google.com", coordinate: newCoordinate)
            LocationRepository.add(newCoordinate.latitude, longitude: newCoordinate.longitude)
            self.mapView.addAnnotation(annotation)
            self.previousAnnotation = annotation
        }
    }

    /// drop pin
    /// :param: mapView map view
    /// :param: view annotation view
    /// :param: newState new drag state
    /// :param: oldState ol drag state
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if(newState == .Ending) {
            let myAnnotation = view.annotation! as! MapLocation
            let droppedAt : CLLocationCoordinate2D = myAnnotation.coordinate
            myAnnotation.coordinate = droppedAt
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
    
    /// reload the other students locations (refresh button is pressed)
    func reloadLocations() {

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
            var controller = self.storyboard!.instantiateViewControllerWithIdentifier("DeletePhotoCollectionViewController") as! DeletePhototCollectionViewController
            controller.mapLocation = mapLocation
            let pins = LocationRepository.find(mapLocation.coordinate.latitude, longitude: mapLocation.coordinate.longitude)
            if !pins.isEmpty {
                controller.pin = pins[0]
                self.navigationController!.pushViewController(controller, animated: true)
            }
        }
    }
}