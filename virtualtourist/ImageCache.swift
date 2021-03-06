//
//  ImageCache.swift
//  virtualtourist
//
//  Created by OLIVER HAGER on 10/12/15.
//  Copyright © 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
import UIKit

class ImageCache {
    
    private var inMemoryCache = NSCache()
    
    // MARK: - Retreiving images
    
    func imageWithIdentifier(identifier: String?) -> UIImage? {
        
        // If the identifier is nil, or empty, return nil
        if identifier == nil || identifier! == "" {
            return nil
        }
        
        let path = pathForIdentifier(identifier!)
        
        // First try the memory cache
        if let image = inMemoryCache.objectForKey(path) as? UIImage {
            return image
        }
        
        // Next Try the hard drive
        if let data = NSData(contentsOfFile: path) {
            return UIImage(data: data)
        }
        
        return nil
    }
    
    // MARK: - Saving images
    
    func storeImage(image: UIImage?, withIdentifier identifier: String) {
        let path = pathForIdentifier(identifier)
        
        // If the image is nil, remove images from the cache
        if image == nil {
            inMemoryCache.removeObjectForKey(path)
            do {
                try NSFileManager.defaultManager().removeItemAtPath(path)
            }
            catch {
                print(error)
            }
            return
        }
        
        // Otherwise, keep the image in memory
        inMemoryCache.setObject(image!, forKey: path)
        
        // And in documents directory
        let data = UIImagePNGRepresentation(image!)
        data!.writeToFile(path, atomically: true)
    }
    
    // MARK: - Helper
    func convertUrlToFileName(url: String) -> String {
        var str = url.stringByReplacingOccurrencesOfString("https://", withString: "")
        str = str.stringByReplacingOccurrencesOfString("/", withString: "_")
        str = str.stringByReplacingOccurrencesOfString(".jpg", withString: "@jpg")
        str = str.stringByReplacingOccurrencesOfString(".", withString: "_")
        str = str.stringByReplacingOccurrencesOfString(" ", withString: "_")
        str = str.stringByReplacingOccurrencesOfString("@jpg", withString: ".jpg")
        return str
    }
    
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
        let fullURL = documentsDirectoryURL!.URLByAppendingPathComponent(convertUrlToFileName(identifier))
        
        return fullURL.path!
    }
}