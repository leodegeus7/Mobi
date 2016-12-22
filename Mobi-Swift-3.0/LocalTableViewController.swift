//
//  LocalTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/9/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//  Criado por Leonardo de Geus // linkedin.com/leodegeus

import UIKit

class LocalTableViewController: UITableViewController,UISearchBarDelegate {
  var data = Dictionary<String,[RadioRealm]>()
  var buttonLateralMenu = UIBarButtonItem()
  var objectArray = [StateRealm]()
  var selectedState = StateRealm()
  var notificationCenter = NSNotificationCenter.defaultCenter()
  
  @IBOutlet weak var menuButton: UIBarButtonItem!
  @IBOutlet weak var searchBar: UISearchBar!
  
  override func viewDidLoad() {
    
    ///////////////////////////////////////////////////////////
    //MARK: --- INITIAL CONFIG ---
    ///////////////////////////////////////////////////////////
    notificationCenter.addObserver(self, selector: #selector(LocalTableViewController.freezeView), name: "freezeViews", object: nil)
    super.viewDidLoad()
    buttonLateralMenu.target = self.revealViewController()
    buttonLateralMenu.action = #selector(SWRevealViewController.revealToggle(_:))
    self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    navigationController?.navigationBar.hidden = false
    self.navigationController?.setNavigationBarHidden(false, animated: false)
    self.title = "Locais"
    
    ///////////////////////////////////////////////////////////
    //MARK: --- REQUEST STATES ---
    ///////////////////////////////////////////////////////////
    
    let manager = RequestManager()
    manager.requestStates() { (resultState) in
      if resultState == true {
        self.tableView.reloadData()
      }
    }
    
  }
  
  func freezeView() {
    
    if DataManager.sharedInstance.menuIsOpen {
      self.tableView.allowsSelection = false
      self.tableView.scrollEnabled = false
    } else {
      self.tableView.allowsSelection = true
      self.tableView.scrollEnabled = true
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- TABLEVIEW DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return DataManager.sharedInstance.allStates.count + 1
    
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.row <= DataManager.sharedInstance.allStates.count-1 {
      let cell = tableView.dequeueReusableCellWithIdentifier("localCell", forIndexPath: indexPath) as! LocalTableViewCell
      cell.labelLocal.text = DataManager.sharedInstance.allStates[indexPath.row].name
      return cell
    } else {
      let cell = UITableViewCell()
      cell.selectionStyle = .None
      //cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
      return cell
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row <= DataManager.sharedInstance.allStates.count-1 {
      self.selectedState = DataManager.sharedInstance.allStates[indexPath.row]
      performSegueWithIdentifier("detailViewCities", sender: self)
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "detailViewCities") {
      let localCitiesVC = (segue.destinationViewController as! LocalCities2TableViewController)
      localCitiesVC.selectedState = selectedState
    }
  }
  
  
  ///////////////////////////////////////////////////////////
  //MARK: --- OTHERS ---
  ///////////////////////////////////////////////////////////
  
  @IBAction func searchButtonTap(sender: AnyObject) {
    DataManager.sharedInstance.instantiateSearch(self.navigationController!)
  }
  
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  @IBAction func menuTap(sender: AnyObject) {
    //searchBar.resignFirstResponder()
    view.endEditing(true)
    UIApplication.sharedApplication().sendAction(buttonLateralMenu.action, to: buttonLateralMenu.target, from: self, forEvent: nil)
  }
  
}
