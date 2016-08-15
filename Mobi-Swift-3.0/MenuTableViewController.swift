//
//  MenuTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/8/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {
    var menuArray = ["Início","Gêneros","Locais","Notícias","Dormir","Configurações"]
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      
      
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      
      if (indexPath.row == 0) {
        let userCell = tableView.dequeueReusableCellWithIdentifier("TopCell", forIndexPath: indexPath) as! TopMenuTableViewCell
        userCell.nameUser.text = "Fulano"
        //let imageUserVar = UIImage()
        //cell.imageUser.image =
        return userCell
        
      } else if(indexPath.row != 5) {
        let firstTypeCell = tableView.dequeueReusableCellWithIdentifier("FirstCell", forIndexPath: indexPath) as! FirstTypeMenuTableViewCell
        firstTypeCell.labelText.text = menuArray[indexPath.row - 1]

        return firstTypeCell
      }
      
      let secondTypeCell = tableView.dequeueReusableCellWithIdentifier("SecondCell", forIndexPath: indexPath) as! SecondMenuTypeTableViewCell
      secondTypeCell.labelText.text = menuArray[4]
      
      return secondTypeCell
      

    }

  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if (indexPath.row == 0) {
      return 70
    }
    return 40
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    if (indexPath.row == 0) {
      self.performSegueWithIdentifier("profileScreen", sender: self)
    } else if (indexPath.row == 1) {
      self.performSegueWithIdentifier("initialScreen", sender: self)
    } else if (indexPath.row == 2) {
      self.performSegueWithIdentifier("genreScreen", sender: self)
    } else if (indexPath.row == 3) {
      self.performSegueWithIdentifier("localScreen", sender: self)
    } else if (indexPath.row == 4) {
      self.performSegueWithIdentifier("newsScreen", sender: self)
    } else if (indexPath.row == 6) {
      self.performSegueWithIdentifier("configScreen", sender: self)
    }
  }
  
  @IBAction func sleepFunction(sender: AnyObject) {
    let sleepAlert = UIAlertController(title: "Escolha um período", message: "hello", preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    var sheets = [UIAlertAction]()
    let values = ["15 min","30 min","45 min","60 min","90 min"]
    for value in values {
      let actionOption = UIAlertAction(title: value, style: UIAlertActionStyle.Default, handler: { (action) in

      })
      sleepAlert.addAction(actionOption)
      sheets.append(actionOption)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
    sleepAlert.addAction(cancelAction)
    
    presentViewController(sleepAlert, animated: true, completion:nil)
  }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
