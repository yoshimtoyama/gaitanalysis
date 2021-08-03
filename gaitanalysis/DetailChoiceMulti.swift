//
//  DetailChoiceMulti.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/03.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit

class DetailChoiceMulti: UITableViewController, DataReturn {
    @IBOutlet weak var navigationItemTitle: UINavigationItem!
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    // 初期値
    var firstValues : [String] = []
    var firstComment: String = ""
    // 表示する値の配列.
    var viewList: [String] = []
    // 登録する値の配列.
    var valueList: [String] = []
    // その他入力
    var commentInputFlg: Bool = false
    var commentViewText: String? = ""
    var commentInputText: String = ""
    // 選択された値
    var selectedRows: [IndexPath] = []
    var selectedValues: [String] = []
    // 初期ロード時のみTrue
    var isFirstLoad: Bool = true
    var inputAssList: JSON?
    var btnCancel = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceの設定をする.
        self.tableView.dataSource = self
        
        // Delegateを設定する.
        self.tableView.delegate = self
        
        // タイトル
        navigationItemTitle.title = appDelegate.selectedMstAss["assName"].asString!
        // 複数選択可
        self.tableView.allowsMultipleSelection = true
        // 選択肢取得
        viewList = appDelegate.selectedMstAss["assChoices"].asString!.components(separatedBy: AppConst.ChoiceSeparater)
        valueList = appDelegate.selectedMstAss["assValues"].asString!.components(separatedBy: AppConst.ChoiceSeparater)
        // その他入力
        commentInputFlg = appDelegate.selectedMstAss["commentInputFlg"].asString! == AppConst.Flag.ON.rawValue
        // その他入力のテキスト
        if commentInputFlg {
            commentViewText = viewList[viewList.count - 1]
        }
        // 入力値取得
        let assItemID = appDelegate.selectedMstAss!["assItemId"].asInt!
        let sid = appDelegate.selectedMstAssSubGroup["assMenuSubGroupId"].asInt!
        if(appDelegate.arrChoiceMulti.isEmpty){
            getInputAssList()
            setInputdata()
        }
        else{
            
            let assdata =  appDelegate.arrChoiceMulti.filter{$0.id == assItemID && $0.subGroupID == sid}
            if(assdata.count != 0){
                firstValues.append(contentsOf: assdata[0].multiChoice)
                if(!assdata[0].cmtIntput.isEmpty){
                    firstComment = assdata[0].cmtIntput
                    commentInputText = firstComment
                }
            }else{
                getInputAssList()
                setInputdata()
            }
        }
        
        // 右上にボタン追加
        let cancelButton = UIBarButtonItem(title: "キャンセル", style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancel(_:)))
        navigationItem.setRightBarButton(cancelButton, animated: true)
    }
    
    func setInputdata(){
        if inputAssList!.length > 0 {
            let commentFlg = appDelegate.selectedMstAss!["commentInputFlg"].asString!
            let assItemID = appDelegate.selectedMstAss!["assItemId"].asInt!
            for i in 0 ..< inputAssList!.length {
                // コメント
                if(inputAssList![i]["assMenuGroupId"].asInt == 2 && (commentFlg == "1")){
                    let list = inputAssList!.enumerated().filter{ $0.element.1["assItemId"].asInt! == assItemID }.map{ $0.element.1["assChoicesAsr"].asString }
                    
                    for i in list{
                        let list = viewList.filter{$0.contains(i ?? "") }
                        if (list.isEmpty){
                            firstValues.append(i!)
                            firstComment = i!
                            commentInputText = firstComment
                        }
                        else{
                            let temp = i!
                            firstValues.append(temp)
                        }
                    }
                    break
                }
                else{
                    // コメント以外
                    // Check Come from Schema Gamen
                    if(appDelegate.selectedImagePartsNum == 0 || (appDelegate.selectedImagePartsNum != 0 && appDelegate.selectedImagePartsNum == inputAssList![i]["imgPartsNo"].asInt!)){
                        if assItemID == inputAssList![i]["assItemId"].asInt{
                            let temp = inputAssList![i]["assChoicesAsr"].asString
                            firstValues.append(temp!)
                        }
                    }
                }
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
        return viewList.count
    }
    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = (indexPath as NSIndexPath).row
        let value = String(valueList[index])
        let view = String(viewList[index])
        
        var cell: UITableViewCell
        if commentInputFlg && view == commentViewText { // その他入力の場合
            cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "MyCell")
            cell.textLabel?.text = view
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            /*
            if firstValues.contains(value) {
                cell.isSelected = true
                self.tableView!.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
            */
            cell.detailTextLabel?.text = commentInputText
        } else { // その他入力以外
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
            cell.textLabel?.text = view
            if isFirstLoad && firstValues.contains(value) {
                cell.isSelected = true
                self.tableView!.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                tableView.deselectRow(at: indexPath, animated: true)
                selectedRows.append(indexPath)
            } else if selectedRows.contains(indexPath) {
                cell.isSelected = true
                self.tableView!.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        return cell
    }
    
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        changeCheckStatus(indexPath: indexPath)
    }
    /*
     Cellが選択が外れた際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        changeCheckStatus(indexPath: indexPath)
    }
    
    /*
     戻る
     値が変更されていたら更新する
     */
    override func viewWillDisappear(_ animated: Bool) {
        if(!btnCancel){
            let assCommon = AssCommon()

            if selectedRows.count > 0 || commentInputText != "" { // 選択されている（登録する場合）
                var isAllContains = true
                var inputArray : [String] = []
                for i in 0 ..< selectedRows.count {
                    let choice = valueList[selectedRows[i].row]
                    if !firstValues.contains(choice) {
                        isAllContains = false
                    }
                    inputArray.append(choice)
                }
                if (inputArray.count == 0){
                    inputArray.append("")
                }
                // 数が違うか、要素が違うか、コメント変更されている場合
                if firstValues.count != selectedRows.count || !isAllContains || firstComment != commentInputText  {
                    /*if assCommon.regAss(controller: self, photoFlag: AppConst.Flag.OFF.rawValue, inputArray: inputArray, commentText: commentInputText) {
                        // 変更されているのでフラグを更新する
                        appDelegate.changeInputAssFlagForList = true
                    }*/
                    let row = appDelegate.arrChoiceMulti.firstIndex(where: {$0.id == appDelegate.selectedMstAss["assItemId"].asInt! && $0.subGroupID == appDelegate.selectedMstAss["assMenuSubGroupId"].asInt!})
                    if (row != nil) {
                        appDelegate.arrChoiceMulti[row!].multiChoice = inputArray
                        appDelegate.arrChoiceMulti[row!].cmtIntput = commentInputText 
                            
                    }
                    else{
                        appDelegate.arrChoiceMulti.insert(AppDelegate.assDataArray(id:appDelegate.selectedMstAss["assItemId"].asInt! , subGroupID: appDelegate.selectedMstAss["assMenuSubGroupId"].asInt!,  cmtIntput: commentInputText, multiChoice: inputArray), at: 0)
                        appDelegate.changeInputAssFlagForList = true
                    }
                }
            } else { // 選択されていないため、削除する
                if firstValues.count > 0 || commentInputText != "" {
                    appDelegate.arrChoiceMulti.insert(AppDelegate.assDataArray(id:appDelegate.selectedMstAss["assItemId"].asInt! , subGroupID: appDelegate.selectedMstAss["assMenuSubGroupId"].asInt!,  cmtIntput: "", multiChoice: [] ), at: 0)
                    if (assCommon.delAss(controller: self)) {
                        // 変更されているのでフラグを更新する
                        appDelegate.changeInputAssFlagForList = true
                    }
                }
            }

            super.viewWillDisappear(animated)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueOtherInputFromMulti" {
            let nextVC = segue.destination as! DetailAssInputOtherText
            // 子画面に値を渡す
            nextVC.otherViewText = commentViewText
            nextVC.otherInputText = commentInputText
            nextVC.delegate = self // delegateを登録
        }
    }
    
    func changeCheckStatus(indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        let index = (indexPath as NSIndexPath).row
        let view = String(viewList[index])
        if commentInputFlg && commentViewText == view {
            performSegue(withIdentifier: "SegueOtherInputFromMulti", sender: self)
        } else {
            for i in 0 ..< selectedRows.count {
                tableView.deselectRow(at: selectedRows[i], animated: true)
            }
            
            if selectedRows.contains(indexPath) {
                cell?.accessoryType = UITableViewCell.AccessoryType.none
                cell?.isSelected = false
                selectedRows.removeAll(where: {$0 == indexPath})
            } else {
                cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                cell?.isSelected = true
                selectedRows.append(indexPath)
            }
        }
    }
    func returnData(inputData: String) {
        if commentInputText != inputData {
            // テキストが変更されている場合は保存して、テーブルを再読み込み
            commentInputText = inputData
            isFirstLoad = false // 初回読み込みでは無い
            self.tableView.reloadData()
            print(inputData)
        }
    }
    func getInputAssList() {
        if inputAssList == nil || appDelegate.changeInputAssFlagForList {
            // マスタデータの取得
            let gid = appDelegate.selectedMstAssSubGroup["assMenuGroupId"].asInt!
            let sid = appDelegate.selectedMstAssSubGroup["assMenuSubGroupId"].asInt!
            let url = "\(AppConst.URLPrefix)ass/GetSubGroupAssDTList/\(appDelegate.selectedUser["customerID"].asInt!)/\(appDelegate.selectedAss["assId"].asInt!)/\(gid)/\(sid)"
                let jsonStr = self.appCommon.getSynchronous(url)
                inputAssList = JSON(string: jsonStr!) // JSON読み込み
        }
    }
    @objc func cancel(_ sender: UIBarButtonItem){
        btnCancel = true
        self.navigationController?.popViewController(animated: true)
    }

}
