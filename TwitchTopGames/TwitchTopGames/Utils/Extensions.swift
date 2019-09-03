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
    static var defaultPurple: UIColor { return UIColor(red: 119/255.0, green: 60/255.0, blue: 199/255.0, alpha: 1) }
    static var defaultBlue: UIColor { return UIColor(red: 0/255.0, green: 109/255.0, blue: 255/255.0, alpha: 1) }
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

