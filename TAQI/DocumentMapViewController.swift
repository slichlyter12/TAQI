//
//  DocumentArcGISMapViewController.swift
//  Timeline
//
//  Created by Samuel Lichlyter on 3/24/19.
//  Copyright © 2019 Samuel Lichlyter. All rights reserved.
//

import UIKit
import ArcGIS
import GoogleMaps

class DocumentMapViewController: UIViewController {
    
    // UI
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var analyzeButton: UIBarButtonItem!
    @IBOutlet weak var mapSegmentedControl: UISegmentedControl!
    
    private let arcGISMapView: AGSMapView = {
        let mapView = AGSMapView()
        mapView.map = AGSMap(basemapType: .lightGrayCanvasVector, latitude: 44.5637844, longitude: -123.281633, levelOfDetail: 13)
        return mapView
    }()
    
    
    // Document
    var document: Document?
    
    // ArcGIS
    private var map: AGSMap!
    private var rasterLayer: AGSRasterLayer!
    private var graphicsOverlay: AGSGraphicsOverlay!
    
    // Google
    private var googleMapView: GMSMapView!
    
    private var heatmapLayer: GMUHeatmapTileLayer!
    private var gradientColors: [UIColor] = [.blue, .red]
    private var gradientStartPoints: [NSNumber] = [0.1, 1.0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ArcGIS
        self.view.addSubview(arcGISMapView)
        setupLayout(mapView: arcGISMapView)
        
        setupRaster()
        createGraphicsOverlay()
        
        // Google
        setupGoogleMap()
        setupLayout(mapView: googleMapView)
        setupPoints()
    }
    
    // MARK: - ArcGIS
    
    private func createGraphicsOverlay() {
        graphicsOverlay = AGSGraphicsOverlay()
        self.arcGISMapView.graphicsOverlays.add(graphicsOverlay!)
    }
    
    private func setupPoints() {
        document?.open(completionHandler: { (success) in
            if success {
                let paths = self.document?.paths
                var list = [GMUWeightedLatLng]()
                for path in paths! {
                    for loc in path.locations {
                        let coord = GMUWeightedLatLng(coordinate: loc.coordinate, intensity: 1.0)
                        list.append(coord)
                    }
                }
                self.heatmapLayer.weightedData = list
                self.heatmapLayer.map = self.googleMapView
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
        rasterLayer.opacity = 0.8
        
        self.arcGISMapView.map?.operationalLayers.add(rasterLayer)
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
    
    // MARK: - Google
    private func setupGoogleMap() {
        let camera = GMSCameraPosition(latitude: 44.5637844, longitude: -123.281633, zoom: 13)
        googleMapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        self.view.addSubview(googleMapView)
        googleMapView.isHidden = true
        setupGoogleHeatmap()
    }
    
    private func setupGoogleHeatmap() {
        heatmapLayer = GMUHeatmapTileLayer()
        heatmapLayer.radius = 50
        heatmapLayer.opacity = 0.8
        heatmapLayer.gradient = GMUGradient(colors: gradientColors, startPoints: gradientStartPoints, colorMapSize: 512)
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
    
    // MARK: - Layout
    
    private func setupLayout(mapView: UIView) {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: mapSegmentedControl.topAnchor, constant: -10).isActive = true
    }
    
    @IBAction func mapSegmentedControlChanged(_ sender: Any) {
        let selected = MapState(rawValue: mapSegmentedControl.selectedSegmentIndex)!
        switch selected {
        case .arcgis:
            arcGISMapView.isHidden = false
            googleMapView.isHidden = true
        case .google:
            arcGISMapView.isHidden = true
            googleMapView.isHidden = false
        }
    }
}

enum MapState: Int {
    case arcgis = 0
    case google
}
