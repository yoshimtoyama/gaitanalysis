//
//  Setting.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2020/08/31.
//  Copyright © 2020 System. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class Setting: UITableViewController {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    var authUI: FUIAuth { get { return FUIAuth.defaultAuthUI()!}}
    
    let loginInfoItems: NSArray = ["メール", "名前"]
    let logoutItems: NSArray = ["ログアウト"]
    // Sectionで使用する配列を定義する.
    let mySections: NSArray = ["ログイン情報", "ログアウト"]


    override func viewDidLoad() {
        super.viewDidLoad()
        
         // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceの設定をする.
        self.tableView.dataSource = self
        
        // Delegateを設定する.
        self.tableView.delegate = self


    }
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
        
        /*
         セクションの数を返す.
         */
        override func numberOfSections(in tableView: UITableView) -> Int {
            return mySections.count
        }
        
        /*
         セクションのタイトルを返す.
         */
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return mySections[section] as? String
        }
        
        /*
         Cellが選択された際に呼び出される.
         */
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if (indexPath as NSIndexPath).section == 0 {
                print("キャンセル")
            } else if (indexPath as NSIndexPath).section == 1 {
                let alertController = UIAlertController(title: "確認", message: "ログアウトしますか？", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "ログアウト", style: UIAlertAction.Style.default, handler:{
                    // ボタンが押された時の処理を書く（クロージャ実装）
                    (action: UIAlertAction!) -> Void in
                    print("pushed ログアウト Button")
                    // self.authUI.signOut()
                    self.appDelegate.loginUser = nil
                    self.dismiss(animated: true, completion: nil)
                })
                let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                    // ボタンが押された時の処理を書く（クロージャ実装）
                    (action: UIAlertAction!) -> Void in
                    print("Cancel")
                })
                
                // addActionした順に左から右にボタンが配置
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            }
            // 選択を外す
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        /*
         テーブルに表示する配列の総数を返す.
         */
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if section == 0 {
                return loginInfoItems.count
            } else if section == 1 {
                return logoutItems.count
            } else {
                return 0
            }
        }
        
        /*
         Cellに値を設定する.
         */
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if (indexPath as NSIndexPath).section == 0 {
                let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value2, reuseIdentifier: "MyCell")
                cell.textLabel?.text = "\(loginInfoItems[(indexPath as NSIndexPath).row])"
                var name = ""
                if (indexPath as NSIndexPath).row == 0 {
                    name = appDelegate.loginUser!["mailAddress"].asString!
                } else {
                    name = appDelegate.loginUser!["displayName"].asString ?? ""
                }
                cell.detailTextLabel?.text = name
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                
                return cell
            } else if (indexPath as NSIndexPath).section == 1 {
                let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
                cell.textLabel?.text = "\(logoutItems[(indexPath as NSIndexPath).row])"
                cell.selectionStyle = UITableViewCell.SelectionStyle.blue
                cell.textLabel?.textColor = UIColor.red
                return cell
            } else  {
                let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
                return cell
            }
        }
        
    }
