//
//  StepCell.swift
//  Venus
//
//  Created by Kenneth on 17/09/2017.
//  Copyright © 2017 ada. All rights reserved.
//

import UIKit

class StepCell : UITableViewCell {
    
    @IBOutlet weak var stepImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stepStateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var stepCountLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    
    override func awakeFromNib() {
        /*
        if let image = UIImage(named: "bg_default") {
            self.backgroundColor = UIColor(patternImage: image)
        }
        */
    }
}
