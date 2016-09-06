//
//  SecretTableViewController.swift
//  
//
//  Created by Jason Bissict on 9/1/16.
//
//

import UIKit

class SecretTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var secrets = [Secret]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem()
        
        if let savedSecrets = loadSecrets(){
            secrets += savedSecrets
        }else{
            loadSampleSecrets()
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func loadSampleSecrets(){
        let secret1 = Secret()
        secret1.title = "Big Secret"
        secret1.date = NSDate()
        secret1.content = "This is a big sample secret shhhhhh"
        let secret2 = Secret()
        secret2.title = "Top Clearance"
        secret2.date = NSDate()
        secret2.content = "Ha, you were tricked. Silly William"
        secrets += [secret1, secret2]
    }
    
    func loadSecrets() -> [Secret]?{
        return RealmManager._instance.downloadRealm()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return secrets.count
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "SecretTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! SecretTableViewCell
        let secret = secrets[indexPath.row]
        
        cell.titleLabel.text = secret.title
        cell.dateLabel.text  = Helper.DateAsString(secret.date!)
        return cell
    }
 
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            secrets.removeAtIndex(indexPath.row)
            RealmManager._instance.deleteSecret(secrets[indexPath.row])
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
 

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowSecret"{
            let secretViewController = segue.destinationViewController as! SecretViewController
            if let selectedSecretCell = sender as? SecretTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedSecretCell)!
                let selectedSecret = secrets[indexPath.row]
                secretViewController.secret = selectedSecret
             }
        }else if segue.identifier == "AddItem"{
        }
    }
    
    
    @IBAction func unwindToSecretList(sender: UIStoryboardSegue){
        if let sourceViewController = sender.sourceViewController as? SecretViewController, secret = sourceViewController.secret{
            if let selectedIndexPath = tableView.indexPathForSelectedRow{
                secrets[selectedIndexPath.row] = secret
                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
            }else{
                let newIndexPath = NSIndexPath(forRow: secrets.count, inSection: 0)
                secrets.append(secret)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
            }
        }
    }

}
