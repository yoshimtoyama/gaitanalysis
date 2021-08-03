//
//  DetailCameraViewController.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/04.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit
import AVFoundation

class DetailCameraViewController: UIViewController, AVCapturePhotoCaptureDelegate{
    // セッション
    var mySession : AVCaptureSession!
    // デバイス
    var myDevice : AVCaptureDevice!
    // 画像のアウトプット
    var myImageOutput : AVCapturePhotoOutput!
    // 対象のアセスメント
    var assMster : JSON?
    // 画像表示のレイヤー
    var myVideoLayer : AVCaptureVideoPreviewLayer!
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    
    override var shouldAutorotate : Bool{
        return true
    }
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // セッションの作成.
        mySession = AVCaptureSession()
        // 出力先を生成.
        myImageOutput = AVCapturePhotoOutput()
        
        
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: device!)
            if (mySession.canAddInput(input)) {
                mySession.addInput(input)
                if (mySession.canAddOutput(myImageOutput)) {
                    mySession.addOutput(myImageOutput)
                    mySession.startRunning()
                    myVideoLayer = AVCaptureVideoPreviewLayer(session: mySession)
                    myVideoLayer.frame = self.view.bounds
                    // 回転させる
                    switch UIApplication.shared.statusBarOrientation {
                    case .landscapeLeft:
                        myVideoLayer.connection?.videoOrientation = .landscapeLeft
                    case .landscapeRight:
                        myVideoLayer.connection?.videoOrientation = .landscapeRight
                    case .portrait:
                        myVideoLayer.connection?.videoOrientation = .portrait
                    case .portraitUpsideDown:
                        myVideoLayer.connection?.videoOrientation = .portraitUpsideDown
                    default:
                        break
                    }
                    myVideoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    self.view.layer.addSublayer(myVideoLayer)
                    
                    
                    // UIボタンを作成.
                    let photoButton = UIButton(frame: CGRect(x: 0,y: 0,width: 120,height: 50))
                    photoButton.backgroundColor = UIColor.photoViewButton().withAlphaComponent(0.7)
                    photoButton.layer.masksToBounds = true
                    photoButton.setTitle("撮影", for: UIControl.State())
                    photoButton.layer.cornerRadius = 10.0
                    photoButton.layer.position = CGPoint(x: (self.view.bounds.width/3)*2, y:self.view.bounds.height-50)
                    photoButton.addTarget(self, action: #selector(DetailCameraViewController.onClickMyButton(_:)), for: .touchUpInside)
                    photoButton.setTitleColor(UIColor.gray, for: .highlighted)
                    
                    // UIボタンを作成.
                    let closeButton = UIButton(frame: CGRect(x: 0,y: 0,width: 120,height: 50))
                    closeButton.backgroundColor = UIColor.photoViewButton().withAlphaComponent(0.7)
                    closeButton.layer.masksToBounds = true
                    closeButton.setTitle("閉じる", for: UIControl.State())
                    closeButton.layer.cornerRadius = 10.0
                    closeButton.layer.position = CGPoint(x: self.view.bounds.width/3, y:self.view.bounds.height-50)
                    closeButton.addTarget(self, action: #selector(DetailCameraViewController.onClickCancelButton(_:)), for: .touchUpInside)
                    closeButton.setTitleColor(UIColor.gray, for: .highlighted)
                    
                    
                    // UIボタンをViewに追加.
                    self.view.addSubview(photoButton);
                    self.view.addSubview(closeButton);
                    
                    
                    
                    //let assmenuGroupId = appDelegate.SelectedMstAssessmentSubGroup!["assmenuGroupId"].asInt!
                    //let assMenuSubGroupId = appDelegate.SelectedMstAssessmentSubGroup!["assMenuSubGroupId"].asInt!
                    
//                    var noSchema = false
                    // シェーマ区分取得
                    //let schemaKb = appDelegate.SelectedMstAssessmentSubGroup!["schemaKb"].asString
                    // シェーマが無い場合は戻るボタン非表示
//                    if schemaKb! == AppConst.SchemaKB.NO_SCHEMA.rawValue {
//                        noSchema = true
//                    }
                    // 最初のカメラアセスメントを取得する
//                    if noSchema {
//                        assMster = appDelegate.SelectedMstAssessmentItem
//                    } else {
//                        //for var i = 0; i < appDelegate.MstAssessmentList?.length; i += 1 {
//                        for i in 0 ..< appDelegate.MstAssessmentList!.length {
//                            let mst = appDelegate.MstAssessmentList![i]
//                            let mstmenuGroupId = mst["assmenuGroupId"].asInt!
//                            let mstMenuSubGroupID = mst["assMenuSubGroupId"].asInt!
//                            let imgPartsNo : Int? = mst["imgPartsNo"].asInt
//                            let assInputKB = mst["assInputKb"].asString!
//
//                            if mstmenuGroupId == assmenuGroupId && mstMenuSubGroupID == assMenuSubGroupId && AppConst.InputKB.PHOTO.rawValue == assInputKB {
//                                // シェーマがないか、イメージパーツNoが同じ
//                                if noSchema || imgPartsNo == appDelegate.SelectedAssImagePartsNo {
//                                    // 最初のアセスメントを取得する
//                                    assMster = mst
//                                    break
//                                }
//                            }
//                        }
//                    }
//                    if assMster == nil {
//                        dismiss(animated: true, completion: nil)
//                    }
                }
            }
        }
        catch {
            print(error)
        }
    }
    // 画面回転時に呼び出される
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        myVideoLayer.frame = self.view.bounds
        
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeLeft:
            myVideoLayer.connection?.videoOrientation = .landscapeLeft
        case .landscapeRight:
            myVideoLayer.connection?.videoOrientation = .landscapeRight
        case .portrait:
            myVideoLayer.connection?.videoOrientation = .portrait
        case .portraitUpsideDown:
            myVideoLayer.connection?.videoOrientation = .portraitUpsideDown
        default:
            break
        }
    }
    
    // ボタンイベント.
    @objc func onClickMyButton(_ sender: UIButton){
        let settingsForMonitoring = AVCapturePhotoSettings()
        myImageOutput?.capturePhoto(with: settingsForMonitoring, delegate: self)
    }
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let photoSampleBuffer = photoSampleBuffer {
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            
            var ori : UIImage.Orientation!
            switch UIApplication.shared.statusBarOrientation {
            case .landscapeLeft:
                ori = UIImage.Orientation.down
            case .landscapeRight:
                ori = UIImage.Orientation.up
            case .portrait:
                ori = UIImage.Orientation.left
            case .portraitUpsideDown:
                ori = UIImage.Orientation.right
            default:
                break
            }
            
            let myImage = UIImage(cgImage: (UIImage(data: photoData!)?.cgImage)!, scale: 1.0, orientation: ori)
            //let tranceImageData:Data = UIImageJPEGRepresentation(myImage, 1.0)!
            //let fileString = tranceImageData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
            /*
            let customerId = self.appDelegate.SelectedCustomer!["customerId"].asString!
            let assID = String(self.appDelegate.SelectedAssAssID!)
            let itemID = self.assMster!["assItemId"].asInt!
            let assmenuGroupId = self.appDelegate.SelectedMstAssessmentSubGroup!["assmenuGroupId"].asInt!
            let assMenuSubGroupId = self.appDelegate.SelectedMstAssessmentSubGroup!["assMenuSubGroupId"].asInt!
            
            let url = "\(AppConst.URLPrefix)assessment/PostAssPhotoFile"
            let params: [String: AnyObject] = [
                "customerId": customerId as AnyObject,
                "assID": assID as AnyObject,
                "assmenuGroupId": String(assmenuGroupId) as AnyObject,
                "assMenuSubGroupId": String(assMenuSubGroupId) as AnyObject,
                "itemID": String(itemID) as AnyObject,
                "extention": "jpg" as AnyObject,
                "fileData": fileString as AnyObject,
            ]
            
            _ = self.appCommon.postSynchronous(url, params: params)
            */
            // 閉じる
            self.dismiss(animated: true, completion: nil)
            
            // フラグを変更する
            //self.appDelegate.ChangeInputAssFlagForList = true
            //self.appDelegate.ChangeInputAssFlagForShcema = true
            // 撮影したので切り替え
            //appDelegate.ChangeInputAssFlagForShcema = true
            
            // Post Notification（送信）
            let center = NotificationCenter.default
            center.post(name: NSNotification.Name(rawValue: "requiredAssSubList"), object: nil)
        }
    }
    
    @objc func onClickCancelButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

