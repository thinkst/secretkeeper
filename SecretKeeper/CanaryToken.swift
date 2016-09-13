//
//  CanaryToken.swift
//  SecretKeeper
//
//  Created by Jason Bissict on 9/7/16.
//  Copyright © 2016 Jay. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class CanaryToken {
    
    private static func saveCurrentTokenTimestamp() -> String?{
        let ts = NSDate().timeIntervalSince1970
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject("\(ts)", forKey: "CanaryTS")
        return "\(ts)"
    }
    
    static func triggerStartupToken(){
        let ts = self.saveCurrentTokenTimestamp() as String!
        print("Canary Token Timestamp: \(ts)")
        let defaults = NSUserDefaults.standardUserDefaults()
        if let existingToken = defaults.objectForKey("CanaryToken") as! String?{
            print("Triggering token: \(existingToken)")
            let url = "http://canarytokens.com/\(existingToken)/contact.php?ts_key=\(ts)"
//            let url = "http://localhost/\(existingToken)/contact.php?ts_key=\(ts)"
            let myUrl = NSURL(string: url)
            let request = NSMutableURLRequest(URL: myUrl!)
            request.HTTPMethod = "GET"
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request)
            task.resume()
            
        }
    }
    
    static func sendTokenLocation(){
        let defaults = NSUserDefaults.standardUserDefaults()
        var plcString:String = ""
        var latlng:String = ""
        if let place = defaults.objectForKey("place") as! String!{
            plcString = place
        }
        if let coords = defaults.objectForKey("location") as! String!{
            latlng = coords
        }
        if !(latlng=="") && !(plcString==""){
            if let token = defaults.objectForKey("CanaryToken") as! String!{
                if let tokenTS = defaults.objectForKey("CanaryTS") as! String!{
                    let myUrl = createURLWithComponents(token, tokents: tokenTS, placeInfo: plcString, latlng: latlng)
                    let request = NSMutableURLRequest(URL: myUrl!)
                    request.HTTPMethod = "POST"
                    let task = NSURLSession.sharedSession().dataTaskWithRequest(request)
                    task.resume()
                }
            }
        }
    }
    
    static func saveTokenLocation(coords:CLLocation, place:CLPlacemark){
        let defaults = NSUserDefaults.standardUserDefaults()
        let plcArr = place.addressDictionary!["FormattedAddressLines"] as! NSArray
        let plcString = plcArr.componentsJoinedByString("\n")
        let latlng = "\(coords.coordinate.latitude),\(coords.coordinate.longitude)" as String
        defaults.setObject(latlng, forKey: "location")
        defaults.setObject(plcString, forKey: "place")
    }
    
    static func createURLWithComponents(token:String, tokents:String, placeInfo:String, latlng:String) -> NSURL?{
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = "localhost"
        urlComponents.host = "canarytokens.com"
//        urlComponents.path = "/\(token)/contact.php"
        
        let tokenTSQuery = NSURLQueryItem(name: "key", value: tokents)
        let tokenQuery = NSURLQueryItem(name: "canarytoken", value: token)
        let placeQuery = NSURLQueryItem(name: "address_info", value: placeInfo)
        let coordsQuery = NSURLQueryItem(name: "loc", value: latlng)
        let typeQuery = NSURLQueryItem(name: "name", value: "iOS-App")
        
        urlComponents.queryItems = [tokenTSQuery, tokenQuery, coordsQuery, placeQuery, typeQuery]
        
        return urlComponents.URL
    }
    
    //sendTokenTriggerLocation
    //sendTokenTriggerPic
}
