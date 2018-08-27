//
//  RssTypesTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 12/1/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class RssTypesTableViewController: UITableViewController {
  
  @IBOutlet weak var backButton: UIBarButtonItem!
  @IBOutlet weak var searchButton: UIBarButtonItem!
  
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
  var newsType = [RSS]()
  var selectRSS:RSS!
  var notificationCenter = NotificationCenter.default
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Notícias"
    notificationCenter.addObserver(self, selector: #selector(RssTypesTableViewController.freezeView), name: NSNotification.Name(rawValue: "freezeViews"), object: nil)
    
    activityIndicator.center = view.center
    activityIndicator.startAnimating()
    activityIndicator.isHidden = false
    self.view.addSubview(activityIndicator)
    backButton.target = self.revealViewController()
    backButton.action = #selector(SWRevealViewController.revealToggle(_:))
    backButton.tintColor = UIColor.white
    searchButton.tintColor = UIColor.white
    self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    let rssmanager = RequestManager()
    rssmanager.requestRSS { (resultRSS) in
      self.activityIndicator.isHidden = true
      self.activityIndicator.removeFromSuperview()
      self.newsType = resultRSS
      self.tableView.reloadData()
      
    }
  }
  
  func freezeView() {
    
    if DataManager.sharedInstance.menuIsOpen {
      self.tableView.allowsSelection = false
      self.tableView.isScrollEnabled = false
    } else {
      self.tableView.allowsSelection = true
      self.tableView.isScrollEnabled = true
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func searchButtonTap(_ sender: AnyObject) {
    DataManager.sharedInstance.instantiateSearch(self.navigationController!)
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return newsType.count
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RssTableViewCell
    let colorAlpha = DataManager.sharedInstance.interfaceColor.color.withAlphaComponent(0.2)
    let viewSelected = UIView()
    viewSelected.backgroundColor = colorAlpha
    cell.selectedBackgroundView = viewSelected
    if newsType[indexPath.row].desc == "Abert" {
      cell.imageRSS.image = UIImage(named: "logoABERT.png")
    } else if newsType[indexPath.row].desc.contains("G1"){
      cell.imageRSS.image = UIImage(named: "g1.png")
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectRSS = newsType[indexPath.row]
    self.performSegue(withIdentifier: "segueRSS", sender: self)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "segueRSS" {
      let radioVC = (segue.destination as! NewsTableViewController)
      radioVC.rss = selectRSS
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
