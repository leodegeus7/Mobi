//
//  LocalCitiesViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/19/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class LocalCitiesViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
  
  @IBOutlet weak var tableViewRadiosInState: UITableView!
  @IBOutlet weak var tableViewCities: UITableView!
  
  var citiesInState = Dictionary<String,[RadioRealm]>()
  var selectedRadio = RadioRealm()
  var citiesArray = [CityRealm]()
  var selectedState = StateRealm()
  var selectedCity = CityRealm()
  
  @IBOutlet weak var height: NSLayoutConstraint!
  @IBOutlet weak var height2: NSLayoutConstraint!
  
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
  
  override func viewDidLoad() {
    
    ///////////////////////////////////////////////////////////
    //MARK: --- INITIAL CONFIG ---
    ///////////////////////////////////////////////////////////
    
    super.viewDidLoad()
    self.title = selectedState.name
    activityIndicator.center = view.center
    activityIndicator.startAnimating()
    activityIndicator.hidden = true

    
    
    ///////////////////////////////////////////////////////////
    //MARK: --- INITIAL REQUEST ---
    ///////////////////////////////////////////////////////////
    
    let managerRadios = RequestManager()
    managerRadios.requestRadiosInStates(selectedState.id) { (resultState) in
      self.selectedState.updateRadiosOfState(resultState)
      if self.selectedState.radios.count == 2 {
        self.height.constant = 240
        self.tableViewRadiosInState.frame = CGRectMake(0, 0, 460, 240)
      } else  if self.selectedState.radios.count == 1 {
        self.height.constant = 120
        self.tableViewRadiosInState.frame = CGRectMake(0, 0, 460, 120)
      } else  if self.selectedState.radios.count >= 3 {
        self.height.constant = 360
        self.tableViewRadiosInState.frame = CGRectMake(0, 0, 460, 360)
      }
      self.tableViewRadiosInState.reloadData()
    }
    
    let managerCities = RequestManager()
    managerCities.requestCitiesInState(selectedState.id) { (resultCities) in
      self.citiesArray = resultCities
      let count = self.citiesArray.count
      self.tableViewCities.frame = CGRectMake(0, 0, 460, 40*CGFloat(count))
      self.height2.constant = 40*CGFloat(count)
      self.tableViewCities.reloadData()
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
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView == tableViewRadiosInState {
      if selectedState.radios.count > 3 {
        return 3
      } else {
        return selectedState.radios.count
      }
    }
    else if tableView == tableViewCities {
      return citiesArray.count
    }
    return 0
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if tableView == tableViewRadiosInState {
      tableView.rowHeight = 120
      return 120
    }
    return 40
  }
  
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if tableView == tableViewCities {
      let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
      cell.textLabel?.text = citiesArray[indexPath.row].name
      return cell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier("radioCell") as! InitialTableViewCell
      cell.labelName.text = selectedState.radios[indexPath.row].name
      cell.labelLocal.text = selectedState.radios[indexPath.row].address.formattedLocal
      cell.imageBig.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(selectedState.radios[indexPath.row].thumbnail)))
      if selectedState.radios[indexPath.row].isFavorite {
        cell.imageSmallOne.image = UIImage(named: "heartRed.png")
      } else {
        cell.imageSmallOne.image = UIImage(named: "heart.png")
      }
      cell.labelDescriptionOne.text = "\(selectedState.radios[indexPath.row].likenumber)"
      cell.imageSmallTwo.image = UIImage(contentsOfFile: "")
      cell.labelDescriptionTwo.text = ""
      return cell
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    view.addSubview(activityIndicator)
    activityIndicator.hidden = false
    tableViewCities.allowsSelection = false
    tableViewRadiosInState.allowsSelection = false
    let manager = RequestManager()
    if tableView == tableViewCities {
      selectedCity = citiesArray[indexPath.row]
      manager.requestRadiosInCity(selectedCity.id, completion: { (resultCity) in
        self.selectedCity.updateRadiosOfCity(resultCity)
        self.tableViewCities.allowsSelection = true
        self.tableViewRadiosInState.allowsSelection = true
        self.activityIndicator.hidden = true
        self.activityIndicator.removeFromSuperview()
        self.performSegueWithIdentifier("detailCity", sender: self)
      })
    } else if tableView == tableViewRadiosInState {
      selectedRadio = selectedState.radios[indexPath.row]
      performSegueWithIdentifier("detailRadio", sender: self)
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "detailCity" {
      let radioListVC = (segue.destinationViewController as! RadioListTableViewController)
      let radios = selectedCity.radios
      radioListVC.radios = Array(radios)
      radioListVC.superSegue = "detailCity"
      
    } else if segue.identifier == "detailRadio" {
      let radioVC = (segue.destinationViewController as! RadioViewController)
      radioVC.actualRadio = selectedRadio
    }
  }
  
  
}
