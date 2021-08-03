//
//  DetailViewDetail.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/02.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit

class DetailViewDetail: UIViewController {
    
    @IBOutlet weak var navigationItemTitle: UINavigationItem!
    @IBOutlet weak var textViewDetailText: UITextView!
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItemTitle.title = appDelegate.viewDetailTitle
        textViewDetailText.text = appDelegate.viewDetailText
    }
}
