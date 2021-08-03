//
//  DetailCustomerSelectSingle.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2020/11/24.
//  Copyright © 2020 System. All rights reserved.
//

import UIKit

class DetailCustomerSelectSingle: UITableViewController {
    
    @IBOutlet weak var navigationItemTitle: UINavigationItem!
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    var list: [String] = []
    var valueList: [String] = []
    var firstValue = ""
    var currentValue = ""
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
        navigationItemTitle.title = appDelegate.selectedMstCustomer["itemText"].asString!
        // 複数選択不可
        self.tableView.allowsMultipleSelection = false
        // 選択肢取得
        list = appDelegate.selectedMstCustomer["itemChoices"].asString!.components(separatedBy: AppConst.ChoiceSeparater)
        valueList = appDelegate.selectedMstCustomer["itemValues"].asString!.components(separatedBy: AppConst.ChoiceSeparater)
        // 右上にボタン追加
        let cancelButton = UIBarButtonItem(title: "キャンセル", style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancel(_:)))
        navigationItem.setRightBarButton(cancelButton, animated: true)
    }
    @objc func cancel(_ sender: UIBarButtonItem){
        btnCancel = true
        self.navigationController?.popViewController(animated: true)
    }
    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

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

        let index = (indexPath as NSIndexPath).row
        
        let text = String(list[index])
        let value = String(valueList[index])

        cell.textLabel?.text = text
        
        if value == appDelegate.selectedCustomerValue {
            cell.isSelected = true
            self.tableView!.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        return cell
    }
    
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let index = (indexPath as NSIndexPath).row
        
        // 選択された値を設定
        currentValue = valueList[index]
        
        cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
    }
    /*
     Cellが選択が外れた際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        cell?.accessoryType = UITableViewCell.AccessoryType.none
    }

    
    /*
     戻る
     値が変更されていたら更新する
     */
    override func viewWillDisappear(_ animated: Bool) {
        if(!btnCancel){
            if currentValue != appDelegate.selectedCustomerValue {
                let url = "\(AppConst.URLPrefix)customer/UpdateCustomerInfo"
                let params: [String: AnyObject] = [
                    "CustomerID": appDelegate.selectedUser["customerID"].asInt! as AnyObject,
                    "ColumnName": appDelegate.selectedMstCustomer["columnName"].asString! as AnyObject,
                    "Value": currentValue as AnyObject,
                            ]
                
                let res = appCommon.postSynchronous(url, params:params)
                if AppCommon.isNilOrEmpty(string: res.err) {
                    // 変更されているのでフラグを更新する
                    appDelegate.ChangeCustomerInfo = true
                } else {
                    AppCommon.alertMessage(controller: self, title: "登録失敗", message: res.err)
                }
            }
        }
    }
}
