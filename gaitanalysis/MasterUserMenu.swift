//
//  MasterUserMenu.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/02.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit

class MasterUserMenu: UITableViewController {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    let personalItems: NSArray = ["利用者基本情報設定"]
    let assessmentItems: NSArray = ["アセスメント"]
    let sections: NSArray = ["利用者情報", "アセスメント情報"]
    var backButton : UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceの設定をする.
        self.tableView.dataSource = self
        
        // Delegateを設定する.
        self.tableView.delegate = self
        
        // 詳細画面に利用者基本情報表示
        AppCommon.changeDetailView(sb: storyboard!, sv: splitViewController!, storyBoardID: "PersonalInfo")
        
        // Replace the default back button
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.backButton = UIBarButtonItem(title: "利用者一覧", style: UIBarButtonItem.Style.plain, target: self, action: #selector(goBack))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    /*
     セクションの数を返す.
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    /*
     セクションのタイトルを返す.
     */
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section] as? String
    }
    
    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return personalItems.count
        } else if section == 1 {
            return assessmentItems.count
        }else {
            return 0
        }
    }
    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath as NSIndexPath
        if index.section == 0 {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
                        cell.textLabel?.text = "\(personalItems[index.row])"
            return cell
        } else if index.section == 1 {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
            cell.textLabel?.text = "\(assessmentItems[index.row])"
            return cell
        } else  {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
            return cell
        }
    }
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath as NSIndexPath
        if(appDelegate.changeInputAssFlagForList == true){
            showAlert(rowid: index as IndexPath)
        }
        if(appDelegate.changeInputAssFlagForList == false){
            setdataTotable(rowid: index as IndexPath)
        }
    }
    
    func setdataTotable(rowid : IndexPath){
        if rowid.section == 0 {
            print("利用者情入力")
            // 詳細を変更
            AppCommon.changeDetailView(sb: storyboard!, sv: splitViewController!, storyBoardID: "PersonalInfo")
            return
            
        } else if rowid.section == 1 {
            print("アセスメント")
            // 詳細を変更
            AppCommon.changeDetailView(sb: storyboard!, sv: splitViewController!, storyBoardID: "Assessment")
            return
            
        } else if rowid.section == 2 {
            print("紹介")
            // 詳細を変更
            AppCommon.changeDetailView(sb: storyboard!, sv: splitViewController!, storyBoardID: "Referral")
            return
            
        }
    }
    @objc func showAlert(rowid : IndexPath){
        // create the alert
        let alertController = UIAlertController(title: "アセスメント", message: "入力したアセスメント情報を保存しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.default, handler:{ [self]
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            appCommon.saveAssessment(controller: self)
            setdataTotable(rowid: rowid as IndexPath)
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{ [self]
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            
            // Clear Data
            appDelegate.arrChoiceMulti.removeAll()
            appDelegate.arrChoiceOne.removeAll()
            appDelegate.assItemID = nil
            appDelegate.subGroupID = nil
            appDelegate.changeInputAssFlagForList = false
            self.setdataTotable(rowid: rowid as IndexPath)
        })
        // addActionした順に左から右にボタンが配置
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    //戻る機能
    @objc func goBack() {
        // Here we just remove the back button, you could also disabled it or better yet show an activityIndicator
        if(appDelegate.changeInputAssFlagForList == true){
                let alertController = UIAlertController(title: "アセスメント", message: "入力したアセスメント情報を保存しますか？", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.default, handler:{ [self]
                    // ボタンが押された時の処理を書く（クロージャ実装）
                    (action: UIAlertAction!) -> Void in
                    appCommon.saveAssessment(controller: self)
                    navigationController?.popViewController(animated: true)
                })
                let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{ [self]
                    // ボタンが押された時の処理を書く（クロージャ実装）
                    (action: UIAlertAction!) -> Void in
                    
                    // Clear Data
                    appDelegate.arrChoiceMulti.removeAll()
                    appDelegate.arrChoiceOne.removeAll()
                    appDelegate.assItemID = nil
                    appDelegate.subGroupID = nil
                    appDelegate.changeInputAssFlagForList = false
                    navigationController?.popViewController(animated: true)
                })
                // addActionした順に左から右にボタンが配置
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                DispatchQueue.main.async(execute: {
                    self.present(alertController, animated: true)
                    super.viewWillDisappear(false)
                })
            }
        else{
            navigationController?.popViewController(animated: true)
        }
       
    }
}
