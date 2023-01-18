//
//  AlarmViewController.swift
//  Venus
//
//  Created by Kenneth on 18/07/2017.
//  Copyright © 2017 ada. All rights reserved.
//

import UIKit
import CoreBluetooth

class AlarmViewController: UIViewController {

    // call BTDataModel.sharedInstance will start scan device
    var btDataModel = BTDataModel.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

