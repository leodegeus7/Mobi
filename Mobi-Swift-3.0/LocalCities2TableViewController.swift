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
  
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Cidades"
    activityIndicator.center = view.center
    activityIndicator.startAnimating()
    activityIndicator.isHidden = true
    
    self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "Voltar", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    
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
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if citiesArray.count == 0 {
      return 0
    }
    return citiesArray.count + 1
    
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    return 40
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row <= citiesArray.count-1 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "localCityCell", for: indexPath) as! LocalCitiesTableViewCell
      cell.labelLocal.text = citiesArray[indexPath.row].name
      return cell
    } else {
      let cell = UITableViewCell()
      //cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
      cell.selectionStyle = .none
      return cell
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.row <= citiesArray.count-1 {
      view.addSubview(activityIndicator)
      activityIndicator.isHidden = false
      tableView.allowsSelection = false
      let manager = RequestManager()
      selectedCity = citiesArray[indexPath.row]
      manager.requestRadiosInCity(selectedCity.id,pageNumber:0,pageSize:10, completion: { (resultCity) in
        self.selectedCity.updateRadiosOfCity(resultCity)
        self.tableView.allowsSelection = true
        self.activityIndicator.isHidden = true
        self.activityIndicator.removeFromSuperview()
        self.performSegue(withIdentifier: "detailCity", sender: self)
      })
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "detailCity" {
      let radioListVC = (segue.destination as! RadioListTableViewController)
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
