//
//  CanaryToken.swift
//  SecretKeeper
//
//  Created by Jason Bissict on 9/7/16.
//  Copyright © 2016 Jay. All rights reserved.
//

import RealmSwift

class CanaryToken: Object {
    
    struct PropertyKey {
        static let tokenKey = "token"
        static let dateKey = "date"
    }
    
    dynamic var token: String? = nil
    dynamic var date: NSDate? = nil
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
