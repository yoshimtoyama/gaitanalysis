//
//  SplitViewController.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/08/28.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    convenience init(masterViewController: UITableViewController, detailViewController: UIViewController) {
        self.init()
        viewControllers = [masterViewController, detailViewController]
    }
    var masterViewController: UIViewController? {
        return viewControllers.first
    }
    
    var detailViewController: UIViewController? {
        guard viewControllers.count == 2 else { return nil }
        return viewControllers.last
    }
}
