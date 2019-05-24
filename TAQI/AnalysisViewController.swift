//
//  AnalysisViewController.swift
//  TAQI
//
//  Created by Samuel Lichlyter on 5/1/19.
//  Copyright © 2019 Samuel Lichlyter. All rights reserved.
//

import UIKit
import ArcGIS

class AnalysisViewController: UITableViewController {
    
    let spinner = UIActivityIndicatorView()
    
    var document: Document!
    var loaded: Bool = false
    
    var averageAQI: Double = 0.0
    var stdDeviation: Double = 0.0
    
    var failed: Bool = false
    var distanceMeasurement: AGSLocationDistanceMeasurement?
    
    var stats: [AQIStat] = [
        AQIStat(title: "Minimum PM2.5", path: nil),
        AQIStat(title: "Maximum PM2.5", path: nil)
    ]
    
    private let dispatchGroup = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        getAQIData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !loaded {
            setupView()
            loaded = true
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stats.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "aqiCell", for: indexPath) as! AQIStatTableViewCell
        let title = stats[indexPath.row].title
        let path = stats[indexPath.row].path
        cell.setTitle(title)
        cell.setPath(path)
        
        return cell
    }
    
    private func setupView() {
        addSpinner()
        disableCells()
    }
    
    private func addSpinner() {
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
    }
    
    private func addInfoButton() {
        let button = UIButton(type: .infoDark)
        button.addTarget(self, action: #selector(showInfo), for: .touchUpInside)
        let barItem = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = barItem
    }
    
    private func disableCells() {
        tableView.isScrollEnabled = false
        let cells = tableView.visibleCells
        for cell in cells {
            cell.isUserInteractionEnabled = false
        }
    }
    
    private func getAQIData() {
        let paths = document.getQueryPaths()
        var min: Double = Double(truncating: kCFNumberPositiveInfinity)
        var max: Double = Double(truncating: kCFNumberNegativeInfinity)
        
        var counter = 0
        for path in paths {
            dispatchGroup.enter()
            let q = DispatchQueue(label: "aqiNetworkQuery", qos: .userInitiated)
            q.async {
                path.getAQI(completion: { (error) in
                    if error != nil {
                        print("Get AQI Error: " + (error?.localizedDescription ?? "Unknown Error Occurred"))
                        self.failed = true
                    } else {
                        if let pm25 = path.pm25 {
                            
                            // get minimum AQI
                            if pm25 < min {
                                min = pm25
                                self.stats[0].path = path
                            }
                            
                            // get max AQI
                            if pm25 > max {
                                max = pm25
                                self.stats[1].path = path
                            }
                        }
                    }
                    
                    self.dispatchGroup.leave()
                    counter += 1
                    print("leaving: \(counter) of \(paths.count)")
                })
            }
        }
        
        dispatchGroup.notify(queue: .global()) {
            DispatchQueue.main.async {
                
                print("all left")
                
//                if self.failed {
//                    let errorAlert = UIAlertController(title: "Error", message: "Failed to load AQI data", preferredStyle: .alert)
//                    let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (action) in
//                        self.spinner.stopAnimating()
//                    })
//                    errorAlert.addAction(okayAction)
//                    self.present(errorAlert, animated: true, completion: nil)
//                    print("failed")
//                    return
//                }
                
                let cells = self.tableView.visibleCells as! [AQIStatTableViewCell]
                for cell in cells {
                    for stat in self.stats {
                        if cell.title == stat.title {
                            let path = stat.path
                            cell.setPath(path)
                            cell.accessoryType = .disclosureIndicator
                            cell.isUserInteractionEnabled = true
                        }
                    }
                }
                
                let stat = self.document.getAverage()
                self.averageAQI = stat.mean
                self.stdDeviation = stat.stdDeviation
                
                self.spinner.stopAnimating()
                self.addInfoButton()
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let id = segue.identifier {
            switch id {
            case "statSegue":
                if let statVC = segue.destination as? AQIStatViewController {
                    let ip = tableView.indexPathForSelectedRow!
                    let selectedCell = tableView.cellForRow(at: ip) as! AQIStatTableViewCell
                    let title = selectedCell.title
                    let path = selectedCell.path
                    statVC.path = path
                    statVC.title = title
                }
            case "statInfoSegue":
                if let vc = segue.destination as? AQIInfoViewController {
                    vc.averageAQI = averageAQI
                    vc.stdDeviation = stdDeviation
                }
                
            default: break
            }
        }
    }
    
    @objc func showInfo() {
        self.performSegue(withIdentifier: "statInfoSegue", sender: self)
    }

}

struct AQIStat {
    let title: String
    var path: Path?
}

extension Measurement where UnitType == Unit {
    init(distance: AGSDistance) {
        let unit = Unit(symbol: distance.unit.abbreviation)
        let value = distance.value
        self.init(value: value, unit: unit)
    }
}
