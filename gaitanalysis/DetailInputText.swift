//
//  DetailInputText.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/02.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit

class DetailInputText: UIViewController {
    @IBOutlet weak var navigationItemTitle: UINavigationItem!
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var labelUnit: UILabel!
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    var btnCancel = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // フォーカスを当てる
        textInput.becomeFirstResponder()
        // タイトル
        navigationItemTitle.title = appDelegate.selectedMstAss["assName"].asString!

        // テキスト入力
        let assCommon = AssCommon()
        if(!appDelegate.arrinputAccText.isEmpty){
            let assItemID = appDelegate.selectedMstAss!["assItemId"].asInt!
            let sid = appDelegate.selectedMstAssSubGroup["assMenuSubGroupId"].asInt!
            let assdata =  appDelegate.arrinputAccText.filter{$0.id == assItemID && $0.subGroupID == sid}
            if(!assdata.isEmpty){
                textInput.text = assdata[0].textData.joined()
            }
            else{
                let inputAss = assCommon.getInputAssList()
                if(inputAss.length != 0){
                    if (inputAss[0]["assChoicesAsr"].asString != "")
                    {textInput.text = inputAss[0]["assChoicesAsr"].asString!}
                }
            }
        }else{
            let inputAss = assCommon.getInputAssList()
            if(inputAss.length != 0){
                if ( inputAss[0]["assChoicesAsr"].asString != "")
                {textInput.text = inputAss[0]["assChoicesAsr"].asString!}
            }
        }
        
        // 右上にボタン追加
        let cancelButton = UIBarButtonItem(title: "キャンセル", style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancel(_:)))
        navigationItem.setRightBarButton(cancelButton, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // AssNameを設定する
        if (!appDelegate.selectedMstAss["assUnit"].isNull){
            let unit = appDelegate.selectedMstAss["assUnit"].asString!
            if !AppCommon.isNilOrEmpty(string: unit) {
                labelUnit.text = "(単位：\(unit))"
            } else {
                labelUnit.text = ""
            }
        }else{labelUnit.text = ""}
    }
    /*
     戻る
     値が変更されていたら更新する
     */
    override func viewWillDisappear(_ animated: Bool) {
        if(!btnCancel){
            //if textInput.text != "" {
                var inputArray : [String] = []
                inputArray.append(textInput.text!)
                let row = appDelegate.arrinputAccText.firstIndex(where: {$0.id == appDelegate.selectedMstAss["assItemId"].asInt! && $0.subGroupID == appDelegate.selectedMstAss["assMenuSubGroupId"].asInt!})
                if (row != nil) {
                    appDelegate.arrinputAccText[row!].textData = inputArray
                    appDelegate.arrinputAccText[row!].cmtIntput = ""
                }
                else{
                    appDelegate.arrinputAccText.insert(AppDelegate.assDataTextArray(id: appDelegate.selectedMstAss["assItemId"].asInt!, subGroupID: appDelegate.selectedMstAss["assMenuSubGroupId"].asInt!, textData: inputArray, cmtIntput: ""), at: 0)
                    appDelegate.changeInputAssFlagForList = true
                }
           // }else{
           //     appDelegate.changeInputAssFlagForList = false
            //}
        }
    }
    @objc func cancel(_ sender: UIBarButtonItem){
        btnCancel = true
        self.navigationController?.popViewController(animated: true)
    }
}
