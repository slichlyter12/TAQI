//
//  AnalysisViewController.swift
//  TAQI
//
//  Created by Samuel Lichlyter on 5/1/19.
//  Copyright © 2019 Samuel Lichlyter. All rights reserved.
//

import UIKit

class AnalysisViewController: UITableViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    
    var document: Document!
    
    private let dispatchGroup = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        getAQIData()
    }
    
    private func getAQIData() {
        let paths = document.paths
        var min: Double = Double(truncating: kCFNumberPositiveInfinity)
        var max: Double = Double(truncating: kCFNumberNegativeInfinity)
        
        for path in paths {
            dispatchGroup.enter()
            let q = DispatchQueue(label: "aqiNetworkQuery", qos: .userInitiated)
            q.async {
                path.getAQIs(completion: { (error) in
                    if error != nil {
                        print(error?.localizedDescription ?? "Unknown Error Occurred")
                    } else {
                        if let average = path.averageAQI {
                            if average < min {
                                min = average
                                self.document.minPath = path
                            }
                            if average > max {
                                max = average
                                self.document.maxPath = path
                            }
                        }
                    }
                    
                    self.dispatchGroup.leave()
                })
            }
        }
        
        dispatchGroup.notify(queue: .global()) {
            DispatchQueue.main.async {
                if
                    let minPath = self.document.minPath,
                    let maxPath = self.document.maxPath {
                    
                    self.minLabel.text = String(minPath.averageAQI!)
                    self.maxLabel.text = String(maxPath.averageAQI!)
                }
                
                self.activityIndicator.stopAnimating()
            }
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
