/*
 * Copyright (C) 2016 Xu,Cheng Wei <www16852@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
//
//  AlertListener.swift
//  Settings
//
//  Created by waltoncob on 2016/10/25.
//  Copyright © 2016年 waltoncob. All rights reserved.
//

import  UIKit

public class AlertListener:CellTapListener{

    unowned let controller:UIViewController
    unowned let plistManager:PlistManager
    private var alert:UIAlertController?
    private var customAlert:UIViewController?

    public init(controller: UIViewController, plist:PlistManager, alert:UIAlertController? = nil, customAlert:UIViewController? = nil){
        self.controller = controller
        self.plistManager = plist
        self.alert = alert
        self.customAlert = customAlert
    }

    public func tapAction(sender:EventCell){
        print("\(String(describing: sender.textLabel?.text)) trigger AlertController")
        //if sender.getIsOn() == true {
        if self.alert != nil {
            pushViewController(sender)
        } else {
            pushViewCustomController(sender)
        }
        //}
        // it seems to no need to save plist
        // plistManager.savePlist()
    }

    func pushViewController(_ cell:EventCell){
        controller.present(alert!, animated: true, completion: nil)
    }

    func pushViewCustomController(_ cell:EventCell){
        if self.customAlert == nil {
            return
        }
        controller.present(customAlert!, animated: true, completion: nil)
    }
}

