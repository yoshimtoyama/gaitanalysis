//
//  MasterPersonalMenu.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/08/28.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit

class MasterTopMenu: UITableViewController {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    // Personal利用
    //let personalItems: NSArray = ["利用者情報"]
    let personalUserItems: NSArray = ["利用者一覧"]
    let personalSections: NSArray = ["利用者", "イベント", "施設利用"]
    let personalFacilityItems: NSArray = ["施設利用"]
    // Facility利用
    let facilityUserItems: NSArray = ["利用者一覧"]
    let facilityItems: NSArray = ["ログアウト"]
    let facilitySections: NSArray = ["利用者", "イベント", "施設利用"]
    // 共通利用
    let eventItems: NSArray = ["イベント一覧"]


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceの設定をする.
        self.tableView.dataSource = self
        
        // Delegateを設定する.
        self.tableView.delegate = self
        
    }

    /*
     セクションの数を返す.
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return appDelegate.isFacility ? facilitySections.count : personalSections.count
    }
    
    /*
     セクションのタイトルを返す.
     */
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return appDelegate.isFacility ? facilitySections[section] as? String : personalSections[section] as? String
    }
    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if appDelegate.isFacility { // 施設
            if section == 0 {
                return facilityUserItems.count
            } else if section == 1 {
                return eventItems.count
            } else if section == 2 {
                return facilityItems.count
            } else {
                return 0
            }
        } else { // 個人
            if section == 0 {
                return personalUserItems.count
            } else if section == 1 {
                return eventItems.count
            } else if section == 2 {
                return personalFacilityItems.count
            } else {
                return 0
            }
        }
    }
    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath as NSIndexPath
        let cell: UITableViewCell! = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
        
        if appDelegate.isFacility { // 施設
            if index.section == 0 {
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator // 詳細矢印
                cell.textLabel?.text = "\(facilityUserItems[index.row])"
                return cell
            } else if index.section == 1 {
                cell.textLabel?.text = "\(eventItems[index.row])"
                return cell
            } else if index.section == 2 {
                cell.textLabel?.text = "\(facilityItems[index.row])"
                cell.textLabel?.textColor = UIColor.blue
                return cell
            } else  {
                return cell
            }
        } else { // 個人
            if index.section == 0 {
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator // 詳細矢印
                cell.textLabel?.text = "\(personalUserItems[index.row])"
                return cell
            } else if index.section == 1 {
                cell.textLabel?.text = "\(eventItems[index.row])"
                return cell
            } else if index.section == 2 {
                cell.textLabel?.text = "\(personalFacilityItems[index.row])"
                return cell
            } else  {
                return cell
            }
        }
    }
    
    
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath as NSIndexPath
        if appDelegate.isFacility { // 施設利用
            if index.section == 0 {
                print("利用者一覧")
                // 遷移
                performSegue(withIdentifier: "SegueUserList",sender: self)
                // 詳細を変更
                //AppCommon.changeDetailView(sb: storyboard!, sv: splitViewController!, storyBoardID: "UserList")
                // 詳細を変更
               
                return
                
            } else if index.section == 1 {
                print("イベント一覧")
                // 詳細を変更
                AppCommon.changeDetailView(sb: storyboard!, sv: splitViewController!, storyBoardID: "Event")
                return
            } else if index.section == 2 {
                print("ログアウト")
                
                // アラートアクションの設定
                var actionList = [(title: String , style: UIAlertAction.Style ,action: (UIAlertAction) -> Void)]()
                // キャンセルアクション
                actionList.append(
                    (
                        title: "Cancel",
                        style: UIAlertAction.Style.cancel,
                        action: {
                            (action: UIAlertAction!) -> Void in
                            print("Cancel")
                    })
                )
                // OKアクション
                actionList.append(
                    (
                        title: "OK",
                        style: UIAlertAction.Style.default,
                        action: {
                            (action: UIAlertAction!) -> Void in
                            print("OK")
                            
                            AppCommon.facilityLout(view:self)
                            
                            // 詳細を変更
                            AppCommon.changeDetailView(sb: self.storyboard!, sv: self.splitViewController!, storyBoardID: "Blank")
                    })
                )
                AppCommon.alertAnyAction(controller: self, title: "確認", message: "施設利用を終了しますか？", actionList: actionList)
                
                return
            }
        } else { // 個人利用
            if index.section == 0 {
                print("利用者一覧")
                // 遷移
                performSegue(withIdentifier: "SegueUserList",sender: self)
                AppCommon.changeDetailView(sb: storyboard!, sv: splitViewController!, storyBoardID: "DetailMessage")
                return
            } else if index.section == 1 {
                print("イベント一覧")
                // 詳細を変更
                AppCommon.changeDetailView(sb: storyboard!, sv: splitViewController!, storyBoardID: "Event")
                return
                
            } else if index.section == 2 {
                print("施設利用")
                // 詳細を変更
                AppCommon.changeDetailView(sb: storyboard!, sv: splitViewController!, storyBoardID: "FacilityLogin")
                return
            }
        }
        // 選択を外す
        //self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
