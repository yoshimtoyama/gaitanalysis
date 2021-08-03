//
//  DetailAssItami.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/03.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit

class DetailAssItami: UIViewController {
    @IBOutlet weak var navigationItemTitle: UINavigationItem!
    @IBOutlet weak var labelItamiScale: UILabel!
    @IBOutlet weak var sliderItami: UISlider!
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    override func viewWillAppear(_ animated: Bool) {

        // タイトル
        navigationItemTitle.title = appDelegate.selectedMstAss["assName"].asString!
        
        // テキスト入力
        labelItamiScale.text = "5"
        
    }

    @IBAction func itamiValueChanged(_ sender: Any) {
        let intValue = Int(sliderItami.value)
        labelItamiScale.text = String(intValue)
    }
    @IBAction func clickItami0(_ sender: Any) {
        sliderItami.value = 0
        labelItamiScale.text = "0"
    }
    @IBAction func clickItami10(_ sender: Any) {
        sliderItami.value = 10
        labelItamiScale.text = "10"
    }
}
