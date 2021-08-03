//
//  DetailChoiceOne.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/03.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit

class DetailChoiceOne: UITableViewController, DataReturn {
    @IBOutlet weak var navigationItemTitle: UINavigationItem!
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let assCommon = AssCommon()
    // 初期値
    var firstValue : String?
    var firstComment: String = ""
    // 表示する値の配列.
    var viewList: [String] = []
    // 登録する値の配列.
    var valueList: [String] = []
    // その他入力があるか
    var commentInputFlg: Bool = false
    var commentViewText: String? = ""
    var commentInputText: String = ""

    var selectedRow: IndexPath?
    // 初期ロード時のみTrue
    var isFirstLoad: Bool = true
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
        // 選択肢取得
        viewList = appDelegate.selectedMstAss["assChoices"].asString!.components(separatedBy: AppConst.ChoiceSeparater)
        
        valueList = appDelegate.selectedMstAss["assValues"].asString!.components(separatedBy: AppConst.ChoiceSeparater)
        // その他入力
        commentInputFlg = appDelegate.selectedMstAss["commentInputFlg"].asString! == AppConst.Flag.ON.rawValue
        if commentInputFlg {
            commentViewText = viewList[viewList.count - 1]
        }

        // 複数選択不可
        self.tableView.allowsMultipleSelection = false
        
        if(appDelegate.arrChoiceOne.isEmpty){
            setData()
        }else{
            let assItemID = appDelegate.selectedMstAss!["assItemId"].asInt!
            let sid = appDelegate.selectedMstAssSubGroup["assMenuSubGroupId"].asInt!
            let assdata =  appDelegate.arrChoiceOne.filter{$0.id == assItemID && $0.subGroupID == sid}
            if(assdata.count != 0){
                firstValue = assdata[0].oneChoice.first
                if(!assdata[0].cmtIntput.isEmpty){
                    firstComment = assdata[0].cmtIntput
                    commentInputText = firstComment
                }
            }
            else{
                setData()
            }
        }
        
        // 右上にボタン追加
        let cancelButton = UIBarButtonItem(title: "キャンセル", style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancel(_:)))
        navigationItem.setRightBarButton(cancelButton, animated: true)
        
    }
    
    func setData() {
        // 入力値取得
        let inputAss = assCommon.getInputAssList()
        for i in  0 ..<  inputAss.length {
            let imgPartsNo = inputAss[i]["imgPartsNo"].asInt
            if((imgPartsNo) != nil && imgPartsNo != appDelegate.selectedImagePartsNum){
                firstComment = ""
                commentInputText = firstComment
            }else{
                firstValue = inputAss[i]["assChoicesAsr"].asString
                if inputAss[i]["commentFlg"].asString! != AppConst.Flag.ON.rawValue { // コメント以外
                    if((imgPartsNo) != nil && imgPartsNo != appDelegate.selectedImagePartsNum){
                    commentInputText = firstComment
                    }else{
                        firstValue = inputAss[i]["assChoicesAsr"].asString
                    }
                
                } else { // コメントの場合
                    firstComment = inputAss[i]["assChoicesAsr"].asString ?? ""
                    commentInputText = firstComment
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
        //let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
        //cell.selectionStyle = .none
        
        let index = (indexPath as NSIndexPath).row
        
        let value = String(valueList[index])
        let view = String(viewList[index])
        
        var cell: UITableViewCell
        if commentInputFlg && view == commentViewText { // その他入力の場合
            cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "MyCell")
            cell.textLabel?.text = view
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            cell.detailTextLabel?.text = commentInputText
        } else { // その他入力以外
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
            cell.textLabel?.text = view
            if isFirstLoad && firstValue == value {
                cell.isSelected = true
                self.tableView!.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                tableView.deselectRow(at: indexPath, animated: true)
                selectedRow = indexPath
            } else if selectedRow == indexPath {
                cell.isSelected = true
                self.tableView!.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                tableView.deselectRow(at: indexPath, animated: true)
            }
            
            /*
            if value == firstValue {
                cell.isSelected = true
                self.tableView!.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                tableView.deselectRow(at: indexPath, animated: true)
                selectedRow = indexPath
            }
            */
        }

        return cell
    }
    
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
        
        let index = (indexPath as NSIndexPath).row
        let view = String(viewList[index])
        let previousRowIndex = selectedRow
        
        if commentInputFlg && commentViewText == view {
            performSegue(withIdentifier: "SegueOtherInputFromSingle", sender: self)
        } else {
            commentInputText = ""
            if previousRowIndex == nil {
                cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                cell?.isSelected = true
                selectedRow = indexPath
            } else {
                if let previousCell = tableView.cellForRow(at: IndexPath(row: previousRowIndex!.row, section: indexPath.section)) {
                    tableView.deselectRow(at: previousRowIndex!, animated: false)
                    previousCell.accessoryType = .none
                    previousCell.isSelected = false
                    selectedRow = nil
                }
                if previousRowIndex != indexPath {
                    cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                    cell?.isSelected = true
                    selectedRow = indexPath
                 }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueOtherInputFromSingle" {
            let nextVC = segue.destination as! DetailAssInputOtherText
            // 子画面に値を渡す
            nextVC.otherViewText = commentViewText
            nextVC.otherInputText = commentInputText
            nextVC.delegate = self // delegateを登録
        }
    }

    /*
     戻る
     値が変更されていたら更新する
     */
    override func viewWillDisappear(_ animated: Bool) {
        if(!btnCancel){
            let assCommon = AssCommon()
            // 選択されているインデックスを取得する
            //let indexPath = super.tableView?.indexPathForSelectedRow
            if selectedRow != nil || commentInputText != ""  { // 選択されている（登録する場合）
                //let cell = myTableView?.cellForRowAtIndexPath(indexPath!)
                var inputArray : [String] = []
                var value: String = ""
                if selectedRow != nil {
                    value = valueList[selectedRow!.row]
                    inputArray.append(value)
                }
                if value != firstValue || firstComment != commentInputText {
                    var inputArray : [String] = []
                    inputArray.append(value)
                    
                   /* if (assCommon.regAss(controller: self, photoFlag: AppConst.Flag.OFF.rawValue, inputArray: inputArray, commentText: commentInputText)) {
                        // 変更されているのでフラグを更新する
                        appDelegate.changeInputAssFlagForList = true
                    }*/
                    let row = appDelegate.arrChoiceOne.firstIndex(where: {$0.id == appDelegate.selectedMstAss["assItemId"].asInt! && $0.subGroupID == appDelegate.selectedMstAss["assMenuSubGroupId"].asInt!})
                    if (row != nil) {
                        appDelegate.arrChoiceOne[row!].oneChoice = inputArray
                        appDelegate.arrChoiceOne[row!].cmtIntput = commentInputText
                    }
                    else{
                        appDelegate.arrChoiceOne.insert(AppDelegate.assDataOneArray(id: appDelegate.selectedMstAss["assItemId"].asInt! , subGroupID: appDelegate.selectedMstAss["assMenuSubGroupId"].asInt!, oneChoice: inputArray, cmtIntput: commentInputText), at: 0)
                        appDelegate.changeInputAssFlagForList = true
                    }
                    
                }
            } else { // 選択されていないため、削除する
                if !AppCommon.isNilOrEmpty(string: firstValue) {
                    appDelegate.arrChoiceOne.insert(AppDelegate.assDataOneArray(id: appDelegate.selectedMstAss["assItemId"].asInt! , subGroupID: appDelegate.selectedMstAss["assMenuSubGroupId"].asInt!, oneChoice: [], cmtIntput: ""), at: 0)
                    if (assCommon.delAss(controller: self)) {
                        // 変更されているのでフラグを更新する
                        appDelegate.changeInputAssFlagForList = true
                    }
                }
            }
            super.viewWillDisappear(animated)
        }
    }
    
    func returnData(inputData: String) {
        selectedRow = nil // 選択解除
        if commentInputText != inputData {
            // テキストが変更されている場合は保存して、テーブルを再読み込み
            commentInputText = inputData
            isFirstLoad = false // 初回読み込みでは無い
            self.tableView.reloadData()
            print(inputData)
        }
    }
    @objc func cancel(_ sender: UIBarButtonItem){
        btnCancel = true
        self.navigationController?.popViewController(animated: true)
    }

}
