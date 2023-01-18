//
//  CharacteristicViewController.swift
//  Venus
//
//  Created by Kenneth on 06/07/2017.
//  Copyright © 2017 ada. All rights reserved.
//

import UIKit
import CoreBluetooth

class BTServiceInfo {
    var service: CBService!
    var characteristics: [CBCharacteristic]
    init(service: CBService, characteristics: [CBCharacteristic]) {
        self.service = service
        self.characteristics = characteristics
    }
}

class CharacteristicViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    var centralManger: CBCentralManager!
    var peripheral: CBPeripheral!
    
    var btServices: [BTServiceInfo] = []
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("central state:\(central.state.rawValue)")
        switch central.state {
        case .unknown:
            print("CBCentralManagerStateUnknown")
        case .resetting:
            print("CBCentralManagerStateResetting")
        case .unsupported:
            print("CBCentralManagerStateUnsupported")
        case .unauthorized:
            print("CBCentralManagerStateUnauthorized")
        case .poweredOff:
            print("CBCentralManagerStatePoweredOff")
        case .poweredOn:
            print("CBCentralManagerStatePoweredOn")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "CharacteristicCell", bundle: nil), forCellReuseIdentifier: "CharacteristicCell")

        centralManger.connect(peripheral, options: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        centralManger.delegate = self
        peripheral.delegate = self
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for serviceObj in peripheral.services! {
            let service:CBService = serviceObj
            let isServiceIncluded = self.btServices.filter({ (item: BTServiceInfo) -> Bool in
                return item.service.uuid == service.uuid
            }).count
            if isServiceIncluded == 0 {
                btServices.append(BTServiceInfo(service: service, characteristics: []))
            }
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        let serviceCharacteristics = service.characteristics
        
        for item in btServices {
            if item.service.uuid == service.uuid {
                item.characteristics = serviceCharacteristics!
                break
            }
        }
        
        tableView.reloadData()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return btServices[section].service.uuid.description
    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CharacteristicCell = tableView.dequeueReusableCell(withIdentifier: "CharacteristicCell") as! CharacteristicCell
        cell.lbUUID.text = btServices[indexPath.section].characteristics[indexPath.row].uuid.uuidString
        cell.lbPropHex.text = String(format: "0x%02X", btServices[indexPath.section].characteristics[indexPath.row].properties.rawValue)
        cell.lbProp.text = btServices[indexPath.section].characteristics[indexPath.row].getPropertyContent()
        cell.lbName.text = btServices[indexPath.section].characteristics[indexPath.row].uuid.description
        cell.lbValue.text = btServices[indexPath.section].characteristics[indexPath.row].value?.description ?? "null"
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "sgToCharDetail", sender: ["section": indexPath.section, "row": indexPath.row])
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgToCharDetail" {
            let targetVC = segue.destination as! CharacterDetailViewController
            targetVC.peripheral = self.peripheral
            
            let formDict = sender as! Dictionary<String, Any>
            targetVC.char = btServices[formDict["section"] as! Int].characteristics[formDict["row"] as! Int]
        }
        
    }
    

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160.5
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return btServices.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return btServices[section].characteristics.count
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

}
