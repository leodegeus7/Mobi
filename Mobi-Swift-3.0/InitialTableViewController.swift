//
//  InitialTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/9/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import CoreLocation

class InitialTableViewController: UITableViewController, CLLocationManagerDelegate {

  @IBOutlet weak var buttonTop: UIButton!
  @IBOutlet weak var buttonLocal: UIButton!
  @IBOutlet weak var buttonRecents: UIButton!
  @IBOutlet weak var buttonFavorite: UIButton!
  
  let locationManager = CLLocationManager()
  
  var selectedRadioArray:[RadioRealm]!
  enum modes {
    case Top
    case Local
    case Recent
    case Favorite
  }
  
  var selectedMode = modes.Top

  
    override func viewDidLoad() {
        super.viewDidLoad()
        changeTableViewStatus()
        tableView.rowHeight = 120

      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }
  

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return selectedRadioArray.count
    }
  
    override func viewDidAppear(animated: Bool) {
      DataManager.sharedInstance.updateOverdueInterval()
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("initialCell", forIndexPath: indexPath) as! InitialTableViewCell
        switch selectedMode {
          case .Top:
            cell.labelName.text = selectedRadioArray[indexPath.row].name
            cell.labelLocal.text = selectedRadioArray[indexPath.row].formattedLocal
            cell.imageBig.image = UIImage(named: selectedRadioArray[indexPath.row].thumbnail)
            cell.imageSmallOne.image = UIImage(named: "heart.png")
            cell.labelDescriptionOne.text = "\(selectedRadioArray[indexPath.row].likenumber)"
            cell.labelDescriptionTwo.text = ""
            break
        case .Local:
            cell.labelName.text = selectedRadioArray[indexPath.row].name
            cell.labelLocal.text = selectedRadioArray[indexPath.row].formattedLocal
            cell.imageBig.image = UIImage(named: selectedRadioArray[indexPath.row].thumbnail)
            cell.imageSmallOne.image = UIImage(named: "marker.png")
            cell.labelDescriptionOne.text = "\(selectedRadioArray[indexPath.row].distanceFromUser)" + " m"
            cell.imageSmallTwo.image = UIImage(named: "heart.png")
            cell.labelDescriptionTwo.text = "\(selectedRadioArray[indexPath.row].likenumber)"
            break
        case .Recent:
            cell.labelName.text = selectedRadioArray[indexPath.row].name
            cell.labelLocal.text = selectedRadioArray[indexPath.row].formattedLocal
            cell.imageBig.image = UIImage(named: selectedRadioArray[indexPath.row].thumbnail)
            cell.imageSmallOne.image = UIImage(named: "marker.png")
            cell.labelDescriptionOne.text = "\(selectedRadioArray[indexPath.row].distanceFromUser)" + " m"
            cell.imageSmallTwo.image = UIImage(named: "heart.png")
            cell.labelDescriptionTwo.text = "\(selectedRadioArray[indexPath.row].likenumber)"
            break
        default:
            break
        }
      
      


        return cell
    }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if (selectedMode == .Top) {
      return "EM ALTA"
    } else if (selectedMode == .Local) {
      return "AO REDOR"
    } else if (selectedMode == .Favorite) {
      return "FAVORITAS"
    } else if (selectedMode == .Recent) {
      return "HISTÓRICO"
    }
    return ""
  }
  
  @IBAction func buttonTopClick(sender: AnyObject) {
    selectedMode = .Top
    changeTableViewStatus()
  }
  
  @IBAction func buttonLocalClick(sender: AnyObject) {
    if let local = DataManager.sharedInstance.userLocation {
      print(local)
      selectedMode = .Local
      DataManager.sharedInstance.updateRadioDistance()
      changeTableViewStatus()
    } else {
      self.locationManager.requestWhenInUseAuthorization()
      
      if CLLocationManager.locationServicesEnabled() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        selectedMode = .Local
        DataManager.sharedInstance.updateRadioDistance()
        changeTableViewStatus()
        if let local = DataManager.sharedInstance.userLocation {
          print(local)
        } else {
          Util.displayAlert(self, title: "Ops...", message: "Não conseguimos obter sua localização", action: "Ok")
        }
      }
      else {
        Util.displayAlert(self, title: "Ops...", message: "Não conseguimos identificar locais próximos, tente ligar sua localização nos ajustes", action: "Ok")
      }

      
    }
  }

  @IBAction func buttonRecentsClick(sender: AnyObject) {
    selectedMode = .Recent
    DataManager.sharedInstance.updateOverdueInterval()
    changeTableViewStatus()
  }

  @IBAction func buttonFavoriteClick(sender: AnyObject) {
    selectedMode = .Favorite
    changeTableViewStatus()
  }
  
  func changeTableViewStatus() {
    if (selectedMode == .Top) {
      selectedRadioArray = DataManager.sharedInstance.topRadios
    } else if (selectedMode == .Local) {
      selectedRadioArray = DataManager.sharedInstance.localRadios
    } else if (selectedMode == .Favorite) {
      selectedRadioArray = DataManager.sharedInstance.favoriteRadios
    } else if (selectedMode == .Recent) {
      selectedRadioArray = DataManager.sharedInstance.recentsRadios
    } else {
      print("A string ")
    }
    tableView.reloadData()
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let locValue:CLLocationCoordinate2D = manager.location!.coordinate
    let myLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
    DataManager.sharedInstance.userLocation = myLocation
    
  }


}
