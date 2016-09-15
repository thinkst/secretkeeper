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
        navigationItem.leftBarButtonItem = editButtonItem
        
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
        secret1.date = Date()
        secret1.content = "This is a big sample secret shhhhhh"
        let secret2 = Secret()
        secret2.title = "Top Clearance"
        secret2.date = Date()
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return secrets.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SecretTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SecretTableViewCell
        let secret = secrets[(indexPath as NSIndexPath).row]
        
        cell.titleLabel.text = secret.title
        cell.dateLabel.text  = Helper.DateAsString(secret.date!)
        return cell
    }
 
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            secrets.remove(at: (indexPath as NSIndexPath).row)
            RealmManager._instance.deleteSecret(secrets[(indexPath as NSIndexPath).row])
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSecret"{
            let secretViewController = segue.destination as! SecretViewController
            if let selectedSecretCell = sender as? SecretTableViewCell {
                let indexPath = tableView.indexPath(for: selectedSecretCell)!
                let selectedSecret = secrets[(indexPath as NSIndexPath).row]
                secretViewController.secret = selectedSecret
             }
        }else if segue.identifier == "AddItem"{
        }
    }
    
    
    @IBAction func unwindToSecretList(_ sender: UIStoryboardSegue){
        if let sourceViewController = sender.source as? SecretViewController, let secret = sourceViewController.secret{
            if let selectedIndexPath = tableView.indexPathForSelectedRow{
                secrets[(selectedIndexPath as NSIndexPath).row] = secret
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }else{
                let newIndexPath = IndexPath(row: secrets.count, section: 0)
                secrets.append(secret)
                tableView.insertRows(at: [newIndexPath], with: .bottom)
            }
        }
    }

}
