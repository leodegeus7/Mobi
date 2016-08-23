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

  @IBOutlet weak var openMenu: UIBarButtonItem!
  
    override func viewDidLoad() {
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
        setupSideMenu()

      
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
            cell.labelLocal.text = selectedRadioArray[indexPath.row].address.formattedLocal
            cell.imageBig.image = UIImage(named: selectedRadioArray[indexPath.row].thumbnail)
            cell.imageSmallOne.image = UIImage(named: "heart.png")
            cell.labelDescriptionOne.text = "\(selectedRadioArray[indexPath.row].likenumber)"
            cell.imageSmallTwo.image = UIImage(contentsOfFile: "")
            cell.labelDescriptionTwo.text = ""
            break
        case .Local:
            cell.labelName.text = selectedRadioArray[indexPath.row].name
            cell.labelLocal.text = selectedRadioArray[indexPath.row].address.formattedLocal
            cell.imageBig.image = UIImage(named: selectedRadioArray[indexPath.row].thumbnail)
            cell.imageSmallOne.image = UIImage(named: "marker.png")
            cell.labelDescriptionOne.text = "\(selectedRadioArray[indexPath.row].distanceFromUser)" + " m"
            cell.imageSmallTwo.image = UIImage(named: "heart.png")
            cell.labelDescriptionTwo.text = "\(selectedRadioArray[indexPath.row].likenumber)"
            break
        case .Recent:
            cell.labelName.text = selectedRadioArray[indexPath.row].name
            cell.labelLocal.text = selectedRadioArray[indexPath.row].address.formattedLocal
            cell.imageBig.image = UIImage(named: selectedRadioArray[indexPath.row].thumbnail)
            cell.imageSmallOne.image = UIImage(named: "marker.png")
            cell.labelDescriptionOne.text = "\(selectedRadioArray[indexPath.row].distanceFromUser)" + " m"
            cell.imageSmallTwo.image = UIImage(named: "heart.png")
            cell.labelDescriptionTwo.text = Util.getOverdueInterval(selectedRadioArray[indexPath.row].lastAccessDate)
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
  
  private func setupSideMenu() {
    // Define the menus
//    SideMenuManager.menuLeftNavigationController = storyboard!.instantiateViewControllerWithIdentifier("LeftMenuNavigationController") as? UISideMenuNavigationController
//
//    
//    // Enable gestures. The left and/or right menus must be set up above for these to work.
//    // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
//    SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
//    SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
//    
//    // Set up a cool background image for demo purposes
//    SideMenuManager.menuAnimationBackgroundColor = UIColor(patternImage: UIImage(named: "background")!)
  }


}
