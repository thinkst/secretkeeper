//
//  CanaryTokenDeepLink.swift
//  SecretKeeper
//
//  Created by Jason Bissict on 9/6/16.
//  Copyright © 2016 Jay. All rights reserved.
//

import UIKit
let CanaryTokenWebDebugKey: String = "webdebugtoken"
class CanaryTokensDeepLink: NSObject{
    var token : String = ""
    
    
    class func create(_ tokeninfo : [AnyHashable: Any]) -> CanaryTokensDeepLink?{
        let info = tokeninfo as NSDictionary
        
        let token = info.object(forKey: CanaryTokenWebDebugKey) as! String
        
        return CanaryTokensDeepLink(tokenStr: token)
        
    }
    
    fileprivate override init()
    {
        self.token = ""
        super.init()
    }
    
    fileprivate init (tokenStr: String){
        self.token = tokenStr
        super.init()
    }
    
    final func trigger(){
        DispatchQueue.main.async{
            self.triggerToken()
        }
    }
    
    fileprivate func triggerToken(){
//        var vc = SplashViewController()
        
        
    }
}
