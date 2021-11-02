//
//  DetailViewEventPDF.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/18.
//  Copyright © 2019 System. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class DetailViewEventPDF: UIViewController {
    var webView: WKWebView!
    var data : Data?
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    var url : URL!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Viewの高さと幅を取得する.
        //let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        // Status Barの高さを取得をする.
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let navBarHeight = self.navigationController?.navigationBar.frame.size.height
        let navBarWidth = self.navigationController?.navigationBar.frame.size.width
        let barHeight = statusBarHeight + navBarHeight!
        let pdfURL: URL!
        
        pdfURL = Bundle.main.url(forResource: "sokuteikai_18112_outline", withExtension: "pdf")!
        let data = try? Data(contentsOf: pdfURL)
        
        //            let data = Data(base64Encoded: res! as String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        
        let rect = CGRect(x: 0,y: barHeight,width: navBarWidth!,height: displayHeight - barHeight)
        let webConf = WKWebViewConfiguration()
        webView = WKWebView(frame: rect, configuration: webConf)
        self.view.addSubview(webView)
        
        // データロード.
        //webView.loadData(data!, MIMEType:"application/pdf", textEncodingName:"UTF-8", baseURL:nil)
        //            webView.load(data!, mimeType:"application/pdf", textEncodingName:"UTF-8", baseURL:URL(fileURLWithPath: Bundle.main.bundlePath))
        webView.load(data!, mimeType: "application/pdf", characterEncodingName: "UFT-8", baseURL:URL(fileURLWithPath: Bundle.main.bundlePath))
        
        // データ保存
        let paths1 = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask, true)
        
        //let _path = paths1[0].stringByAppendingPathComponent("test.pdf")
        let dir = paths1[0]
        let _path = URL(fileURLWithPath: dir).appendingPathComponent("test.pdf").path
        
        
        //print(_path)
        
        //var result = data?.writeToFile(_path!, atomically: true)
        
        
        //var bundle : NSBundle = NSBundle()
        //var path = bundle.pathForResource(_path, ofType: "PDF")
        
        url = URL(fileURLWithPath: _path)
        let app:UIApplication = UIApplication.shared
        app.openURL(url)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // 画面回転時に呼び出される
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        self.webView.frame = self.view.bounds
    }

}
