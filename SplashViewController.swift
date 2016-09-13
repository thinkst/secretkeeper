//
//  SplashViewController.swift
//  
//
//  Created by Jason Bissict on 9/5/16.
//
//

import UIKit
import CoreLocation
import MapKit
import AVFoundation

class SplashViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var passcodeTextField: UITextField!
    @IBOutlet weak var splashTextField: UITextView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var iamgeView: UIImageView!
    
    var token: String = ""
    var locationManager: CLLocationManager!
    var currLocation : CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passcodeTextField.delegate = self
        splashTextField.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        self.currLocation = nil
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SplashViewController.handleCanaryToken(_:)), name: "HANDLETOKEN", object: nil)
        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
        if let token = delegate?.token{
            print("In App, Canary Token Found : \(token)")
            splashTextField.text = "We see you got a CanaryToken! Please enter your password to add it to trigger when Secret Keeper opens"
            splashTextField.textAlignment = NSTextAlignment.Center
            delegate?.token = nil
            self.token = token
        }
        
        CanaryToken.triggerStartupToken()
        // Do any additional setup after loading the view.
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways{
            print("Location services enabled always")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currLocation = locations[locations.count - 1]
        for location in locations{
            print("Location : \(location)")
        }
        if self.currLocation != nil{
            locationManager.stopUpdatingLocation()
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(self.currLocation, completionHandler: {(placemarks, error) -> Void in
                
                var place: CLPlacemark!
                place = placemarks?[0]
                CanaryToken.saveTokenLocation(self.currLocation, place: place)
                CanaryToken.sendTokenLocation()
            })
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location services has returned an error: \(error.localizedDescription)")
    }
    
    func handleCanaryToken(notification: NSNotification){
        if let token = notification.object as? String{
            print("In App, Canary Token Found Thru NotificationCenter : \(token)")
            splashTextField.text = "We see you got a CanaryToken! Please enter your password to add it to trigger when Secret Keeper opens"
            splashTextField.textAlignment = NSTextAlignment.Center
            self.token = token
        }
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveTokenToUserDefaults(){
        if self.token != ""{
            print("Saving CanaryToken to device; it will now be triggered on startup")
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(self.token, forKey: "CanaryToken")
            
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        saveTokenToUserDefaults()
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "LoginIdentifier"{
            if enterButton === sender{
                let passcode = passcodeTextField.text ?? ""
                let check = RealmManager._instance.activate(passcode)
                if check{
                    return true
                }else{
                    splashTextField.text = "The passcode you entered is incorrect. Please try again."
                    CanaryToken.triggerStartupToken()
                    CanaryToken.sendTokenLocation()
                    return false
                }
            }
        }
        return false
    }
}
