//
//  DetailCustomerInputText.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2020/11/20.
//  Copyright © 2020 System. All rights reserved.
//

import UIKit

class DetailCustomerInputText: UIViewController {
    @IBOutlet weak var navigationItemTitle: UINavigationItem!
    @IBOutlet weak var textInput: UITextField!
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    var btnCancel = false
    override func viewDidLoad() {
        super.viewDidLoad()
        // 右上にボタン追加
        let cancelButton = UIBarButtonItem(title: "キャンセル", style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancel(_:)))
        navigationItem.setRightBarButton(cancelButton, animated: true)

    }
    
    @objc func cancel(_ sender: UIBarButtonItem){
        btnCancel = true
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // フォーカスを当てる
        textInput.becomeFirstResponder()
        // タイトル
        navigationItemTitle.title = appDelegate.selectedMstCustomer["itemText"].asString!
        // テキスト入力
        textInput.text = appDelegate.selectedCustomerValue
    }
    
    /*
     戻る
     値が変更されていたら更新する
     */
    override func viewWillDisappear(_ animated: Bool) {
        if(!btnCancel){
            if textInput.text != appDelegate.selectedCustomerValue {
                let url = "\(AppConst.URLPrefix)customer/UpdateCustomerInfo"
                let params: [String: AnyObject] = [
                    "CustomerID": appDelegate.selectedUser["customerID"].asInt! as AnyObject,
                    "ColumnName": appDelegate.selectedMstCustomer["columnName"].asString! as AnyObject,
                    "Value": textInput.text as AnyObject,
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
