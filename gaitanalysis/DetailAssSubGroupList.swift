//
//  DetailAssSubGroupList.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/03.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit

class DetailAssSubGroupList: UITableViewController {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    var list: [JSON]!
    var inputList: [JSON]!
    var gid: Int?
    var sid: Int?
    var mstList : [JSON]!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceの設定をする.
        self.tableView.dataSource = self
        
        // Delegateを設定する.
        self.tableView.delegate = self
        
        // Clean Image PartsNum
        // 入力一覧
        gid =  2
        getMstAssList()
        list = appDelegate.mstMonshinAssSubGroupList!.enumerated().filter{ $0.element.1["assMenuGroupId"].asInt! == gid }.map{ $0.element.1 }
        
    }
    func getInputAssList (_ sid: Int) {
            // マスタデータの取得
            let url = "\(AppConst.URLPrefix)ass/GetSubGroupAssDTList/\(appDelegate.selectedUser["customerID"].asInt!)/\(appDelegate.selectedAss["assId"].asInt!)/\(gid!)/\(sid)"
            let jsonStr = self.appCommon.getSynchronous(url)
            appDelegate.inputAssList = JSON(string: jsonStr!) // JSON読み込み
    }
    func getMstAssList() {
        if appDelegate.mstAssList == nil {
            // マスタデータの取得
            let url = "\(AppConst.URLPrefix)master/GetAllMstAssessmentList"
            let jsonStr = self.appCommon.getSynchronous(url)
            appDelegate.mstAssList = JSON(string: jsonStr!) // JSON読み込み
        }
    }
    
    
    
    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Clean Image PartsNum
                // 入力一覧
        
        if appDelegate.changeInputAssFlagForList {
                    // 入力一覧
                   // getInputAssList()
                    // テーブル更新
                    // 画面遷移
                    self.gid =  2
                    self.getMstAssList()
                    self.list = self.appDelegate.mstMonshinAssSubGroupList!.enumerated().filter{ $0.element.1["assMenuGroupId"].asInt! == self.gid }.map{ $0.element.1 }
                    self.tableView.reloadData()
        }
    }
    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator // 詳細矢印
        let index = (indexPath as NSIndexPath).row
        
        let assMenuSubGroupName = String(list[index]["assMenuSubGroupName"].asString!)
        mstList = appDelegate.mstAssList!.enumerated().filter{ $0.element.1["assMenuGroupId"].asInt! == gid && $0.element.1["assMenuSubGroupId"].asInt! == (index+1) }.map{ $0.element.1 }
        if (index == 0 || index == 1){
            getInputAssList(index+1)
            if !getInputValue(index){
                let color = UIColor(r: 255, g: 208, b: 215)
                cell.contentView.superview!.backgroundColor = color
            }
        }
        cell.textLabel?.text = "\(assMenuSubGroupName)"
        return cell
    }
    
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let cell = tableView.cellForRow(at: indexPath)
        let index = (indexPath as NSIndexPath).row
        // 選択されたアセスメントサブグループ情報を保存する。
        appDelegate.selectedMstAssSubGroup = list[index]
        
        let schemaKb = String(list[index]["schemaKb"].asString!)
        getInputAssList (index+1)
        // 遷移
        if schemaKb == AppConst.SchemaKB.MULTI.rawValue { // シェーマ
            performSegue(withIdentifier: "SegueSchema",sender: self)
        } else { // アセスメント一覧
            performSegue(withIdentifier: "SegueAssInputListFromSubGroup",sender: self)
        }
    }
    // タブがタップされた時実行される
    func onTapViewContoroller() {
        // 戻るボタン用のタイトル設定（Tabbar直後の画面だけbackになってしまうため)
    
        navigationController!.navigationBar.topItem!.title = self.navigationItem.title!
    }
    
    func getInputValue(_ id: Int) -> Bool! {
        if (appDelegate.inputAssList == nil || appDelegate.inputAssList!.length == 0) {
                return false
        }
        else{
            for i in mstList{
                let assitemid = i["assItemId"].asInt!
                let assDTList = appDelegate.inputAssList!.enumerated().filter{ $0.element.1["assItemId"].asInt! == assitemid
                }.map{ $0.element.1["assChoicesAsr"].asString }
                print(assDTList)
                if (assDTList .isEmpty || assDTList == [""]){
                    return false
                }
            }
        }
        return true
    }

    
}
extension DetailAssSubGroupList: TabBarDelegate {
    func didSelectTab(tabBarController: UITabBarController) {
        onTapViewContoroller()
    }
}
extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
