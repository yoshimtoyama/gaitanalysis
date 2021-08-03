//
//  DetailCustomerInputList.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/02.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit

class DetailCustomerInputList: UITableViewController {
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    var personalInfo: JSON!
    //let columnNameList: [NSString] = ["LastName", "FirstName", "Gender", "Birthday"]
    //let textList: [NSString] = ["姓", "名", "性別", "生年月日"]
    var list: [JSON]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceの設定をする.
        self.tableView.dataSource = self
        
        // Delegateを設定する.
        self.tableView.delegate = self
        
        // マスタ情報の取得
        getMstCustomerInfo()
        // 利用者情報の取得
        getCustomerInfo()
        
        
        // var jsonStr = AppCommon.getResourceString(forResource: "personalInfo", ofType: "json")
        // personalInfo = JSON(string: jsonStr) // JSON読み込み
        
        // jsonStr = AppCommon.getResourceString(forResource: "mstPersonalAssList", ofType: "json")
        // let tempList = JSON(string: jsonStr) // JSON読み込み
        // let gid = 1
        // let sid = 1
        // 絞り込み
        // list = tempList.enumerated().filter{ $0.element.1["assmenuGroupId"].asInt! == gid && $0.element.1["assMenuSubGroupId"].asInt! == sid}.map{ $0.element.1 }
        
    }
    func getCustomerInfo() {
        // 利用者情報の取得
        let url = "\(AppConst.URLPrefix)customer/GetCustomerRowDataInfoList/\(appDelegate.selectedUser["customerID"].asInt!)"
        let jsonStr = self.appCommon.getSynchronous(url)
        personalInfo = JSON(string: jsonStr!) // JSON読み込み
    }
    func getMstCustomerInfo() {
        if appDelegate.mstCustomerList == nil {
            // 利用者情報の取得
            let url = "\(AppConst.URLPrefix)customer/GetMstCustomerList"
            let jsonStr = self.appCommon.getSynchronous(url)
            appDelegate.mstCustomerList = JSON(string: jsonStr!) // JSON読み込み
        }
    }
    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if appDelegate.ChangeCustomerInfo == true {
            // 利用者情報の取得
            getCustomerInfo()
            self.tableView?.reloadData()
            
            // 選択された利用者情報の更新
            let url = "\(AppConst.URLPrefix)customer/GetCustomerList"
            let jsonStr = self.appCommon.getSynchronous(url)
            let userList: JSON! = JSON(string: jsonStr!) // JSON読み込み
            appDelegate.selectedUser = userList.enumerated().filter{ $0.element.1["customerID"].asInt! == appDelegate.selectedUser["customerID"].asInt!}.map{ $0.element.1 }.first!
        }
        appDelegate.ChangeCustomerInfo = false
    }
    
    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return columnNameList.count
        return appDelegate.mstCustomerList!.length
    }
    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = (indexPath as NSIndexPath).row
        let mstCustomer: JSON! = appDelegate.mstCustomerList![index]
        let columnName = mstCustomer["columnName"].asString!
        let target = personalInfo.enumerated().filter{ $0.element.1["columnName"].asString! == columnName}.map{ $0.element.1 }.first!
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "MyCell")
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator // 詳細矢印
        cell.textLabel?.text = mstCustomer["itemText"].asString!
        
        var value = target["value"].asString == nil ? "" : target["value"].asString!
        if mstCustomer["inputKb"].asString! == AppConst.InputKB.SINGLE.rawValue && value != "" {
            let list = mstCustomer["itemChoices"].asString!.components(separatedBy: AppConst.ChoiceSeparater)
            let valueList = mstCustomer["itemValues"].asString!.components(separatedBy: AppConst.ChoiceSeparater)
            let valueIndex = valueList.firstIndex(of: value)
            if valueIndex != nil {
                value = String(list[valueIndex!])
            }
        }
        cell.detailTextLabel?.text = value
        
        /*
        let columnName = columnNameList[index] as String
        let target = personalInfo.enumerated().filter{ $0.element.1["columnName"].asString! == columnName}.map{ $0.element.1 }.first!
        
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "MyCell")
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator // 詳細矢印
        cell.textLabel?.text = textList[index] as String
        cell.detailTextLabel?.text = target["value"].asString == nil ? "" : target["value"].asString!
        */
 
        return cell
    }
    
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = (indexPath as NSIndexPath).row
        let mstCustomer: JSON! = appDelegate.mstCustomerList![index]
        let inputKB = mstCustomer["inputKb"].asString!
        let cell = tableView.cellForRow(at: indexPath)
        let columnName = mstCustomer["columnName"].asString!
        let target = personalInfo.enumerated().filter{ $0.element.1["columnName"].asString! == columnName}.map{ $0.element.1 }.first!
        // 選択されたmstAss情報を保存する。
        appDelegate.selectedMstCustomer = mstCustomer
        appDelegate.selectedCustomerValue = target["value"].asString == nil ? "" : target["value"].asString!
        
        // 入力
        if inputKB == AppConst.InputKB.INPUT.rawValue {
            performSegue(withIdentifier: "SegueCustomerInputText",sender: self)
        } else if inputKB == AppConst.InputKB.SINGLE.rawValue {
            performSegue(withIdentifier: "SegueCustomerSelectSingle",sender: self)
        } else if inputKB == AppConst.InputKB.BIRTHDAY.rawValue {
            performSegue(withIdentifier: "SegueCustomerSelectDate",sender: self)
        }

        /*
        if index == 0 {
            // 表示する詳細を設定する
            appDelegate.viewDetailText = personalInfo["lastName"].asString!
            appDelegate.viewDatailUnit = ""
            // 遷移
            performSegue(withIdentifier: "SegueTextInput",sender: self)
        } else if index == 1 {
            // 表示する詳細を設定する
            appDelegate.viewDetailText = personalInfo["firstName"].asString!
            appDelegate.viewDatailUnit = ""
            // 遷移
            performSegue(withIdentifier: "SegueTextInput",sender: self)
        } else if index == 2 {
            // 表示する詳細を設定する
            appDelegate.viewDetailText = personalInfo["sex"].asString!
            // 遷移
            performSegue(withIdentifier: "SegueOneChoice",sender: self)
        } else if index == 3 {
            // 表示する詳細を設定する
            appDelegate.viewDetailText = personalInfo["birthDay"].asString!
            // 遷移
            performSegue(withIdentifier: "SegueDateSelect",sender: self)
        }
        */

        
        //        let cell = tableView.cellForRow(at: indexPath)
        //let index = (indexPath as NSIndexPath).row
        // 選択された利用者情報を保存する。
        //appDelegate.selectedUser = list[index]
        // 遷移
        //performSegue(withIdentifier: "SegueUserMenu",sender: self)
        
    }
}
