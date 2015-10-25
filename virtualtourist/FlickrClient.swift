//
//  FlickrClient.swift
//  virtualtourist
//
//  Created by Oliver Hager on 9/25/15.
//  Copyright (c) 2015 Oliver Hager. All rights reserved.
//

import Foundation
import UIKit
// MARK: - FlickrClient: NSObject

class FlickrClient : NSObject {
    
    // MARK: Properties
    
    /* Shared session */
    var session: NSURLSession
    
    /* Configuration object */
    var config = FlickrConfig()
    
    /* Authentication state */
    var sessionID : String? = nil
    var userID : Int? = nil
    
    // MARK: Initializers
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }

    // MARK: GET
    
    /// task for sending GET request to Flickr
    /// :param: method Flickr action
    /// :param: parameters URL parameters
    /// :param: completionHandler completion handler for receiving result or handling error
    /// :returns: session task
    func taskForGETMethod(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = parameters
        mutableParameters[ParameterKeys.Method] = method
        mutableParameters[ParameterKeys.ApiKey] = Constants.ApiKey
        /* 2/3. Build the URL and configure the request */
        let urlString = Constants.RestBaseURLSecure + FlickrClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            FlickrClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    /// construct URL for getting Flickr image
    /// :param: urlStr URL with place holders
    /// :param: parameters values for place holders
    /// :returns: complete URL
    func fillUrl(urlStr : String, parameters: [String : AnyObject]) -> String {
        var str = urlStr.stringByReplacingOccurrencesOfString("{\(URLKeys.FarmId)}", withString: parameters[JSONResponseKeys.FarmId] as! String)
        str = str.stringByReplacingOccurrencesOfString("{\(URLKeys.Id)}", withString: parameters[JSONResponseKeys.Id] as! String)
        str = str.stringByReplacingOccurrencesOfString("{\(URLKeys.Secret)}", withString: parameters[JSONResponseKeys.Secret] as! String)
        str = str.stringByReplacingOccurrencesOfString("{\(URLKeys.ServerId)}", withString: parameters[JSONResponseKeys.ServerId] as! String)
        return str
    }
    
    /// delete image by URL
    func deleteImage(url: String) {
        Caches.imageCache.storeImage(nil, withIdentifier: url)
    }
    
    
    /// task for downloading image
    /// :param: url URL to image
    /// :param: completionHandler completion handler for receiving result or handling error
    /// :returns: session task
    func taskForGETImage(url: String,completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask {
        if let cachedImage = Caches.imageCache.imageWithIdentifier(url) as UIImage? {
            completionHandler(imageData: UIImagePNGRepresentation(cachedImage), error: nil)
        }
        /* 1. Set the parameters */
        // There are none...
        var urlToDownload = url
        if let startIndex = url.characters.indexOf("#") {
            urlToDownload = url.substringFromIndex(startIndex.successor())
        }
        /* 2/3. Build the URL and configure the request */
        let urlObj = NSURL(string: urlToDownload)!
        let request = NSURLRequest(URL: urlObj)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            Caches.imageCache.storeImage(UIImage(data: data), withIdentifier: url)
            completionHandler(imageData: data, error: nil)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }

    // MARK: POST
    
    /// task for sending POST request to Flickr    
    /// :param: method Flickr action
    /// :param: parameters URL parameters
    /// :param: jsonBody POST body with JSON payload
    /// :param: completionHandler completion handler for receiving result or handling error
    /// :returns: session task
    func taskForPOSTMethod(method: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = parameters
        mutableParameters[ParameterKeys.Method] = method
        mutableParameters[ParameterKeys.ApiKey] = Constants.ApiKey
        
        /* 2/3. Build the URL and configure the request */
        let urlString = Constants.RestBaseURLSecure + FlickrClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            FlickrClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: Helpers
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        
        return Singleton.sharedInstance
    }
    
    /// image cache back by files stored in local file system
    struct Caches {
        static let imageCache = ImageCache()
    }
}