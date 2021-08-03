//
//  AppCommon.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/08/28.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class AppCommon: UIViewController , UIAlertViewDelegate, XMLParserDelegate {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        
    /*
    詳細ページを変更する
    */
    static func changeDetailView(sb:UIStoryboard!, sv:UISplitViewController!, storyBoardID:String!) -> Void {
        // 詳細を変更
        let vc = sb.instantiateViewController(withIdentifier: storyBoardID)
        // NavigationItemを移植
        var item = vc.navigationItem
        if let nc = vc as? UINavigationController {
            item = nc.topViewController!.navigationItem
        }
        
        item.leftBarButtonItem = sv!.displayModeButtonItem
        item.leftItemsSupplementBackButton = true
        
        // ViewControllerを変更
        sv!.showDetailViewController(vc, sender: self)
    }
    
    /*
    施設ログイン
    */
    static func facilityLogin(sv:UISplitViewController!) {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        appDelegate.isFacility = true
        
        let masterNav = sv.viewControllers.first as! UINavigationController
        let master = masterNav.viewControllers.first as! UITableViewController
        master.tableView.reloadData()
        master.title = "施設メニュー"
    }
    /*
    施設ログアウト（個人メニューを表示）
    */
    static func facilityLout(view:UITableViewController!) {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        appDelegate.isFacility = false
        
        view.tableView.reloadData()
        view.title = "メニュー"
    }
    // 概要:リソースファイルの中身を返す
    // 引数:
    //      forResource:ファイル名（拡張子抜き）
    //      ofType:拡張子
    // 戻り値:ファイルの中身（文字列）
    static func getResourceString(forResource:String, ofType:String) -> String {
        let path = Bundle.main.path(forResource: forResource, ofType: ofType)
        let data = NSData(contentsOfFile: path!)
        return String(NSString(data: data! as Data, encoding: String.Encoding.utf8.rawValue)!)
    }
    // 文字列がNilか空白の場合True
    /*
     static func isNilOrEmpty(_ nsstring: NSString?) -> Bool {
     switch nsstring {
     case .some(let nonNilString): return nonNilString.length == 0
     default:                      return true
     }
     }
     */
    static func isNilOrEmpty(string: String?) -> Bool {
        if string == nil {
            return true
        } else {
            let nsString = string as NSString?
            switch nsString {
            case .some(let nonNilString):
                return nonNilString.length == 0
            default:
                return true
            }
        }
    }

    /******************** アラート関連 start ********************/
    // 任意のメッセージを表示
    static func alertMessage(controller : UIViewController, title : String!, message : String!) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) {
            action in NSLog("OKボタンが押されました")
        }
        // addActionした順に左から右にボタンが配置されます
        alertController.addAction(okAction)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    // 任意のアクションを設定
    static func alertAnyAction(controller : UIViewController, title : String!, message : String!, actionList : [(title : String , style : UIAlertAction.Style ,action : (UIAlertAction) -> Void)]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // addActionした順に左から右にボタンが配置されます
        actionList.forEach{
            alertController.addAction(UIAlertAction(title: $0.title, style: $0.style, handler: $0.action))
        }
        controller.present(alertController, animated: true, completion: nil)
    }
    /******************** アラート関連 end ********************/

    // 画像ファイル取得
    static func getImage(_ imagePath : String!) -> UIImage {
        // let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let imageChars = imagePath.components(separatedBy: "/")
        let fileName = imageChars[imageChars.count - 1]
        let image = UIImage(named: fileName)!
        // appDelegate.ImageList.updateValue(image, forKey: imagePath)
        return image
    }
    
    /*
     カメラ起動許可
     */
    static func checkCameraAuthStatus(controller : UIViewController) -> Bool {
        var ret = false
        
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch status {
        case .authorized, .notDetermined:
            ret = true
            break
            
        case .denied:
            self.alertMessage(controller: controller, title: "エラー", message: "カメラへのアクセスが許可されていません。")
            break
            
        case .restricted:
            break
        @unknown default:
            fatalError()
        }
        
        return ret
    }
    
    /*
     マイク起動許可
     */
    static func checkMicrophoneAuthStatus(controller : UIViewController) -> Bool {
        var ret = false
        
        let status = AVAudioSession.sharedInstance().recordPermission
        switch status {
        case AVAudioSessionRecordPermission.granted, AVAudioSessionRecordPermission.undetermined:
            ret = true
            break
            
        case AVAudioSessionRecordPermission.denied:
            self.alertMessage(controller: controller, title: "エラー", message: "マイクへのアクセスが許可されていません。")
            break
            
        default:
            break
        }
        
        return ret
    }
    static func convertDateStringFromServerDate(fromDateString: String!, format: String!) -> NSString {
        var dateStr = fromDateString!
        dateStr = dateStr.replacingOccurrences(of: "T", with: " ", options: [], range: nil)
        dateStr = dateStr.replacingOccurrences(of: "Z", with: "", options: [], range: nil)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: dateStr)
        
        let myDateFormatter: DateFormatter = DateFormatter()
        myDateFormatter.dateFormat = format
        return myDateFormatter.string(from: date!) as NSString
    }
    static func getAssStatusString(assStatus: String!) -> String {
        var reportStatus: String!
        switch (assStatus) {
        case AppConst.ReportCreateKbn.NO.rawValue: // レポート依頼
            reportStatus = "未作成"
        case AppConst.ReportCreateKbn.REQUEST.rawValue://　レポート作成中
            reportStatus = "作成依頼済み"
        case AppConst.ReportCreateKbn.CREATED.rawValue://　歩行レポート
            reportStatus = "作成済み"
        default:
            reportStatus = ""
        }
        return reportStatus
    }
    
    
    // マスタ情報読み込み。ローカルのデータで保持していなかったら、APIより取得する
    func loadMaster() {
        
        
    }
    // GETリクエスト(同期)
    func getSynchronous(_ url: String!) -> String? {
        var isLogout = false
        var isError = false
        var result : String! = nil
        
        let req = NSMutableURLRequest(url: URL(string: url!)!)
        req.httpMethod = "GET"
        if appDelegate.loginUser != nil { // 認証情報がある場合はヘッダーに設定する。
            req.addValue("Bearer \(appDelegate.loginUser!["token"].asString!)", forHTTPHeaderField: AppConst.AuthorizationHeaderKey)
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: req as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            do {
                if error == nil {
                    result = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as String?
                    
                    if (result != nil) {
                        // ログインキーのエラー
                        if let _ = result!.range(of: AppConst.ErrLogin) {
                            isLogout = true
                        }
                    }
                } else {
                    isError = true
                }
            }
            semaphore.signal()
        }).resume()
        semaphore.wait()
        
        //print(result)
        if isLogout {
            let alertController = UIAlertController(title: "エラー", message: "ログイン情報の有効期限切れです\nログアウト後、再度ログインしなおしてください。", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) {
                action in NSLog("OKボタンが押されました")
            }
            // addActionした順に左から右にボタンが配置されます
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            return nil
        } else if isError {
            let alertController = UIAlertController(title: "エラー", message: "情報を取得できませんでした\nインターネット接続を確認して下さい。", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) {
                action in NSLog("OKボタンが押されました")
            }
            // addActionした順に左から右にボタンが配置されます
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            return nil
        }
        
        return result
    }

    // POSTリクエスト（同期）
    func postSynchronous(_ url: String!, params: [String: AnyObject] = [:]) -> (result: String?, err: String?) {
        //var isLogout = false
        //var isError = false
        var result : String! = nil
        var err : String! = nil
        
        let req = NSMutableURLRequest(url: URL(string: url!)!)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        if appDelegate.loginUser != nil { // 認証情報がある場合はヘッダーに設定する。
            req.addValue("Bearer \(appDelegate.loginUser!["token"].asString!)", forHTTPHeaderField: AppConst.AuthorizationHeaderKey)
        }
        if params.count > 0 {
            req.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        } else {
            req.httpBody = nil
        }
        let semaphore = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: req as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            do {
                if error == nil, let data = data, let response = response as? HTTPURLResponse {
                    //let response = response as! HTTPURLResponse
                    //print("response.statusCode = \(response.statusCode)")
                    
                    //result = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String?
                    result = String(data: data, encoding: String.Encoding.utf8) ?? ""
                    if response.statusCode != 200 {
                        err = result.replacingOccurrences(of:"\"", with:"")
                    }
                } else {
                   err = error!.localizedDescription
                }
            }
            semaphore.signal()
        }).resume()
        semaphore.wait()
                
        return (result, err)
    }

    class func dateFromString(string: String, format: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.date(from: string)!
    }

    class func stringFromDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    class func convertDate(date:String) -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
       // date format getting from server
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let date = dateFormatter.date(from: date)!
        print("date is  ---->%@",date)
        //date format you want
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = tempLocale // reset the locale
        let dateString = dateFormatter.string(from: date)
        print("EXACT_DATE : \(dateString)")
        return dateString
     }
   
    func deleteSynchronous(_ url: String!) -> String? {
        var result : String! = nil
        var err : String! = nil
        let req = NSMutableURLRequest(url: URL(string: url!)!)
        req.httpMethod = "DELETE"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        if appDelegate.loginUser != nil { // 認証情報がある場合はヘッダーに設定する。
            req.addValue("Bearer \(appDelegate.loginUser!["token"].asString!)", forHTTPHeaderField: AppConst.AuthorizationHeaderKey)
        }
        
        
        let semaphore = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: req as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            do {
                if error == nil, let data = data, let response = response as? HTTPURLResponse {
                    //let response = response as! HTTPURLResponse
                    //print("response.statusCode = \(response.statusCode)")
                    
                    //result = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String?
                    result = String(data: data, encoding: String.Encoding.utf8) ?? ""
                    if response.statusCode != 200 {
                        err = result.replacingOccurrences(of:"\"", with:"")
                    }
                } else {
                   err = error!.localizedDescription
                }
            }
            semaphore.signal()
        }).resume()
        semaphore.wait()
                
        return (result)
    }
    
    func deleteSyn(_ url: String!) -> String? {
        var isLogout = false
        var isError = false
        var result : String! = nil
        
        let req = NSMutableURLRequest(url: URL(string: url!)!)
        req.httpMethod = "DELETE"
        if appDelegate.loginUser != nil { // 認証情報がある場合はヘッダーに設定する。
            req.addValue("Bearer \(appDelegate.loginUser!["token"].asString!)", forHTTPHeaderField: AppConst.AuthorizationHeaderKey)
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: req as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            do {
                if error == nil {
                    result = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as String?
                    
                    if (result != nil) {
                        // ログインキーのエラー
                        if let _ = result!.range(of: AppConst.ErrLogin) {
                            isLogout = true
                        }
                    }
                } else {
                    isError = true
                }
            }
            semaphore.signal()
        }).resume()
        semaphore.wait()
        
        //print(result)
        if isLogout {
            let alertController = UIAlertController(title: "エラー", message: "ログイン情報の有効期限切れです\nログアウト後、再度ログインしなおしてください。", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) {
                action in NSLog("OKボタンが押されました")
            }
            // addActionした順に左から右にボタンが配置されます
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            return nil
        } else if isError {
            let alertController = UIAlertController(title: "エラー", message: "情報を取得できませんでした\nインターネット接続を確認して下さい。", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) {
                action in NSLog("OKボタンが押されました")
            }
            // addActionした順に左から右にボタンが配置されます
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            return nil
        }
        
        return result
    }
    
     func saveAssessment(controller : UIViewController)-> Bool {
        let assCommon = AssCommon()
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        if appDelegate.changeInputAssFlagForList {
            if(appDelegate.arrChoiceMulti.count != 0){
                for i in 0..<appDelegate.arrChoiceMulti.count{
                    appDelegate.assItemID = appDelegate.arrChoiceMulti[i].id
                    appDelegate.subGroupID = appDelegate.arrChoiceMulti[i].subGroupID
                    if assCommon.regAss(controller: controller, photoFlag: AppConst.Flag.OFF.rawValue, inputArray: appDelegate.arrChoiceMulti[i].multiChoice, commentText: appDelegate.arrChoiceMulti[i].cmtIntput) {
                        print("アセスメント情報保存しました")
                        //appDelegate.changeInputAssFlagForList = fal
                        
                    }
                }
            }
            if(appDelegate.arrChoiceOne.count != 0){
                for i in 0..<appDelegate.arrChoiceOne.count{
                    appDelegate.assItemID = appDelegate.arrChoiceOne[i].id
                    appDelegate.subGroupID = appDelegate.arrChoiceOne[i].subGroupID
                    if (assCommon.regAss(controller: controller, photoFlag: AppConst.Flag.OFF.rawValue, inputArray: appDelegate.arrChoiceOne[i].oneChoice, commentText: appDelegate.arrChoiceOne[i].cmtIntput)) {
                         // 変更されているのでフラグを更新する
                        // appDelegate.changeInputAssFlagForList = false
                     }
                }
            }
            if(appDelegate.arrinputAccText.count != 0){
                for i in 0..<appDelegate.arrinputAccText.count{
                    appDelegate.assItemID = appDelegate.arrinputAccText[i].id
                    appDelegate.subGroupID = appDelegate.arrinputAccText[i].subGroupID
                    //if(appDelegate.arrinputAccText[i].textData.joined() != ""){
                        if (assCommon.regAss(controller: controller, photoFlag: AppConst.Flag.OFF.rawValue, inputArray: appDelegate.arrinputAccText[i].textData, commentText: "")) {
                         // 変更されているのでフラグを更新する
                         ///appDelegate.changeInputAssFlagForList = false
                        }
                    //}
                }
            }
        }
        else if(appDelegate.selectedImagePartsNum != 0){
            if(appDelegate.arrChoiceMulti.count != 0){
                for i in 0..<appDelegate.arrChoiceMulti.count{
                    appDelegate.assItemID = appDelegate.arrChoiceMulti[i].id
                    appDelegate.subGroupID = appDelegate.arrChoiceMulti[i].subGroupID
                    if assCommon.regAss(controller: controller, photoFlag: AppConst.Flag.OFF.rawValue, inputArray: appDelegate.arrChoiceMulti[i].multiChoice, commentText: appDelegate.arrChoiceMulti[i].cmtIntput) {
                        print("Schema情報保存しました")
                    }
                }
            }
            if(appDelegate.arrChoiceOne.count != 0){
                for i in 0..<appDelegate.arrChoiceOne.count{
                    appDelegate.assItemID = appDelegate.arrChoiceOne[i].id
                    appDelegate.subGroupID = appDelegate.arrChoiceOne[i].subGroupID
                    if (assCommon.regAss(controller: controller, photoFlag: AppConst.Flag.OFF.rawValue, inputArray: appDelegate.arrChoiceOne[i].oneChoice, commentText: appDelegate.arrChoiceOne[i].cmtIntput)) {
                         // 変更されているのでフラグを更新する
                        print("Schema情報保存しました")
                     }
                }
            }
            if(appDelegate.arrinputAccText.count != 0){
                
                for i in 0..<appDelegate.arrinputAccText.count{
                    appDelegate.assItemID = appDelegate.arrinputAccText[i].id
                    appDelegate.subGroupID = appDelegate.arrinputAccText[i].subGroupID
                    //if(appDelegate.arrinputAccText[i].textData.joined() != ""){
                        if (assCommon.regAss(controller: controller, photoFlag: AppConst.Flag.OFF.rawValue, inputArray: appDelegate.arrinputAccText[i].textData, commentText: "")) {
                         // 変更されているのでフラグを更新する
                            print("Schema情報保存しました")
                        }
                    //}
                }
            }
        }
        return true;
    }
    
}
