//
//  Pin.swift
//  virtualtourist
//
//  Created by OLIVER HAGER on 9/25/15.
//  Copyright © 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
import CoreData

/// represents a pin on the map (i.e. its corrdinate)
class Pin : NSManagedObject {
    @NSManaged var latitude : Double
    @NSManaged var longitude : Double
    @NSManaged var photos : NSMutableOrderedSet
    @NSManaged var isDownloadCompleted : Bool
    
    /// initialize managed object
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /// initialize managed object with passed properties
    init(insertIntoManagedObjectContext context: NSManagedObjectContext, latitude: Double, longitude: Double, photos: NSMutableOrderedSet) {
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.latitude = latitude
        self.longitude = longitude
        self.photos = photos
        self.isDownloadCompleted = false
    }
}
