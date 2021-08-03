//
//  DetailReferralUser.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/05.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit

class DetailReferralUser: UITableViewController {
    @IBOutlet weak var textUserName: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // フォーカスを当てる
        textUserName.becomeFirstResponder()

    }
    @IBAction func clickReferralInfo(_ sender: Any) {
        // 遷移
        performSegue(withIdentifier: "SegueEventDetail",sender: self)
    }
}
