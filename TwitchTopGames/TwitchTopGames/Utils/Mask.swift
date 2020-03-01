//
//  Mask.swift
//  TwitchTopGames
//
//  Created by Felipe Bassi on 03/09/19.
//  Copyright © 2019 fbassi. All rights reserved.
//

import Foundation

class Mask {
    var type: MaskType!
    private var secondType: MaskType!
    public init(type: MaskType, secondType: MaskType) {
        self.type = type
        self.secondType = secondType
    }
    public func matches(value: String) -> Bool {
        if type == .empty {
            return true
        } else  if type == .mail {
            let emailTest = NSPredicate(format: "SELF MATCHES %@", type.mask)
            return emailTest.evaluate(with: value)
        } else if type == .creditCardCVV {
            let creditCardCvv = NSPredicate(format: "SELF MATCHES %@", type.mask)
            return creditCardCvv.evaluate(with: value)
        } else if type == .rne {
            let rne = NSPredicate(format: "SELF MATCHES %@", type.mask)
            return rne.evaluate(with: value)
        } else {
            let pattern = Array(type.mask)
            let array = Array(value)
            for (index, char) in pattern.enumerated() {
                if array.count <= index { return false }
                if char == "#" {
                    if Int(String(array[index])) == nil { return false }
                } else {
                    if char != array[index] { return false }
                }
            }
        }
        return true
    }
    func maskMoney(_ value: Double) -> String {
        let valueString = String(value)
        let valueArr = valueString.split {$0 == "."}.map(String.init)
        let decimal = valueArr[1].count == 1 ? "\(valueArr[1])0" :  (valueArr[1])
        return "R$ \(valueArr[0]).\(decimal)"
    }
    
    public func applyMask(value: String) -> String {
        if type == .empty || type == .mail {
            return value
        }
        if type == .creditCardCVV {
            return String(describing: value.prefix(4))
        }
        if type == .money {
            return maskMoney(Double(value)!)
        }
        
        if type == .rne {
            var newValue = ""
            let pattern = Array(type.mask)
            let unmasked = Array(Mask.unmaskWithString(value: value))
            var index = 0
            for char in pattern {
                if unmasked.count <= index { break }
                if char == "#" {
                    newValue += "\(unmasked[index])"
                    index+=1
                } else {
                    newValue += "\(char)"
                }
            }
            return newValue
        }
        
        var newValue = ""
        let pattern = Array(type.mask)
        let unmasked = Array(Mask.unmask(value: value))
        var index = 0
        for char in pattern {
            if unmasked.count <= index { break }
            if char == "#" {
                newValue += "\(unmasked[index])"
                index+=1
            } else {
                newValue += "\(char)"
            }
        }
        return newValue
    }
    
    public static func unmask(value: String) -> String {
        var unmasked: String = ""
        for char in value {
            if let number = Int(String(char)) {
                unmasked += "\(number)"
            }
        }
        return unmasked
    }
    
    public static func unmaskWithString(value: String) -> String {
        var unmasked: String = ""
        for char in value.replacingOccurrences(of: "-", with: "") {
            let text = String(char)
            unmasked += text.capitalized
        }
        return unmasked
    }
}

// MARK: - Enum Extension

extension Mask {
    enum MaskType: String {
        case cnpj = "cnpj"
        case cpf = "cpf"
        case mail = "mail"
        case cellphone = "cellphone"
        case zipCode = "zipCode"
        case date = "date"
        case simpleDate = "simpleDate"
        case creditCard = "creditCard"
        case creditCardCVV = "creditCardCVV"
        case money = "money"
        case rne = "rne"
        case validationCode = "validationCode"
        case empty = ""
        var mask: String {
            switch self {
            case .cnpj:
                return "##.###.###/####-##"
            case .cpf:
                return "###.###.###-##"
            case .mail:
                return "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            case .cellphone:
                return "(##) #####-####"
            case .zipCode:
                return "##.###-###"
            case .date:
                return "##/##/####"
            case .simpleDate:
                return "##/##"
            case .creditCard:
                return "#### #### #### ####"
            case .creditCardCVV:
                return "^[0-9]{3,4}$"
            case .money:
                return "R$"
            case .rne:
                return "##.###.###-#"
            case .validationCode:
                return "# # # - # # #"
            case .empty:
                return ""
            }
        }
    }
}
