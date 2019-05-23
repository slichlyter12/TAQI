//
//  AQIInfoViewController.swift
//  TAQI
//
//  Created by Samuel Lichlyter on 5/22/19.
//  Copyright © 2019 Samuel Lichlyter. All rights reserved.
//

import UIKit

class AQIInfoViewController: UIViewController {

    @IBOutlet weak var averageAQILabel: UILabel!
    @IBOutlet weak var stdDeviationLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView!
    
    var averageAQI: Double = 0.0
    var stdDeviation: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let url = Bundle.main.url(forResource: "aqiInfo", withExtension: "rtf")!
        let opts: [NSMutableAttributedString.DocumentReadingOptionKey: Any] = [.documentType: NSAttributedString.DocumentType.rtf]
        let content = try! NSAttributedString(url: url, options: opts, documentAttributes: nil)
        
        infoTextView.attributedText = content
        
        averageAQILabel.text = String(averageAQI)
        stdDeviationLabel.text = String(stdDeviation)
    }
}
