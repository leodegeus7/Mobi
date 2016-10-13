//
//  InitialTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/9/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//  Criado por Leonardo de Geus // linkedin.com/leodegeus

import UIKit
import CoreLocation
import SideMenu
import Kingfisher
import Firebase

class InitialTableViewController: UITableViewController, CLLocationManagerDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate {
  
  
  @IBOutlet weak var segmentedControlMenu: UISegmentedControl!
  
  
  @IBOutlet weak var openMenu: UIBarButtonItem!
  
  var selectedMode = modes.Top
  var selectedRadio = RadioRealm()
  var notificationCenter = NSNotificationCenter.defaultCenter()
  let locationManager = CLLocationManager()
  var selectedRadioArray:[RadioRealm]!
  enum modes {
    case Top
    case Local
    case Recent
    case Favorite
  }
  
  override func viewDidLoad() {
    
    ///////////////////////////////////////////////////////////
    //MARK: --- BASIC CONFIG ---
    ///////////////////////////////////////////////////////////
    
    if !DataManager.sharedInstance.isLoadScreenAppered {
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("loadView") as? LoadViewController
      let app = UIApplication.sharedApplication().delegate as! AppDelegate
      let windows = app.window
      windows?.rootViewController?.presentViewController(vc!, animated: false, completion: {
      })
      DataManager.sharedInstance.isLoadScreenAppered = true
    }
    super.viewDidLoad()
    notificationCenter.addObserver(self, selector: #selector(InitialTableViewController.reloadData), name: "reloadData", object: nil)
    changeTableViewStatus()
    tableView.rowHeight = 120
    openMenu.target = self.revealViewController()
    openMenu.action = #selector(SWRevealViewController.revealToggle(_:))
    if revealViewController() != nil {
      openMenu.target = self.revealViewController()
      openMenu.action = #selector(SWRevealViewController.revealToggle(_:))
    }
    self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    tableView.registerNib(UINib(nibName: "CellDesign",bundle:nil), forCellReuseIdentifier: "baseCell")
    tableView.emptyDataSetSource = self
    tableView.emptyDataSetDelegate = self
    tableView.tableFooterView = UIView()
    let image1 = Util.imageResize(UIImage(named: "icone-grafico.png")!, sizeChange: CGSize(width: 20, height: 20))
    let image2 = Util.imageResize(UIImage(named: "icone-local.png")!, sizeChange: CGSize(width: 20, height: 20))
    let image3 = Util.imageResize(UIImage(named: "icone-historico.png")!, sizeChange: CGSize(width: 20, height: 20))
    let image4 = Util.imageResize(UIImage(named: "icone-coracao.png")!, sizeChange: CGSize(width: 20, height: 20))
    segmentedControlMenu.setImage(image1, forSegmentAtIndex: 0)
    segmentedControlMenu.setImage(image2, forSegmentAtIndex: 1)
    segmentedControlMenu.setImage(image3, forSegmentAtIndex: 2)
    segmentedControlMenu.setImage(image4, forSegmentAtIndex: 3)
    selectedRadioArray = DataManager.sharedInstance.topRadios
    
    ///////////////////////////////////////////////////////////
    //MARK: --- INITIAL REQUEST ---
    ///////////////////////////////////////////////////////////
    
    let requestTest = RequestManager()
    requestTest.testServer { (result) in
      if !result {
        Util.displayAlert(self, title: "Atenção", message: "Tivemos um problema ao conectar aos nossos servidores", action: "Ok")
      }
    }
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- DATA ---
  ///////////////////////////////////////////////////////////
  
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
  
  ///////////////////////////////////////////////////////////
  //MARK: --- TABLEVIEW DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return selectedRadioArray.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("baseCell", forIndexPath: indexPath) as! InitialTableViewCell
    switch selectedMode {
    case .Top:
      cell.labelName.text = selectedRadioArray[indexPath.row].name
      if let address = selectedRadioArray[indexPath.row].address {
        cell.labelLocal.text = address.formattedLocal
      }
      cell.imageBig.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(selectedRadioArray[indexPath.row].thumbnail)))
      cell.labelDescriptionOne.text = "\(selectedRadioArray[indexPath.row].likenumber)"
      cell.widthTextOne.constant = 30
      cell.imageSmallTwo.image = UIImage(contentsOfFile: "")
      cell.labelDescriptionTwo.text = ""
      if selectedRadioArray[indexPath.row].isFavorite {
        cell.imageSmallOne.image = UIImage(named: "heartRed.png")
      } else {
        cell.imageSmallOne.image = UIImage(named: "heart.png")
      }
      break
    case .Local:
      cell.labelName.text = selectedRadioArray[indexPath.row].name
      if let address = selectedRadioArray[indexPath.row].address {
        cell.labelLocal.text = address.formattedLocal
      }
      cell.imageBig.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(selectedRadioArray[indexPath.row].thumbnail)))
      cell.imageSmallOne.image = UIImage(named: "marker.png")
      if selectedRadioArray[indexPath.row].resetDistanceFromUser() {
        cell.labelDescriptionOne.text = "\(Util.getDistanceString(selectedRadioArray[indexPath.row].distanceFromUser))"
      }
      cell.widthTextOne.constant = 80
      cell.widthTextTwo.constant = 30
      if selectedRadioArray[indexPath.row].isFavorite {
        cell.imageSmallTwo.image = UIImage(named: "heartRed.png")
      } else {
        cell.imageSmallTwo.image = UIImage(named: "heart.png")
      }
      cell.labelDescriptionTwo.text = "\(selectedRadioArray[indexPath.row].likenumber)"
      break
    case .Recent:
      cell.labelName.text = selectedRadioArray[indexPath.row].name
      if let address = selectedRadioArray[indexPath.row].address {
        cell.labelLocal.text = address.formattedLocal
      }
      cell.imageBig.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(selectedRadioArray[indexPath.row].thumbnail)))
      cell.imageSmallOne.image = UIImage(named: "clock-icon.png")
      if (NSDate().timeIntervalSinceDate(selectedRadioArray[indexPath.row].lastAccessDate) > 1) {
        cell.labelDescriptionOne.text = Util.getOverdueInterval(selectedRadioArray[indexPath.row].lastAccessDate)
      } else {
        cell.labelDescriptionOne.text = ""
      }
      if selectedRadioArray[indexPath.row].isFavorite {
        cell.imageSmallTwo.image = UIImage(named: "heartRed.png")
      } else {
        cell.imageSmallTwo.image = UIImage(named: "heart.png")
      }
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
      if selectedRadioArray[indexPath.row].isFavorite {
        cell.imageSmallOne.image = UIImage(named: "heartRed.png")
      } else {
        cell.imageSmallOne.image = UIImage(named: "heart.png")
      }
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
  
  static func distanceBetweenTwoLocationsMeters(source:CLLocation,destination:CLLocation) -> Int{
    let distanceMeters = source.distanceFromLocation(destination)
    return Int(distanceMeters)
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
    DataManager.sharedInstance.instantiateRadioDetailView(navigationController!, radio: selectedRadio)
    
    
  }
  
  override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    let manager = RequestManager()
    
    
    
    if selectedRadioArray[indexPath.row].isFavorite {
      let favorite = UITableViewRowAction(style: .Normal, title: "Desfavoritar") { action, index in
        self.selectedRadioArray[indexPath.row].updateIsFavorite(false)
        self.selectedRadioArray[indexPath.row].removeOneLikesNumber()
        manager.deleteFavRadio(self.selectedRadioArray[indexPath.row], completion: { (result) in
          manager.requestUserFavorites({ (resultFav) in
          })
        })
        if self.selectedMode == .Favorite {
          DataManager.sharedInstance.favoriteRadios.removeAtIndex(indexPath.row)
          self.selectedRadioArray = DataManager.sharedInstance.favoriteRadios
          tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
          if DataManager.sharedInstance.favoriteRadios.count == 0 {
            tableView.reloadData()
          }
        } else {
          self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
      }
      favorite.backgroundColor = UIColor.orangeColor()
      return [favorite]
    } else {
      let favorite = UITableViewRowAction(style: .Normal, title: "Favoritar") { action, index in
        self.selectedRadioArray[indexPath.row].updateIsFavorite(true)
        self.selectedRadioArray[indexPath.row].addOneLikesNumber()
        manager.favRadio(self.selectedRadioArray[indexPath.row], completion: { (result) in
          self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
          
        })
        
      }
      
      favorite.backgroundColor = UIColor.orangeColor()
      return [favorite]
    }
    
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  @IBAction func segmentedAction(sender: UISegmentedControl) {
    switch segmentedControlMenu.selectedSegmentIndex {
    case 0:
      selectedMode = .Top
    case 1:
      if let local = DataManager.sharedInstance.userLocation {
        print(local)
        selectedMode = .Local
        DataManager.sharedInstance.updateRadioDistance()
      } else {
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
          locationManager.delegate = self
          locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
          locationManager.startUpdatingLocation()
          selectedMode = .Local
          DataManager.sharedInstance.updateRadioDistance()
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
      break
    case 2:
      selectedMode = .Recent
      DataManager.sharedInstance.updateAllOverdueInterval()
      break
    case 3:
      selectedMode = .Favorite
      break
    default: break
    }
    changeTableViewStatus()
  }
  
  
  ///////////////////////////////////////////////////////////
  //MARK: --- VIEW FUNCTIONS ---
  ///////////////////////////////////////////////////////////
  
  override func viewWillAppear(animated: Bool) {
    tableView.reloadData()
    
  }
  
  override func viewDidAppear(animated: Bool) {
    if DataManager.sharedInstance.recentsRadios.count > 0 {
      DataManager.sharedInstance.updateAllOverdueInterval()
    }
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- DATA FUNCTIONS ---
  ///////////////////////////////////////////////////////////
  
  func changeTableViewStatus() {
    let manager = RequestManager()
    if (selectedMode == .Top) {
      selectedRadioArray = DataManager.sharedInstance.topRadios
      manager.requestTopLikesRadios(0, pageSize: 20, completion: { (resultTop) in
        self.selectedRadioArray = DataManager.sharedInstance.topRadios
        self.tableView.reloadData()
      })
    } else if (selectedMode == .Local) {
      selectedRadioArray = DataManager.sharedInstance.localRadios
      if let local = DataManager.sharedInstance.userLocation {
        let localRadioManager = RequestManager()
        localRadioManager.requestLocalRadios(CGFloat(local.coordinate.latitude), longitude: CGFloat(local.coordinate.longitude), pageNumber: 0, pageSize: 20, completion: { (resultHistoric) in
          self.selectedRadioArray = DataManager.sharedInstance.localRadios
          self.tableView.reloadData()
        })
      }
    } else if (selectedMode == .Favorite) {
      manager.requestUserFavorites({ (resultFav) in
        self.selectedRadioArray = DataManager.sharedInstance.favoriteRadios
        self.tableView.reloadData()
      })
      selectedRadioArray = DataManager.sharedInstance.favoriteRadios
    } else if (selectedMode == .Recent) {
      selectedRadioArray = DataManager.sharedInstance.recentsRadios
      manager.requestHistoricRadios(0, pageSize: 20, completion: { (resultTop) in
        self.selectedRadioArray = DataManager.sharedInstance.recentsRadios
        self.tableView.reloadData()
      })
    } else {
      print("A string ")
    }
    tableView.reloadData()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //    if segue.identifier == "detailRadio" {
    //      let radioVC = (segue.destinationViewController as! RadioViewController)
    //      radioVC.actualRadio = selectedRadio
    //    }
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- OTHERS FUNCTIONS ---
  ///////////////////////////////////////////////////////////
  
  func showMenu () {
    self.performSegueWithIdentifier("initialView", sender: self)
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let locValue:CLLocationCoordinate2D = manager.location!.coordinate
    let myLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
    DataManager.sharedInstance.userLocation = myLocation
    
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- IBACTIONS ---
  ///////////////////////////////////////////////////////////
  
  
  @IBAction func searchButtonTap(sender: AnyObject) {
    DataManager.sharedInstance.instantiateSearch(self.navigationController!)
  }
  
  func titleForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
    var str = ""
    if selectedMode == .Favorite {
      str = "Sem Favoritos"
    } else if selectedMode == .Recent {
      str = "Nenhuma rádio foi reproduzida"
    } else {
      str = "Nenhuma radio para mostrar"
    }
    let attr = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func descriptionForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
    var str = ""
    if selectedMode == .Favorite {
      str = "Você não marcou nenhuma rádio como favorito, retorne a início e marque algumas!"
    } else if selectedMode == .Recent {
      str = "Selecione alguma rádio e as reproduza para que possamos gerar seu histórico"
    } else {
      str = "Nenhuma radio para mostrar"
    }
    let attr = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func imageForEmptyDataSet(scrollView: UIScrollView) -> UIImage? {
    return Util.imageResize(UIImage(named: "happy.jpg")!, sizeChange: CGSize(width: 100, height: 100))
  }
  
  func emptyDataSetDidTapButton(scrollView: UIScrollView) {
    dismissViewControllerAnimated(true) {
    }
  }
}
