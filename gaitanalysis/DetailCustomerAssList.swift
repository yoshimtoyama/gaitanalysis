//
//  DetailUserAssList.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/04.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit

class DetailCustomerAssList: UITableViewController {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    var hdList: JSON!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceの設定をする.
        self.tableView.dataSource = self
        
        // Delegateを設定する.
        self.tableView.delegate = self
        
        // 利用者のアセスメントHDリストを取得する
        getCustomerHDList()
        getMstAssSubGroupList()
    }
    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(appDelegate.arrMediaList.count != 0){
            appDelegate.arrMediaList.removeAll()
        }
    }
    
    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hdList.length
    }
    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "MyCell")
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator // 詳細矢印
        let index = (indexPath as NSIndexPath).row
        cell.textLabel?.text = "\(AppCommon.convertDateStringFromServerDate(fromDateString: hdList[index]["assDate"].asString!, format: "yyyy-MM-dd"))"
        cell.detailTextLabel?.text = "レポート：\(AppCommon.getAssStatusString(assStatus: hdList[index]["assStatus"].asString!))"
        return cell
    }
    
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let cell = tableView.cellForRow(at: indexPath)
        let index = (indexPath as NSIndexPath).row
        // 選択されたアセスメントを保存する。
        appDelegate.selectedAss = hdList[index]
        
        // 遷移
        performSegue(withIdentifier: "SegueAssessment",sender: self)

    }
    
    @IBAction func clickAddAss(_ sender: Any) {
        addCustomerHD()
    }
    
    func getCustomerHDList() {
        // AssHDの取得
        let url = "\(AppConst.URLPrefix)ass/GetAssHDList/\(appDelegate.selectedUser["customerID"].asInt!)"
        let jsonStr = self.appCommon.getSynchronous(url)
        hdList = JSON(string: jsonStr!) // JSON読み込み
    }
    
    func addCustomerHD() {
        // 利用者情報の取得
        let url = "\(AppConst.URLPrefix)ass/RegAssHD"
        let params: [String: AnyObject] = [
            "CustomerID": appDelegate.selectedUser["customerID"].asInt! as AnyObject,
                    ]
        
        let res = appCommon.postSynchronous(url, params:params)
        if AppCommon.isNilOrEmpty(string: res.err) {
            // 登録成功しているのでテーブルを更新する
            getCustomerHDList()
            self.tableView?.reloadData()
        } else {
            AppCommon.alertMessage(controller: self, title: "登録失敗", message: res.err)
        }
    }

    func getMstAssSubGroupList() {
        if appDelegate.mstMonshinAssSubGroupList == nil {
            // 利用者情報の取得
            let url = //"\(AppConst.URLPrefix)master/GetMstAssessmentSubGroupList/\(AppConst.AssMenuSubGroupID.MONSHIN.rawValue)"
                "\(AppConst.URLPrefix)master/GetMstAssessmentSubGroupList/"
            let jsonStr = self.appCommon.getSynchronous(url)
            appDelegate.mstMonshinAssSubGroupList = JSON(string: jsonStr!) // JSON読み込み
        }
    }
}
