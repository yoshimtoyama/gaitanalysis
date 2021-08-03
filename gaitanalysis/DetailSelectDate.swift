//
//  DetailSelectDate.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/03.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit

class DetailSelectDate: UIViewController {
    @IBOutlet weak var navigationItemTitle: UINavigationItem!
    @IBOutlet weak var datePickerDate: UIDatePicker!
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    override func viewWillAppear(_ animated: Bool) {

        // タイトル
        navigationItemTitle.title = appDelegate.selectedMstAss["assName"].asString!
        
        datePickerDate.maximumDate = Date()
        // デフォルト日付
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        datePickerDate.date = formatter.date(from: appDelegate.viewDetailText)!
    }
}
