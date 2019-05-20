//
//  DocumentArcGISMapViewController.swift
//  Timeline
//
//  Created by Samuel Lichlyter on 3/24/19.
//  Copyright © 2019 Samuel Lichlyter. All rights reserved.
//

import UIKit

class DocumentMapViewController: UIViewController {
    
    // UI
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var analyzeButton: UIBarButtonItem!
    @IBOutlet weak var mapView: DynamicMapView!
    
    // Document
    var document: Document?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPoints()
    }
    
    private func getPoints() {
        document?.open(completionHandler: { (success) in
            if success {
                let paths = self.document?.paths
                self.mapView.setPaths(paths: paths!)
                self.analyzeButton.isEnabled = true
            } else {
                let alertController = UIAlertController(title: "Import Failed", message: "Could not read document", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(okayAction)
                self.show(alertController, sender: nil)
            }
        })
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
