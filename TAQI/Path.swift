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
    
    init(locations: [Location]) {
        self.locations = locations
    }
}
