//
//  MapLocation
//  OnTheMap
//
//  Created by OLIVER HAGER on 9/30/15.
//  Copyright (c) 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
import MapKit

class MapLocation: NSObject, MKAnnotation {
    var title: String?
    var locationName: String
    var coordinate: CLLocationCoordinate2D
    var mediaURL: String
    init(title: String, locationName: String, mediaURL: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.mediaURL = mediaURL
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return mediaURL
    }
}