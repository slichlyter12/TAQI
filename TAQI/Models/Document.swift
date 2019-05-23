//
//  Document.swift
//  Timeline
//
//  Created by Samuel Lichlyter on 11/8/18.
//  Copyright © 2018 Samuel Lichlyter. All rights reserved.
//

import UIKit
import Accelerate

class Document: UIDocument {
    
    var paths: [Path] = []
    var minPath: Path?
    var maxPath: Path?
    var package: FileWrapper?
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
        
        if
            let json = try? JSONSerialization.jsonObject(with: contents as! Data, options: []),
            let dictionary = json as? [String: Any] {
                if let locations = dictionary["locations"] as? [Any] {
                    let validLocations = locations.compactMap { Location(google: $0 as! [String : Any])}
                    generatePaths(locations: validLocations)
                    // Google updated file structure so now they no longer need to be reversed (older files will show incorrect results)
                }
        } else { return }
    }
    
    private func generatePaths(locations: [Location]) {
        
        if locations.count == 0 {
            return
        }
        
        var paths: [Path] = []
        var pathLocations: [Location] = []
        pathLocations.append(locations[0])
        
        for location in locations {
            let calendar = Calendar.current
            let lastTimestamp = pathLocations.last!.timestamp!
            let fifteenMinutes = calendar.date(byAdding: .minute, value: 15, to: lastTimestamp)
            if location.timestamp! < fifteenMinutes! {
                pathLocations.append(location)
            } else {
                if pathLocations.count > 2 {
                    let path = Path(locations: pathLocations)
                    paths.append(path)
                }
                pathLocations.removeAll()
                pathLocations.append(location)
            }
            
            // if last location, make a path
            if location == locations.last! {
                if pathLocations.count > 2 {
                    let path = Path(locations: pathLocations)
                    paths.append(path)
                }
            }
        }
        
        self.paths = paths
    }
    
    func getAverage() -> Stat {
        var aqis: [Double] = []
        for path in paths {
            for location in path.locations {
                aqis.append(location.aqi!)
            }
        }
        
        var mean = 0.0
        var stdDev = 0.0
        vDSP_normalizeD(aqis, 1, nil, 1, &mean, &stdDev, vDSP_Length(aqis.count))
        stdDev *= sqrt(Double(aqis.count)/Double(aqis.count - 1))
        
        let stat = Stat(mean: mean, stdDeviation: stdDev)
        return stat
    }
}

struct Stat {
    let mean: Double
    let stdDeviation: Double
}
