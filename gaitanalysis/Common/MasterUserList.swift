//
//  DetailUserList.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/08/30.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit

class MasterUserList: UITableViewController {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    var list: JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceの設定をする.
        self.tableView.dataSource = self
        
        // Delegateを設定する.
        self.tableView.delegate = self
        
     }
    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // テーブル表示
        getAndViewCustomers()
    }
    func getAndViewCustomers() {
        // 利用者一覧取得
        let url = "\(AppConst.URLPrefix)customer/GetCustomerList"
        let jsonStr = self.appCommon.getSynchronous(url)

        list = JSON(string: jsonStr!) // JSON読み込み

        self.tableView.reloadData()
    }
    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.length
    }
    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "MyCell")
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator // 詳細矢印
        let index = (indexPath as NSIndexPath).row
        
        let userID = String(list[index]["customerID"].asInt!)
        let userName = String((list[index]["customerName"].asString == nil) ? "名前未設定" : list[index]["customerName"].asString!)
        let sex = String(list[index]["genderString"].asString!)
        //let birthDay = String(userList[index]["birthDay"].asString!)
        let age = String(list[index]["age"].asString!)
        //let registerDate = String(userList[index]["registerDate"].asString!)

        cell.textLabel?.text = "\(userName)"
        cell.detailTextLabel?.text = "ID：\(userID) 性別：\(sex) 年齢：\(age)"
        
        return cell
    }
    
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = (indexPath as NSIndexPath).row
        // 選択された利用者情報を保存する。
        appDelegate.selectedUser = list[index]
        // 遷移
        performSegue(withIdentifier: "SegueUserMenu",sender: self)

    }
    /*
     利用者追加クリック
     */
    @IBAction func clickAddCustomer(_ sender: Any) {
        let url = "\(AppConst.URLPrefix)customer/RegCustomer"
        let res = appCommon.postSynchronous(url)
        if AppCommon.isNilOrEmpty(string: res.err) {
            // テーブル表示
            getAndViewCustomers()
            // 更新
            super.viewWillAppear(true)
        } else {
            AppCommon.alertMessage(controller: self, title: "登録失敗", message: res.err)
        }
    }
    
}
