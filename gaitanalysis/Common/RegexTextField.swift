//
//  RegexTextField.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2020/03/02.
//  Copyright © 2020 System. All rights reserved.
//

import UIKit

class RegexTextField: UITextField {

    private var length: Int = Int.max

    private var pattern: String = ".*"

    private var tmpText: String?

    init() {
        super.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        registerForNotifications()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        registerForNotifications()
    }

    private func registerForNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChange),
            name: NSNotification.Name(rawValue: "UITextFieldTextDidChangeNotification"),
            object: self
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBInspectable var maxLength: Int {
        get { return length }
        set { length = newValue }
    }

    @IBInspectable var regexPattern: String {
        get { return pattern }
        set { pattern = newValue }
    }

    @objc func textDidChange() {
        let target = text ?? ""

        // 正規表現でチェック
        if !isMatch(target: target, pattern: pattern) {
            text = tmpText
            return
        }

        // 長さでチェック
        if target.count > length {
            text = tmpText
            return
        }

        // 次回の比較用に退避
        tmpText = text
    }

    private func isMatch(target: String, pattern: String) -> Bool {
        do {
            let re = try NSRegularExpression(pattern: pattern)
            let matches = re.matches(in: target, range: NSMakeRange(0, target.count))
            return matches.count > 0
        } catch {
            return false
        }
    }
}
