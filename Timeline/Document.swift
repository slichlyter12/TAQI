//
//  Document.swift
//  Timeline
//
//  Created by Samuel Lichlyter on 11/8/18.
//  Copyright © 2018 Samuel Lichlyter. All rights reserved.
//

import UIKit

class Document: UIDocument {
    
    var locations: [Location] = []
    var package: FileWrapper?
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
        
        if
            let json = try? JSONSerialization.jsonObject(with: contents as! Data, options: []),
            let dictionary = json as? [String: Any] {
                if let locations = dictionary["locations"] as? [Any] {
                    let validLocations = locations.compactMap { Location(google: $0 as! [String : Any])}
                    self.locations = validLocations
                } else if let locations = dictionary["features"] as? [Any] {
                    let validLocations = locations.compactMap { Location(geojson: $0 as! [String: Any])}
                    self.locations = validLocations
            }
        } else { return }
    }
}
