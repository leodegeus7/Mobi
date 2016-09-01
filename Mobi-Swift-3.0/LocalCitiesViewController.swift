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
  

  @IBOutlet weak var height: NSLayoutConstraint!
  
  @IBOutlet weak var height2: NSLayoutConstraint!

  var citiesArray = [City]()
  var radiosInSelectedState = State()
  
  var selectedCity = City()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    separateInformation()
  
    self.title = radiosInSelectedState.stateName
    
    if radiosInSelectedState.radios.count == 2 {
      height.constant = 240
      tableViewRadiosInState.frame = CGRectMake(0, 0, 460, 240)
    } else  if radiosInSelectedState.radios.count == 1 {
      height.constant = 120
      tableViewRadiosInState.frame = CGRectMake(0, 0, 460, 120)
    } else  if radiosInSelectedState.radios.count >= 3 {
      height.constant = 360
      tableViewRadiosInState.frame = CGRectMake(0, 0, 460, 360)
    }
    
    let count = citiesArray.count
    
    tableViewCities.frame = CGRectMake(0, 0, 460, 40*CGFloat(count))
    height2.constant = 40*CGFloat(count)
        // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  

  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView == tableViewRadiosInState {
      if radiosInSelectedState.radios.count > 3 {
        return 3
      } else {
        return radiosInSelectedState.radios.count
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
      cell.textLabel?.text = citiesArray[indexPath.row].cityName

      return cell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier("radioCell") as! InitialTableViewCell
      cell.labelName.text = radiosInSelectedState.radios[indexPath.row].name
      cell.labelLocal.text = radiosInSelectedState.radios[indexPath.row].address.formattedLocal
      cell.imageBig.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(radiosInSelectedState.radios[indexPath.row].thumbnail)))
      cell.imageSmallOne.image = UIImage(named: "heart.png")
      cell.labelDescriptionOne.text = "\(radiosInSelectedState.radios[indexPath.row].likenumber)"
      cell.imageSmallTwo.image = UIImage(contentsOfFile: "")
      cell.labelDescriptionTwo.text = ""
      return cell
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if tableView == tableViewCities {
            selectedCity = citiesArray[indexPath.row]
      performSegueWithIdentifier("detailCity", sender: self)

    } else if tableView == tableViewRadiosInState {
      selectedRadio = radiosInSelectedState.radios[indexPath.row]
      performSegueWithIdentifier("detailRadio", sender: self)
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "detailCity" {
      let localCitiesVC = (segue.destinationViewController as! RadioListTableViewController)
      let radios = selectedCity.radios
      localCitiesVC.radios = radios
      localCitiesVC.superSegue = "detailCity"
    } else if segue.identifier == "detailRadio" {
      let radioVC = (segue.destinationViewController as! RadioViewController)
      radioVC.actualRadio = selectedRadio
    }
  }
  
  func separateInformation() {
    var citiesName = [String]()
    let allRadiosInState = radiosInSelectedState.radios
    
    var nameOfCities = [String]()
    
    for radio in allRadiosInState {
      if radio.address.city != "" {
        nameOfCities.append(radio.address.city)
      }
    }


    for city in nameOfCities {
      citiesName.append(city)
    }
    citiesName = Util.removeDuplicateStrings(citiesName)
    
    for city in citiesName {
      var radios = [RadioRealm]()
      for radio in allRadiosInState {
        if (city == radio.address.city) {
          radios.append(radio)
          break
        }
      }
      citiesArray.append(City(cityName: city, radios: radios))
    }
    
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
