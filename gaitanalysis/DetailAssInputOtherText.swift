//
//  DetailAssInputOtherText.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2021/03/17.
//  Copyright © 2021 System. All rights reserved.
//

import UIKit

protocol DataReturn {
    func returnData(inputData: String)
}

class DetailAssInputOtherText: UIViewController {
    
    @IBOutlet weak var labelOtherText: UILabel!
    @IBOutlet weak var textFieldOtherText: UITextField!
    @IBOutlet weak var navigationTitle: UINavigationBar!
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    var delegate: DataReturn?
    // その他入力
    var otherInputText: String!
    var otherViewText: String!

    
    override func viewWillAppear(_ animated: Bool) {
        // フォーカスを当てる
        textFieldOtherText.becomeFirstResponder()

        // ラベル
        labelOtherText.text = otherViewText
        // テキスト入力
        textFieldOtherText.text = otherInputText
        
        navigationTitle.items?.first?.title = "aaaaaaa"

    }
    
    @IBAction func clickButtonBack(_ sender: Any) {
        delegate?.returnData(inputData: textFieldOtherText.text ?? "")
        // 画面を閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
}
