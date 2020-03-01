//
//  Extensions.swift
//  TwitchTopGames
//
//  Created by Felipe Bassi on 03/09/19.
//  Copyright © 2019 fbassi. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static var defaultLabelTextColor: UIColor { return UIColor(red: 19/255.0, green: 21/255.0, blue: 22/255.0, alpha: 1) }
    static var defaultPurple: UIColor { return UIColor(red: 116/255.0, green: 0/255.0, blue: 199/255.0, alpha: 1) }
    static var defaultBlue: UIColor { return UIColor(red: 0/255.0, green: 109/255.0, blue: 255/255.0, alpha: 1) }
    static var defaultRed: UIColor { return UIColor(red: 192/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1) }
    static var alertBlue: UIColor { return UIColor(red: 0/255.0, green: 15/255.0, blue: 230/255.0, alpha: 1) }
}

extension Collection {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension String {
    /// Validate email string
    ///
    /// - parameter email: A String that rappresent an email address
    ///
    /// - returns: A Boolean value indicating whether an email is valid.
    func isEmailValid() -> Bool {
        let emailRegEx = "(?:[a-zA-Z0-9!#$%\\&‘*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-" +
            "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format: "SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func isValidCellphone() -> Bool {
        let cellPhoneRegularExpression = "^[0-9]{11}$"
        let cellPhoneNSPredicate = NSPredicate(format: "SELF MATCHES %@", cellPhoneRegularExpression)
        return cellPhoneNSPredicate.evaluate(with: self)
    }
    
    /// Function that gets the unicode in given string and converts to emoji
    ///
    /// - Returns: The same string with an emoji
    func replaceUnicodesToEmojis() -> String {
        let words = self.split(separator: " ")
        var wordsRefined = [String]()
        var emojis = [String]()
        for word in words {
            if word.contains("U+") {
                let myStr = word.replacingOccurrences(of: "U+", with: "")
                emojis.append(myStr)
            }else {
                if emojis.count > 0 {
                    let values = emojis.compactMap { Int($0, radix: 16) }
                    var string = ""
                    for value in values {
                        if let scalarValue = UnicodeScalar(value) {
                            string += String(scalarValue)
                        }
                    }
                    wordsRefined.append(String(string))
                    emojis.removeAll()
                }
                wordsRefined.append(String(word))
            }
        }
        
        if emojis.count > 0 {
            let values = emojis.compactMap { Int($0, radix: 16) }
            var string = ""
            for value in values {
                if let scalarValue = UnicodeScalar(value) {
                    string += String(scalarValue)
                }
            }
            wordsRefined.append(String(string))
            emojis.removeAll()
        }
        
        return wordsRefined.joined(separator: " ")
    }
    
    func stringByRemovingEmoji() -> String {
        return String(self.filter { !$0.isEmoji() })
    }
}

extension StringProtocol {
    var isValidCPF: Bool {
        let numbers = compactMap({ Int(String($0)) })
        guard numbers.count == 11 && Set(numbers).count != 1 else { return false }
        let soma1 = 11 - ( numbers[0] * 10 +
            numbers[1] * 9 +
            numbers[2] * 8 +
            numbers[3] * 7 +
            numbers[4] * 6 +
            numbers[5] * 5 +
            numbers[6] * 4 +
            numbers[7] * 3 +
            numbers[8] * 2 ) % 11
        let dv1 = soma1 > 9 ? 0 : soma1
        let soma2 = 11 - ( numbers[0] * 11 +
            numbers[1] * 10 +
            numbers[2] * 9 +
            numbers[3] * 8 +
            numbers[4] * 7 +
            numbers[5] * 6 +
            numbers[6] * 5 +
            numbers[7] * 4 +
            numbers[8] * 3 +
            numbers[9] * 2 ) % 11
        let dv2 = soma2 > 9 ? 0 : soma2
        return dv1 == numbers[9] && dv2 == numbers[10]
    }
    
    func indexes(of string: Self, options: String.CompareOptions = []) -> [Index] {
        var result: [Index] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...].range(of: string, options: options) {
                result.append(range.lowerBound)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

extension Character {
    fileprivate func isEmoji() -> Bool {
        return Character(UnicodeScalar(UInt32(0x1d000))!) <= self && self <= Character(UnicodeScalar(UInt32(0x1f77f))!)
            || Character(UnicodeScalar(UInt32(0x2100))!) <= self && self <= Character(UnicodeScalar(UInt32(0x26ff))!)
    }
}

extension UIViewController {
    
    func showOkButtonAlert(title: String? = nil, message: String? = nil, handler: (() -> Void)? = nil ) {
        var customAlert: AlertView!
        
        let storyboard = UIStoryboard.init(name: "AlertView", bundle: nil)
        customAlert = storyboard.instantiateViewController(withIdentifier: "AlertView") as? AlertView
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customAlert.handlerOk = handler
        customAlert.alertTitle = title
        customAlert.message = message
        customAlert.okTitle = K.Buttons.alertOkButton
        customAlert.hideCancel = true
        customAlert.hideSeparator = true
        self.present(customAlert, animated: true, completion: nil)
        
    }
    
    func showBothButtonAlert(title: String? = nil, message: String? = nil, okTitle: String? = nil, cancelTitle: String? = nil, okColor: UIColor? = .defaultPurple, cancelColor: UIColor? = .defaultRed, handlerOK: (() -> Void)? = nil, handlerCancel: (() -> Void)? = nil) {
        
        var customAlert: AlertView!
        
        let storyboard = UIStoryboard.init(name: "AlertView", bundle: nil)
        customAlert = storyboard.instantiateViewController(withIdentifier: "AlertView") as? AlertView
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customAlert.handlerOk = handlerOK
        customAlert.handlerCancel = handlerCancel
        customAlert.alertTitle = title
        customAlert.message = message
        customAlert.okTitle = okTitle
        customAlert.cancelTitle = cancelTitle
        customAlert.okColor = okColor
        customAlert.cancelColor = cancelColor
        self.present(customAlert, animated: true, completion: nil)
        
    }
    
    private struct ToastCounter {
        static var counter: Int = 3
    }
    
    private var toastCount: Int {
        get {
            return ToastCounter.counter
        }
        set(newValue) {
            ToastCounter.counter = newValue
        }
    }
    
    func showToast(message : String? = K.Alerts.Message.error, backgroundColor: UIColor? = UIColor.defaultRed) {
        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: message)        
        DispatchQueue.main.async {
            
            if !self.createdToast(inView: self.view, backgroundColor: backgroundColor, message: message) {
                self.showOkButtonAlert(title: K.Alerts.Title.error, message: K.Alerts.Message.error, handler: nil)
            }
        }
    }
    
    func createdToast(inView: UIView, backgroundColor: UIColor? = UIColor.defaultRed, message : String? = K.Alerts.Message.error) -> Bool {
        if backgroundColor == .defaultRed {
            guard toastCount >= 1 else {
                toastCount = 3
                return false
            }
        } else {
            toastCount = 3
        }
        
        var safeAreaFrame: CGRect?
        let safeAreaInsets: UIEdgeInsets = inView.safeAreaInsets
        
        if #available(iOS 11.0, *) {
            safeAreaFrame  = CGRect(x: 0, y: (safeAreaInsets.top + 60) * -1, width: inView.frame.size.width, height: safeAreaInsets.top + 60)
        }
        toastCount -= 1
        
        let toastView = UIView(frame: safeAreaFrame ??  CGRect(x: 0, y: -60, width: inView.frame.size.width, height: 60))
        toastView.backgroundColor = backgroundColor
        
        let toastLabel = UILabel()
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastView.addSubview(toastLabel)
        
        toastLabel.topAnchor.constraint(equalTo: toastView.topAnchor, constant: 16).isActive = true
        toastLabel.bottomAnchor.constraint(equalTo: toastView.bottomAnchor, constant: 16).isActive = true
        toastLabel.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 16).isActive = true
        toastLabel.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -16).isActive = true
        
        toastLabel.backgroundColor = .clear
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        toastLabel.text = message
        toastLabel.lineBreakMode = .byTruncatingTail
        toastLabel.numberOfLines = 3
        toastLabel.alpha = 1.0
        
        let currentWindow: UIWindow? = UIApplication.shared.keyWindow
        currentWindow?.addSubview(toastView)
        
        UIView.animate(withDuration: 0.7, delay: 0.0, options: .curveEaseIn, animations: {
            toastView.frame.origin.y += safeAreaInsets.top + 60
        }, completion: { _ in
            UIView.animate(withDuration: 0.7, delay: 1.5, options: .curveEaseOut, animations: {
                toastView.frame.origin.y -= (safeAreaInsets.top + 60)
            }, completion: { _ in
                toastView.removeFromSuperview()
            })
        })
        return true
    }
    
}

extension UITableView {
    func showPlaceholder(customTitle: String? = nil, customDescription: String? = nil) {
        self.backgroundView = nil
        let placeholderView = TableViewPlaceholder()
        placeholderView.placeholderTitle.text = K.Alerts.Message.emptyTableTitle
        placeholderView.placeHolderDescription.text = K.Alerts.Message.emptyTableMessage
        self.separatorStyle = .none
        self.backgroundView = placeholderView
        Placeholder.isVisible = true
        self.reloadData()
    }
    
    func removePlaceholder(seperatorBackToDefault: Bool) {
        self.backgroundView = nil
        Placeholder.isVisible = false
        if seperatorBackToDefault {
            self.separatorStyle = .singleLine
        }
    }
    
    struct Placeholder {
        static var isVisible: Bool = false
    }
    
    var isPlaceholderVisible: Bool {
        get {
            return Placeholder.isVisible
        }
        set(newValue) {
            Placeholder.isVisible = newValue
        }
    }
}

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "."
        formatter.numberStyle = .decimal
        return formatter
    }()
}

extension Int {
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
    
    var boolValue: Bool { return self != 0 }
    var stringValue: String { return String (self) }
}

extension UIRefreshControl {
    typealias handler = () -> ()
    
    func endRefresh(completion: @escaping handler) {
        self.endRefreshing()
        completion()
    }
}
