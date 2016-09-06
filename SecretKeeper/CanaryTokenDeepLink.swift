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
    
    
    class func create(tokeninfo : [NSObject : AnyObject]) -> CanaryTokensDeepLink?{
        let info = tokeninfo as NSDictionary
        
        let token = info.objectForKey(CanaryTokenWebDebugKey) as! String
        
        return CanaryTokensDeepLink(tokenStr: token)
        
    }
    
    private override init()
    {
        self.token = ""
        super.init()
    }
    
    private init (tokenStr: String){
        self.token = tokenStr
        super.init()
    }
    
    final func trigger(){
        dispatch_async(dispatch_get_main_queue()){
            self.triggerToken()
        }
    }
    
    private func triggerToken(){
//        var vc = SplashViewController()
        
        
    }
}
