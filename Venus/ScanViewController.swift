//
//  ScanViewController.swift
//  Venus
//
//  Created by Kenneth on 20/06/2017.
//  Copyright © 2017 ada. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScanViewController: UITableViewController {
    //系统蓝牙管理对象
    var btCentralManager: CBCentralManager!
    var btPeripherals: [CBPeripheral] = []
    var selectedPeripheral: CBPeripheral?
    var btRSSIs: [NSNumber] = []
    var btConnectable: [Int] = []

    @IBOutlet weak var bbRefresh: UIBarButtonItem!
    
    @IBAction func actionRefresh(_ sender: UIBarButtonItem!) {
        self.refresh()
    }
    
    func refresh() {
        bbRefresh.isEnabled = false
        btConnectable.removeAll()
        btPeripherals.removeAll()
        btRSSIs.removeAll()
        tableView.register(UINib(nibName: "PeripheralCell", bundle: nil), forCellReuseIdentifier: "PeripheralCell")
        
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(ScanViewController.stopScan), userInfo: nil, repeats: false)
        btCentralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopScan() {
        btCentralManager.stopScan()
        bbRefresh.isEnabled = true
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        btCentralManager.delegate = self
        if selectedPeripheral != nil {
            btCentralManager.cancelPeripheralConnection(selectedPeripheral!)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PeripheralCell = tableView.dequeueReusableCell(withIdentifier: "PeripheralCell") as! PeripheralCell
        cell.lbConntable.text = btConnectable[indexPath.row].description
        cell.lbName.text = btPeripherals[indexPath.row].name
        cell.lbRSSI.text = btRSSIs[indexPath.row].description
        cell.lbUUID.text = btPeripherals[indexPath.row].identifier.uuidString
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "sgToServiceList", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let targetVC = segue.destination as! CharacteristicViewController
        targetVC.centralManger = self.btCentralManager
        selectedPeripheral = btPeripherals[sender as! Int]
        targetVC.peripheral = selectedPeripheral
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130.5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return btPeripherals.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btCentralManager = CBCentralManager(delegate: self, queue: nil)
        tableView.register(UINib(nibName: "PeripheralCell", bundle: nil), forCellReuseIdentifier: "PeripheralCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ScanViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
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
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let temp = btPeripherals.filter { (pl) -> Bool in
            return pl.identifier.uuidString == peripheral.identifier.uuidString
        }
        
        if temp.count == 0 {
            btPeripherals.append(peripheral)
            btRSSIs.append(RSSI)
            btConnectable.append(Int((advertisementData[CBAdvertisementDataIsConnectable]! as AnyObject).description)!)
        }
    }
}
