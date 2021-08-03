//
//  DetailFacilityLogin.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/08/28.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit

class DetailFacilityLogin: UIViewController {
    var appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    @IBAction func clickLogin(_ sender: Any) {
        // ログイン
        AppCommon.facilityLogin(sv:splitViewController!)
        // Detailを変更
        AppCommon.changeDetailView(sb: storyboard!, sv: splitViewController!, storyBoardID: "FacilityTop")

    }
    @IBAction func clickRegFaciliry(_ sender: Any) {
        performSegue(withIdentifier: "SegueRegFacility",sender: self)
    }
}
