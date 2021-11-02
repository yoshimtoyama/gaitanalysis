//
//  DetailViewPDF.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/04.
//  Copyright © 2019 System. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class DetailViewPDF: UIViewController {
    var webView: WKWebView!
    var data : Data?
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    var url : URL!
    var jsonStr : String!
    
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
        
        pdfURL = Bundle.main.url(forResource: "report_hoko", withExtension: "pdf")!
        let data = try? Data(contentsOf: pdfURL)
        
        //            let data = Data(base64Encoded: res! as String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        
        let rect = CGRect(x: 0,y: barHeight,width: navBarWidth!,height: displayHeight - barHeight)
        let webConf = WKWebViewConfiguration()
        webView = WKWebView(frame: rect, configuration: webConf)
        self.view.addSubview(webView)
        
        let string64url = "\(AppConst.URLPrefix)ass/GetAnalysisReportBase64String/\(appDelegate.selectedUser["customerID"].asInt!)/\(appDelegate.selectedAss["assId"].asInt!)"
        jsonStr = appCommon.getSynchronous(string64url)
        if(jsonStr == "レポートが取得できませんでした。"){
            AppCommon.alertMessage(controller: self, title: "Error", message: jsonStr)
        }
            if let data = NSData(base64Encoded: jsonStr!, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) as Data? {
                //self.webView.load(data, mimeType: "application/pdf", textEncodingName: "", baseURL: URL(fileURLWithPath: ""))
                self.webView.load(data, mimeType: "application/pdf", characterEncodingName: "", baseURL: URL(fileURLWithPath: ""))
            }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        onTapViewContoroller()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // 画面回転時に呼び出される
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        self.webView.frame = self.view.bounds
    }
    @IBAction func clickViewReport(_ sender: AnyObject) {
        //        let pdfURL = Bundle.main.url(forResource: "report_all", withExtension: "pdf")!
        //        let data = try? Data(contentsOf: pdfURL)
        //        let nsUrl = URL(string:resStr)
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        // 全画面表示のために取得したレポートデータを渡す。
        //if (segue.identifier == "SeguePDFAll") {
        //    let nav: UINavigationController = segue.destinationViewController as UINavigationController
        //    let nextViewController: ViewPDFAll = nav.visibleViewController as ViewPDFAll
        //    nextViewController.data = data
        //}
    }
    
    
    @IBAction func print(_ sender: UIBarButtonItem) {
        //if let guide_url = Bundle.main.url(forAuxiliaryExecutable: webView.request!.url!.absoluteString)
        if let guide_url = Bundle.main.url(forAuxiliaryExecutable: webView.url!.absoluteString)
        {
            if UIPrintInteractionController.canPrint(guide_url) {
                let printInfo = UIPrintInfo(dictionary: nil)
                printInfo.jobName = guide_url.lastPathComponent
                printInfo.outputType = .photo

                let printController = UIPrintInteractionController.shared
                printController.printInfo = printInfo
                printController.showsNumberOfCopies = false

                printController.printingItem = guide_url

                printController.present(animated: true, completionHandler: nil)
            }
        }
    }
    // タブがタップされた時実行される
    func onTapViewContoroller() {
        // 戻るボタン用のタイトル設定（Tabbar直後の画面だけbackになってしまうため)
        navigationController!.navigationBar.topItem!.title = self.navigationItem.title!
        // 右上にボタン追加
        let helpButton = UIBarButtonItem(title: "PRINT", style: UIBarButtonItem.Style.plain, target: self, action: #selector(print(_:)))
        navigationController!.navigationBar.topItem!.setRightBarButtonItems([helpButton], animated: true)

    }
    
}
extension DetailViewPDF: TabBarDelegate {
    func didSelectTab(tabBarController: UITabBarController) {
        onTapViewContoroller()
    }
}

