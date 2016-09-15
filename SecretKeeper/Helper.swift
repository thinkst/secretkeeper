//
//  Helper.swift
//  SecretKeeper
//
//  Created by Jason Bissict on 9/1/16.
//  Copyright © 2016 Jay. All rights reserved.
//

import UIKit

class Helper{
    
    static func DateAsString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let str = dateFormatter.string(from: date)
        return str
    }
    
    static func CheckValidSecretName(_ textField: UITextField) -> Bool{
        let text = textField.text ?? ""
        return !text.isEmpty
    }
}
