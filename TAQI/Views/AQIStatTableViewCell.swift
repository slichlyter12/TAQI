//
//  AQIStatTableViewCell.swift
//  TAQI
//
//  Created by Samuel Lichlyter on 5/20/19.
//  Copyright © 2019 Samuel Lichlyter. All rights reserved.
//

import UIKit

class AQIStatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var aqiStatLabel: UILabel!
    @IBOutlet weak var aqiStatValueLabel: UILabel!
    
    var path: Path?
    var title: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        aqiStatLabel.text = ""
        aqiStatValueLabel.text = "loading..."
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setTitle(_ newTitle: String) {
        title = newTitle
        aqiStatLabel.text = newTitle + ":"
    }
    
    func setPath(_ newPath: Path?) {
        path = newPath
        let label: String
        if newPath != nil {
            label = String(newPath!.pm25!)
        } else {
            label = "loading..."
        }
        aqiStatValueLabel.text = label
    }

}
