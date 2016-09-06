//
//  SplashViewController.swift
//  
//
//  Created by Jason Bissict on 9/5/16.
//
//

import UIKit

class SplashViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var passcodeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passcodeTextField.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SplashViewController.handleCanaryToken(_:)), name: "HANDLETOKEN", object: nil)
        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
        if let token = delegate?.token{
            print("In App, Canary Token Found : \(token)")
            passcodeTextField.text = "We see you got a CanaryToken! Please enter your password to add it to trigger when Secret Keeper opens"
            delegate?.token = nil
        }
        // Do any additional setup after loading the view.
    }
    
    func handleCanaryToken(notification: NSNotification){
        if let token = notification.object as? String{
            print("In App, Canary Token Found Thru NotificationCenter : \(token)")
            passcodeTextField.text = "We see you got a CanaryToken! Please enter your password to add it to trigger when Secret Keeper opens"
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
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
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
                    return false
                }
            }
        }
        return false
    }


}
