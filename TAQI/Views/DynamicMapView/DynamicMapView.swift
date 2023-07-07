//
//  DynamicMapView.swift
//  TAQI
//
//  Created by Samuel Lichlyter on 5/20/19.
//  Copyright © 2019 Samuel Lichlyter. All rights reserved.
//

import UIKit
import ArcGIS
import GoogleMaps
import GoogleMapsUtils

class DynamicMapView: UIView {
    
    let CONTENT_XIB_NAME = "DynamicMapView"

    @IBOutlet weak var mapSegmentedControl: UISegmentedControl!
    @IBOutlet weak var view: UIView!
    
    private let arcGISMapView: AGSMapView = {
        let mapView = AGSMapView()
        mapView.map = AGSMap(basemapType: .lightGrayCanvasVector, latitude: 44.5637844, longitude: -123.281633, levelOfDetail: 13)
        return mapView
    }()
    
    // ArcGIS
    private var map: AGSMap!
    private var rasterLayer: AGSRasterLayer!
    private var graphicsOverlay: AGSGraphicsOverlay!
    
    // Google
    private var googleMapView: GMSMapView!
    
    private var heatmapLayer: GMUHeatmapTileLayer!
    private var gradientColors: [UIColor] = [.blue, .red]
    private var gradientStartPoints: [NSNumber] = [0.1, 1.0]
    
    private var paths: [Path] = []
    
    // From: https://gis.stackexchange.com/questions/7430/what-ratio-scales-do-google-maps-zoom-levels-correspond-to
    private let zoomScaleReference: [Int: Double] = [
        20 : 1128.497220,
        19 : 2256.994440,
        18 : 4513.988880,
        17 : 9027.977761,
        16 : 18055.955520,
        15 : 36111.911040,
        14 : 72223.822090,
        13 : 144447.644200,
        12 : 288895.288400,
        11 : 577790.576700,
        10 : 1155581.153000,
        9  : 2311162.307000,
        8  : 4622324.614000,
        7  : 9244649.227000,
        6  : 18489298.450000,
        5  : 36978596.910000,
        4  : 73957193.820000,
        3  : 147914387.600000,
        2  : 295828775.300000,
        1  : 591657550.500000
    ]
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setPaths(paths: [Path]) {
        self.paths = paths
        setupGoogleHeatmap()
    }
    
    private func setup() {
        Bundle.main.loadNibNamed("DynamicMapView", owner: self, options: nil)
        view.fixInView(self)
        
        // ArcGIS
        self.view.addSubview(arcGISMapView)
        setupLayout(mapView: arcGISMapView)
        mapSegmentedControl.isEnabled = true
        
        setupRaster()
        createGraphicsOverlay()
        
        // Google
        setupGoogleMap()
        setupLayout(mapView: googleMapView)
    }
    
    // MARK: - ArcGIS
    private func createGraphicsOverlay() {
        graphicsOverlay = AGSGraphicsOverlay()
        self.arcGISMapView.graphicsOverlays.add(graphicsOverlay!)
    }
    
    func drawPath(path: Path) {
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
        googleMapView.settings.tiltGestures = false
        self.view.addSubview(googleMapView)
        googleMapView.isHidden = true
    }
    
    private func setupGoogleHeatmap() {
        heatmapLayer = GMUHeatmapTileLayer()
        heatmapLayer.radius = 50
        heatmapLayer.opacity = 0.8
        heatmapLayer.gradient = GMUGradient(colors: gradientColors, startPoints: gradientStartPoints, colorMapSize: 512)
        
        var points = [GMUWeightedLatLng]()
        for path in paths {
            for loc in path.locations {
                let coord = GMUWeightedLatLng(coordinate: loc.coordinate, intensity: 1.0)
                points.append(coord)
            }
        }
        
        heatmapLayer.weightedData = points
        heatmapLayer.map = googleMapView
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
            setArcView(fromGoogleCamera: googleMapView.camera)
            arcGISMapView.isHidden = false
            googleMapView.isHidden = true
            
        case .google:
           let viewpoint = arcGISMapView.currentViewpoint(with: .centerAndScale)
           setGoogleView(fromArcViewpoint: viewpoint!)
            
            arcGISMapView.isHidden = true
            googleMapView.isHidden = false
        }
    }
    
    func setArcView(toCoordinates coord: CLLocationCoordinate2D) {
        let point = AGSPoint(clLocationCoordinate2D: coord)
        let viewpoint = AGSViewpoint(center: point, scale: 144447.644200)
        
        arcGISMapView.setViewpoint(viewpoint)
    }
    
    private func setArcView(fromGoogleCamera camera: GMSCameraPosition) {
        let googleTarget = camera.target
        let centerPoint = AGSPoint(clLocationCoordinate2D: googleTarget)
        let zoom = Int(camera.zoom) > 20 ? 20 : Int(camera.zoom)
        let scale = zoomScaleReference[zoom]!
        let bearing = camera.bearing
        let viewpoint = AGSViewpoint(center: centerPoint, scale: scale, rotation: bearing)
        
        arcGISMapView.setViewpoint(viewpoint)
    }
    
    private func setGoogleView(fromArcViewpoint viewpoint: AGSViewpoint) {
        let rotation = viewpoint.rotation
        let scale = viewpoint.targetScale
        let zoom = getZoom(scale: scale)
        let extent = viewpoint.targetGeometry.extent
        let latLonExtent = AGSGeometryEngine.projectGeometry(extent, to: .wgs84())
        let lat = latLonExtent!.extent.yMin
        let lon = latLonExtent!.extent.xMin
        
        let coord = CLLocationCoordinate2DMake(lat, lon)
        googleMapView.camera = GMSCameraPosition.camera(withTarget: coord, zoom: Float(zoom), bearing: rotation, viewingAngle: 0)
    }
    
    private func getZoom(scale: Double) -> Int {
        let values = (zoomScaleReference as NSDictionary).allValues as! [Double]
        var minDiff = Double(truncating: kCFNumberPositiveInfinity)
        var min: Double = values.first!
        for value in values {
            let diff = abs(value - scale)
            print(diff)
            if diff < minDiff {
                min = value
                minDiff = diff
                print("set diff")
            }
        }
        
        let keys = (zoomScaleReference as NSDictionary).allKeys(for: min) as! [Int]
        return keys[0]
    }
}

enum MapState: Int {
    case arcgis = 0
    case google
}

// From: https://medium.com/@umairhassanbaig/ios-swift-creating-a-custom-view-with-xib-ace878cd41c5
extension UIView {
    func fixInView(_ container: UIView!) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        
        container.addSubview(self)
        
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
