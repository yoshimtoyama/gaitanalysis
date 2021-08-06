//
//  DetailPhotoMovieAssInputList.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/04.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit

class DetailAssInputListPhotoMovie: UITableViewController {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    let assCommon = AssCommon()
    var list: [JSON]!
    var gid: Int?
    var sid1: Int?
    var sid2: Int?
    var flagList: JSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceの設定をする.
        self.tableView.dataSource = self
        
        // Delegateを設定する.
        self.tableView.delegate = self
        
        getMstAssList()
            // 絞り込み
        list = appDelegate.mstAssList!.enumerated().filter{ $0.element.1["assMenuGroupId"].asInt! == 3 }.map{ $0.element.1 }
        getMovieFileInput()
    }
    
    // マスタデータの取得
    func getMstAssList() {
        if appDelegate.mstAssList == nil {
            let url = "\(AppConst.URLPrefix)master/GetAllMstAssessmentList"
            let jsonStr = self.appCommon.getSynchronous(url)
            appDelegate.mstAssList = JSON(string: jsonStr!) // JSON読み込み
        }
    }
    
    // 動画と写真　あり・なしのためデータ取得「Bool Return」
    func getMovieFileInput() {
        let url = "\(AppConst.URLPrefix)ass/GetPhotoMovieFileInput/\(appDelegate.selectedUser["customerID"].asInt!)/\(appDelegate.selectedAss["assId"].asInt!)/"
        let jsonStr = self.appCommon.getSynchronous(url)
        flagList =  JSON(string: jsonStr!)
    }
    
    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        super.viewWillAppear(animated)

    }
    
    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "MyCell")
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator // 詳細矢印
        let index = (indexPath as NSIndexPath).row
        
        let assName = String(list[index]["assName"].asString!)
        
        // 選択されたmstAss情報を保存する。
        appDelegate.selectedMstAss = list[index]
        cell.textLabel?.text = "\(assName)"
        let flag = getInputValue(itemID: index)
        if(flag){cell.detailTextLabel?.text = "あり"}
        else {cell.detailTextLabel?.text = "なし"}
        
        return cell
    }
    
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = (indexPath as NSIndexPath).row
        // 選択されたmstAss情報を保存する。
        appDelegate.selectedMstAss = list[index]
        // assInputKb
        let assInputKb = appDelegate.selectedMstAss["assInputKb"].asString!
        // 遷移
        if assInputKb == AppConst.InputKB.INPUT.rawValue { // 入力
            performSegue(withIdentifier: "SegueTextInput", sender: self)
        } else if assInputKb == AppConst.InputKB.SINGLE.rawValue { // 択一
            performSegue(withIdentifier: "SegueOneChoice", sender: self)
        } else if assInputKb == AppConst.InputKB.MULTI.rawValue { // 複数選択
            performSegue(withIdentifier: "SegueMultiChoice", sender: self)
        } else if assInputKb == AppConst.InputKB.ITAMI.rawValue { // 痛み
            performSegue(withIdentifier: "SegueItami", sender: self)
        } else if assInputKb == AppConst.InputKB.VIDEO.rawValue { // 動画
            activityIndicator("動画取得中")
            DispatchQueue.global(qos: .background).async {
                DispatchQueue.main.async { [self] in
                    effectView.removeFromSuperview()
                    grayOutView.removeFromSuperview()
                    performSegue(withIdentifier: "SegueAssMovie", sender: self)
                }
            }
        } else if assInputKb == AppConst.InputKB.PHOTO.rawValue { // 写真
            activityIndicator("画像取得中")
            DispatchQueue.global(qos: .background).async {
                DispatchQueue.main.async { [self] in
                    effectView.removeFromSuperview()
                    grayOutView.removeFromSuperview()
                    performSegue(withIdentifier: "SegueAssPhoto", sender: self)
                }
            }
        }
    }
    // タブがタップされた時実行される
    func onTapViewContoroller() {
        // 戻るボタン用のタイトル設定（Tabbar直後の画面だけbackになってしまうため)
        navigationController!.navigationBar.topItem!.title = self.navigationItem.title!
    }
    
    func getInputValue(itemID: Int) -> Bool {
        // ロード時に写真があるかどうか確認する
        if(appDelegate.arrMediaList.count == flagList?.length){
            let flitlist = appDelegate.arrMediaList.filter{$0.id == appDelegate.selectedMstAss["assItemId"].asInt! && $0.subGroupID == appDelegate.selectedMstAss["assMenuSubGroupId"].asInt!}
            return flitlist[0].flgSave
        }else{
            if(flagList?.length != 0){
                var IID = itemID + 1
                if(appDelegate.selectedMstAss["assMenuSubGroupId"].asInt! == 2){IID = 1}
                let list = flagList!.enumerated().filter{ $0.element.1["assItemID"].asInt! == IID  && $0.element.1["assMenuSubGroupID"].asInt! == appDelegate.selectedMstAss["assMenuSubGroupId"].asInt! }.map{ $0.element.1["existInput"].asBool }
                for list in list {
                    appDelegate.arrMediaList.insert(AppDelegate.mediaArray(id: appDelegate.selectedMstAss["assItemId"].asInt!, subGroupID: appDelegate.selectedMstAss["assMenuSubGroupId"].asInt!, flgSave: list ?? false), at: 0)
                    return list ?? false
                }
            }
        }
        return false
    }
    
    //Indicator View
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    var grayOutView = UIView()
    func activityIndicator(_ title: String) {
            strLabel.removeFromSuperview()
            activityIndicator.removeFromSuperview()
            effectView.removeFromSuperview()
            strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 150, height: 46))
            strLabel.text = title
            strLabel.font = .systemFont(ofSize: 14, weight: .medium)
            strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
            effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: (view.frame.midY - strLabel.frame.height/2) - 50 , width: 150, height: 46)
            effectView.layer.cornerRadius = 15
            effectView.layer.masksToBounds = true
            activityIndicator = UIActivityIndicatorView(style: .white)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
            activityIndicator.startAnimating()
            effectView.contentView.addSubview(activityIndicator)
            effectView.contentView.addSubview(strLabel)
        grayOutView = UIView(frame: self.view.frame)
        grayOutView.backgroundColor = UIColor.black
        grayOutView.alpha = 0.6
        view.addSubview(grayOutView)
        view.addSubview(effectView)
    }
}
extension DetailAssInputListPhotoMovie: TabBarDelegate {
    
    func didSelectTab(tabBarController: UITabBarController) {
        onTapViewContoroller()
    }
}
