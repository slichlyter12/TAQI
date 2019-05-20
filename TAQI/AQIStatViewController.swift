//
//  AQIStatViewController.swift
//  TAQI
//
//  Created by Samuel Lichlyter on 5/20/19.
//  Copyright © 2019 Samuel Lichlyter. All rights reserved.
//

import UIKit

class AQIStatViewController: UIViewController {
    
    @IBOutlet weak var mapView: DynamicMapView!
    
    var path: Path?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if path != nil {
            mapView.setPaths(paths: [path!])
            mapView.drawPath(path: path!)
            let coord = (path?.locations.first?.coordinate)!
            mapView.setArcView(toCoordinates: coord)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
