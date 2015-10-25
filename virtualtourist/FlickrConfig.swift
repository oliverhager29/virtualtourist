//
//  FlickrConfig.swift
//  virtualtourist
//
//  Created by Oliver Hager on 9/25/15.
//  Copyright (c) 2015 Oliver Hager. All rights reserved.
//

import Foundation

// MARK: - File Support

private let _documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as NSURL!
private let _fileURL: NSURL = _documentsDirectoryURL.URLByAppendingPathComponent("virtualtourist-Context")

// MARK: - FlickrConfig: NSObject, NSCoding

class FlickrConfig: NSObject, NSCoding {
    
    // MARK: Properties
    
    /* Default values from 1/12/15 */
    var secureBaseImageURLString =  "https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg"
    var dateUpdated: NSDate? = nil
    
    /* Returns the number days since the config was last updated */
//    var daysSinceLastUpdate: Int? {
//        if let lastUpdate = dateUpdated {
//            return Int(NSDate().timeIntervalSinceDate(lastUpdate)) / 60*60*24
//        } else {
//            return nil
//        }
//    }
    
    // MARK: Initialization
    
    override init() {}
    
    convenience init?(dictionary: [String : AnyObject]) {
        
        self.init()
    }
    
    // MARK: Update

    
    // MARK: NSCoding
    
    let SecureBaseImageURLStringKey =  "config.secure_base_image_url_key"
    let DateUpdatedKey = "config.date_update_key"
    
    required init(coder aDecoder: NSCoder) {
        secureBaseImageURLString = aDecoder.decodeObjectForKey(SecureBaseImageURLStringKey) as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(secureBaseImageURLString, forKey: SecureBaseImageURLStringKey)
        aCoder.encodeObject(dateUpdated, forKey: DateUpdatedKey)
    }
    
    func save() {
        NSKeyedArchiver.archiveRootObject(self, toFile: _fileURL.path!)
    }
    
    class func unarchivedInstance() -> FlickrConfig? {
        
        if NSFileManager.defaultManager().fileExistsAtPath(_fileURL.path!) {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(_fileURL.path!) as? FlickrConfig
        } else {
            return nil
        }
    }
}
