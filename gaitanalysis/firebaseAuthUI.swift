//
//  firebaseAuthUI.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2021/07/06.
//  Copyright © 2021 System. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class firebaseAuthUI: FUIAuthPickerViewController {

    override init(nibName: String?, bundle: Bundle?, authUI: FUIAuth) {
        super.init(nibName: "FUIAuthPickerViewController", bundle: bundle, authUI: authUI)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

    }
    //LogoinPopUpにロゴ追加
    private func setupUI() {
        let scrollView = self.view.subviews[0]
        scrollView.backgroundColor = .clear
        let contentView = scrollView.subviews[0]
        contentView.backgroundColor = .clear
        let logoImagView = UIImageView()
        let image = UIImage(named:"rewalk_logo")!
        logoImagView.frame = CGRect(x: 250, y: 100, width: (image.size.width), height: (image.size.height))
        logoImagView.image = image
        self.view.addSubview(logoImagView)
       }

}
