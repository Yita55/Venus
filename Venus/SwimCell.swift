//
//  SwimCell.swift
//  Venus
//
//  Created by Kenneth on 29/08/2017.
//  Copyright © 2017 ada. All rights reserved.
//

import UIKit

class SwimCell : UITableViewCell {
    
    @IBOutlet weak var swimImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var swimDurationLabel: UILabel!
    @IBOutlet weak var swolfLabel: UILabel!
    @IBOutlet weak var swimDistanceLabel: UILabel!
    @IBOutlet weak var swimCallLabel: UILabel!
    @IBOutlet weak var swimTypeLabel: UILabel!
    @IBOutlet weak var swimLapLabel: UILabel!
    @IBOutlet weak var swimSectionLabel: UILabel!
    
    override func awakeFromNib() {
        /*
        if let image = UIImage(named: "bg_default") {
            self.backgroundColor = UIColor(patternImage: image)
        }
        */
    }
}
