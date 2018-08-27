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
  
  
  @IBOutlet weak var buttonInfoUsers: UIBarButtonItem!
  
  var adClicked = AdsInfo()
  var isFirstTime = true
  var adsInfo = [AdsInfo]()
  var local = [LocalVAds]()
  override func viewDidLoad() {
    super.viewDidLoad()
    let request = RequestManager()
    request.requestUserInfo { (result) in
      DispatchQueue.main.async {
        self.adsInfo = result
        self.tableView.reloadData()
        var count = 0
        for user in result {
          if user.lastCoordUpdate != "" {
            if Util.convertStringToNSDate(user.lastCoordUpdate).timeIntervalSince(Date()) > -86400 {
              count+=1
            }
          }
        }
        self.buttonInfoUsers.title = "User online in last 24 hours: \(count)"
        
      }
    }
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(VAdsInfoTableViewController.goView))
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.navigationController?.setToolbarHidden(false, animated: true)
  }
  
  // MARK: - Table view data source
  
  
  func goView() {
    self.performSegue(withIdentifier: "show", sender: self)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let ident = (segue.identifier)!
    if ident == "show" {
      let createVC = (segue.destination as! VAdsInfo2ViewController)
      createVC.adsInfo = adsInfo
      
    } else if ident == "show2" {
      let createVC = (segue.destination as! VAdsInfo2ViewController)
      createVC.adsInfo = adsInfo
      createVC.local = local
      createVC.titleVar = adClicked.name
      createVC.initialCoordinate = CLLocation(latitude: Double(adClicked.la)!, longitude: Double(adClicked.lo)!)
    }
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return adsInfo.count
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "adsCell", for: indexPath) as? VAdsInfoTableViewCell
    cell?.nameU.text = "\(adsInfo[indexPath.row].server)  -  \(adsInfo[indexPath.row].name)"
    cell?.firstU.text = "\(adsInfo[indexPath.row].la)"
    cell?.firstU2.text = "\(adsInfo[indexPath.row].lo)"
    
    if adsInfo[indexPath.row].image  == "avatar.png" {
      cell?.imageU.image = UIImage(named: "avatar.png")
    } else {
      cell?.imageU.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(adsInfo[indexPath.row].image)))
    }
    if adsInfo[indexPath.row].lastCoordUpdate != "" {
      cell?.secondU.text = "\(Util.getOverdueInterval(Util.convertStringToNSDate(adsInfo[indexPath.row].lastCoordUpdate)))"
      // Configure the cell...
    } else {
      cell?.secondU.text = "Não compartilhou"
    }
    if adsInfo[indexPath.row].image != "" && adsInfo[indexPath.row].image != "avatar.png" {
      cell?.imageU.backgroundColor = UIColor.flatNavyBlue
    }
    
    return cell!
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    adClicked = adsInfo[indexPath.row]
    let request = RequestManager()
    request.getLocal(adClicked.server, completion: { (result) in
      self.local = result
      self.performSegue(withIdentifier: "show2", sender: self)
    })
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
