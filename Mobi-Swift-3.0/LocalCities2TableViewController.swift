//
//  LocalCities2TableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 9/14/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class LocalCities2TableViewController: UITableViewController {
  
  var citiesInState = Dictionary<String,[RadioRealm]>()
  var selectedRadio = RadioRealm()
  var citiesArray = [CityRealm]()
  var selectedState = StateRealm()
  var selectedCity = CityRealm()
  
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Cidades"
    activityIndicator.center = view.center
    activityIndicator.startAnimating()
    activityIndicator.hidden = true
    
    self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "Voltar", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
    
    ///////////////////////////////////////////////////////////
    //MARK: --- INITIAL REQUEST ---
    ///////////////////////////////////////////////////////////
    
    let managerCities = RequestManager()
    managerCities.requestCitiesInState(selectedState.id) { (resultCities) in
      self.citiesArray = resultCities
      self.tableView.reloadData()
      self.selectedState.updateCityOfState(resultCities)
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
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if citiesArray.count == 0 {
      return 0
    }
    return citiesArray.count + 1
    
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
    return 40
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.row <= citiesArray.count-1 {
      let cell = tableView.dequeueReusableCellWithIdentifier("localCityCell", forIndexPath: indexPath) as! LocalCitiesTableViewCell
      cell.labelLocal.text = citiesArray[indexPath.row].name
      return cell
    } else {
      let cell = UITableViewCell()
      //cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
      cell.selectionStyle = .None
      return cell
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row <= citiesArray.count-1 {
      view.addSubview(activityIndicator)
      activityIndicator.hidden = false
      tableView.allowsSelection = false
      let manager = RequestManager()
      selectedCity = citiesArray[indexPath.row]
      manager.requestRadiosInCity(selectedCity.id,pageNumber:0,pageSize:10, completion: { (resultCity) in
        self.selectedCity.updateRadiosOfCity(resultCity)
        self.tableView.allowsSelection = true
        self.activityIndicator.hidden = true
        self.activityIndicator.removeFromSuperview()
        self.performSegueWithIdentifier("detailCity", sender: self)
      })
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "detailCity" {
      let radioListVC = (segue.destinationViewController as! RadioListTableViewController)
      let radios = selectedCity.radios
      radioListVC.radios = Array(radios)
      radioListVC.superSegue = "detailCity"
      radioListVC.idCitySelected = selectedCity.id
    }
    
    let backButton = UIBarButtonItem()
    backButton.title = "Voltar"
    navigationItem.backBarButtonItem = backButton
  }
  
  
}
