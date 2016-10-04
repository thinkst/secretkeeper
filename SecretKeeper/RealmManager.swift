//
//  RealmManager.swift
//  SecretKeeper
//
//  Created by Jason Bissict on 9/2/16.
//  Copyright © 2016 Jay. All rights reserved.
//

import UIKit
import RealmSwift
import Security
import CryptoSwift

class RealmManager {
    
    static let _instance = RealmManager()
    var realm:Realm?
    var signedIn:Bool = false
    
    init(){
        print("Initialised Realm Manager")
    }
    
    fileprivate func connectToRealm(_ key:Data) -> Bool{
        do{
            let config = Realm.Configuration(encryptionKey: key)
            realm = try Realm(configuration: config)
            print("Connection to Encrypted Realm Database Successful")
            signedIn = true
            return true
        }catch{
            print("Open realm database failed:\(error)")
            signedIn = false
        }
        return false
    }
    
    fileprivate func deriveKeyFromPassword(_ password:String) -> Data{
        let passArr = password.utf8.map {$0}
        let salt  = "nacl".utf8.map {$0}
        let value = try! PKCS5.PBKDF2(password: passArr, salt: salt, iterations: 4096 ,variant: .sha512).calculate()
        //let paddedData = PKCS7().add(value, blockSize: 64)
        let data = Data(bytes: value)
        print ("64 byte encryption key: \(data)")
        return data
    }
    
    func activate(_ key: String) -> Bool {
        let check = connectToRealm(deriveKeyFromPassword(key))
        return check
    }
    
    func downloadRealm() -> [Secret]?{
        var resultArr:[Secret] = []
            if let results = realm?.allObjects(ofType: Secret.self).sorted(onProperty: "date"){
                for item in results{
                    let secret = Secret()
                    secret.title = item.title
                    secret.date = item.date
                    secret.content = item.content
                    print("Secret retrieved: \(item.title), \(item.date), \(item.content)")
                    resultArr.append(secret)
                }
                return resultArr
            }
        print("Realm database isn't signed in yet")
        return nil
    }
    
    func deleteSecret(_ secret:Secret){
        try! realm?.write{
            realm?.delete(secret)
        }
    }
    
    func saveSecret(_ secret:Secret){
        try! realm?.write{
            realm?.add(secret, update: true)
        }
        
    }
}

