//
//  DetailTestTab.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/13.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit

class DetailTestTab: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceの設定をする.
        self.tableView.dataSource = self
        
        // Delegateを設定する.
        self.tableView.delegate = self

        
    }

    // タブがタップされた時実行される
    func onTapViewContoroller() {
        // 戻るボタン用のタイトル設定（Tabbar直後の画面だけbackになってしまうため)
        navigationController!.navigationBar.topItem!.title = self.navigationItem.title!
    }

}
extension DetailTestTab: TabBarDelegate {
    
    func didSelectTab(tabBarController: UITabBarController) {
        onTapViewContoroller()
    }
}

