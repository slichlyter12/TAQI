//
//  DocumentArcGISMapViewController.swift
//  Timeline
//
//  Created by Samuel Lichlyter on 3/24/19.
//  Copyright © 2019 Samuel Lichlyter. All rights reserved.
//

import UIKit
import ArcGIS

class DocumentMapViewController: UIViewController {
    
    // UI
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var analyzeButton: UIBarButtonItem!
    
    
    // Document
    var document: Document?
    
    // ArcGIS
    private var map: AGSMap!
    private var rasterLayer: AGSRasterLayer!
    private var graphicsOverlay: AGSGraphicsOverlay!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMap()
        setupRaster()
        createGraphicsOverlay()
        setupPoints()
    }
    
    // MARK: - ArcGIS
    
    private func setupMap() {
        self.map = AGSMap(basemapType: .lightGrayCanvasVector, latitude: 44.5637844, longitude: -123.281633, levelOfDetail: 10)
        self.mapView.map = map
    }
    
    private func createGraphicsOverlay() {
        graphicsOverlay = AGSGraphicsOverlay()
        self.mapView.graphicsOverlays.add(graphicsOverlay!)
    }
    
    private func setupPoints() {
        document?.open(completionHandler: { (success) in
            if success {
                let paths = self.document?.paths
                for path in paths! {
                    self.drawPath(path: path)
                }
            } else {
                let alertController = UIAlertController(title: "Import Failed", message: "Could not read document", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(okayAction)
                self.show(alertController, sender: nil)
            }
        })
    }
    
    private func drawPath(path: Path) {
        var points: [AGSPoint] = []
        for location in path.locations {
            let point = AGSPoint(x: location.coordinate.longitude, y: location.coordinate.latitude, spatialReference: .wgs84())
            points.append(point)
        }
        let line = AGSPolyline(points: points)
        let symbol = AGSSimpleLineSymbol(style: .solid, color: .orange, width: 3.0)
        let graphic = AGSGraphic(geometry: line, symbol: symbol, attributes: nil)
        graphicsOverlay.graphics.add(graphic)
    }
    
    private func setupRaster() {
        
        let raster = AGSRaster(name: "pnw", extension: "tif")
        let rasterLayer = AGSRasterLayer(raster: raster)
        
        let colors = getColors(filename: "magma")
        let renderer = AGSColormapRenderer(colors: colors)
        rasterLayer.renderer = renderer
        
        self.mapView.map?.operationalLayers.add(rasterLayer)
        self.rasterLayer = rasterLayer
    }
    
    private func getColors(filename: String) -> [UIColor] {
        var colors: [UIColor] = []
        if let path = Bundle.main.path(forResource: filename, ofType: "clr") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                let lines = data.components(separatedBy: .newlines)
                for line in lines {
                    let row = line.components(separatedBy: .whitespaces)
                    let r = row[1]
                    let g = row[2]
                    let b = row[3]
                    let color = UIColor(red: CGFloat(Double(r)!/255), green: CGFloat(Double(g)!/255), blue: CGFloat(Double(b)!/255), alpha: 1.0)
                    colors.append(color)
                }
            } catch {
                print(error)
            }
        }
        
        return colors
    }
    
    // MARK: - Navigation
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        dismiss(animated: true) {
            self.document?.close(completionHandler: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.identifier
        switch destination {
        case "analyzeSegue":
            if let analysisVC = segue.destination as? AnalysisViewController {
                analysisVC.document = self.document
            }
        default: break
        }
    }
    
}
