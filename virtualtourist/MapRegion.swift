//
//  MapRegion.swift
//  virtualtourist
//
//  Created by OLIVER HAGER on 10/18/15.
//  Copyright © 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
import CoreData

/// represents a map region that was displayed in the map view
class MapRegion : NSManagedObject {
    @NSManaged var latitude : Double
    @NSManaged var longitude : Double
    @NSManaged var latitudeDelta : Double
    @NSManaged var longitudeDelta : Double
    
    /// initialize managed object
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /// initialize managed object with passed properties
    init(insertIntoManagedObjectContext context: NSManagedObjectContext, latitude: Double, longitude: Double, latitudeDelta: Double, longitudeDelta: Double) {
        let entity =  NSEntityDescription.entityForName("MapRegion", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.latitude = latitude
        self.longitude = longitude
        self.latitudeDelta = latitudeDelta
        self.longitudeDelta = longitudeDelta
    }
}
