//
//  Extensions.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2020/03/02.
//  Copyright © 2020 System. All rights reserved.
//
import Foundation
import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func startIndicator() {

        let loadingIndicator = UIActivityIndicatorView(style: .whiteLarge)

        loadingIndicator.center = self.view.center
        let grayOutView = UIView(frame: self.view.frame)
        grayOutView.backgroundColor = .black
        grayOutView.alpha = 0.6

        // 他のViewと被らない値を代入
        loadingIndicator.tag = 999
        grayOutView.tag = 999

        self.view.addSubview(grayOutView)
        self.view.addSubview(loadingIndicator)
        self.view.bringSubviewToFront(grayOutView)
        self.view.bringSubviewToFront(loadingIndicator)

        loadingIndicator.startAnimating()
    }

    func dismissIndicator() {
        self.view.subviews.forEach {
            if $0.tag == 999 {
                $0.removeFromSuperview()
            }
        }
    }
}






extension UIColor {
    class func hexStr (_ hexStr : NSString, alpha : CGFloat) -> UIColor {
        var hexStr = hexStr
        hexStr = hexStr.replacingOccurrences(of: "#", with: "") as NSString
        let scanner = Scanner(string: hexStr as String)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red:r,green:g,blue:b,alpha:alpha)
        } else {
            print("invalid hex string", terminator: "")
            return UIColor.white;
        }
    }
    
    /* カスタムカラー */
    // 文字色
    class func textBlue() -> UIColor {
        return #colorLiteral(red: 0.01858329214, green: 0.4816223383, blue: 1, alpha: 1)
    }
    class func textRed() -> UIColor {
        return #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
    }
    
    // デフォルト色再現
    class func defaultSectionBackGround() -> UIColor {
        return #colorLiteral(red: 0.9685533643, green: 0.9686693549, blue: 0.968513906, alpha: 1)
    }
    
    // ステータス
    class func good() -> UIColor {
        return #colorLiteral(red: 0.682792707, green: 0.9004378855, blue: 0.9568627477, alpha: 1)
    }
    class func bad() -> UIColor {
        return #colorLiteral(red: 0.9707921147, green: 0.831622764, blue: 0.8298224903, alpha: 1)
    }
    class func disabled() -> UIColor {
        return #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    }
    
    // フォトビュー等で使用するボタン用の背景色
    class func photoViewButton() -> UIColor {
        return UIColor(red:0.365, green:0.678, blue:0.925, alpha:1.0)
    }
    class func recordingButton() -> UIColor {
        return UIColor(red:0.965, green:0.378, blue:0.625, alpha:1.0)
    }
}
