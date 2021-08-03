//
//  DetailTabbarController.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/04.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit

class DetailTabbarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController is TabBarDelegate {
            let vc = viewController as! TabBarDelegate
            vc.didSelectTab(tabBarController: self)
        }
    }
}
