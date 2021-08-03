//
//  DetailEventList.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/02.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit

class DetailEventList: UITableViewController {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    var list: JSON!

    // EventList
    var eventList:JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceの設定をする.
        self.tableView.dataSource = self
        
        // Delegateを設定する.
        self.tableView.delegate = self
        
        //DBからデータ取得する
        getMstEventList()
        list = appDelegate.eventList
    }
    
    //EventMasterからデータ取得する
    func getMstEventList() {
        if appDelegate.mstAssList == nil {
            let url = "\(AppConst.URLPrefix)master/GetActiveEventList"
            let jsonStr = self.appCommon.getSynchronous(url)
            if(jsonStr == nil){
                print("No Data")
            }
            else{
                appDelegate.eventList = JSON(string: jsonStr!) // JSON読み込み
            }
        }
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        
        let eventName = String(list[index]["eventName"].asString!)
        let place = String(list[index]["place"].asString!)
        let fromDateTime = String(list[index]["fromDateTime"].asString!)
        
        cell.textLabel?.text = eventName
        
        // The default timeZone for ISO8601DateFormatter is UTC
        let utcISODateFormatter = ISO8601DateFormatter()

        // Parsing a string timestamp representing a date
        let utcDate = utcISODateFormatter.date(from:fromDateTime)
        cell.detailTextLabel?.text = "施設：\(place) 日程：\(AppCommon.convertDateStringFromServerDate(fromDateString: utcISODateFormatter.string(from: utcDate!), format: "yyyy-MM-dd HH:MM"))"
        
        return cell
    }
    
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let cell = tableView.cellForRow(at: indexPath)
        let index = (indexPath as NSIndexPath).row
        // 選択された利用者情報を保存する。
        appDelegate.selectedEvent = list[index]
        // 遷移
        performSegue(withIdentifier: "SegueViewEventItemDetail",sender: self)
        
    }

    
}
