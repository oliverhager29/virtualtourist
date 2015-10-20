//
//  FlickrConvenience.swift
//  virtualtourist
//
//  Created by Oliver Hager on 9/25/15.
//  Copyright (c) 2015 Oliver Hager. All rights reserved.
//

import UIKit
import Foundation

// MARK: - FlickrClient (Convenient Resource Methods)

extension FlickrClient {
    
    // MARK: GET Convenience Methods
    
    /// get photo by URL
    /// :param: url URL for retrieving Flickr image
    func getImageByUrl(url: String, completionHandler: (result: UIImage?, error: NSError?) -> Void) {
        FlickrClient.sharedInstance().taskForGETImage(url) {
            imageData, error in
            if let error = error {
                print(error)
                completionHandler(result: nil, error: error)
            }
            else {
                completionHandler(result: UIImage(data: imageData!), error: nil)
            }
        }
    }
    
    /// get photos by location
    /// :param: latitude latitude
    /// :param: longitude longitude
    /// :param: completionHandler completion handler to retrieve Photos entities or handle error
    func getPhotosByLocation(latitude: Double, longitude: Double, completionHandler: (result: [Photo]?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters : [String : AnyObject] = [FlickrClient.ParameterKeys.Latitude: latitude, FlickrClient.ParameterKeys.Longitude: longitude, FlickrClient.ParameterKeys.Format: FlickrClient.ParameterConstants.FormatJson, FlickrClient.ParameterKeys.NoJsonCallBack: FlickrClient.ParameterConstants.NoJsonCallBackTrue]
        
        /* 2. Make the request */
        taskForGETMethod(FlickrClient.Methods.SearchPhotos, parameters: parameters) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(result: nil, error: error)
            }
            else {
                if let photosJson = JSONResult[FlickrClient.JSONResponseKeys.Photos] as? [String : AnyObject] {
                    var photos : [Photo] = []
                    if let photoJson = photosJson[FlickrClient.JSONResponseKeys.Photo] as? [[String : AnyObject]] {
                        for elem in photoJson {
                        let id = elem[FlickrClient.JSONResponseKeys.Id] as! String
                        let secret = elem[FlickrClient.JSONResponseKeys.Secret] as! String
                        let server = elem[FlickrClient.JSONResponseKeys.ServerId] as! String
                        let farmId = elem[FlickrClient.JSONResponseKeys.FarmId] as! Int
                        let farm = "\(farmId)"
                        let owner = elem[FlickrClient.JSONResponseKeys.Owner] as! String
                        let title = elem[FlickrClient.JSONResponseKeys.Title] as! String
                        let jsonParams : [String : AnyObject] = [FlickrClient.JSONResponseKeys.Id: id, FlickrClient.JSONResponseKeys.Secret: secret, FlickrClient.JSONResponseKeys.ServerId: server, FlickrClient.JSONResponseKeys.FarmId: farm]
                        
                        let urlFilled = self.fillUrl(FlickrClient.Constants.ImageBaseURL, parameters: jsonParams)
                            let photo = Photo(insertIntoManagedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext, id: id, owner: owner, secret: secret, server: server, farm: farm, title: title, url: urlFilled, latitude: latitude, longitude: longitude)
                        photos.append(photo)
                    }
                    completionHandler(result: photos, error: nil)
                }
            }
            else {
                    completionHandler(result: nil, error: NSError(domain: "getPhotosByLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getPhotosByLocation"]))
                }
            }
        }
    }
}