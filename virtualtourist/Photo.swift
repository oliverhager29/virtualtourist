//
//  Photo.swift
//  virtualtourist
//
//  Created by OLIVER HAGER on 9/24/15.
//  Copyright © 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
import CoreData

/// Represents a Flickr photo and contains all meta data to retrieve the actual image
class Photo : NSManagedObject {
    @NSManaged var id : String
    @NSManaged var owner : String
    @NSManaged var secret : String
    @NSManaged var server : String
    @NSManaged var farm : String
    @NSManaged var title : String
    @NSManaged var url : String
    @NSManaged var pin : Pin
    
    /// initialize managed object
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /// initialize managed object with passed properties
    init(insertIntoManagedObjectContext context: NSManagedObjectContext, id: String, owner: String, secret: String, server: String, farm: String, title: String, url: String, pin: Pin) {
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.id = id
        self.owner = owner
        self.secret = secret
        self.server = server
        self.farm = farm
        self.title = title
        self.url = url
        self.pin = pin
    }
    
    /// delete file for image associated with Photo entity
    override func prepareForDeletion() {
        super.prepareForDeletion()
        FlickrClient.sharedInstance().deleteImage(getUniqueKey())
    }
    
    func getUniqueKey() -> String {
        return "_\(pin.latitude)_\(pin.longitude)#"+url
    }
}
