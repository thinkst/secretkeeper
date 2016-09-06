//
//  Helper.swift
//  SecretKeeper
//
//  Created by Jason Bissict on 9/1/16.
//  Copyright © 2016 Jay. All rights reserved.
//

import UIKit

class Helper{
    
    static func DateAsString(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let str = dateFormatter.stringFromDate(date)
        return str
    }
    
    static func CheckValidSecretName(textField: UITextField) -> Bool{
        let text = textField.text ?? ""
        return !text.isEmpty
    }
}
