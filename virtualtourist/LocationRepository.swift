//
//  LocationRepository.swift
//  virtualtourist
//
//  Created by OLIVER HAGER on 10/7/15.
//  Copyright © 2015 OLIVER HAGER. All rights reserved.
//
import Foundation
import CoreData

/// enacapsulated persistence operations on locations
class LocationRepository {
    static var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    /// for comparison of coordinates
    static let DELTA : Double = 0.000001
    
    /// add location
    /// :param: latitude latitude
    /// :param: longitude longitude
    static func add(latitude: Double, longitude: Double) {
        let pin = Pin(insertIntoManagedObjectContext: sharedContext, latitude: latitude, longitude: longitude, photos: [])
        do {
            try sharedContext.save()
            FlickrClient.sharedInstance().getPhotosByLocation(pin) {
                result, error in                if let error = error as NSError? {
                    print(error)
                }
                else if let result = result as [Photo]? {
                    dispatch_async(dispatch_get_main_queue()) {
                        pin.photos = NSMutableOrderedSet(array: result)
                        do {
                            try self.sharedContext.save()
                        }
                        catch {
                            print(error)
                        }
                    }
                    for photo in result {
                        FlickrClient.sharedInstance().getImageByUrl(photo.getUniqueKey()) {
                            results, error in
                            if let error = error {
                                print(error)
                            }
                            dispatch_async(dispatch_get_main_queue()) {
                                photo.pin = pin
                                if self.sharedContext.deletedObjects.contains(pin) {
                                    FlickrClient.sharedInstance().deleteImage(photo.getUniqueKey())
                                }
                            }
                        }
                    }
                }
            }
        }
        catch {
            print("Saving a newly created pin failed")
        }
    }
    
    /// remove location
    /// :param: latitude latitude
    /// :param: longitude longitude
    static func remove(latitude: Double, longitude: Double) {
        let pins = find(latitude, longitude: longitude)
        for pin in pins {
           for photo in pin.photos {
              let photoToDelete = photo as! Photo
              sharedContext.deleteObject(photoToDelete)
           }
           sharedContext.deleteObject(pin)
            do {
                try self.sharedContext.save()
            }
            catch {
                print(error)
            }
        }
    }
    
    /// find locations
    /// :param: latitude latitude
    /// :param: longitude longitude
    /// :returns: found locations
    static func find(latitude: Double, longitude: Double) -> [Pin] {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        //fetchRequest.predicate = NSPredicate(format: "abs(latitude - %@) <= %@ and abs(longitude - %@) <= %@", NSNumber(double:latitude), NSNumber(double:DELTA), NSNumber(double:longitude), NSNumber(double:DELTA));
        fetchRequest.predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", NSNumber(double:latitude), NSNumber(double:longitude))
        do {
            let results = try sharedContext.executeFetchRequest(fetchRequest)
            return results as! [Pin]
        }
        catch {
            print("Error in findAll(): \(error)")
        }
        return []
    }
    
    /// find all locations
    /// :returns: all locations
    static func findAll() -> [Pin] {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        do {
            let results = try sharedContext.executeFetchRequest(fetchRequest)
            return results as! [Pin]
        }
        catch {
            print("Error in findAll(): \(error)")
        }
        return []

    }
    
    /// get map region displayed in the map view
    /// :returns: map region
    static func getMapRegion() -> MapRegion? {
        let fetchRequest = NSFetchRequest(entityName: "MapRegion")
        var mapRegion : MapRegion? = nil
        do {
            let results = try sharedContext.executeFetchRequest(fetchRequest)
            if !results.isEmpty {
                mapRegion = results.first as! MapRegion?
            }
        }
        catch {
            print("Error in getMapRegion(): \(error)")
        }
        return mapRegion
    }
    
    /// update map region displayed in the map view
    /// :params: latitude latitude
    /// :params: longitude longitude
    /// :params: latitudeDelta latitudeDelta (span of region)
    /// :params: longitudeDelta longitudeDelta (span of region)
    static func updateMapRegion(latitude: Double, longitude: Double, latitudeDelta: Double, longitudeDelta: Double) {
        var mapRegion = getMapRegion()
        if mapRegion == nil {
            mapRegion = MapRegion(insertIntoManagedObjectContext: sharedContext, latitude: latitude, longitude: longitude, latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        }
        else {
            mapRegion?.latitude = latitude
            mapRegion?.longitude = longitude
            mapRegion?.latitudeDelta = latitudeDelta
            mapRegion?.longitudeDelta = longitudeDelta
        }
        CoreDataStackManager.sharedInstance().saveContext()
    }
}