//
//  SecretViewController.swift
//  SecretKeeper
//
//  Created by Jason Bissict on 9/1/16.
//  Copyright © 2016 Jay. All rights reserved.
//

import UIKit

class SecretViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    //MARK: Properties
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var secret: Secret?

    override func viewDidLoad() {
        super.viewDidLoad()
        contentTextView.delegate = self
        titleTextField.delegate = self
        // Do any additional setup after loading the view.
        
        if let secret = secret {
            navigationItem.title = secret.title
            titleTextField.text = secret.title
            contentTextView.text = secret.content
        }
        
        saveButton.enabled = Helper.CheckValidSecretName(titleTextField)
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        saveButton.enabled = Helper.CheckValidSecretName(textField)
        navigationItem.title = textField.text
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        //Disable the Save button while editing
        saveButton.enabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation
    @IBAction func cancel(sender: UIBarButtonItem) {
        let isPresentingAddSecretMode = presentingViewController is UINavigationController
        if isPresentingAddSecretMode{
            dismissViewControllerAnimated(true, completion: nil)
        }else{
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
     /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: Navigation
    
    //This method lets you configure a view ocntroller before it's presented
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender{
            let title = titleTextField.text ?? ""
            let content = contentTextView.text ?? ""
            
            secret = Secret()
            secret?.content = content
            secret?.date = NSDate()
            secret?.title = title
            
            RealmManager._instance.saveSecret(secret!)
        }
    }
    
    //MARK: Actions

}
