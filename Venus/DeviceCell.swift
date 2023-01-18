//
//  DeviceCell.swift
//  Venus
//
//  Created by Kenneth on 13/07/2017.
//  Copyright © 2017 ada. All rights reserved.
//

import UIKit

class DeviceCell : UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var connectStatusLabel: UILabel!
    @IBOutlet weak var batteryLevelLabel: UILabel!
    @IBOutlet weak var batteryImageView: UIImageView!
    
    override func awakeFromNib() {
        /*
        if let image = UIImage(named: "bg_default") {
            self.backgroundColor = UIColor(patternImage: image)
        }
        */
    }
}
