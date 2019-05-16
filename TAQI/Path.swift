//
//  Path.swift
//  Timeline
//
//  Created by Samuel Lichlyter on 2/26/19.
//  Copyright © 2019 Samuel Lichlyter. All rights reserved.
//

import UIKit
import MapKit

class Path: NSObject {
    var locations: [Location] = []
    
    var averageAQI: Double? {
        var sum: Double = 0.0
        var count = 0
        for location in locations {
            if let aqi = location.aqi {
                sum += aqi
                count += 1
            }
        }
        
        if count > 0 {
            let average = sum / Double(count)
            return average
        } else {
            return nil
        }
    }
    
    private let aqiURL = URL(string: "https://sedac.ciesin.columbia.edu/arcgis/rest/services/sedac/sdei_global_annual_avg_pm2_5_2001_2010_image_service/ImageServer/getSamples")!
    
    init(locations: [Location]) {
        self.locations = locations
    }
    
    func getAQIs(completion: @escaping (Error?) -> Void) {
        let coordinates = locations.map { (location) -> [Double] in
            return [location.coordinate.longitude, location.coordinate.latitude]
        }
        
        var postString = "geometryType=esriGeometryMultipoint"
        postString += #"&geometry={"points":"#
        postString += coordinates.description
        postString += #", "spatialReference" : {"wkid":4326}}"#
        postString += "&f=json"
        
        let postData = Data(postString.data(using: .utf8)!)
        
        var request = URLRequest(url: aqiURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = postData
        
        let dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                completion(error)
            } else {
                let jsonData = try? (JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any])
                if let samples = jsonData!["samples"] as? NSArray {
                    var i = 0
                    for location in samples {
                        let l = location as! [String: Any]
                        let value = l["value"] as! String
                        
                        let d = Double(value)!
                        
                        self.locations[i].aqi = d
                        i += 1
                    }

                    completion(nil)
                }
            }
        })
        
        dataTask.resume()
    }
}
