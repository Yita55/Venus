//
//  AboutTableViewController.swift
//  FoodPin
//
//  Created by Simon Ng on 22/8/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import SafariServices

class AboutTableViewController: UITableViewController {

    var sectionTitles = ["",
                         PropertyUtils.readLocalizedProperty("device_info"),
                         PropertyUtils.readLocalizedProperty("connect_with_us")]
    var sectionContent = [["1.000.007"],
                          ["  " + PropertyUtils.readLocalizedProperty("device_info_fw") + ": ", "  " + PropertyUtils.readLocalizedProperty("device_info_hw") + ": "],
                          [PropertyUtils.readLocalizedProperty("Contact_us"), PropertyUtils.readLocalizedProperty("Visit_our_website"), PropertyUtils.readLocalizedProperty("Watch_us_on_Youtube"), "Copyright ©2017 by Cloudchip"]]
    /*
    var links = ["https://twitter.com/appcodamobile",
                 "https://facebook.com/appcodamobile",
                 "https://www.pinterest.com/appcoda/"]
    */
    var email = "yr.deng@cloudchip.com"
    var webUrl = "http://www.cloudchip.com/"
    var youtubeUrl = "https://www.youtube.com/channel/UCH66Z4p9tiq05dzapCO4apA"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sectionContent[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        switch indexPath.section {
            
        case 0:
            // Configure the cell...
            var bundleVersion = ""
            
            if let buildNumber = Bundle.main.object(forInfoDictionaryKey: UserDefaultsKey.BundleVersion) {
                if buildNumber is String {
                    bundleVersion = String(describing: buildNumber)
                }
            }
            //cell.textLabel?.text = sectionContent[indexPath.section][indexPath.row]
            cell.textLabel?.text = bundleVersion
            cell.imageView?.image = UIImage(named: "ic_history_48pt")
            break
            
        // Device Information section
        case 1:
            // Configure the cell...
            if indexPath.row == 0 {
                let fwVersion: String = UserDefaults.standard.string(forKey: UserDefaultsKey.FirmwareRevision)!

                cell.textLabel?.text = "  " + PropertyUtils.readLocalizedProperty("device_info_fw") + ": " + fwVersion
            } else if indexPath.row == 1 {
                let hwVersion: String = UserDefaults.standard.string(forKey: UserDefaultsKey.HardwareRevision)!
                
                cell.textLabel?.text = "  " + PropertyUtils.readLocalizedProperty("device_info_hw") + ": " + hwVersion
            } else {
                cell.textLabel?.text = sectionContent[indexPath.section][indexPath.row]
            }
            break
            
        // Connect with us section
        case 2:
            if indexPath.row == 0 {
                // open Email
                // Configure the cell...
                cell.imageView?.image = UIImage(named: "emailPic")
            } else if indexPath.row == 1 {
                // Configure the cell...
                cell.imageView?.image = UIImage(named: "urlPic")
            } else if indexPath.row == 2 {
                // Configure the cell...
                cell.imageView?.image = UIImage(named: "youtubePic")
            } else if indexPath.row == 3 {
                cell.textLabel?.textAlignment = .center
            }
            
            cell.textLabel?.text = sectionContent[indexPath.section][indexPath.row]
        default:
            break
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        
        case 0:
            break
            
        // Device Information section
        case 1:
            break
            
        // Connect with us section
        case 2:
            if indexPath.row == 0 {
                // open Email
                let url = URL(string: "mailto:\(email)")
                UIApplication.shared.openURL(url!)
                /*
                if let url = URL(string: "http://www.apple.com/itunes/charts/paid-apps/") {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url)
                    } else {
                        // Fallback on earlier versions
                        UIApplication.shared.openURL(url)
                    }
                }
                */
            } else if indexPath.row == 1 {
                /*
                performSegue(withIdentifier: "showWebView", sender: self)
                */
                if let url = URL(string: webUrl) {
                    let safariController = SFSafariViewController(url: url)
                    present(safariController, animated: true, completion: nil)
                }
            } else if indexPath.row == 2 {
                if let url = URL(string: youtubeUrl) {
                    let safariController = SFSafariViewController(url: url)
                    present(safariController, animated: true, completion: nil)
                }
            }
            
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }

}
