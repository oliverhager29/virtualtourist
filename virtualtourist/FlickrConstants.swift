//
//  FlickrConstants.swift
//  virtualtourist
//
//  Created by Oliver Hager on 9/25/15.
//  Copyright (c) 2015 Oliver Hager. All rights reserved.
//

// MARK: - FlickrClient (Constants)

extension FlickrClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: API Key
        static let ApiKey : String = "833cffcf90cb31b46bc73887b55c9ad8"
        
        // MARK: URLs
        static let RestBaseURLSecure : String = "https://api.flickr.com/services/rest/"
        static let ImageBaseURL : String = "https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg"
    }
    
    // MARK: Methods
    struct Methods {
        static let SearchPhotos = "flickr.photos.search"
    }

    // MARK: URL Keys
    struct URLKeys {
        static let FarmId = "farm-id"
        static let Id = "id"
        static let ServerId = "server-id"
        static let Secret = "secret"
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let Method = "method"
        static let ApiKey = "api_key"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Format = "format"
        static let NoJsonCallBack = "nojsoncallback"
    }
    
    // MARK: JSON Body Keys
    struct ParameterConstants {
        
        static let FormatJson = "json"
        static let NoJsonCallBackTrue = "1"
    }

    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        static let Photos = "photos"
        static let Photo = "photo"
        static let FarmId = "farm"
        static let ServerId = "server"
        static let Id = "id"
        static let Secret = "secret"
        static let Owner = "owner"
        static let Title = "title"
    }
}