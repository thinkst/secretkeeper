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
    
    //static let host:String  = "localhost"
    static let host:String = "canarytokens.com"
    
    fileprivate static func saveCurrentTokenTimestamp() -> String?{
        let ts = Date().timeIntervalSince1970
        let defaults = UserDefaults.standard
        defaults.set("\(ts)", forKey: "CanaryTS")
        return "\(ts)"
    }
    
    static func triggerStartupToken(){
        let ts = self.saveCurrentTokenTimestamp() as String!
        print("Canary Token Timestamp: \(ts)")
        let defaults = UserDefaults.standard
        if let existingToken = defaults.object(forKey: "CanaryToken") as! String?{
            print("Triggering token: \(existingToken)")
            let myUrl = createStartUpURLWithComponents(existingToken, tokents: ts!)
            let request = NSMutableURLRequest(url: myUrl!)
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request as URLRequest)
            task.resume()
        }
    }
    
    static func createStartUpURLWithComponents(_ token:String, tokents:String) -> URL?{
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = host
        urlComponents.path = "/\(token)/contact.php"
        let tokenTSQuery = URLQueryItem(name: "ts_key", value: tokents)
        let triggerQuery = URLQueryItem(name: "src", value: "StartUpTrigger")

        urlComponents.queryItems = [tokenTSQuery, triggerQuery]
        
        return urlComponents.url
    }
    
    static func sendTokenLocation(){
        let defaults = UserDefaults.standard
        var plcString:String = ""
        var latlng:String = ""
        if let place = defaults.object(forKey: "place") as! String!{
            plcString = place
        }
        if let coords = defaults.object(forKey: "location") as! String!{
            latlng = coords
        }
        if !(latlng=="") && !(plcString==""){
            if let token = defaults.object(forKey: "CanaryToken") as! String!{
                if let tokenTS = defaults.object(forKey: "CanaryTS") as! String!{
                    let myUrl = createLocationURLWithComponents(token, tokents: tokenTS, placeInfo: plcString, latlng: latlng)
                    let request = NSMutableURLRequest(url: myUrl!)
                    request.httpMethod = "POST"
                    let task = URLSession.shared.dataTask(with: request as URLRequest)
                    task.resume()
                }
            }
        }
    }
    
    static func saveTokenLocation(_ coords:CLLocation, place:CLPlacemark){
        let defaults = UserDefaults.standard
        let plcArr = place.addressDictionary!["FormattedAddressLines"] as! NSArray
        let plcString = plcArr.componentsJoined(by: "\n")
        let latlng = "\(coords.coordinate.latitude),\(coords.coordinate.longitude)" as String
        defaults.set(latlng, forKey: "location")
        defaults.set(plcString, forKey: "place")
    }
    
    static func sendTokenFaceGrab(_ image:UIImage){
        
        let defaults = UserDefaults.standard
        let token = defaults.object(forKey: "CanaryToken") as! String!
        let tokenTS = defaults.object(forKey: "CanaryTS") as! String!
        
        let url = createUploadURLWithComponents(token!, tokents: tokenTS!)
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        //define the multipart request type
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let image_data = UIImageJPEGRepresentation(image, 1.0)
        
        
        if(image_data == nil)
        {
            return
        }
        
        let body = NSMutableData()
        
        let mimetype = "image/jpeg"
        
        //define the data post parameter
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"key\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(tokenTS!)\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"secretkeeper_photo\"; filename=\"pic.png\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(image_data!)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        request.httpBody = body as Data
        
        let task = URLSession.shared.dataTask(with: request as URLRequest!) { (data, response, error) in
          
            guard let _:Data = data, let _:URLResponse = response , error == nil else {
                print("error")
                return
            }
            
           // let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            //print(dataString)
        }
        
        task.resume()
    }
    
     static func generateBoundaryString() -> String
    {
        return "Boundary-\(UUID().uuidString)"
    }
    
    static func createUploadURLWithComponents(_ token:String, tokents:String) -> URL?{
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = host
        urlComponents.path = "/\(token)/contact.php"
        
        let tokenTSQuery = URLQueryItem(name: "key", value: tokents)
        let tokenQuery = URLQueryItem(name: "canarytoken", value: token)
        let srcQuery = URLQueryItem(name: "src", value: "FaceGrabTrigger")
        
        urlComponents.queryItems = [tokenTSQuery, tokenQuery, srcQuery]
        
        return urlComponents.url
    }
    
    static func createLocationURLWithComponents(_ token:String, tokents:String, placeInfo:String, latlng:String) -> URL?{
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = host
        urlComponents.path = "/\(token)/contact.php"
        
        let tokenTSQuery = URLQueryItem(name: "key", value: tokents)
        let tokenQuery = URLQueryItem(name: "canarytoken", value: token)
        let placeQuery = URLQueryItem(name: "address_info", value: placeInfo)
        let coordsQuery = URLQueryItem(name: "loc", value: latlng)
        let typeQuery = URLQueryItem(name: "name", value: "iOS-App")
        let srcQuery = URLQueryItem(name: "src", value: "LocationTrigger")
        
        urlComponents.queryItems = [tokenTSQuery, tokenQuery, coordsQuery, placeQuery, typeQuery, srcQuery]
        
        return urlComponents.url
    }
    
}
