//
//  DetailAssessmentInputList.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/03.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit

class DetailAssInputList: UITableViewController {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    var list: [JSON]!
    var inputAssList: JSON?
    var gid: Int?
    var sid: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // 入力一覧
        inputAssList = appDelegate.inputAssList
        
        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceの設定をする.
        self.tableView.dataSource = self
        
        // Delegateを設定する.
        self.tableView.delegate = self
        
        // 絞り込み
        gid = appDelegate.selectedMstAssSubGroup["assMenuGroupId"].asInt!
        sid = appDelegate.selectedMstAssSubGroup["assMenuSubGroupId"].asInt!
        getInputAssList() // マスタ読み込み
        list = appDelegate.mstAssList!.enumerated().filter{ $0.element.1["assMenuGroupId"].asInt! == gid && $0.element.1["assMenuSubGroupId"].asInt! == sid }.map{ $0.element.1 }
        
    }
    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // テーブル更新
        self.tableView.reloadData()
    }
    
    //戻るとデータ保存機能実行
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        if(appDelegate.goSegument != AppConst.InputKB.INPUT.rawValue && appDelegate.goSegument != AppConst.InputKB.SINGLE.rawValue && appDelegate.goSegument != AppConst.InputKB.MULTI.rawValue && appDelegate.goSegument != AppConst.InputKB.ITAMI.rawValue && appDelegate.goSegument != AppConst.InputKB.HINDO.rawValue &&
            appDelegate.goSegument != AppConst.InputKB.VIDEO.rawValue && appDelegate.goSegument != AppConst.InputKB.PHOTO.rawValue){
            
            //データ保存すること
            let Fsave = self.appCommon.saveAssessment(controller: self)
            // データリセットする
            appDelegate.arrChoiceMulti.removeAll()
            appDelegate.arrChoiceOne.removeAll()
            appDelegate.arrinputAccText.removeAll()
            appDelegate.assItemID = nil
            appDelegate.subGroupID = nil
        }
        else{
            appDelegate.goSegument = nil
        }
    }
    
    //入力されたデータをDTから取得する
    func getInputAssList () {
        // マスタデータの取得
        let url = "\(AppConst.URLPrefix)ass/GetSubGroupAssDTList/\(appDelegate.selectedUser["customerID"].asInt!)/\(appDelegate.selectedAss["assId"].asInt!)/\(gid!)/\(sid!)"
                let jsonStr = self.appCommon.getSynchronous(url)
                inputAssList = JSON(string: jsonStr!) // JSON読み込み
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
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "MyCell")
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator // 詳細矢印
        let index = (indexPath as NSIndexPath).row
        
        let assName = String(list[index]["assName"].asString!)
        let assRequiredFlg = String(list[index]["assRequiredFlg"].asString!)
        // 選択されたmstAss情報を保存する。
        appDelegate.selectedMstAss = list[index]
        let assdata =  appDelegate.arrChoiceMulti.filter{$0.id == list[index]["assItemId"].asInt!}
        let assInputKb = appDelegate.selectedMstAss["assInputKb"].asString!
        cell.textLabel?.text = "\(assName)"
        if(index == 0 && appDelegate.arrChoiceMulti.count != 0){
            if(assdata.count != 0){
                if(assdata[0].cmtIntput != ""){
                    cell.detailTextLabel?.text =  assdata[0].multiChoice.joined(separator: ",") +  assdata[0].cmtIntput
                }else{
                    cell.detailTextLabel?.text =  assdata[0].multiChoice.joined(separator: ",")
                }
            }
            else{
                cell.detailTextLabel?.text = getInputValue(mstAss: list[index])
            }
        }
        else if(index == 1 && appDelegate.arrChoiceMulti.count != 0 && assInputKb == AppConst.InputKB.MULTI.rawValue){
            if(assdata.count != 0){
                let cmtdata = assdata.filter{$0.id == list[index]["assItemId"].asInt! && $0.subGroupID == list[index]["assMenuSubGroupId"].asInt! }
                if(cmtdata.count != 0){
                    if(cmtdata[0].cmtIntput != ""){
                        cell.detailTextLabel?.text =  cmtdata[0].multiChoice.joined(separator: ",")  + "," + cmtdata[0].cmtIntput
                        
                    }else{cell.detailTextLabel?.text =  cmtdata[0].multiChoice.joined(separator: ",")}
                }
            }else{
                cell.detailTextLabel?.text = getInputValue(mstAss: list[index])
            }
        }
        else if (assInputKb == AppConst.InputKB.SINGLE.rawValue){
            let onedata = appDelegate.arrChoiceOne.filter{$0.id == list[index]["assItemId"].asInt!}
            if(onedata.count != 0){
                if(onedata[0].cmtIntput != ""){
                    cell.detailTextLabel?.text = onedata[0].cmtIntput
                }else{
                    cell.detailTextLabel?.text =  onedata[0].oneChoice.joined()
                }
            }
            else{
                cell.detailTextLabel?.text = getInputValue(mstAss: list[index])
            }
        }
        else if(assInputKb == AppConst.InputKB.INPUT.rawValue){
            let inputData = appDelegate.arrinputAccText.filter{$0.id == list[index]["assItemId"].asInt!}
            if(inputData.count != 0){
                cell.detailTextLabel?.text =  inputData[0].textData.joined()
            }else{
                cell.detailTextLabel?.text = getInputValue(mstAss: list[index])
            }
        }
        else{
            cell.detailTextLabel?.text = getInputValue(mstAss: list[index])
        }
        if(cell.detailTextLabel?.text == ""){
            cell.detailTextLabel?.text = "(未入力)"
        }
        if(cell.detailTextLabel?.text == "(未入力)" && assRequiredFlg == "1"){
            let color = UIColor(r: 255, g: 208, b: 215)
            cell.contentView.superview!.backgroundColor = color
        }
        return cell
    }
    
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = (indexPath as NSIndexPath).row
        // 選択されたmstAss情報を保存する。
        appDelegate.selectedMstAss = list[index]
        if(appDelegate.isReportIrai == false){
            // assInputKb
            let assInputKb = appDelegate.selectedMstAss["assInputKb"].asString!
            // 遷移
            appDelegate.goSegument = assInputKb
            if assInputKb == AppConst.InputKB.INPUT.rawValue { // 入力
                performSegue(withIdentifier: "SegueTextInput", sender: self)
            } else if assInputKb == AppConst.InputKB.SINGLE.rawValue { // 択一
                performSegue(withIdentifier: "SegueOneChoice", sender: self)
            } else if assInputKb == AppConst.InputKB.MULTI.rawValue { // 複数選択
                performSegue(withIdentifier: "SegueMultiChoice", sender: self)
            } else if assInputKb == AppConst.InputKB.ITAMI.rawValue { // 痛み
                performSegue(withIdentifier: "SegueItami", sender: self)
            } else if assInputKb == AppConst.InputKB.HINDO.rawValue { // 頻度
                performSegue(withIdentifier: "SegueHindo", sender: self)
            } else if assInputKb == AppConst.InputKB.VIDEO.rawValue { // 動画
                performSegue(withIdentifier: "SegueAssMovie", sender: self)
            } else if assInputKb == AppConst.InputKB.PHOTO.rawValue { // 写真
                performSegue(withIdentifier: "SegueAssPhoto", sender: self)
            }
        }
    }
 
    func getInputValue(mstAss: JSON!) -> String! {
        let assItemID = mstAss["assItemId"].asInt!
        if (inputAssList == nil || inputAssList!.length == 0) {
            return "(未入力)"
        } else {
            if(appDelegate.selectedImagePartsNum == 0){
                let assDTList = inputAssList!.enumerated().filter{ $0.element.1["assMenuGroupId"].asInt! == gid! && $0.element.1["assMenuSubGroupId"].asInt! == sid! && $0.element.1["assItemId"].asInt! == assItemID
                }.map{ $0.element.1["assChoicesAsr"].asString }
                if (assDTList.count == 0) {
                    return "(未入力)"
                } else if (assDTList.count > 1) {
                    var inputs: [String] = []
                    
                    for (_, value) in assDTList.enumerated() {
                        if(!value!.isEmpty){
                            inputs.append(value!)
                        }
                    }
                    return inputs.joined(separator: ",")
                } else {
                    return assDTList.first!
                }
            }else{
                let assDTList = inputAssList!.enumerated().filter{ $0.element.1["assMenuGroupId"].asInt! == gid! && $0.element.1["assMenuSubGroupId"].asInt! == sid! && $0.element.1["assItemId"].asInt! == assItemID &&
                    $0.element.1["imgPartsNo"].asInt! == appDelegate.selectedImagePartsNum
                }.map{ $0.element.1["assChoicesAsr"].asString }
                if (assDTList.count == 0) {
                    return "(未入力)"
                } else if (assDTList.count > 1) {
                    var inputs: [String] = []
                    for (_, value) in assDTList.enumerated() {
                        inputs.append(value!)
                    }
                    return inputs.joined(separator: ",")
                } else {
                    return assDTList.first!
                }
            }
            
        }
    }
}
