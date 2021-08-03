//
//  DetailRegFacility.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/05.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit

class DetailRegFacility: UITableViewController {
    @IBOutlet weak var textFacilityName: UITextField!
    override func viewWillAppear(_ animated: Bool) {
        // フォーカスを当てる
        textFacilityName.becomeFirstResponder()

    }
}
