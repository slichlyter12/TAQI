//
//  Location.swift
//  Timeline
//
//  Created by Samuel Lichlyter on 2/18/19.
//  Copyright © 2019 Samuel Lichlyter. All rights reserved.
//

import Foundation
import MapKit

class Location: NSObject, MKAnnotation {
    let timestamp: Date
    let coordinate: CLLocationCoordinate2D
    let accuracy: Int?
    let heading: Int?
    let altitude: Int?
    let verticalAccuracy: Int?
    let velocity: Int?
    
    init?(google: [String: Any]) {
        let timestamp = google["timestamp"] as! String
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        var date = dateFormatter.date(from: timestamp)
        if date == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            date = dateFormatter.date(from: timestamp)
        }
        self.timestamp = date!
        
        if
            let latitude = google["latitudeE7"] as? Double,
            let longitude = google["longitudeE7"] as? Double {
            let coordinate = CLLocationCoordinate2D(latitude: latitude / 1e7, longitude: longitude / 1e7) // divide by 1e7 because that's what format Google Location data is in
            self.coordinate = coordinate
        } else {
            self.coordinate = CLLocationCoordinate2D()
        }

        self.accuracy = google["accuracy"] as? Int
        self.heading = google["heading"] as? Int
        self.altitude = google["altitude"] as? Int
        self.verticalAccuracy = google["verticalAccuracy"] as? Int
        self.velocity = google["velocity"] as? Int
    }
}
