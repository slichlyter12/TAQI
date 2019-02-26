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
    let timestamp: Date?
    let title: String?
    let coordinate: CLLocationCoordinate2D
    let accuracy: Int?
    let heading: Int?
    let altitude: Int?
    let verticalAccuracy: Int?
    let velocity: Int?
    
    init?(google: [String: Any]) {
        if let timestamp = Double(google["timestampMs"] as! String) {
            let date = Date(timeIntervalSince1970: timestamp / 1000) // convert from miliseconds to seconds
            self.timestamp = date
            self.title = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
        } else {
            self.timestamp = Date()
            self.title = ""
        }
        
        if
            let latitude = google["latitudeE7"] as? Double,
            let longitude = google["longitudeE7"] as? Double {
            self.coordinate = CLLocationCoordinate2D(latitude: latitude / 1e7, longitude: longitude / 1e7) // divide by 1e7 because that's what format Google Location data is in
        } else {
            self.coordinate = CLLocationCoordinate2D()
        }
        
        self.accuracy = google["accuracy"] as? Int
        self.heading = google["heading"] as? Int
        self.altitude = google["altitude"] as? Int
        self.verticalAccuracy = google["verticalAccuracy"] as? Int
        self.velocity = google["velocity"] as? Int
    }
    
    init?(geojson: [String: Any]) {
        self.timestamp = Date()
        
        if let properties = geojson["properties"] as? [String: Any] {
            self.title = properties["name"] as? String
        } else {
            self.title = "Untitled"
        }
        
        if
            let geometry = geojson["geometry"] as? [String: Any],
            let coordinates = geometry["coordinates"] as? [Double] {
                let latitude = coordinates[1]
                let longitude = coordinates[0]
                self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            self.coordinate = CLLocationCoordinate2D()
        }
        
        self.accuracy = geojson["accuracy"] as? Int
        self.heading = geojson["heading"] as? Int
        self.altitude = geojson["altitude"] as? Int
        self.verticalAccuracy = geojson["verticalAccuracy"] as? Int
        self.velocity = geojson["velocity"] as? Int
    }
}
