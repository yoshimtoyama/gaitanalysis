//
//  DetailAssVideo.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/03.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MobileCoreServices


class DetailAssVideo: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var myContainer: UIView!
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    @IBOutlet weak var buttonDelete: UIBarButtonItem!
    @IBOutlet weak var lblnoVideo : UILabel!
    let assCommon = AssCommon()
    // 再生用のアイテム.
    var playerItem : AVPlayerItem!
    // AVPlayer.
    var videoPlayer : AVPlayer!
    
    // 動画データリスト
    var videoFileList:[JSON?] = []
    
    // 選択中の動画
    var selectedSeqNo:Int?
    
    // 動画切り替えボタン
    var subViewButtons:[UIButton] = []
    var recodVideoString: String?
    let appCommon = AppCommon()
    var forMoviemp4: URL?
    var videolist : JSON?
    var returnVideoItem: Data?
    var VideofromDB = false
    var openPickerView = false
    let selectButton = UIButton(frame: CGRect(x: 0,y: 0,width: 180,height: 50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Viewの高さと幅を取得する.
        let displayHeight: CGFloat = self.view.frame.height
        // Status Barの高さを取得をする.
        let navBarWidth = self.navigationController?.navigationBar.frame.size.width
        
        // UIボタンを作成.
        selectButton.backgroundColor = UIColor.photoViewButton()
        selectButton.layer.masksToBounds = true
        selectButton.setTitle("動画撮影", for: UIControl.State())
        selectButton.layer.cornerRadius = 10.0
        selectButton.layer.position = CGPoint(x: (navBarWidth!/2), y:displayHeight-50)
        selectButton.addTarget(self, action: #selector(self.ClickVideoRec(_:)), for: .touchUpInside)
        selectButton.setTitleColor(UIColor.gray, for: .highlighted)
        // UIボタンをViewに追加.
        self.view.addSubview(selectButton);
        print(self.appDelegate.selectedAss["assId"].asInt!)
        
        videolist = assCommon.getInputAssList()
        print(videolist?.length as Any)
        if(videolist?.length != 0){
            showVideoFromServer()
            VideofromDB = true
            lblnoVideo.isHidden = true
            selectButton.backgroundColor = UIColor.systemGray
            selectButton.isEnabled = false
        }
        activityIndicator("動画保存中")
        self.effectView.isHidden = true
        self.grayOutView.isHidden = true
        
        //play url with your AVPlayer
       /* getMstAssList()
        let gid = appDelegate.selectedMstAssSubGroup["assMenuGroupId"].asInt!
        let sid = appDelegate.selectedMstAssSubGroup["assMenuSubGroupId"].asInt!
        let list = appDelegate.mstAssList!.enumerated().filter{ $0.element.1["assMenuGroupId"].asInt! == gid && $0.element.1["assMenuSubGroupId"].asInt! == sid }.map{ $0.element.1 }*/
        
    }
    
    func showVideoFromServer() {
        let decodeVideoData = getVideoAssessmentList()
        let tmpFileURL = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("video").appendingPathExtension("mp4")
        let wasFileWritten = (try? decodeVideoData.write(to: tmpFileURL, options: [.atomic])) != nil

        if !wasFileWritten{
            print("File was NOT Written")
        }else{
            let avAsset = AVURLAsset(url: tmpFileURL)
            
            // AVPlayerに再生させるアイテムを生成.
            playerItem = AVPlayerItem(asset: avAsset)
            // AVPlayerを生成.
            videoPlayer = AVPlayer(playerItem: playerItem)
            
            let playerViewController = AVPlayerViewController()
            playerViewController.player = videoPlayer
            displayContentController(content: playerViewController, container: myContainer)
        }
    
    }
    
    // 画像取得する
    func getVideoAssessmentList()-> Data{
        // マスタデータの取得
        
        let url = "\(AppConst.URLPrefix)ass/GetAssPhotoFileBase64String/\(appDelegate.selectedUser["customerID"].asInt!)/\(appDelegate.selectedAss["assId"].asInt!)/\(appDelegate.selectedMstAss["assMenuGroupId"].asInt! as AnyObject)/\(appDelegate.selectedMstAss["assMenuSubGroupId"].asInt!)/\(appDelegate.selectedMstAss["assItemId"].asInt!)/\(videolist![0]["seqno"].asInt!)"
        let jsonStr = appCommon.getSynchronous(url)
        if jsonStr != nil {
               returnVideoItem = Data(base64Encoded: jsonStr!)
            }
        return returnVideoItem!
    }
    
    func getMstAssList() {
        if self.appDelegate.mstAssList == nil {
                // マスタデータの取得
            let url = "\(AppConst.URLPrefix)master/GetAllMstAssessmentList"
            let jsonStr = self.appCommon.getSynchronous(url)
            appDelegate.mstAssList = JSON(string: jsonStr!) // JSON読み込み
        }
    }
    override func willMove(toParent parent: UIViewController?)
    {
        super.willMove(toParent: parent)
        if parent == nil
        {
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // DBに登録されている動画を全て取得する
        // 新規登録 or 動画がない場合はnil
        /*if videoFileListJSON != nil && (videoFileListJSON.length)! > 0 {
            videoFileList = (videoFileListJSON.map{ $0.1 })!
        }*/
        
        // 一旦全てのボタンを削除する
       /* subViewButtons.forEach{
            $0.removeFromSuperview()
        }
        subViewButtons = [] // 初期化
        
       // selectedSeqNo = nil
        selectedSeqNo = 0*/
        // 動画ボタンの追加
      /*  if (appDelegate.videoContainerFrameOriginY == nil) {
            appDelegate.videoContainerFrameOriginY = myContainer.frame.origin.y
        }*/
       /* if((videolist!.isNull) ){
            //VideofromDB = showMovie(seq: selectedSeqNo)
            //print(showMovie(seq: selectedSeqNo))
            //print(VideofromDB)
        }*/
    }

     func viewShouldDisappear(_ animated: Bool) {
    
        super.viewWillDisappear(animated)
    }
    
    // 動画撮影に必要なデバイスの使用許可を確認
    @objc func ClickVideoRec(_ sender: AnyObject) {
        // カメラ
        if !AppCommon.checkCameraAuthStatus(controller: self) {
            return
        }
        // マイク
        if !AppCommon.checkMicrophoneAuthStatus(controller: self) {
            return
        }
        
        // 遷移
        //performSegue(withIdentifier: "SegueVideoRecord",sender: self)
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
    }
    /*
     表示する動画を変更
     */
    func showMovie(seq: Int?) -> Bool {
        var isEnabled = false
        
        // 表示対象が存在しない場合代替画像を表示
        if seq == nil {
            let imageView = UIImageView(image: UIImage(named: "noimage.jpg"))
            imageView.frame = myContainer.bounds
            myContainer.addSubview(imageView)
            return isEnabled
        }
        
        // 選択されたら太字
        subViewButtons.forEach{
            $0.titleLabel!.font = UIFont(name: "Helvetica",size: CGFloat(20))
            
            if $0.tag == seq! {
                $0.titleLabel!.font = UIFont(name: "Helvetica-Bold",size: CGFloat(20))
            }
        }
        let asset = NSDataAsset(name: "media1")

        isEnabled = true
        
        // start recording
        let tmpPath = NSTemporaryDirectory()
        // ファイル名.
        let filePath = "\(tmpPath)tmp.mp4"
        // URL.
        let fileURL = URL(fileURLWithPath: filePath)
        
        do {
            try asset!.data.write(to: fileURL)
        } catch let error as NSError {
            print("failed to write: \(error)")
        }
        let avAsset = AVURLAsset(url: fileURL)
        
        // AVPlayerに再生させるアイテムを生成.
        playerItem = AVPlayerItem(asset: avAsset)
        // AVPlayerを生成.
        videoPlayer = AVPlayer(playerItem: playerItem)
        
        let playerViewController = AVPlayerViewController()
        playerViewController.player = videoPlayer
        displayContentController(content: playerViewController, container: myContainer)
        
        //        }
        
        return isEnabled
    }
    func displayContentController(content:UIViewController, container:UIView){
        addChild(content)
        content.view.frame = container.bounds
        container.addSubview(content.view)
    }
    
    // For Record Video and Save DB
    func imagePickerController(
      _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
      dismiss(animated: true, completion: nil)
      guard
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
        mediaType == (kUTTypeMovie as String),
        // 1
        let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
        // 2
        UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
      
        else { return }
        
        // 2
        self.videoPlayer = AVPlayer(url: url)
        let vcPlayer = AVPlayerViewController()
        vcPlayer.player = self.videoPlayer
        displayContentController(content: vcPlayer, container: myContainer)
        openPickerView = true
        forMoviemp4 = url
        lblnoVideo.isHidden = true
        self.effectView.isHidden = false
        self.grayOutView.isHidden = false
        encodeVideo(at: url)
        // Change File type to .MOV to .mp4、DBで動画保存する
    }
/*
    @objc func video(
      _ videoPath: String,
      didFinishSavingWithError error: Error?,
      contextInfo info: AnyObject
    ) {
      let title = (error == nil) ? "Success" : "Error"
      let message = (error == nil) ? "Video was saved" : "Video failed to save"

      let alert = UIAlertController(
        title: title,
        message: message,
        preferredStyle: .alert)
      alert.addAction(UIAlertAction(
        title: "OK",
        style: UIAlertAction.Style.cancel,
        handler: nil))
      present(alert, animated: true, completion: nil)
    }
    
    */
    
    // Don't forget to import AVKit
    func encodeVideo(at videoURL: URL) {
        
        let avAsset = AVURLAsset(url: videoURL, options: nil)
        let startDate = Date()
        //Create Export session
        guard let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough) else {
            return
        }
            
        //Creating temp path to save the converted video
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        let filePath = documentsDirectory.appendingPathComponent("rendered-Video.mp4")
            
        //Check if the file already exists then remove the previous file
        if FileManager.default.fileExists(atPath: filePath.path) {
            do {
                try FileManager.default.removeItem(at: filePath)
            } catch {
                print("")
            }
        }
            
        exportSession.outputURL = filePath
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
        let range = CMTimeRangeMake(start: start, duration: avAsset.duration)
        exportSession.timeRange = range
            
        exportSession.exportAsynchronously(completionHandler: { [self]() -> Void in
            switch exportSession.status {
            case .failed:
                print(exportSession.error ?? "NO ERROR")
            case .cancelled:
                print("Export canceled")
            case .completed:
                //Video conversion finished
                let endDate = Date()
                    
                let time = endDate.timeIntervalSince(startDate)
                print(time)
                print("Successful!")
                print(exportSession.outputURL ?? "NO OUTPUT URL")
                let myMovieData = try? Data(contentsOf: exportSession.outputURL!)
                //print(myMovieData as Any)
                let fileStringString = myMovieData?.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
                let fileString = fileStringString! as NSString
                
                let dbSaveurl = "\(AppConst.URLPrefix)ass/PostAssMovieFile"
                 let params: [String: AnyObject] = [
                    "CustomerID": self.appDelegate.selectedUser["customerID"].asInt! as AnyObject,
                    "AssID": self.appDelegate.selectedAss["assId"].asInt! as AnyObject,
                    "AssMenuGroupID": self.appDelegate.selectedMstAss["assMenuGroupId"].asInt! as AnyObject,
                    "AssMenuSubGroupID": self.appDelegate.selectedMstAss["assMenuSubGroupId"].asInt! as AnyObject,
                    "AssItemID": self.appDelegate.selectedMstAss["assItemId"].asInt! as AnyObject,
                     "extention": "mp4" as AnyObject,
                    "fileData": fileString as AnyObject,
                    "ImgPartsNo": 0 as AnyObject
                 ]
                let res = self.appCommon.postSynchronous(dbSaveurl, params: params)

                if AppCommon.isNilOrEmpty(string: res.err) {
                    // 変更されているのでフラグを更新する
                    self.appDelegate.ChangeCustomerInfo = true
                    let row = appDelegate.arrMediaList.firstIndex(where: {$0.id == appDelegate.selectedMstAss["assItemId"].asInt! && $0.subGroupID == appDelegate.selectedMstAss["assMenuSubGroupId"].asInt!})
                        appDelegate.arrMediaList[row!].flgSave = true
                    print("ok")
                    DispatchQueue.main.async {
                        effectView.isHidden = true
                        grayOutView.isHidden = true
                        selectButton.backgroundColor = UIColor.systemGray
                        selectButton.isEnabled = false
                    }
                } else {
                    AppCommon.alertMessage(controller: self, title: "登録失敗", message: res.err)
                    print ("not ok")
                }
                default: break
            }
                
        })
    }
    // 削除ボタン
    @IBAction func ClickDelete(_ sender: AnyObject) {
        print(VideofromDB)
        print(openPickerView)
        if(VideofromDB == true || openPickerView == true){
            let alertController = UIAlertController(title: "確認", message: "動画を削除しますか？", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "削除", style: UIAlertAction.Style.default, handler:{ [self]
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                deleteMovie()
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
            let alertController = UIAlertController(title: "確認", message: "削除するため動画ありません。", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ [self]
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
        })
        // addActionした順に左から右にボタンが配置
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
    
    func deleteMovie(){
        print (selectedSeqNo as Any)
        activityIndicator("動画削除中")
        self.effectView.isHidden = true
        self.grayOutView.isHidden = true
        if(VideofromDB != true){
            videolist = assCommon.getInputAssList()
        }
            let seqno = videolist![0]["seqno"].asInt!
            let url = "\(AppConst.URLPrefix)ass/DeleteAssessmentDT/\(appDelegate.selectedUser["customerID"].asInt!)/\(appDelegate.selectedAss["assId"].asInt!)/\(appDelegate.selectedMstAss["assMenuGroupId"].asInt!)/\(appDelegate.selectedMstAss["assMenuSubGroupId"].asInt!)/\(appDelegate.selectedMstAss["assItemId"].asInt!)/\(seqno)"
            let result = self.appCommon.deleteSynchronous(url)
        let row = appDelegate.arrMediaList.firstIndex(where: {$0.id == appDelegate.selectedMstAss["assItemId"].asInt! && $0.subGroupID == appDelegate.selectedMstAss["assMenuSubGroupId"].asInt!})
            appDelegate.arrMediaList[row!].flgSave = false
        VideofromDB = false
        openPickerView = false
        lblnoVideo.isHidden = false
        let grayView = UIViewController()
        grayView.view.backgroundColor = UIColor.opaqueSeparator
        displayContentController(content: grayView, container: myContainer)
        DispatchQueue.main.async {
            self.effectView.isHidden = true
            self.grayOutView.isHidden = true
            self.selectButton.backgroundColor = UIColor.photoViewButton()
            self.selectButton.isEnabled = true
        }
    }
    
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    var grayOutView = UIView()
    func activityIndicator(_ title: String) {
            strLabel.removeFromSuperview()
            activityIndicator.removeFromSuperview()
            effectView.removeFromSuperview()
            strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 46))
            strLabel.text = title
            strLabel.font = .systemFont(ofSize: 14, weight: .medium)
            strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
            effectView.frame = CGRect(x: (view.frame.midX - strLabel.frame.width/2) - 100, y: (view.frame.midY - strLabel.frame.height/2)-70 , width: 200, height: 46)
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
        self.view.addSubview(grayOutView)
        self.view.addSubview(effectView)
    }
}
    enum VideoHelper {
        static func startMediaBrowser(
            delegate: UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate,
            sourceType: UIImagePickerController.SourceType
            ) {
                guard UIImagePickerController.isSourceTypeAvailable(sourceType)
                else { return }

        let mediaUI = UIImagePickerController()
            mediaUI.videoQuality = .typeHigh
        mediaUI.sourceType = sourceType
        mediaUI.mediaTypes = [kUTTypeMovie as String]
        mediaUI.allowsEditing = true
        mediaUI.delegate = delegate
        delegate.present(mediaUI, animated: true, completion: nil)
        mediaUI.videoMaximumDuration = 20
    }
        
    
}
