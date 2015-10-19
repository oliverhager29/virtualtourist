//
//  DeletePhotoCollectionViewController.swift
//  virtualtourist
//
//  Created by OLIVER HAGER on 10/4/15.
//  Copyright © 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

/// DeletePhotoCollectionViewController - map that user to delete a photo
class DeletePhototCollectionViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
 
    /// navigation item to enhance for a second right button
    @IBOutlet weak var myNavigationItem: UINavigationItem!


    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    @IBOutlet weak var newCollectionButton: UIButton!
    
    /// error alert when having no images are available for a location
    var noImagesAlert: UIAlertController!
    var errorRetrievingImagesAlert: UIAlertController!
    
    var mapLocation: MapLocation!
    var pin: Pin!
    var images : [UIImage] = []
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    var previousAnnotation : MapLocation?
    
    @IBAction func okButtonPressed(sender: UIButton) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    @IBAction func newCollectionButtonPressed(sender: UIButton) {
        reloadPhotos()
    }
    /// initialize the alerts and their handlers
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.noImagesAlert = UIAlertController(title: "Error", message: "No images available", preferredStyle: UIAlertControllerStyle.Alert)
        self.noImagesAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.errorRetrievingImagesAlert = UIAlertController(title: "Error", message: "Failed to retrieve images", preferredStyle: UIAlertControllerStyle.Alert)
        self.errorRetrievingImagesAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        myCollectionView.allowsSelection = true
        mapView.delegate = self
        myCollectionView.delegate = self
        addAnnotation(mapLocation)
        reloadPhotos()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5);
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenSize = UIScreen.mainScreen().bounds
        let cellSize = (screenSize.size.width / 3.0) - (2.0 * 5.0)
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func reloadPhotos() {
        newCollectionButton.enabled = false
        pin.photos.removeAllObjects()
        CoreDataStackManager.sharedInstance().saveContext()
        images.removeAll()
        FlickrClient.sharedInstance().getPhotosByLocation(pin.latitude, longitude: pin.longitude) {
            result, error in
            if let error = error {
                print(error)
                dispatch_async(dispatch_get_main_queue(), {
                    self.presentViewController(self.errorRetrievingImagesAlert, animated: true, completion: nil)
                })
            }
            else {
                if result!.isEmpty {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentViewController(self.noImagesAlert, animated: true, completion: nil)
                    })
                }
                else {
                    self.pin.photos.addObjectsFromArray(result!)
                    CoreDataStackManager.sharedInstance().saveContext()
                    for obj in self.pin.photos {
                        let photo = obj as! Photo
                        FlickrClient.sharedInstance().getPhotoByUrl(photo.url) {
                            result, error in
                            if let error = error {
                                print(error)
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.presentViewController(self.errorRetrievingImagesAlert, animated: true, completion: nil)
                                })

                            }
                            else if let result = result as UIImage? {
                                self.images.append(result)
                                dispatch_async(dispatch_get_main_queue()) {
                                    if self.myCollectionView != nil {
                                        self.myCollectionView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.newCollectionButton.enabled = true
                }
            }
        }
    }
    
    /// add annotations to map
    /// - parameter mapview: map view
    /// :patam: locations for which annotations are created
    func addAnnotation(location: MapLocation) {
            mapView.addAnnotation(location)
        let coordinate = MKMapPointForCoordinate(location.coordinate);
        let coordinateRect = MKMapRectMake(coordinate.x, coordinate.y, 10000.0, 10000.0);
        mapView.setVisibleMapRect(coordinateRect, animated: true)
        mapView.setCenterCoordinate(location.coordinate, animated: true)
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
                view.canShowCallout = false
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
    
    /// the right accesory view in the annotation has been pressed and th elink of the location is opened in a web view
    /// - parameter mapView: map
    /// - parameter annotationView: annotation view
    /// - parameter calloutAccessoryControlTapped: control
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl) {
            if control == view.rightCalloutAccessoryView {
                if let mapLocation = view.annotation as? MapLocation {
                    if mapLocation.mediaURL != "" {
                        UIApplication.sharedApplication().openURL(NSURL(string: mapLocation.mediaURL)!)
                    }
                }
            }
    }
    
    /// return number of Memes in the collection
    /// :param: colleciton view
    /// :param: section (here only one section exists)
    /// :returns: number of Memes
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    /// fill cell with content (Memed image)
    /// :param: collection view
    /// :param: index path to cell to filled with content
    /// :returns: filled collection view cell
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        /* Get cell type */
        let cellReuseIdentifier = "DeletePhotoCollectionViewCell"
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! DeletePhotoCollectionViewCell
        
        /* Set cell defaults */
        if indexPath.row < images.count {
            cell.imageView.image = images[indexPath.row]
        }
        return cell
    }
    
    /// cell was selected and web browser window is opened with the media URL of the selected location
    /// :param: collectionView collection view
    /// :param: indexPath index path (row) of selected cell
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        images.removeAtIndex(indexPath.row)
        self.pin.photos.removeObjectAtIndex(indexPath.row)
        CoreDataStackManager.sharedInstance().saveContext()
        myCollectionView.reloadData()
    }
}
