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
    
    var pm25: Double?
    
    private let pm25URL = URL(string: "https://sedac.ciesin.columbia.edu/arcgis/rest/services/sedac/sdei_global_annual_avg_pm2_5_2001_2010_image_service/ImageServer/getSamples")!
    
    init(locations: [Location]) {
        self.locations = locations
    }
    
    func getAQI(url: URL? = nil, completion: @escaping (Error?) -> Void) {
        let url = url ?? pm25URL
        
        let first = locations.first!
        let x = first.coordinate.longitude
        let y = first.coordinate.latitude
        
        var postString = "geometryType=esriGeometryPoint"
        postString += #"&geometry={"x":\#(x), "y": \#(y)"#
        postString += #", "spatialReference" : {"wkid":4326}}"#
        postString += "&f=json"
        
        let postData = Data(postString.data(using: .utf8)!)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = postData
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 2.0 * 60.0
        config.timeoutIntervalForResource = 4.0 * 60.0
        config.waitsForConnectivity = true
//        let session = URLSession(configuration: config)
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                    completion(error)
                    return
            }
            
            guard (200 ... 299) ~= response.statusCode else {
                print("Status code is not OK: \(response.statusCode)")
                print("response: \(response)")
                let error = NSError(domain: "", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed Response with \(response.statusCode): \(response)"])
                completion(error)
                return
            }
            
            let jsonData = try? (JSONSerialization.jsonObject(with: data, options: []) as! [String: Any])
            if let samples = jsonData!["samples"] as? NSArray {
                for location in samples {
                    let l = location as! [String: Any]
                    let value = l["value"] as! String
                    
                    let d = Double(value)!
                    
                    self.pm25 = d
                }
                
                completion(nil)
            } else {
                let dataResponse = String(data: data, encoding: .utf8)!
                let info: [String: String] = [NSLocalizedDescriptionKey: dataResponse]
                let error = NSError(domain: "", code: 1, userInfo: info)
                completion(error)
            }
        })
        
        dataTask.resume()
    }
}
