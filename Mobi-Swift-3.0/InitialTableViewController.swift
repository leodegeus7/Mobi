//
//  InitialTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/9/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import CoreLocation
import SideMenu
import Kingfisher
import Firebase

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
  var selectedRadio = RadioRealm()
  var notificationCenter = NSNotificationCenter.defaultCenter()
  @IBOutlet weak var openMenu: UIBarButtonItem!
    

  
  override func viewDidLoad() {
    if DataManager.sharedInstance.allRadios.count == 0 {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("loadView") as? LoadViewController
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let windows = app.window
        windows?.rootViewController?.presentViewController(vc!, animated: false, completion: {
        })
        
    }
    notificationCenter.addObserver(self, selector: #selector(InitialTableViewController.reloadData), name: "reloadData", object: nil)
    super.viewDidLoad()
    changeTableViewStatus()
    tableView.rowHeight = 120
    //let menuButton = UIBarButtonItem(title: "Menu", style: .Plain, target: self, action:#selector(showMenu))
    
    openMenu.target = self.revealViewController()
    openMenu.action = #selector(SWRevealViewController.revealToggle(_:))
    
    if revealViewController() != nil {
      openMenu.target = self.revealViewController()
      openMenu.action = #selector(SWRevealViewController.revealToggle(_:))
    }
    self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())

    
    
  }
  
    
    func reloadData() {
        selectedMode = modes.Top
        changeTableViewStatus()
        tableView.reloadData()
        if ((self.refreshControl?.refreshing) != nil) {
            self.refreshControl?.endRefreshing()
        }
    }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    
    return 1
  }
  
  func showMenu () {
    self.performSegueWithIdentifier("initialView", sender: self)
  }
  
  
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return selectedRadioArray.count
  }
  
  override func viewDidAppear(animated: Bool) {
    DataManager.sharedInstance.updateAllOverdueInterval()
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("initialCell", forIndexPath: indexPath) as! InitialTableViewCell
    switch selectedMode {
    case .Top:
      cell.labelName.text = selectedRadioArray[indexPath.row].name
      if let address = selectedRadioArray[indexPath.row].address {
        cell.labelLocal.text = address.formattedLocal
      }
      cell.imageBig.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(selectedRadioArray[indexPath.row].thumbnail)))
      cell.imageSmallOne.image = UIImage(named: "heart.png")
      cell.labelDescriptionOne.text = "\(selectedRadioArray[indexPath.row].likenumber)"
      cell.widthTextOne.constant = 30
      cell.imageSmallTwo.image = UIImage(contentsOfFile: "")
      cell.labelDescriptionTwo.text = ""
      
      break
    case .Local:
      cell.labelName.text = selectedRadioArray[indexPath.row].name
      if let address = selectedRadioArray[indexPath.row].address {
        cell.labelLocal.text = address.formattedLocal
      }
      cell.imageBig.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(selectedRadioArray[indexPath.row].thumbnail)))
      cell.imageSmallOne.image = UIImage(named: "marker.png")
      cell.labelDescriptionOne.text = "\(selectedRadioArray[indexPath.row].distanceFromUser)" + " m"
      cell.widthTextOne.constant = 80
      cell.widthTextTwo.constant = 30
      cell.imageSmallTwo.image = UIImage(named: "heart.png")
      cell.labelDescriptionTwo.text = "\(selectedRadioArray[indexPath.row].likenumber)"
      break
    case .Recent:
      cell.labelName.text = selectedRadioArray[indexPath.row].name
      if let address = selectedRadioArray[indexPath.row].address {
        cell.labelLocal.text = address.formattedLocal
      }
      cell.imageBig.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(selectedRadioArray[indexPath.row].thumbnail)))
      cell.imageSmallOne.image = UIImage(named: "clock-icon.png")
       if let _ = DataManager.sharedInstance.recentsRadios[0].lastAccessDate {
        cell.labelDescriptionOne.text = Util.getOverdueInterval(selectedRadioArray[indexPath.row].lastAccessDate)
      }
      cell.imageSmallTwo.image = UIImage(named: "heart.png")
      cell.labelDescriptionTwo.text = "\(selectedRadioArray[indexPath.row].likenumber)"
      cell.widthTextOne.constant = 110
      cell.widthTextTwo.constant = 30
      break
    case .Favorite:
      cell.labelName.text = selectedRadioArray[indexPath.row].name
      if let address = selectedRadioArray[indexPath.row].address {
        cell.labelLocal.text = address.formattedLocal
      }
      cell.imageBig.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(selectedRadioArray[indexPath.row].thumbnail)))
      cell.imageSmallOne.image = UIImage(named: "heart.png")
      cell.labelDescriptionOne.text = "\(selectedRadioArray[indexPath.row].likenumber)"
      cell.widthTextOne.constant = 30
      cell.imageSmallTwo.image = UIImage(contentsOfFile: "")
      cell.labelDescriptionTwo.text = ""
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
    DataManager.sharedInstance.updateAllOverdueInterval()
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
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    switch selectedMode {
    case .Favorite:
      selectedRadio = DataManager.sharedInstance.favoriteRadios[indexPath.row]
    case .Local:
      selectedRadio = DataManager.sharedInstance.localRadios[indexPath.row]
    case .Recent:
      selectedRadio = DataManager.sharedInstance.recentsRadios[indexPath.row]
    case .Top:
      selectedRadio = DataManager.sharedInstance.topRadios[indexPath.row]
    }
    performSegueWithIdentifier("detailRadio", sender: self)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "detailRadio" {
      let radioVC = (segue.destinationViewController as! RadioViewController)
      radioVC.actualRadio = selectedRadio
    }
  }
  
    func requestInitialInformation(completion: (resultAddress: Bool) -> Void) {
        let manager = RequestManager()
        manager.requestStationUnits(.stationUnits) { (result) in
            let data = Data.response(result)
            print(result)
            print(data)
            let array = result["data"] as! NSArray
            for singleResult in array {
                let dic = singleResult as! NSDictionary
                let radio = RadioRealm(id: "\(dic["id"] as! Int)", name: dic["name"] as! String, thumbnail: dic["image"]!["identifier40"] as! String, repository: true)
                DataManager.sharedInstance.allRadios.append(radio)
            }
            DataBaseTest.infoWithoutRadios()
            completion(resultAddress: true)
            //self.performSegueWithIdentifier("initialSegue", sender: self)
        }
    }
  @IBAction func searchButtonTap(sender: AnyObject) {
    DataManager.sharedInstance.instantiateSearch(self.navigationController!)
  }
}
