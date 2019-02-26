//
//  DocumentMapViewController.swift
//  Timeline
//
//  Created by Samuel Lichlyter on 2/18/19.
//  Copyright © 2019 Samuel Lichlyter. All rights reserved.
//

import UIKit
import MapKit

class DocumentMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var document: Document?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set location to view Corvallis, OR
        let initialLocation = CLLocation(latitude: 44.5637844, longitude: -123.281633)
        centerMapOnLocation(location: initialLocation)
        
        // Access Document
        document?.open(completionHandler: {(success) in
            if success {
                // display content
                let locations = self.document?.locations
                self.mapView.addAnnotations(locations!)
            } else {
                let alert = UIAlertController(title: "Import Failed", message: "Could not read document", preferredStyle: .alert)
                self.show(alert, sender: nil)
            }
        })
    }
    
    let regionRadius: CLLocationDistance = 5000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        dismiss(animated: true) {
            self.document?.close(completionHandler: nil)
        }
    }
}

extension DocumentMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Location else { return nil }
        
        let identifier = "location"
        var view: MKMarkerAnnotationView
        
        if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequedView.annotation = annotation
            view = dequedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        return view
    }
}
