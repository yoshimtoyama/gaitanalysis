//
//  DetailAssSchema.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/03.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit
import SwiftUI

class DetailAssSchema: UIViewController, UINavigationControllerDelegate{
    
    let isIpad9inches:Bool = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height) <= 1024
    let isIpadPro12:Bool = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height) >= 1366
    
    var imageView: UIImageView!
    
    @IBOutlet weak var slideImageView1: UIImageView!
    @IBOutlet weak var slideImageView2: UIImageView!
    @IBOutlet weak var slideImageView3: UIImageView!
    @IBOutlet weak var slideImageView4: UIImageView!

    
    var touchStart = CGPoint.zero
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    // 削除するためにコントローラを保存する
    var dirButton : [UIButton] = []
    // 現在表示されているシェーマ番号(0はメイン)
    var currentSchemaNum : Int! = 0
    // シェーマがあるか
    var noSchema = false
    // ボタンが表示されているか
    var existsButtonUp = true
    var existsButtonDown = true
    var existsButtonLeft = true
    var existsButtonRight = true
    
    // 対象のアセスメントアイテム
    var currentMstAssessmentList : [JSON] = []
    
    // 対象のイメージパーツ
    var imagePartsList:[JSON] = []
    
    // 削除するためにコントローラを保存する
    var uiButtons : [UIButton] = []
    
     // 初回ロードされた時
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        self.navigationController?.delegate = self
        getMstAssList()
        getImagePartsList()
        getInputAssList()
        print("対象のアセスメント数は　\(currentMstAssessmentList.count)")
        
        
        // シェーマが無い場合は次の画面に飛ばす
        let schemaKb = appDelegate.selectedMstAssSubGroup!["schemaKb"].asString
        // シェーマが無い場合は次の画面に飛ばす
        if schemaKb! == AppConst.SchemaKB.NO_SCHEMA.rawValue {
            performSegue(withIdentifier: "SegueAssInputList",sender: self)
            noSchema = true
            return
        } else {// シェーマがあるばあいはシェーマを設定する
            showSchemaPhoto()
        }
        
        // スワイプ認識.
        let mySwipeUp = UISwipeGestureRecognizer(target: self, action: #selector(DetailAssSchema.swipeUp(_:)))
        let mySwipeDown = UISwipeGestureRecognizer(target: self, action: #selector(DetailAssSchema.swipeDown(_:)))
        let mySwipeRight = UISwipeGestureRecognizer(target: self, action: #selector(DetailAssSchema.swipeRight(_:)))
        let mySwipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(DetailAssSchema.swipeLeft(_:)))
        
        mySwipeUp.direction = UISwipeGestureRecognizer.Direction.up
        mySwipeDown.direction = UISwipeGestureRecognizer.Direction.down
        mySwipeRight.direction = UISwipeGestureRecognizer.Direction.right
        mySwipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        
        self.view.addGestureRecognizer(mySwipeUp)
        self.view.addGestureRecognizer(mySwipeDown)
        self.view.addGestureRecognizer(mySwipeRight)
        self.view.addGestureRecognizer(mySwipeLeft)
        
    }
    
    func getImagePartsList() {
        if appDelegate.assMstImagePartsList == nil {
            // 利用者情報の取得
            let url = //"\(AppConst.URLPrefix)master/GetMstAssessmentSubGroupList/\(AppConst.AssMenuSubGroupID.MONSHIN.rawValue)"
                "\(AppConst.URLPrefix)master/GetAssMstImagePartsList/"
            let jsonStr = self.appCommon.getSynchronous(url)
            appDelegate.assMstImagePartsList = JSON(string: jsonStr!) // JSON読み込み
        }
    }
    
    // Masterデータを取得
    
    func getMstAssList() {
        if appDelegate.mstAssList == nil {
            // マスタデータの取得
            let url = "\(AppConst.URLPrefix)master/GetAllMstAssessmentList"
            let jsonStr = self.appCommon.getSynchronous(url)
            appDelegate.mstAssList = JSON(string: jsonStr!) // JSON読み込み
        }
    }
    
    
    func getInputAssList() {
       // if appDelegate.inputAssList == nil || appDelegate.changeInputAssFlagForList {
            // マスタデータの取得
            let url = "\(AppConst.URLPrefix)ass/GetSubGroupAssDTList/\(appDelegate.selectedUser["customerID"].asInt!)/\(appDelegate.selectedAss["assId"].asInt!)/\(appDelegate.selectedMstAssSubGroup["assMenuGroupId"].asInt!)/\(appDelegate.selectedMstAssSubGroup!["assMenuSubGroupId"].asInt!)"
            let jsonStr = self.appCommon.getSynchronous(url)
            appDelegate.inputAssList = JSON(string: jsonStr!) // JSON読み込み
       // }
    }
    
    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if noSchema {
            return
        }
        if appDelegate.changeInputAssFlagForList == true {
            clearButtons()
            getInputAssList()
            showSchemaPhoto()
            appDelegate.changeInputAssFlagForList = false
        }
    }
    
    //Press backbutton
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)

        if parent == nil {
            appDelegate.selectedImagePartsNum = 0
        }
    }

    
    // DBから画像URLを取得して表示する
    func showSchemaPhoto() {
        // Viewの高さと幅を取得する.
        let displayHeight: CGFloat = self.view.frame.height
        // Status Barの高さを取得をする.
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let navBarHeight = self.navigationController?.navigationBar.frame.size.height
        let navBarWidth = self.navigationController?.navigationBar.frame.size.width
        
        let barHeight = statusBarHeight + navBarHeight!
        // UIImageView
        imageView = UIImageView(frame: CGRect(x: 0, y: barHeight, width: navBarWidth!, height: displayHeight - barHeight))
        // mode
        imageView.contentMode = UIView.ContentMode.scaleToFill
        
        // 入力されているアセスメントを取得する
        // ViewDidloadで取得しているので、変更している場合のみ取得する
        if appDelegate.changeInputAssFlagForList == true {
        //    appDelegate.inputAssList = assCommon.getInputAssList()
          //  appDelegate.changeInputAssFlagForList = false // フラグを戻す
        }
        // 表示する画像を設定する.
        var imagePath : String! = ""
        switch currentSchemaNum
        {
        case 1:
            imagePath = appDelegate.selectedMstAssSubGroup!["imgSchemaPath1"].asString!
            break
        case 2:
            imagePath = appDelegate.selectedMstAssSubGroup!["imgSchemaPath2"].asString!
            break
        case 3:
            imagePath = appDelegate.selectedMstAssSubGroup!["imgSchemaPath3"].asString!
            break
        case 4:
            imagePath = appDelegate.selectedMstAssSubGroup!["imgSchemaPath4"].asString!
            break
        default:
            if(appDelegate.selectedMstAssSubGroup!["imgSchemaMainPath"].isNull){
                showAlert()
            }else{
            imagePath = appDelegate.selectedMstAssSubGroup!["imgSchemaMainPath"].asString!
            }
        }
        if(!imagePath.isEmpty){
            //println(imagePath)
            let url = URL(string:imagePath)!
            do {
                let data = try Data(contentsOf: url)
                    // 取得した画像表示
                imageView.image = UIImage(data: data)
                self.view.addSubview(imageView)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        
        // 対象サブメニューに一致するデータのみ取得
        let assMenuGroupID = appDelegate.selectedMstAssSubGroup!["assMenuGroupId"].asInt!
        let assMenuSubGroupID = appDelegate.selectedMstAssSubGroup!["assMenuSubGroupId"].asInt!
        
        imagePartsList = []
        for i in 0 ..< appDelegate.assMstImagePartsList!.length {
            let imgPartsID = appDelegate.assMstImagePartsList![i]["imgPartsId"].asInt!
            let imgPartsSubID = appDelegate.assMstImagePartsList![i]["imgPartsSubId"].asInt!
            let imgShemaNo = appDelegate.assMstImagePartsList![i]["imgSchemaNo"].asInt
            
            if imgPartsID == assMenuGroupID && imgPartsSubID == assMenuSubGroupID && imgShemaNo == currentSchemaNum {
                imagePartsList.append(appDelegate.assMstImagePartsList![i])
            }
        }
        
        // ボタン配置
        for i in 0 ..< imagePartsList.count {
            let ob = imagePartsList[i]
            
            let button : UIButton = UIButton()
            // ImgPartsNo
            let imgPartsNo = ob["imgPartsNo"].asInt!
            // 大きさ
            let height = ob["imgPartsSizeHeight"].asDouble
            let width = ob["imgPartsSizeWidth"].asDouble
            button.frame = CGRect(x: 0, y: 0, width: CGFloat(width!), height: CGFloat(height!))
            
            //配置場所
            let x = ob["imgPartsLocationX"].asDouble
            let y = ob["imgPartsLocationY"].asDouble
            let getXpercent = 100 / CGFloat(x!)
            let getYpercent = 100 / CGFloat(y!)
            let percentXshow = self.imageView.frame.size.width/getXpercent
            let percentYshow = self.imageView.frame.size.height/getYpercent
            // Screen size<1024
            if isIpad9inches{
                print(self.imageView.frame.size.width)
                button.layer.position = CGPoint(x: CGFloat(percentXshow), y: (percentYshow + barHeight))
            }
            else if isIpadPro12{
                print(self.imageView.frame.size.width)
                //button.layer.position = CGPoint(x: CGFloat(center.x - percentXshow), y: (percentYshow + barHeight))
                button.layer.position = CGPoint(x: CGFloat(percentXshow), y: (percentYshow + barHeight))
                button.layer.frame.size = CGSize(width: CGFloat(width!) + 30, height: CGFloat(height!) + 30)
            }
            print(self.view.center)
            print(button.layer.position)
            
            // 画像(未選択時)
            imagePath = ob["imgPartsSctPath2"].asString!
            button.setBackgroundImage(AppCommon.getImage(imagePath), for: UIControl.State())
            
            // 画像(選択時)
            imagePath = ob["imgPartsSctPath1"].asString!
            button.setBackgroundImage(AppCommon.getImage(imagePath), for: UIControl.State.selected)
            
            // 回転
            let angle = ob["imgPartsLocationAngle"].asDouble
            UIView.animate(withDuration: 0, animations: {
                button.transform = CGAffineTransform.identity.rotated(by: (CGFloat(angle!) * .pi)/180)
                }, completion:nil)
            // タグにインデックスを保存する
            button.tag = i
            // ボタンの状態を決める
            let selected : Bool! = getImagePartsInputAssNum(imgPartsNo, inputAssList: appDelegate.inputAssList)
            
            
            button.isSelected = selected
            
            //ボタンをタップした時に実行するメソッドを指定
            button.addTarget(self, action: #selector(clickShema(_:)), for:.touchUpInside)
            
            //viewにボタンを追加する
            self.view.addSubview(button)
            uiButtons.append(button)
        }
        
        let imgSchemaPath1 = appDelegate.selectedMstAssSubGroup!["imgSchemaPath1"].asString
        let imgSchemaPath2 = appDelegate.selectedMstAssSubGroup!["imgSchemaPath2"].asString
        let imgSchemaPath3 = appDelegate.selectedMstAssSubGroup!["imgSchemaPath3"].asString
        let imgSchemaPath4 = appDelegate.selectedMstAssSubGroup!["imgSchemaPath4"].asString
        
        // 上下左右ボタン表示
        existsButtonUp = false
        existsButtonDown = false
        existsButtonRight = false
        existsButtonLeft = false
        
        if currentSchemaNum == 3 || (currentSchemaNum == 0 && !AppCommon.isNilOrEmpty(string: imgSchemaPath1)) {
            // 上
            existsButtonUp = true
            let imageUp = UIImage(named: "move_up.png")
            let buttonUp : UIButton = UIButton()
            let sizeX : CGFloat = 100
            let sizeY : CGFloat = 40
            buttonUp.frame = CGRect(x: 0,y: 0,width: sizeX,height: sizeY)
            buttonUp.layer.position = CGPoint(x: navBarWidth!/2, y:barHeight + sizeY/2)
            buttonUp.setBackgroundImage(imageUp, for: UIControl.State())
            buttonUp.alpha = 0.5 // 透過
            buttonUp.addTarget(self, action: #selector(clickUp(_:)), for:.touchUpInside)
            self.view.addSubview(buttonUp)
            uiButtons.append(buttonUp)
        }
        if currentSchemaNum == 1 || (currentSchemaNum == 0 && !AppCommon.isNilOrEmpty(string: imgSchemaPath3)) {
            // 下
            existsButtonDown = true
            let imageDown = UIImage(named: "move_down.png")
            let buttonDown : UIButton = UIButton()
            let sizeX : CGFloat = 100
            let sizeY : CGFloat = 40
            buttonDown.frame = CGRect(x: 0,y: 0,width: sizeX,height: sizeY)
            buttonDown.layer.position = CGPoint(x: navBarWidth!/2, y:displayHeight - sizeY/2)
            buttonDown.setBackgroundImage(imageDown, for: UIControl.State())
            buttonDown.alpha = 0.5 // 透過
            buttonDown.addTarget(self, action: #selector(clickDown(_:)), for:.touchUpInside)
            self.view.addSubview(buttonDown)
            uiButtons.append(buttonDown)
        }
        if currentSchemaNum == 4 || (currentSchemaNum == 0 && !AppCommon.isNilOrEmpty(string: imgSchemaPath2)) {
            // 右
            existsButtonRight = true
            let imageRight = UIImage(named: "move_right.png")
            let buttonRight : UIButton = UIButton()
            let sizeX : CGFloat = 40
            let sizeY : CGFloat = 100
            buttonRight.frame = CGRect(x: 0,y: 0,width: sizeX,height: sizeY)
            buttonRight.layer.position = CGPoint(x: navBarWidth! - sizeX/2, y:displayHeight/2)
            buttonRight.setBackgroundImage(imageRight, for: UIControl.State())
            buttonRight.alpha = 0.5 // 透過
            buttonRight.addTarget(self, action: #selector(clickRight(_:)), for:.touchUpInside)
            self.view.addSubview(buttonRight)
            uiButtons.append(buttonRight)
        }
        if currentSchemaNum == 2 || (currentSchemaNum == 0 && !AppCommon.isNilOrEmpty(string: imgSchemaPath4)) {
            // 左
            existsButtonLeft = true
            let imageLeft = UIImage(named: "move_left.png")
            let buttonLeft : UIButton = UIButton()
            let sizeX : CGFloat = 40
            let sizeY : CGFloat = 100
            buttonLeft.frame = CGRect(x: 0,y: 0,width: sizeX,height: sizeY)
            buttonLeft.layer.position = CGPoint(x: 0 + sizeX/2, y:displayHeight/2)
            buttonLeft.setBackgroundImage(imageLeft, for: UIControl.State())
            buttonLeft.alpha = 0.5 // 透過
            buttonLeft.addTarget(self, action: #selector(clickLeft(_:)), for:.touchUpInside)
            self.view.addSubview(buttonLeft)
            uiButtons.append(buttonLeft)
        }
        
    }

    // 対象のイメージパーツで入力アセスメントがあるか？（入力されているか？）
    func getImagePartsInputAssNum(_ imgPartsNo : Int!, inputAssList : JSON?) -> Bool! {
        if (inputAssList == nil) {
            return false
        }
        for i in 0 ..< inputAssList!.length {
            let mstImgPartsNo = inputAssList![i]["imgPartsNo"].asInt
            let mstAssID = appDelegate.inputAssList![i]["assId"].asInt!
            print (mstImgPartsNo as Any)
            // PartsNoが一致するデータのみ比較
            if (mstImgPartsNo == imgPartsNo ) {
                if((appDelegate.inputAssList![i]["assChoicesAsr"].asString != "")  && appDelegate.selectedAss["assId"].asInt! == mstAssID){
                    return true
                }else {return false}
            }
        }
        
        return false
    }
    
    // MARK: - Actions
    
    @IBAction func resetPressed(_ sender: Any) {
        showSchemaPhoto()
        
    }
    
    /*
     スワイプイベント
     */
    @objc func swipeUp(_ sender: UISwipeGestureRecognizer){
        print("swipeUp")
        clickDown(UIButton())
    }
    @objc func swipeDown(_ sender: UISwipeGestureRecognizer){
        print("swipeDown")
        clickUp(UIButton())
    }
    @objc func swipeRight(_ sender: UISwipeGestureRecognizer){
        print("swipeRight")
        clickLeft(UIButton())
    }
    @objc func swipeLeft(_ sender: UISwipeGestureRecognizer){
        print("swipeLeft")
        clickRight(UIButton())
    }
    // 配置したボタンを削除する
    func clearButtons() {
        
        for i in 0 ..< dirButton.count {
            dirButton[i].removeFromSuperview()
        }
        dirButton = []
    }
    @objc func clickUp(_ sender: UIButton) {
        print("clickUp")
        // ボタンが表示されていない場合は処理を行わない
        if !existsButtonUp {
            return
        }
        if (currentSchemaNum == 3) {
            clearButtons()
            currentSchemaNum = 0
            showSchemaPhoto()
        } else if (currentSchemaNum == 0) {
            clearButtons()
            currentSchemaNum = 1
            showSchemaPhoto()
        }
    }
    @objc func clickDown(_ sender: UIButton) {
        print("clickDown")
        // ボタンが表示されていない場合は処理を行わない
        if !existsButtonDown {
            return
        }
        if (currentSchemaNum == 1) {
            clearButtons()
            currentSchemaNum = 0
            showSchemaPhoto()
            
        } else if (currentSchemaNum == 0) {
            clearButtons()
            currentSchemaNum = 3
            showSchemaPhoto()
        }
    }
    @objc func clickRight(_ sender: UIButton) {
        print("clickRight")
        // ボタンが表示されていない場合は処理を行わない
        if !existsButtonRight {
            return
        }
        if (currentSchemaNum == 4) {
            clearButtons()
            currentSchemaNum = 0
            showSchemaPhoto()
        } else if (currentSchemaNum == 0) {
            clearButtons()
            currentSchemaNum = 2
            showSchemaPhoto()
        }
    }
    @objc func clickLeft(_ sender: UIButton) {
        print("clickLeft")
        // ボタンが表示されていない場合は処理を行わない
        if !existsButtonLeft {
            return
        }
        if (currentSchemaNum == 2) {
            clearButtons()
            currentSchemaNum = 0
            showSchemaPhoto()
        } else if (currentSchemaNum == 0) {
            clearButtons()
            currentSchemaNum = 4
            showSchemaPhoto()
        }
    }
    
    // Schema 画像取得出ないばあい
    @objc func showAlert(){
        // create the alert
                let alert = UIAlertController(title: "No Schema", message: "画像取得出ませんでした。", preferredStyle: UIAlertController.Style.alert)

                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                // show the alert
                self.present(alert, animated: true, completion: nil)
    }
    // シェーマのボタンクリックイベント
    @objc func clickShema(_ sender: UIButton) {
        print("tapped")
        // カメラが無い場合は次の画面に飛ばす
        let schemaKb = appDelegate.selectedMstAssSubGroup!["schemaKb"].asString
        let assMenuGroupID = appDelegate.selectedMstAssSubGroup!["assMenuGroupId"].asInt!
        let assMenuSubGroupID = appDelegate.selectedMstAssSubGroup!["assMenuSubGroupId"].asInt!
        let imgPartsNo = imagePartsList[sender.tag]["imgPartsNo"].asInt!
        // imgPartsNo保存
        appDelegate.selectedImagePartsNum = imgPartsNo
        
        if(schemaKb == AppConst.SchemaKB.SINGLE.rawValue || schemaKb == AppConst.SchemaKB.MULTI.rawValue){ // 択一 or 複数
            for i in 0..<appDelegate.mstAssList!.length {
                let mst = appDelegate.mstAssList![i]
                let mstMenuGroupID = mst["assMenuGroupId"].asInt!
                let mstMenuSubGroupID = mst["assMenuSubGroupId"].asInt!
                let imgPartsNo : Int? = mst["imgPartsNo"].asInt
                let assInputKB = mst["assInputKb"].asString!
                
                if mstMenuGroupID == assMenuGroupID && mstMenuSubGroupID == assMenuSubGroupID && AppConst.InputKB.PHOTO.rawValue == assInputKB && imgPartsNo == appDelegate.selectedImagePartsNum {
                    appDelegate.selectedMstAssessmentItem = mst
                    break
                }
            }
        }
        performSegue(withIdentifier: "SegueAssListFromSchema",sender: self)
    }
    
    
}
