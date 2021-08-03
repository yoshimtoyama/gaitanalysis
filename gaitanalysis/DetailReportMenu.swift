//
//  DetailReportMenu.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/04.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit

class DetailReportMenu: UITableViewController {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    
    @IBOutlet weak var cellAssStatus: UITableViewCell!
    @IBOutlet weak var cellAssReportRequestDate: UITableViewCell!
    @IBOutlet weak var cellAssReportCreatedDate: UITableViewCell!
    @IBOutlet weak var btnrequestReport : UIButton!
    @IBOutlet weak var lblrequestReport : UILabel!
    @IBOutlet weak var cellforReportButton: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceの設定をする.
        self.tableView.dataSource = self
        
        // Delegateを設定する.
        self.tableView.delegate = self
        
        if (appDelegate.selectedAss["assStatus"].asString! == "1"){
            lblrequestReport.text = "レポート依頼"
            lblrequestReport.textColor = UIColor.red
        }else if (appDelegate.selectedAss["assStatus"].asString! == "2"){
            lblrequestReport.text = "レポート作成中"
            lblrequestReport.textColor = UIColor.red
        }else if (appDelegate.selectedAss["assStatus"].asString! == "3"){
            lblrequestReport.text = "歩行レポート"
            lblrequestReport.textColor = UIColor.blue
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 基本情報を設定
        setBasicInfo()
    }
    
    func setBasicInfo() {
        
        cellAssStatus.detailTextLabel?.text = AppCommon.getAssStatusString(assStatus: appDelegate.selectedAss["assStatus"].asString!)

        cellAssReportRequestDate.detailTextLabel?.text = appDelegate.selectedAss["reportRequestDate"].asString == nil ? "" : "\(AppCommon.convertDateStringFromServerDate(fromDateString: appDelegate.selectedAss["reportRequestDate"].asString, format: "yyyy-MM-dd"))"
        
        cellAssReportCreatedDate.detailTextLabel?.text = appDelegate.selectedAss["reportCreatedDate"].asString == nil ? "" : "\(AppCommon.convertDateStringFromServerDate(fromDateString: appDelegate.selectedAss["reportCreatedDate"].asString, format: "yyyy-MM-dd"))"
        tableView.reloadData()
    }
    
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath as NSIndexPath
        
        if index.section == 1 {
            // 遷移
            if (appDelegate.selectedAss["assStatus"].asString! == "3"){
                performSegue(withIdentifier: "SegueGaitAnalysisReport",sender: self)
            }
            else if(appDelegate.selectedAss["assStatus"].asString! == "1"){
                showAlert()
            }
            return
        }
        // 選択を外す
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func postReportList() {
        // AssHDの取得
        let url = "\(AppConst.URLPrefix)ass/RequestAssReport"
        let params: [String: AnyObject] = [
            "CustomerID": appDelegate.selectedUser["customerID"].asInt! as AnyObject,
            "AssID": appDelegate.selectedAss["assId"].asInt! as AnyObject]
        
        let res = self.appCommon.postSynchronous(url, params:params)
        if AppCommon.isNilOrEmpty(string: res.err) {
            // 変更されているのでフラグを更新する
            appDelegate.ChangeCustomerInfo = true
        } else {
            AppCommon.alertMessage(controller: self, title: "登録失敗", message: res.err)
        }
    }
    
    
    
    // タブがタップされた時実行される
    func onTapViewContoroller() {
        // 戻るボタン用のタイトル設定（Tabbar直後の画面だけbackになってしまうため)
        navigationController!.navigationBar.topItem!.title = self.navigationItem.title!
    }
    
    func showAlert(){
        let alertController = UIAlertController(title: "確認", message: "レポート依頼しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.default, handler:{ [self]
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            appDelegate.isReportIrai = true
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "いいえ", style: UIAlertAction.Style.cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("いいえ")
        })
        // addActionした順に左から右にボタンが配置
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

}
extension DetailReportMenu: TabBarDelegate {
    
    func didSelectTab(tabBarController: UITabBarController) {
        onTapViewContoroller()
        let tag = tabBarController.tabBarItem.tag
        print(tag)
    }
}
