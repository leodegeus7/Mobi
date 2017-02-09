//
//  AdsInfoTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 2/9/17.
//  Copyright © 2017 Access Mobile. All rights reserved.
//

import UIKit
import Kingfisher
import MapKit

class VAdsInfoTableViewController: UITableViewController {
  var adClicked = AdsInfo()
  var isFirstTime = true
  var adsInfo = [AdsInfo]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let request = RequestManager()
    request.requestUserInfo { (result) in
      dispatch_async(dispatch_get_main_queue()) {
        self.adsInfo = result
        self.tableView.reloadData()
      }
    }
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: #selector(VAdsInfoTableViewController.goView))
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  
  func goView() {
    self.performSegueWithIdentifier("show", sender: self)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let ident = (segue.identifier)!
    if ident == "show" {
      let createVC = (segue.destinationViewController as! VAdsInfo2ViewController)
      createVC.adsInfo = adsInfo
    } else if ident == "show2" {
      let createVC = (segue.destinationViewController as! VAdsInfo2ViewController)
      createVC.adsInfo = adsInfo
      createVC.initialCoordinate = CLLocation(latitude: Double(adClicked.la)!, longitude: Double(adClicked.lo)!)
    }
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return adsInfo.count
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("adsCell", forIndexPath: indexPath) as? VAdsInfoTableViewCell
    cell?.nameU.text = "\(adsInfo[indexPath.row].server)  -  \(adsInfo[indexPath.row].name)"
    cell?.firstU.text = "\(adsInfo[indexPath.row].la)"
    cell?.firstU2.text = "\(adsInfo[indexPath.row].lo)"
    cell?.secondU.text = "\(Util.getOverdueInterval(Util.convertStringToNSDate(adsInfo[indexPath.row].lastCoordUpdate)))"
    // Configure the cell...
    
    return cell!
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if isFirstTime {
      isFirstTime = false
      let cell = tableView.cellForRowAtIndexPath(indexPath) as! VAdsInfoTableViewCell
      adClicked = adsInfo[indexPath.row]
      cell.imageU.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(adsInfo[indexPath.row].image)))
    } else {
      if adsInfo[indexPath.row] == adClicked {
        isFirstTime = true
        self.performSegueWithIdentifier("show2", sender: self)
      } else {
        tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow!, animated: true)
        adClicked = adsInfo[indexPath.row]
      }
    }
    
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
