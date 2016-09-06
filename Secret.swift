//
//  Secret.swift
//  
//
//  Created by Jason Bissict on 9/1/16.
//
//

import RealmSwift

class Secret: Object {
    
    struct PropertyKey {
        static let titleKey = "title"
        static let contentKey = "content"
    }
    
    dynamic var title: String? = nil
    dynamic var date: NSDate? = nil
    dynamic var content: String? = nil
    
    override static func primaryKey() -> String? {
        return "title"
    }
    
//    init(title: String, date: NSDate, content: String){
//        self.title = title
//        self.content = content
//        self.date = date
//        
//    }
    
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
