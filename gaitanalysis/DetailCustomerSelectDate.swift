//
//  DetailCustomerSelectDate.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2020/11/24.
//  Copyright © 2020 System. All rights reserved.
//

import UIKit

class DetailCustomerSelectDate: UIViewController {
    
    @IBOutlet weak var navigationItemTitle: UINavigationItem!
    @IBOutlet weak var datePickerDate: UIDatePicker!
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    var list: [String] = []
    let appCommon = AppCommon()
    var btnCancel = false

    override func viewDidLoad() {
        super.viewDidLoad()
                
        // タイトル
        navigationItemTitle.title = appDelegate.selectedMstCustomer["itemText"].asString!
        
        let day = Date()
        datePickerDate.maximumDate = day
        datePickerDate.minimumDate = Calendar.current.date(byAdding: .year, value: -150, to: day)!
        
        // デフォルト日付
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        
        if appDelegate.selectedCustomerValue != "" {
            datePickerDate.date = formatter.date(from: appDelegate.selectedCustomerValue)!
        } else {
            let day = Date()
            datePickerDate.date = Calendar.current.date(byAdding: .year, value: -20, to: day)! // 30歳をデフォルト
        }
        // 右上にボタン追加
        let cancelButton = UIBarButtonItem(title: "キャンセル", style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancel(_:)))
        navigationItem.setRightBarButton(cancelButton, animated: true)

    }
    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    /*
     戻る
     値が変更されていたら更新する
     */
    override func viewWillDisappear(_ animated: Bool) {
        if(!btnCancel){
            let dateStr = AppCommon.stringFromDate(date: datePickerDate.date, format: "yyyy-MM-dd")
            if dateStr != appDelegate.selectedCustomerValue {
                let url = "\(AppConst.URLPrefix)customer/UpdateCustomerInfo"
                let params: [String: AnyObject] = [
                    "CustomerID": appDelegate.selectedUser["customerID"].asInt! as AnyObject,
                    "ColumnName": appDelegate.selectedMstCustomer["columnName"].asString! as AnyObject,
                    "Value": dateStr as AnyObject,
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
    
    
    @objc func cancel(_ sender: UIBarButtonItem){
        btnCancel = true
        self.navigationController?.popViewController(animated: true)
    }
}
