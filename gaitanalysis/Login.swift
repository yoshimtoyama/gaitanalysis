//
//  Login.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2020/08/31.
//  Copyright © 2020 System. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class Login : UIViewController, FUIAuthDelegate {
    @IBOutlet weak var authButton: UIButton!
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    var authUI: FUIAuth { get { return FUIAuth.defaultAuthUI()!}}

    // 認証に使用するプロバイダの選択
    let providers: [FUIAuthProvider] = [
        FUIGoogleAuth(),
        FUIFacebookAuth(),
        FUIEmailAuth(),
        FUIOAuth.appleAuthProvider()
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // authUIのデリゲート
        self.authUI.delegate = self
        self.authUI.providers = providers
        authButton.addTarget(self,action: #selector(self.authButtonTapped(sender:)),for: .touchUpInside)
    }
    
    @objc func authButtonTapped(sender : AnyObject) {
        let authUI = FUIAuth.defaultAuthUI()
        let providers: [FUIAuthProvider] = [FUIGoogleAuth(), FUIFacebookAuth(), FUIEmailAuth(), FUIOAuth.appleAuthProvider()]
        
        authUI?.providers = providers
        authUI?.delegate = self as FUIAuthDelegate

        let authViewController = firebaseAuthUI(authUI: authUI!)
        let navc = UINavigationController(rootViewController: authViewController)
        self.present(navc, animated: true, completion: nil)
        
    }
    
    //　認証画面から離れたときに呼ばれる（キャンセルボタン押下含む）
    public func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?){
        if error != nil {
            return
        }
        guard let authDataResult = authDataResult else {
            return
        }
        
        authDataResult.user.getIDTokenForcingRefresh(true) { token, error in
            // FirebaseのToken取得
            guard let token = token else {
              return
            }
            self.appDelegate.idToken = token
            
            // ログイン情報登録（Firebase のユーザID）
            let url = "\(AppConst.URLPrefix)auth/login"
            let params: [String: AnyObject] = ["Token": token as AnyObject]
            let res = self.appCommon.postSynchronous(url, params: params)
            if AppCommon.isNilOrEmpty(string: res.err) {
                self.appDelegate.loginUser = JSON(string: res.result!) // JSON読み込み
                // 遷移
                self.performSegue(withIdentifier: "SegueToSplitView", sender: nil)
            } else {
                AppCommon.alertMessage(controller: self, title: "ログイン失敗", message: res.err)
            }
        }
    }
}
