//
//  CharacterDetailViewController.swift
//  Venus
//
//  Created by Kenneth on 06/07/2017.
//  Copyright © 2017 ada. All rights reserved.
//

import UIKit
import CoreBluetooth
class CharacterDetailViewController: UIViewController, CBPeripheralDelegate {
    
    var char: CBCharacteristic!
    var peripheral: CBPeripheral!
    @IBOutlet weak var lbUUID: UILabel!
    @IBOutlet weak var lbProp: UILabel!
    @IBOutlet weak var lbPropHex: UILabel!
    @IBOutlet weak var btnRead: UIButton!
    @IBOutlet weak var tvResponse: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbUUID.text = char.uuid.uuidString
        lbProp.text = char.getPropertyContent()
        lbPropHex.text = String(format: "0x%02X", char.properties.rawValue)
        
        // Do any additional setup after loading the view.
    }


    override func viewWillAppear(_ animated: Bool) {
        peripheral.delegate = self
        if !char.isReadable() {
            btnRead.isEnabled = false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionRead(_ sender: UIButton){
        peripheral.readValue(for: char)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            tvResponse.text = (data.getByteArray()?.description)! + "\n" + tvResponse.text
        }
    }

}
