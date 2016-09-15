//
//  LocalTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/9/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//  Criado por Leonardo de Geus // linkedin.com/leodegeus

import UIKit

class LocalTableViewController: UITableViewController,UISearchBarDelegate {
  var isSearchOn = false
  var searchResults = [StateRealm]()
  var data = Dictionary<String,[RadioRealm]>()
  var buttonLateralMenu = UIBarButtonItem()
  var objectArray = [StateRealm]()
  var selectedState = StateRealm()
  
  
  @IBOutlet weak var menuButton: UIBarButtonItem!
  @IBOutlet weak var searchBar: UISearchBar!
  
  override func viewDidLoad() {
    
    ///////////////////////////////////////////////////////////
    //MARK: --- INITIAL CONFIG ---
    ///////////////////////////////////////////////////////////
    
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
    if isSearchOn == true && !searchResults.isEmpty {
      return searchResults.count
    } else {
      return DataManager.sharedInstance.allStates.count
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("localCell", forIndexPath: indexPath) as! LocalTableViewCell
    if isSearchOn == true && !searchResults.isEmpty {
      cell.labelLocal.text = searchResults[indexPath.row].name
    } else {
      cell.labelLocal.text = DataManager.sharedInstance.allStates[indexPath.row].name
    }
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if !isSearchOn {
      self.selectedState = DataManager.sharedInstance.allStates[indexPath.row]
    } else {
      self.selectedState = searchResults[indexPath.row]
    }
    performSegueWithIdentifier("detailViewCities", sender: self)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "detailViewCities") {
          let localCitiesVC = (segue.destinationViewController as! LocalCities2TableViewController)
          localCitiesVC.selectedState = selectedState
        }
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- SEARCHBAR DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    searchBar.text = nil
    searchBar.showsCancelButton = false
    searchBar.resignFirstResponder()
    isSearchOn = false
    self.tableView.reloadData()
  }
  
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    searchBar.showsCancelButton = true
    if !searchText.isEmpty {
      isSearchOn = true
      self.filterContentForSearchText(searchText)
      self.tableView.reloadData()
    }
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- OTHERS ---
  ///////////////////////////////////////////////////////////
  
  @IBAction func searchButtonTap(sender: AnyObject) {
    DataManager.sharedInstance.instantiateSearch(self.navigationController!)
  }
  
  func filterContentForSearchText(text: String) {
    searchResults.removeAll(keepCapacity: false)
    for state in objectArray {
      let stringToLookFor = state.name as NSString
      if stringToLookFor.localizedCaseInsensitiveContainsString(text as String) {
        searchResults.append(state)
      }
    }
  }
  
  func collectionViewBackgroundTapped() {
    searchBar.resignFirstResponder()
  }
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  @IBAction func menuTap(sender: AnyObject) {
    searchBar.resignFirstResponder()
    view.endEditing(true)
    UIApplication.sharedApplication().sendAction(buttonLateralMenu.action, to: buttonLateralMenu.target, from: self, forEvent: nil)
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  

}
