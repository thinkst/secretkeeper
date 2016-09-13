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
    
    //Password : Hello
    //64 byte key : ad133ca3c1806d86a80ec0772b2458642b0707ba3bd605f528bf013517eee253fc3041049b79ea3744bd7c8c2d9290d91671967de2a50af82a2e93ab47b85235
    
    init(){
        print("Initialised Realm Manager")
    }
    
    private func connectToRealm(key:NSData) -> Bool{
        do{
            let config = Realm.Configuration(encryptionKey: key, fileURL: NSURL(fileURLWithPath: "/Users/jay/Work/iOS/SecretKeeper/database.realm"))
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
    
    private func deriveKeyFromPassword(password:String) -> NSData{
        let passArr = password.utf8.map {$0}
        let salt  = "nacl".utf8.map {$0}
        let value = try! PKCS5.PBKDF2(password: passArr, salt: salt, iterations: 4096 ,variant: .sha512).calculate()
        //let paddedData = PKCS7().add(value, blockSize: 64)
        let data = NSData(bytes: value)
        print ("64 byte encryption key: \(data)")
        return data
    }
    
    func activate(key: String) -> Bool {
        let check = connectToRealm(deriveKeyFromPassword(key))
        return check
    }
    
    func downloadRealm() -> [Secret]?{
        var resultArr:[Secret] = []
            if let results = realm?.objects(Secret.self).sorted("date"){
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
    
    func deleteSecret(secret:Secret){
        try! realm?.write{
            realm?.delete(secret)
        }
    }
    
    func saveSecret(secret:Secret){
        try! realm?.write{
            realm?.add(secret, update: true)
        }
        
    }
}

