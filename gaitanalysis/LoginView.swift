//
//  File.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2020/03/02.
//  Copyright © 2020 System. All rights reserved.
//

import UIKit
//import GoogleSignIn
import Firebase
import FirebaseUI


class LoginView : UIViewController, UITextFieldDelegate, FUIAuthDelegate {
    @IBOutlet weak var textLoginID: RegexTextField!
    @IBOutlet weak var textPassword: RegexTextField!
    @IBOutlet weak var textTest: UITextField!
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    var authUI: FUIAuth { get { return FUIAuth.defaultAuthUI()!}}
    // 認証に使用するプロバイダの選択
    let providers: [FUIAuthProvider] = [
        FUIGoogleAuth(),
        FUIFacebookAuth(),
        FUIEmailAuth()
    ]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textLoginID?.delegate = self
        textPassword?.delegate = self
        
        textLoginID.becomeFirstResponder()
        
        hideKeyboardWhenTappedAround() // テキストボックス以外をクリックした時にキーボードを隠す
        
        //ddddddtextPassword.isSecureTextEntry = true
        
        
        // authUIのデリゲート
        self.authUI.delegate = self
        self.authUI.providers = providers
        //authButton.addTarget(self,action: #selector(self.authButtonTapped(sender:)),for: .touchUpInside)

    }
     

    @IBAction func clickLogin(_ sender: Any) {
        textPassword.isSecureTextEntry = false
        let staffID = textLoginID.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let password = textPassword.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        textPassword.isSecureTextEntry = true
        
        if staffID == "" || password == "" {
              let alertController = UIAlertController(title: "エラー", message: "入力されていない項目があります。", preferredStyle: .alert)
              let okAction = UIAlertAction(title: "OK", style: .default) {
                  action in NSLog("OKボタンが押されました")
              }
              alertController.addAction(okAction)
              present(alertController, animated: true, completion: nil)
              return
        }
        
        startIndicator() // Start Loading
        let url = "\(AppConst.URLPrefix)auth/login"
        let params: [String: AnyObject] = [
             "LoginId": staffID as AnyObject,
             "Password": password as AnyObject,
             ]
        
        
        let res = self.appCommon.postSynchronous(url, params: params)
        if (res.err != nil) {
            let alertController = UIAlertController(title: "エラー", message: "ログインできませんでした。", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) {
                action in NSLog("OKボタンが押されました")
            }
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            
            self.dismissIndicator() // End Loading
            return
        } else {
            DispatchQueue.global(qos: .default).async {
                Thread.sleep(forTimeInterval: 2)
                // マスターの読み込み
                DispatchQueue.main.async {
                    // 画面遷移
                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "MainSplitView")
                    self.present(vc, animated: true, completion: nil)
                    self.dismissIndicator() // End Loading
                }
            }
        }
    }
    
    @IBAction func clickLoginWithGoogle(_ sender: Any) {
//        // デリゲートを設定
//        GIDSignIn.sharedInstance()?.delegate = self
//
//        // ログイン画面の表示元を設定
//        GIDSignIn.sharedInstance()?.presentingViewController = self
//
//        if GIDSignIn.sharedInstance()!.hasPreviousSignIn() {
//            // 以前のログイン情報が残っていたら復元する
//            GIDSignIn.sharedInstance()!.restorePreviousSignIn()
//        } else {
//            // 通常のログインを実行
//            GIDSignIn.sharedInstance()?.signIn()
//        }
        
        // FirebaseUIのViewの取得
        let authViewController = self.authUI.authViewController()
        // FirebaseUIのViewの表示
        self.present(authViewController, animated: true, completion: nil)

    }
    
    
    /* Sign in with Google */
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        if error == nil {
//            // ログイン成功した場合
//            print("signIned user email: \(user!.profile!.email!)")
//            print("signIned user name: \(user!.profile!.name!)")
//        } else {
//            // ログイン失敗した場合
//            print("error: \(error!.localizedDescription)")
//
//            let alertController = UIAlertController(title: "エラー", message: "ログインできませんでした。", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "OK", style: .default) {
//                action in NSLog("OKボタンが押されました")
//            }
//            alertController.addAction(okAction)
//            present(alertController, animated: true, completion: nil)
//
//            self.dismissIndicator() // End Loading
//            return
//        }
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == textLoginID) {
            textPassword?.becomeFirstResponder() // Move Password
        } else if (textField == textPassword) {
            textField.resignFirstResponder() // Close Keyboard
        }
        return true
    }
    //　認証画面から離れたときに呼ばれる（キャンセルボタン押下含む）
    public func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?){
        // 認証に成功した場合
        if error == nil {
            
            //self.performSegue(withIdentifier: "toNextView", sender: nil)
            // ログインユーザの保存
            // appDelegate.loginUser = user!
            
            
            
            DispatchQueue.global(qos: .default).async {
                Thread.sleep(forTimeInterval: 2)
                // マスターの読み込み
                DispatchQueue.main.async {
                    // 画面遷移
                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "MainSplitView")
                    self.present(vc, animated: true, completion: nil)
                    self.dismissIndicator() // End Loading
                }
            }

            
            
        } else {
        //失敗した場合
            print("error")
        }
    }

}
