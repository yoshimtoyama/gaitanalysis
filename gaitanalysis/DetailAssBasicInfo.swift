//
//  DetailAssBasicInfo.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/04.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit

class DetailAssBasicInfo: UITableViewController {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    var assHD: JSON!
    
    @IBOutlet weak var cellCustomerName: UITableViewCell!
    @IBOutlet weak var cellCustomerBirthDay: UITableViewCell!
    @IBOutlet weak var cellCustomerAge: UITableViewCell!
    @IBOutlet weak var cellCustomerGender: UITableViewCell!
    @IBOutlet weak var cellAssCreateDate: UITableViewCell!
    @IBOutlet weak var cellAssStatus: UITableViewCell!
    @IBOutlet weak var cellAssReportRequestDate: UITableViewCell!
    @IBOutlet weak var cellAssReportCreatedDate: UITableViewCell!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 基本情報を設定
        setBasicInfo()

        onTapViewContoroller()
    }
    
    @objc func clickHelpButton(_ sender: UIBarButtonItem){
        //helpButtonを押した際の処理を記述
        print("clickHelpButton")
        
        // ViewHelp
        let storyboard: UIStoryboard = self.storyboard!
        let helpView = storyboard.instantiateViewController(withIdentifier: "ViewHelp")
        helpView.modalPresentationStyle = .popover
        helpView.popoverPresentationController?.barButtonItem = sender
        helpView.popoverPresentationController?.permittedArrowDirections = .up
        // 矢印の向きを制限する場合
        self.present(helpView, animated: true, completion: nil)
    }
    
    // タブがタップされた時実行される
    func onTapViewContoroller() {
        // 戻るボタン用のタイトル設定（Tabbar直後の画面だけbackになってしまうため)
        navigationController!.navigationBar.topItem!.title = self.navigationItem.title!
        // 右上にボタン追加
        let helpButton = UIBarButtonItem(title: "アセスメント入力方法", style: UIBarButtonItem.Style.plain, target: self, action: #selector(clickHelpButton(_:)))
        navigationController!.navigationBar.topItem!.setRightBarButtonItems([helpButton], animated: true)
    }
    
    func setBasicInfo() {
        cellCustomerName.detailTextLabel?.text = String((appDelegate.selectedUser["customerName"].asString == nil) ? "未設定" : appDelegate.selectedUser["customerName"].asString!)
        cellCustomerBirthDay.detailTextLabel?.text = String((appDelegate.selectedUser["birthDay"].asString == nil) ? "未設定" : appDelegate.selectedUser["birthDay"].asString!)
        cellCustomerAge.detailTextLabel?.text = String((appDelegate.selectedUser["age"].asString == nil) ? "未設定" : appDelegate.selectedUser["age"].asString!)
        cellCustomerGender.detailTextLabel?.text = String((appDelegate.selectedUser["genderString"].asString == nil) ? "未設定" : appDelegate.selectedUser["genderString"].asString!)
        
        // The default timeZone for ISO8601DateFormatter is UTC
        let utcISODateFormatter = ISO8601DateFormatter()
        // Printing a Date
        // Parsing a string timestamp representing a date
        let DateString = appDelegate.selectedAss["createDateTime"].asString!
        let utcDate = utcISODateFormatter.date(from:DateString)
        cellAssCreateDate.detailTextLabel?.text = "\(AppCommon.convertDateStringFromServerDate(fromDateString: utcISODateFormatter.string(from: utcDate!), format: "yyyy-MM-dd"))"
        cellAssStatus.detailTextLabel?.text = AppCommon.getAssStatusString(assStatus: appDelegate.selectedAss["assStatus"].asString!)
        cellAssReportRequestDate.detailTextLabel?.text = appDelegate.selectedAss["reportRequestDate"].asString == nil ? "" : "\(AppCommon.convertDateStringFromServerDate(fromDateString: appDelegate.selectedAss["reportRequestDate"].asString, format: "yyyy-MM-dd"))"
        cellAssReportCreatedDate.detailTextLabel?.text = appDelegate.selectedAss["reportCreatedDate"].asString == nil ? "" : "\(AppCommon.convertDateStringFromServerDate(fromDateString: appDelegate.selectedAss["reportCreatedDate"].asString, format: "yyyy-MM-dd"))"
        
        
    }
}
extension DetailAssBasicInfo: TabBarDelegate {
    func didSelectTab(tabBarController: UITabBarController) {
        onTapViewContoroller()
        tabBarController.tabBarItem.tag = 0
    }
}
