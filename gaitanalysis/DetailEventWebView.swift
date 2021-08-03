//
//  DetailEventWebView.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2021/07/05.
//  Copyright © 2021 System. All rights reserved.
//

import Foundation
import UIKit
// WebKitをimportする
import WebKit

class DetailEventWebView: UIViewController, UINavigationControllerDelegate {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = self
        // WKWebViewを生成
        // Viewの高さと幅を取得する.
        // mode
        webView.contentMode = UIView.ContentMode.scaleToFill
        print(view.frame)
        print(webView.frame)
        getwebLink()
    }
    
    
    func getwebLink() {
        let selectedEvent = appDelegate.selectedEvent as JSON
        let url = selectedEvent["webLink"].asString ?? ""
        // リクエストを生成
        if(!url .isEmpty){
            let request = URLRequest(url: URL(string: url)!)
            // リクエストをロードする
            webView.load(request)
        }
        else{
            webView.loadHTMLString("<div style=\"position: fixed; top: 40%; left: 25%;\"><p style=\"font-family: courier; font-size: 25;\"> Web公開情報が設定されていません </p></div>", baseURL: nil)
        }
    }

}
