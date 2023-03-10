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
//  ReturnVC.swift
//  Setting
//
//  Created by waltoncob on 2016/10/27.
//  Copyright © 2016年 waltoncob. All rights reserved.
//

import UIKit

public class ReturnViewController: UIViewController {

    private let tableView:UITableView
    private let sourceCell:EventCell
    private let backFunc:()->()
    private var backTitle:String

    public init(sender:EventCell, table:UITableView, backTitle:String?, back: @escaping ()->()){
        self.sourceCell = sender
        self.tableView = table
        self.backTitle = backTitle ?? "back"
        self.backFunc = back
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view = tableView
//        self.navigationItem.hidesBackButton = true
//        setupTopBar()
    }

    func setupTopBar(){
        let newBackButton = UIBarButtonItem(title: "＜" + backTitle, style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = newBackButton;
    }

    deinit {
        var result:String?
        if let indexPath = tableView.indexPathForSelectedRow{
            let cell = tableView.cellForRow(at: indexPath)
            //if cell?.textLabel?.text != nil {
            //    result = PropertyUtils.readLocalizedProperty(cell!.textLabel!.text!)
            //} else {
                result = cell?.textLabel?.text
            //}
            sourceCell.setContent(detail: result!)
            sourceCell.updateView()
        }
        self.backFunc()
    }

    func back(){
        var result:String?
        if let indexPath = tableView.indexPathForSelectedRow{
            let cell = tableView.cellForRow(at: indexPath)
            //if cell?.textLabel?.text != nil {
            //    result = PropertyUtils.readLocalizedProperty(cell!.textLabel!.text!)
            //} else {
                result = cell?.textLabel?.text
            //}
            sourceCell.setContent(detail: result!)
            sourceCell.updateView()
        }
        self.backFunc()
        let _ = self.navigationController?.popViewController(animated: true)
    }

    /*
    override public var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    */
    
}

