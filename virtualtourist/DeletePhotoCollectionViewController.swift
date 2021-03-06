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

/// DeletePhotoCollectionViewController - shows images associated with pin on map (selected in previous screen) and allows user to delete image(s)
class DeletePhototCollectionViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let NEW_COLLECTION = "New Collection"
    
    let REMOVE_SELECTED_PICTURES = "Remove Selected Picture"
    
    /// no images label when having no images are available for a location
    @IBOutlet weak var noImagesLabel: UILabel!
    
    /// reference to map view
    @IBOutlet weak var mapView: MKMapView!
    
    /// reference to collection view
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    /// new collection button
    @IBOutlet weak var newCollectionButton: UIButton!
    
    /// map location
    var mapLocation: MapLocation!
    
    /// pin
    var pin: Pin!
    
    /// selected cells in collection view
    var selectedCellIndexes : [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    var previousAnnotation : MapLocation?
    
    /// ok button pressed
    @IBAction func okButtonPressed(sender: UIButton) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    /// new collection button pressed
    @IBAction func newCollectionButtonPressed(sender: UIButton) {
        if(!self.selectedCellIndexes.isEmpty) {
            deleteCells(self.selectedCellIndexes)
            self.selectedCellIndexes.removeAll()
        }
        else {
            reloadPhotos(pin, viewController: self, collectionView: myCollectionView, newCollectionButton: newCollectionButton)
        }
    }
    
    /// initialize the alerts and their handlers
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        myCollectionView.allowsSelection = true
        myCollectionView.allowsMultipleSelection = true
        mapView.delegate = self
        myCollectionView.delegate = self
        addAnnotation(mapLocation)
        handleLoadResult()
    }
    
    /// load photos for a given Pin into the collection view
    /// :param: pin Pin
    /// :param: viewController view controller that contains map and collection view
    /// :param: collectionView collection view
    /// :param: newCollectionButton new collection button
    func reloadPhotos(pin: Pin, viewController: UIViewController, collectionView: UICollectionView!, newCollectionButton: UIButton!) {
        newCollectionButton.enabled = false
        let tmpPhotos = pin.photos.array as! [Photo]
        var photosToDelete : [Photo] = []
        photosToDelete.appendContentsOf(tmpPhotos)
        for photo in photosToDelete {
            CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(photo)
        }
        pin.photos.removeAllObjects()
        CoreDataStackManager.sharedInstance().saveContext()
        LocationRepository.loadPhotos(pin)
        handleLoadResult()
    }
    
    /// handle load result by enabling/disabling the new collection button and displaying the No images label
    func handleLoadResult() {
        var pinUniqueKey : String!
        CoreDataStackManager.sharedInstance().managedObjectContext.performBlockAndWait() {
            pinUniqueKey = self.pin.getUniqueKey()
        }
        selectedCellIndexes = []
        newCollectionButton.setTitle(NEW_COLLECTION, forState: UIControlState.Normal)
        newCollectionButton.enabled = LocationRepository.pinDownloadCompleted.keys.contains(pin.getUniqueKey()) && !LocationRepository.pinDownloadCompleted[pinUniqueKey]!
        while !LocationRepository.pinDownloadCompleted.keys.contains(pinUniqueKey) {
            
        }
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        //if !pin.isDownloadCompleted {
        if !LocationRepository.pinDownloadCompleted[pinUniqueKey]! {
            dispatch_async(dispatch_get_main_queue(), {
                self.myCollectionView.allowsSelection = false
                self.myCollectionView.allowsMultipleSelection = false
                self.newCollectionButton.enabled = false
            })
            dispatch_async(backgroundQueue, {
                //while !self.pin.isDownloadCompleted {
                while !LocationRepository.pinDownloadCompleted[pinUniqueKey]! {
                    NSThread.sleepForTimeInterval(1)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.myCollectionView.reloadData()
                    })
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.newCollectionButton.enabled = true
                    if self.pin.photos.count == 0 {
                        //self.presentViewController(self.noImagesAlert, animated: true, completion: nil)
                        self.myCollectionView.hidden = true
                        self.noImagesLabel.hidden = false
                    }
                    else {
                        self.myCollectionView.hidden = false
                        self.noImagesLabel.hidden = true
                    }
                    self.myCollectionView.allowsSelection = true
                    self.myCollectionView.allowsMultipleSelection = true
                    self.myCollectionView.reloadData()
                })
            })
        }
        else {
            self.newCollectionButton.enabled = true
            if self.pin.photos.count == 0 {
                self.myCollectionView.hidden = true
                self.noImagesLabel.hidden = false
            }
            else {
                self.myCollectionView.hidden = false
                self.noImagesLabel.hidden = true
            }
            self.myCollectionView.allowsSelection = true
            self.myCollectionView.allowsMultipleSelection = true
            self.myCollectionView.reloadData()
        }
    }
    
    /// get cell border sizes
    /// get ceollection view cell size
    /// :param: collectionView collection view
    /// :param: layout collection view layout
    /// :param: sizeForItemAtIndexPath cell position
    /// :returns: border sizes
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5);
    }
    
    /// get ceollection view cell size
    /// :param: collectionView collection view
    /// :param: layout collection view layout
    /// :param: sizeForItemAtIndexPath cell position
    /// :returns: cell size
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenSize = UIScreen.mainScreen().bounds
        let cellSize = (screenSize.size.width / 3.0) - (2.0 * 5.0)
        return CGSize(width: cellSize, height: cellSize)
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
        return pin.photos.count
    }
    
    /// fill cell with content (Memed image)
    /// :param: collection view
    /// :param: index path to cell to filled with content
    /// :returns: filled collection view cell
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row < pin.photos.count {
            let photo = pin.photos[indexPath.row] as! Photo
            
            if let uiImage = FlickrClient.Caches.imageCache.imageWithIdentifier(photo.getUniqueKey()) {
                let cellReuseIdentifier = "DeletePhotoCollectionViewCell"
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! DeletePhotoCollectionViewCell
                cell.imageView.image = uiImage
                if self.selectedCellIndexes.indexOf(indexPath.row) != nil {
                    cell.layer.borderWidth = 5.0
                    cell.layer.borderColor = UIColor.whiteColor().CGColor
                }
                else {
                    cell.layer.borderWidth = 5.0
                    cell.layer.borderColor = UIColor.blackColor().CGColor
                }
                return cell
            }
        }
        let cellReuseIdentifier = "PlaceHolderCollectionViewCell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath)
        return cell
    }
    
    /// cell to delete is selected and high lighted
    /// :param: collectionView collection view
    /// :param: indexPath index path (row) of selected cell
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedCellIndexes.append(indexPath.row)
        if let cell = self.myCollectionView.cellForItemAtIndexPath(indexPath) {
            cell.layer.borderWidth = 5.0
            cell.layer.borderColor = UIColor.whiteColor().CGColor
        }
        newCollectionButton.setTitle(REMOVE_SELECTED_PICTURES, forState: UIControlState.Normal)
    }
    
    /// cell to delete is selected and high lighted
    /// :param: collectionView collection view
    /// :param: indexPath index path (row) of selected cell
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if let pos = self.selectedCellIndexes.indexOf(indexPath.row) {
            self.selectedCellIndexes.removeAtIndex(pos)
            if let cell = self.myCollectionView.cellForItemAtIndexPath(indexPath) {
                cell.layer.borderWidth = 5.0
                cell.layer.borderColor = UIColor.blackColor().CGColor
            }
            if self.selectedCellIndexes.isEmpty {
                newCollectionButton.setTitle(NEW_COLLECTION, forState: UIControlState.Normal)
            }
            else {
               newCollectionButton.setTitle(REMOVE_SELECTED_PICTURES, forState: UIControlState.Normal)
            }
        }
    }
    
    
    /// delete cells and underlying photos and image files
    /// :param: indexes indexes of cells to delete
    func deleteCells(indexes: [Int]) {
        var photosToDelete : [Photo] = []
        for index in indexes {
            photosToDelete.append(self.pin.photos[index] as! Photo)
        }
        for photoToDelete in photosToDelete {
            LocationRepository.deletePhotoFromPin(self.pin, photoToDelete: photoToDelete)
        }
        myCollectionView.reloadData()
        newCollectionButton.setTitle(NEW_COLLECTION, forState: UIControlState.Normal)
    }
}
