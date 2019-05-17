//
//  InstructionsViewController.swift
//  TAQI
//
//  Created by Samuel Lichlyter on 5/17/19.
//  Copyright © 2019 Samuel Lichlyter. All rights reserved.
//

import UIKit

class InstructionsViewController: UIViewController {

    @IBOutlet weak var instructionsTextView: UITextView!
    @IBOutlet weak var takeoutButton: UIButton!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    private let url = URL(string: "https://takeout.google.com/settings/takeout/custom/location_history")!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let url = Bundle.main.url(forResource: "takeout_instructions", withExtension: "rtf")!
        let opts: [NSMutableAttributedString.DocumentReadingOptionKey: Any] = [.documentType: NSAttributedString.DocumentType.rtf]
        let content = try! NSAttributedString(url: url, options: opts, documentAttributes: nil)
        
        instructionsTextView.attributedText = content
    }

    @IBAction func takeoutButtonPressed(_ sender: Any) {
        UIApplication.shared.open(url, options: [:]) { (success) in
            if success {
                print("Nailed it!")
            }
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
