//
//  SplashViewController.swift
//  
//
//  Created by Jason Bissict on 9/5/16.
//
//

import UIKit

class SplashViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var passcodeTextField: UITextField!
    @IBOutlet weak var splashTextField: UITextView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var token: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passcodeTextField.delegate = self
        splashTextField.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SplashViewController.handleCanaryToken(_:)), name: "HANDLETOKEN", object: nil)
        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
        if let token = delegate?.token{
            print("In App, Canary Token Found : \(token)")
            splashTextField.text = "We see you got a CanaryToken! Please enter your password to add it to trigger when Secret Keeper opens"
            splashTextField.textAlignment = NSTextAlignment.Center
            delegate?.token = nil
            self.token = token
        }
        
        triggerCanaryToken()
        // Do any additional setup after loading the view.
    }
    
    func triggerCanaryToken(){
        let defaults = NSUserDefaults.standardUserDefaults()
        if let existingToken = defaults.objectForKey("CanaryToken") as! String?{
            print("Triggering token")
            let url = "http://canarytokens.com/\(existingToken)/contact.php"
            let myUrl = NSURL(string: url)
            let request = NSMutableURLRequest(URL: myUrl!)
            request.HTTPMethod = "GET"
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request)
            task.resume()
        }
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
                    print("Open Sesame")
                    return true
                }else{
                    print("Abort abort abort")
                    splashTextField.text = "The passcode you entered is incorrect. Please try again."
                    triggerCanaryToken()
                    return false
                }
            }
        }
        return false
    }


}
