//
//  DetailAssPhoto.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/04.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit
import AVFoundation

class DetailAssPhoto: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonDelete: UIBarButtonItem!
    @IBOutlet weak var lblnoImage : UILabel!
    

    // 写真アセスメントのリスト
    var trnAssessmentList : JSON?
    // アセスメント入力へボタン
    var isButtonEnable = false
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let assCommon = AssCommon()
    
    // 写真ボタンを入れる
    var subViewButtons : [UIButton] = []
    var returnimage: UIImage?
    // 選択されているSEQNO
    var selectedSeqNo : Int?
    // 画面表示時に写真が1つ以上あるか？
    var existsPhotoOnStart = false
    let selectButton = UIButton(frame: CGRect(x: 0,y: 0,width: 180,height: 50))
    let captureButton = UIButton(frame: CGRect(x: 0,y: 0,width: 180,height: 50))
    let appCommon = AppCommon()
    
    // 画像チェック
    var isopenImagePicker = false
    var pickerImage = UIImage()
    var posts: [picArray] = []
    var indexCount :Int?
    var dbphoto: [JSON]!
    var seqno : Int?
    var btnCount : Int?
    var seqlist : [Int] = []
    var filterList : [picArray] = []
    var forDeleteposts: [picArray] = []
    var deletefilter: [picArray] = []

    var deleteflat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        // Viewの高さと幅を取得する.
        let displayHeight: CGFloat = self.view.frame.height
        // Status Barの高さを取得をする.
        let navBarWidth = self.navigationController?.navigationBar.frame.size.width
        
        // UIボタンを作成.
        selectButton.backgroundColor = UIColor.photoViewButton()
        selectButton.layer.masksToBounds = true
        selectButton.setTitle("写真選択", for: UIControl.State())
        selectButton.layer.cornerRadius = 10.0
        selectButton.layer.position = CGPoint(x: (navBarWidth!/2)+100, y:displayHeight-50)
        selectButton.addTarget(self, action: #selector(DetailAssPhoto.pickImageFromLibrary(_:)), for: .touchUpInside)
        selectButton.setTitleColor(UIColor.gray, for: .highlighted)
        // UIボタンをViewに追加.
        self.view.addSubview(selectButton);
        // UIボタンを作成.
        
        captureButton.backgroundColor = UIColor.photoViewButton()
        captureButton.layer.masksToBounds = true
        captureButton.setTitle("部位撮影", for: UIControl.State())
        captureButton.layer.cornerRadius = 10.0
        captureButton.layer.position = CGPoint(x: (navBarWidth!/2)-100, y:displayHeight-50)
        captureButton.addTarget(self, action: #selector(DetailAssPhoto.ClickCamera(_:)), for: .touchUpInside)
        captureButton.setTitleColor(UIColor.gray, for: .highlighted)
        // UIボタンをViewに追加.
        self.view.addSubview(captureButton);
        
        // ロード時に写真があるかどうか確認する
        appDelegate.photoAssList = assCommon.getInputAssList()
        if(appDelegate.photoAssList!.length != 0){
            lblnoImage.isHidden = true
            // Default seqno
            selectedSeqNo = 0
            //Show Button
            btnCount = appDelegate.photoAssList!.length
            // add post array to photo list
            for i in 0..<appDelegate.photoAssList!.length{
                posts.insert(picArray(id: "\(i)", seqno: (appDelegate.photoAssList![i]["seqno"]).asInt!, name: ""), at: 0)
            }
            if(btnCount == 10){
                selectButton.isEnabled = false
                captureButton.isEnabled = false
                selectButton.backgroundColor = UIColor.systemGray
                captureButton.backgroundColor = UIColor.systemGray
            }
            createButton()
        }
        else{
            btnCount=0
            lblnoImage.isHidden = false
            let row = appDelegate.arrMediaList.firstIndex(where: {$0.id == appDelegate.selectedMstAss["assItemId"].asInt! && $0.subGroupID == appDelegate.selectedMstAss["assMenuSubGroupId"].asInt!})
            appDelegate.arrMediaList[row!].flgSave = false
        }
    }
    
    @objc func backAction(sender: UIBarButtonItem) {

        let alertController = UIAlertController(title: "Are You Sure?", message: "If You Proceed, All Data On This Page Will Be Lost", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (result : UIAlertAction) -> Void in
            self.navigationController?.popViewController(animated: true)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    func activityIndicator(_ title: String) {
            strLabel.removeFromSuperview()
            activityIndicator.removeFromSuperview()
            effectView.removeFromSuperview()
            strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46))
            strLabel.text = title
            strLabel.font = .systemFont(ofSize: 14, weight: .medium)
            strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
            effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 , width: 160, height: 46)
            effectView.layer.cornerRadius = 15
            effectView.layer.masksToBounds = true
        activityIndicator = UIActivityIndicatorView(style: .white)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
            activityIndicator.startAnimating()
            effectView.contentView.addSubview(activityIndicator)
            effectView.contentView.addSubview(strLabel)
        self.view.addSubview(effectView)
    }
    
    // 画像取得する
    func getPhotoAssessmentList()-> UIImage{
        let url = "\(AppConst.URLPrefix)ass/GetAssPhotoFileBase64String/\(appDelegate.selectedUser["customerID"].asInt!)/\(appDelegate.selectedAss["assId"].asInt!)/\(appDelegate.selectedMstAss["assMenuGroupId"].asInt! as AnyObject)/\(appDelegate.selectedMstAss["assMenuSubGroupId"].asInt!)/\(appDelegate.selectedMstAss["assItemId"].asInt!)/\(seqno!)"
        let jsonStr = appCommon.getSynchronous(url)
        if jsonStr != nil {
            let decodedData = NSData(base64Encoded: jsonStr!, options: [])
            if let data = decodedData {
                returnimage = UIImage(data: data as Data)!
                } else {
                    print("error with decodedData")
                }
        } else {
            print("error with base64String")
        }
    
        return returnimage!
    }
    
    func setPhotoList(_seqnoid : Int)  {
        if(isopenImagePicker){
            //選択された画像をArrayで設定
            let tranceImageData:Data = pickerImage.jpegData(compressionQuality: 0.75)!
            let fileString = tranceImageData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
                btnCount = btnCount! + 1
            //DBから取得したデータがない場合
            if !posts.isEmpty{
                posts.insert(picArray(id: "\(btnCount! - 1)", seqno: 0, name: fileString), at: 0)
            }
            else{
                posts.insert(picArray(id: "\(btnCount! - 1)", seqno: 0, name: fileString), at: 0)
            }
        }
        else{
            posts.sort {
                $0.id < $1.id
            }
            //templist.append(image)
            if !posts.isEmpty {
                
                    if(posts[_seqnoid].name.isEmpty){
                            // マスタデータの取得
                        seqno = posts[_seqnoid].seqno
                        let image = getPhotoAssessmentList()
                        let tranceImageData:Data = image.jpegData(compressionQuality: 0.75)!
                        let fileString = tranceImageData.base64EncodedString(options:      NSData.Base64EncodingOptions.lineLength64Characters)
                              //  posts.insert(picArray(id: "\(_seqnoid)", seqno: seqno!, name: fileString), at: 0)
                            if let row = self.posts.firstIndex(where: {$0.seqno == seqno}){
                                posts[row].name = fileString
                            }
                        }
            }
        }
    }
    // ライブラリから写真を選択する
    @objc func pickImageFromLibrary(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerController.SourceType.photoLibrary
            controller.modalPresentationStyle = UIModalPresentationStyle.popover
            controller.popoverPresentationController?.sourceView = self.view
            controller.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            self.present(controller, animated: true, completion: nil)
        }
    }
    // imagePicker popoverの大きさ指定
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
    
    struct picArray: Identifiable {
        var id : String
        var seqno : Int
        var name: String
    }

    
    // 写真を選択した時に呼ばれる
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        lblnoImage.isHidden = true
        if info[.originalImage] != nil {
            pickerImage = info[.originalImage] as! UIImage
            selectedSeqNo = btnCount!
            isopenImagePicker = true
            setPhotoList(_seqnoid: btnCount! )
        }
        createButton()
        picker.dismiss(animated: true, completion: nil)
    }
    
 
    // 画面が表示される都度
    func createButton() {
        // Viewの高さと幅を取得する.
        // Status Barの高さを取得をする.
        let navBarWidth = self.navigationController?.navigationBar.frame.size.width
        
        // 一旦全てのボタンを削除する
        for i in 0 ..< subViewButtons.count {
            subViewButtons[i].removeFromSuperview()
        }
        subViewButtons = [] // 初期化
        //selectedSeqNo = nil
        // 写真ボタンの追加
        let haba : CGFloat = 100 // ボタンを動かす幅
        let centerX : CGFloat = (navBarWidth!/2)
        var x : CGFloat
        var y : CGFloat = imageView.frame.origin.y + imageView.frame.size.height + 50
        
        if (appDelegate.photoAssList!.length != 0 || btnCount != 0 ) {
            for i in 0 ..< btnCount! {
                if i >= 10 {
                    break
                }
               // let trn = templist[i]
                let count = i < 5 ? i : i - 5
                x = 150 + ((CGFloat(count) - 1) * haba)
                // UIボタンを作成.
                let button = UIButton(frame: CGRect(x: 0,y: 0,width: 70,height: 30))
                button.addTarget(self, action: #selector(DetailAssPhoto.onClickPhotoButton(_:)), for: .touchUpInside)
                button.setTitle("写真\(i+1)", for: UIControl.State())
                if i == 0 { // 一つ目が選択状態
                    button.titleLabel!.font = UIFont(name: "Helvetica-Bold",size: CGFloat(20))
                } else {
                    button.titleLabel!.font = UIFont(name: "Helvetica",size: CGFloat(20))
                }
                print(y)
                button.layer.position = CGPoint(x: x, y: y)
                button.setTitleColor(UIColor.textBlue(), for: UIControl.State())
                button.setTitleColor(UIColor.textBlue().withAlphaComponent(0.3), for: .highlighted)
               // button.tag = trn["seqno"].asInt!
                button.tag = i
                // UIボタンをViewに追加.
                self.view.addSubview(button);
                // あとで削除するため保存する
                subViewButtons.append(button)
                if i == 4 { // 次の段
                    y += 50
                }
            }
        }
        if selectedSeqNo != nil {
            // ファイルの取得
            let uiButton = UIButton()
            uiButton.tag = selectedSeqNo!
            onClickPhotoButton(uiButton)
        } else {
            let image = UIImage(named: "noimage.jpg")
            imageView.image = image
            buttonDelete.isEnabled = false
            //buttonAllDelete.isEnabled = false
        }
    }
    /*
     写真ボタンクリックイベント.
     */
    @objc func onClickPhotoButton(_ sender: UIButton) {
        activityIndicator("画像取得")
        self.view.addSubview(effectView)
        print(sender.tag)
        if(!isopenImagePicker){
            selectedSeqNo = sender.tag
            setPhotoList(_seqnoid: selectedSeqNo!)
        }
        // For Array of image
        isopenImagePicker = false
        
        // For Display image in imageview
        indexCount = 0
        
        for i in 0 ..< subViewButtons.count {
            if subViewButtons[i].tag == selectedSeqNo { // 選択状態
                subViewButtons[i].titleLabel!.font = UIFont(name: "Helvetica-Bold",size: CGFloat(20))
            } else {
                subViewButtons[i].titleLabel!.font = UIFont(name: "Helvetica",size: CGFloat(20))
            }
        }
        //assetsの番号を取得
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        
        if(btnCount != 0){
            print(selectedSeqNo as Any)
            DispatchQueue.main.async {
                DispatchQueue.main.async { [self] in
                            self.effectView.removeFromSuperview()
                            let filterpost = self.posts.filter{$0.id.contains(String(selectedSeqNo!)) }
                            let dataDecoded : Data = Data(base64Encoded: filterpost[0].name, options: .ignoreUnknownCharacters)!
                           
                                    // 画面遷移
                            self.imageView.image = UIImage(data: dataDecoded)
                }
            }
        }
        else {
            self.effectView.removeFromSuperview()
            lblnoImage.isHidden = false
            self.imageView.image = nil
            let row = appDelegate.arrMediaList.firstIndex(where: {$0.id == appDelegate.selectedMstAss["assItemId"].asInt! && $0.subGroupID == appDelegate.selectedMstAss["assMenuSubGroupId"].asInt!})
            appDelegate.arrMediaList[row!].flgSave = false
        }
         
        buttonDelete.isEnabled = true
        if (btnCount == 10){
            selectButton.isEnabled = false
            captureButton.isEnabled = false
            selectButton.backgroundColor = UIColor.systemGray
            captureButton.backgroundColor = UIColor.systemGray
        }
    }
    
    // 削除ボタン
    @IBAction func ClickDelete(_ sender: AnyObject) {
        if(btnCount != 0){
            let alertController = UIAlertController(title: "確認", message: "写真を削除しますか？", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "削除", style: UIAlertAction.Style.default, handler:{ [self]
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                deletePhoto()
            })
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("キャンセル")
            })
            
            // addActionした順に左から右にボタンが配置
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }else{
            let alertController = UIAlertController(title: "確認", message: "削除するため画像ありません。", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ [self]
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
            })
            
            // addActionした順に左から右にボタンが配置
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func deletePhoto(){
        deleteflat = 1
        print (selectedSeqNo as Any)
        // filter only delete Data
        deletefilter = posts.filter{$0.id.contains(String(selectedSeqNo!)) }
        if(posts.count != 1 && selectedSeqNo != 0){
                selectedSeqNo = selectedSeqNo! - 1
        }
        
        // filter for not contain delete data
        posts = posts.filter{!$0.id.contains(deletefilter[0].id) }
        
        // check Delete Row is from db
        if deletefilter[0].seqno != 0 {
            // Append for Delete row in DB
            forDeleteposts.append(contentsOf: deletefilter)
        }
        
        for i in 0..<posts.count{
            if(posts[i].id >= deletefilter[0].id){
                posts[i].id = "\(Int(posts[i].id)! - 1)"
            }
        }
        btnCount = btnCount! - 1
        if (btnCount != 10){
            selectButton.isEnabled = true
            captureButton.isEnabled = true
            selectButton.backgroundColor = UIColor.photoViewButton()
            captureButton.backgroundColor = UIColor.photoViewButton()
        }
        createButton()
        
    }
    
    @objc func ClickInputList(_ sender: AnyObject) {
        // 遷移
        performSegue(withIdentifier: "SegueAssInputList",sender: self)
    }
    
    // カメラから写真撮った時の設定
    enum ImageSource {
            case photoLibrary
            case camera
        }
    @objc func ClickCamera(_ sender: AnyObject) {
        
        selectImageFrom(.camera)
    }
    func selectImageFrom(_ source: ImageSource){
           let imagePicker =  UIImagePickerController()
           imagePicker.delegate = self
           switch source {
           case .camera:
               imagePicker.sourceType = .camera
           case .photoLibrary:
               imagePicker.sourceType = .photoLibrary
           }
           present(imagePicker, animated: true, completion: nil)
       }
    /*
     戻る
     */
    override func viewWillDisappear(_ animated: Bool) {
        print("back")
        
        super.viewWillDisappear(animated)
    }
    override func willMove(toParent parent: UIViewController?)
    {
        super.willMove(toParent: parent)
        if parent == nil
        {
            let row = appDelegate.arrMediaList.firstIndex(where: {$0.id == appDelegate.selectedMstAss["assItemId"].asInt! && $0.subGroupID == appDelegate.selectedMstAss["assMenuSubGroupId"].asInt!})
            if(!posts.isEmpty)
            {
                for i in 0..<posts.count{
                    if(posts[i].seqno == 0){
                        appDelegate.arrMediaList[row!].flgSave = true
                        //設定したArrayをDBで保存
                        let url = "\(AppConst.URLPrefix)ass/PostAssPhotoFile"
                        let params: [String: AnyObject] = [
                            "CustomerID": appDelegate.selectedUser["customerID"].asInt! as AnyObject,
                            "AssID": appDelegate.selectedAss["assId"].asInt! as AnyObject,
                            "AssMenuGroupID": appDelegate.selectedMstAss["assMenuGroupId"].asInt! as AnyObject,
                            "AssMenuSubGroupID": appDelegate.selectedMstAss["assMenuSubGroupId"].asInt! as AnyObject,
                            "AssItemID": appDelegate.selectedMstAss["assItemId"].asInt! as AnyObject,
                            "extention": "jpg" as AnyObject,
                            "fileData": posts[i].name as AnyObject,
                            "ImgPartsNo": 0 as AnyObject
                        ]
                        
                        let res = self.appCommon.postSynchronous(url, params: params)

                        if AppCommon.isNilOrEmpty(string: res.err) {
                            // 変更されているのでフラグを更新する
                            appDelegate.ChangeCustomerInfo = true
                        } else {
                            AppCommon.alertMessage(controller: self, title: "登録失敗", message: res.err)
                        }
                    }
                }
            }
            if (forDeleteposts.count != 0){
                for i in forDeleteposts{
                    appDelegate.arrMediaList[row!].flgSave = false
                    let url = "\(AppConst.URLPrefix)ass/DeleteAssessmentDT/\(appDelegate.selectedUser["customerID"].asInt!)/\(appDelegate.selectedAss["assId"].asInt!)/\(appDelegate.selectedMstAss["assMenuGroupId"].asInt!)/\(appDelegate.selectedMstAss["assMenuSubGroupId"].asInt!)/\(appDelegate.selectedMstAss["assItemId"].asInt!)/\(i.seqno)"
                    _ = self.appCommon.deleteSynchronous(url)
                }
            }
        }
    }
    // Schema 画像取得出ないばあい
    @objc func showAlert(){
        // create the alert
        let alert = UIAlertController(title: "保存", message: "画像取得出ませんでした。", preferredStyle: UIAlertController.Style.alert)

                // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
}

