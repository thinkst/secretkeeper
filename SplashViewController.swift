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
    
    var cameraController:CameraController!
    var token: String = "wzrg7az1vuh9hb1eokey9bd4i"
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
        cameraController = CameraController()
        cameraController.startRunning()
        self.currLocation = nil
        
        NotificationCenter.default.addObserver(self, selector: #selector(SplashViewController.handleCanaryToken(_:)), name: NSNotification.Name(rawValue: "HANDLETOKEN"), object: nil)
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let token = delegate?.token{
            print("In App, Canary Token Found : \(token)")
            splashTextField.text = "We see you got a CanaryToken! Please enter your password to add it to trigger when Secret Keeper opens"
            splashTextField.textAlignment = NSTextAlignment.center
            delegate?.token = nil
            self.token = token
        }
        
        CanaryToken.triggerStartupToken()
        // Do any additional setup after loading the view.
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways{
            print("Location services enabled always")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currLocation = locations[locations.count - 1]
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location services has returned an error: \(error.localizedDescription)")
    }
    
    func handleCanaryToken(_ notification: Notification){
        if let token = notification.object as? String{
            print("In App, Canary Token Found Thru NotificationCenter : \(token)")
            splashTextField.text = "We see you got a CanaryToken! Please enter your password to add it to trigger when Secret Keeper opens"
            splashTextField.textAlignment = NSTextAlignment.center
            self.token = token
        }
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
            let defaults = UserDefaults.standard
            defaults.set(self.token, forKey: "CanaryToken")
            
            
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        saveTokenToUserDefaults()
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "LoginIdentifier"{
            if enterButton === sender as? UIButton{
                let passcode = passcodeTextField.text ?? ""
                let check = RealmManager._instance.activate(passcode)
                if check{
                    return true
                }else{
                    splashTextField.text = "The passcode you entered is incorrect. Please try again."
                    //CanaryToken.triggerStartupToken()
                    CanaryToken.sendTokenLocation()
                    cameraController.captureSingleStillImage(completionHandler: { (image, metadata) in
                       CanaryToken.sendTokenFaceGrab(image)
                   })
                    return false
                }
            }
        }
        return false
    }
}
