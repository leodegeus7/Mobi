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
import AVFoundation
import ChameleonFramework
class InitialTableViewController: UITableViewController, CLLocationManagerDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate {
  
  
  @IBOutlet weak var segmentedControlMenu: UISegmentedControl!
  
  
  @IBOutlet weak var openMenu: UIBarButtonItem!
  
  var selectedMode = modes.top
  var selectedRadio = RadioRealm()
  var notificationCenter = NotificationCenter.default
  let locationManager = CLLocationManager()
  var selectedRadioArray = [RadioRealm]()
  
  var pagesLoadedTop = 1
  var pagesLoadedLocal = 1
  var pagesLoadedFavorites = 1
  var pagesLoadedHistoric = 1
  
  var inProcess = false
  
  
  enum modes {
    case top
    case local
    case recent
    case favorite
  }
  
  override func viewDidLoad() {
    
    ///////////////////////////////////////////////////////////
    //MARK: --- BASIC CONFIG ---
    ///////////////////////////////////////////////////////////
    
    if !DataManager.sharedInstance.isLoadScreenAppered {
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let vc = storyboard.instantiateViewController(withIdentifier: "loadView") as? LoadViewController
      vc?.viewInitial = self
      let app = UIApplication.shared.delegate as! AppDelegate
      let windows = app.window
      windows?.rootViewController?.present(vc!, animated: false, completion: {
      })
      DataManager.sharedInstance.isLoadScreenAppered = true
    }
    
    
    
    super.viewDidLoad()
    //selectedRadioArray = DataManager.sharedInstance.topRadios
    notificationCenter.addObserver(self, selector: #selector(InitialTableViewController.reloadData), name: NSNotification.Name(rawValue: "reloadData"), object: nil)
    notificationCenter.addObserver(self, selector: #selector(InitialTableViewController.freezeView), name: NSNotification.Name(rawValue: "freezeViews"), object: nil)
    //changeTableViewStatus()
    tableView.rowHeight = 120
    openMenu.target = self.revealViewController()
    openMenu.action = #selector(SWRevealViewController.revealToggle(_:))
    if revealViewController() != nil {
      openMenu.target = self.revealViewController()
      openMenu.action = #selector(SWRevealViewController.revealToggle(_:))
    }
    self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    tableView.register(UINib(nibName: "CellDesign",bundle:nil), forCellReuseIdentifier: "baseCell")
    tableView.emptyDataSetSource = self
    tableView.emptyDataSetDelegate = self
    tableView.tableFooterView = UIView()
    defineSegments()
    
    if DataManager.sharedInstance.topRadios.count > 0 {
      selectedRadioArray = DataManager.sharedInstance.topRadios
    }
    
    DataManager.sharedInstance.navigationController = self.navigationController!
    
    ///////////////////////////////////////////////////////////
    //MARK: --- INITIAL REQUEST ---
    ///////////////////////////////////////////////////////////
    
    let requestTest = RequestManager()
    requestTest.testServer { (result) in
      if !result {
        Util.displayAlert(self, title: "Atenção", message: "Tivemos um problema ao conectar aos nossos servidores", action: "Ok")
      } else {
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
          self.locationManager.delegate = self
          self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
          self.locationManager.startUpdatingLocation()
          DataManager.sharedInstance.updateRadioDistance()
          if let local = DataManager.sharedInstance.userLocation {
            print(local)
          } else {
            
          }
        }
        else {
          Util.displayAlert(self, title: "Ops...", message: "Não conseguimos identificar locais próximos, tente ligar sua localização nos ajustes", action: "Ok")
        }
        
        
      }
    }
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- DATA ---
  ///////////////////////////////////////////////////////////
  
  func reloadData() {
    selectedMode = modes.top
    changeTableViewStatus()
    tableView.reloadData()
    if ((self.refreshControl?.isRefreshing) != nil) {
      self.refreshControl?.endRefreshing()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    
  }
  
  func freezeView() {
    
    if DataManager.sharedInstance.menuIsOpen {
      tableView.allowsSelection = false
      tableView.isScrollEnabled = false
    } else {
      tableView.allowsSelection = true
      tableView.isScrollEnabled = true
    }
  }
  
  func defineSegments() {
    
    //    viewWithSVG.addSubview(svgCoracao)
    //    let image22 = Util.viewToImage(viewWithSVG)
    //let image1 = Util.imageResize(UIImage(named: "icone-grafico.png")!, sizeChange: CGSize(width: 20, height: 20))
    let image1 = Util.imageResize(UIImage(named: "icones_branco-grafico.png")!, sizeChange: CGSize(width: 20, height: 20))//UIImage(named: "icone-grafico.png")!
    let image2 = Util.imageResize(UIImage(named: "icones_branco-ponteiro.png")!, sizeChange: CGSize(width: 20, height: 20))//UIImage(named: "icone-local.png")!
    let image3 = Util.imageResize(UIImage(named: "icones_branco-relogio.png")!, sizeChange: CGSize(width: 20, height: 20))//UIImage(named: "icone-historico.png")!
    let image4 = Util.imageResize(UIImage(named: "icones_branco-coracao.png")!, sizeChange: CGSize(width: 20, height: 20))//UIImage(named: "icone-coracao.png")!
    segmentedControlMenu.setImage(image1, forSegmentAt: 0)
    segmentedControlMenu.setImage(image2, forSegmentAt: 1)
    segmentedControlMenu.setImage(image3, forSegmentAt: 2)
    segmentedControlMenu.setImage(image4, forSegmentAt: 3)
    
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- TABLEVIEW DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if selectedRadioArray.count > 0 {
      return selectedRadioArray.count + 1
    } else {
      return 0
    }
  }
  
  override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row <= selectedRadioArray.count-1 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "baseCell", for: indexPath) as! InitialTableViewCell
      switch selectedMode {
      case .top:
        
        if indexPath.row == (20*pagesLoadedTop - 1) && !inProcess {
          inProcess = true
          
          self.pushMoreRadios()
        }
        
        cell.labelName.text = selectedRadioArray[indexPath.row].name
        if let address = selectedRadioArray[indexPath.row].address {
          cell.labelLocal.text = address.formattedLocal
        }
        cell.imageBig.kf.indicatorType = .activity
        cell.imageBig.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(selectedRadioArray[indexPath.row].thumbnail)))
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
      case .local:
        
        if indexPath.row == (20*pagesLoadedLocal - 1) && !inProcess {
          inProcess = true
          
          self.pushMoreRadios()
        }
        
        cell.labelName.text = selectedRadioArray[indexPath.row].name
        if let address = selectedRadioArray[indexPath.row].address {
          cell.labelLocal.text = address.formattedLocal
        }
        cell.imageBig.kf.indicatorType = .activity
        cell.imageBig.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(selectedRadioArray[indexPath.row].thumbnail)))
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
      case .recent:
        
        if indexPath.row == (20*pagesLoadedHistoric - 1) && !inProcess {
          inProcess = true
          
          self.pushMoreRadios()
        }
        
        cell.labelName.text = selectedRadioArray[indexPath.row].name
        if let address = selectedRadioArray[indexPath.row].address {
          cell.labelLocal.text = address.formattedLocal
        }
        cell.imageBig.kf.indicatorType = .activity
        cell.imageBig.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(selectedRadioArray[indexPath.row].thumbnail)))
        cell.imageSmallOne.image = UIImage(named: "clock-icon.png")
        if (Date().timeIntervalSince(selectedRadioArray[indexPath.row].lastAccessDate as Date) > 1) {
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
      case .favorite:
        
        if indexPath.row == (20*pagesLoadedFavorites - 1) && !inProcess {
          inProcess = true
          
          self.pushMoreRadios()
        }
        
        cell.labelName.text = selectedRadioArray[indexPath.row].name
        if let address = selectedRadioArray[indexPath.row].address {
          cell.labelLocal.text = address.formattedLocal
        }

        cell.imageBig.kf.indicatorType = .activity
        
        

        cell.imageBig.kf.setImage(with: URL(string: RequestManager.getLinkFromImageWithIdentifierString(selectedRadioArray[indexPath.row].thumbnail)))
        

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
    } else {
      let cell = UITableViewCell()
      cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
      cell.selectionStyle = .none
      return cell
    }
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if (selectedMode == .top) {
      return "Em alta"
    } else if (selectedMode == .local) {
      return "Ao redor"
    } else if (selectedMode == .favorite) {
      return "Favoritas"
    } else if (selectedMode == .recent) {
      return "Histórico"
    }
    return ""
  }
  
  func pushMoreRadios() {
    
    if selectedMode == .top {

      let manager = RequestManager()
    
    manager.requestTopLikesRadios(pagesLoadedTop+1, pageSize: 20, completion: { (resultTop) in
      DataManager.sharedInstance.topRadios.append(contentsOf: resultTop)
      self.selectedRadioArray = DataManager.sharedInstance.topRadios
      self.pagesLoadedTop += 1
      self.inProcess = false
      self.tableView.reloadData()
    })
    } else if selectedMode == .local {
      if let local = DataManager.sharedInstance.userLocation {
        let localRadioManager = RequestManager()
        localRadioManager.requestLocalRadios(CGFloat(local.coordinate.latitude), longitude: CGFloat(local.coordinate.longitude), pageNumber: pagesLoadedLocal+1, pageSize: 20, completion: { (resultHistoric) in
          DataManager.sharedInstance.localRadios.append(contentsOf: resultHistoric)
          self.pagesLoadedLocal += 1
          self.inProcess = false
          self.selectedRadioArray = DataManager.sharedInstance.localRadios
          self.tableView.reloadData()
        })
      }
    } else if selectedMode == .recent {
      let manager = RequestManager()
      manager.requestHistoricRadios(pagesLoadedHistoric+1, pageSize: 20, completion: { (resultTop) in
        DataManager.sharedInstance.recentsRadios.append(contentsOf: resultTop)
        self.selectedRadioArray = DataManager.sharedInstance.recentsRadios
        self.pagesLoadedHistoric += 1
        self.inProcess = false
        self.tableView.reloadData()
      })
    }

    
  }
  
  static func distanceBetweenTwoLocationsMeters(_ source:CLLocation,destination:CLLocation) -> Int{
    let distanceMeters = source.distance(from: destination)
    return Int(distanceMeters)
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.row <= selectedRadioArray.count-1 {
      switch selectedMode {
      case .favorite:
        selectedRadio = DataManager.sharedInstance.favoriteRadios[indexPath.row]
      case .local:
        selectedRadio = DataManager.sharedInstance.localRadios[indexPath.row]
      case .recent:
        selectedRadio = DataManager.sharedInstance.recentsRadios[indexPath.row]
      case .top:
        selectedRadio = DataManager.sharedInstance.topRadios[indexPath.row]
      }
      DataManager.sharedInstance.instantiateRadioDetailView(navigationController!, radio: selectedRadio)
    }
    
  }
  
  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let manager = RequestManager()
    
    
    
    if selectedRadioArray[indexPath.row].isFavorite {
      let favorite = UITableViewRowAction(style: .normal, title: "Desfavoritar") { action, index in
        self.selectedRadioArray[indexPath.row].updateIsFavorite(false)
        self.selectedRadioArray[indexPath.row].removeOneLikesNumber()
        manager.deleteFavRadio(self.selectedRadioArray[indexPath.row], completion: { (result) in
          manager.requestUserFavorites({ (resultFav) in
          })
        })
        if self.selectedMode == .favorite {
          DataManager.sharedInstance.favoriteRadios.remove(at: indexPath.row)
          self.selectedRadioArray = DataManager.sharedInstance.favoriteRadios
          tableView.deleteRows(at: [indexPath], with: .automatic)
          if DataManager.sharedInstance.favoriteRadios.count == 0 {
            tableView.reloadData()
          }
        } else {
          self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
      }
      favorite.backgroundColor = UIColor.orange
      return [favorite]
    } else {
      let favorite = UITableViewRowAction(style: .normal, title: "Favoritar") { action, index in
        if DataManager.sharedInstance.isLogged {
          self.selectedRadioArray[indexPath.row].updateIsFavorite(true)
          self.selectedRadioArray[indexPath.row].addOneLikesNumber()
          manager.favRadio(self.selectedRadioArray[indexPath.row], completion: { (result) in
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            
          })
        } else {
          func okAction() {
            DataManager.sharedInstance.instantiateProfile(self.navigationController!)
          }
          func cancelAction() {
          }
          self.displayAlert(title: "Atenção", message: "Para utilizar este recurso é necessário fazer login. Deseja fazer isso agora?", okTitle: "Logar", cancelTitle: "Cancelar", okAction: okAction, cancelAction: cancelAction)
        }
      }
      
      favorite.backgroundColor = UIColor.orange
      return [favorite]
    }
    
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    if DataManager.sharedInstance.menuIsOpen {
      return false
    } else {
      return true
    }
  }
  
  @IBAction func segmentedAction(_ sender: UISegmentedControl) {
    pagesLoadedTop = 1
    pagesLoadedLocal = 1
    inProcess = false
    switch segmentedControlMenu.selectedSegmentIndex {
    case 0:
      selectedMode = .top

    case 1:
      if let local = DataManager.sharedInstance.userLocation {
        print(local)
        selectedMode = .local
        DataManager.sharedInstance.updateRadioDistance()
      } else {
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
          self.locationManager.delegate = self
          self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
          self.locationManager.startUpdatingLocation()
          self.selectedMode = .local
          DataManager.sharedInstance.updateRadioDistance()
          if let local = DataManager.sharedInstance.userLocation {
            print(local)
            selectedMode = .local
            DataManager.sharedInstance.updateRadioDistance()
            tableView.reloadData()
          } else {
          }
        }
      }
      break
    case 2:
      selectedMode = .recent
      DataManager.sharedInstance.updateAllOverdueInterval()
      break
    case 3:
      selectedMode = .favorite
      break
    default: break
    }
    changeTableViewStatus()
  }
  
  
  ///////////////////////////////////////////////////////////
  //MARK: --- VIEW FUNCTIONS ---
  ///////////////////////////////////////////////////////////
  
  override func viewWillAppear(_ animated: Bool) {
    tableView.reloadData()
    openMenu.tintColor = UIColor.white
    
  }
  
  
  
  override func viewDidAppear(_ animated: Bool) {
    if DataManager.sharedInstance.recentsRadios.count > 0 {
      DataManager.sharedInstance.updateAllOverdueInterval()
    }
    
    Chameleon.setGlobalThemeUsingPrimaryColor(DataManager.sharedInstance.interfaceColor.color, with: .light)
    self.setStatusBarStyle(.lightContent)
    navigationController?.navigationBar.shadowImage = nil
    navigationController?.navigationBar.isTranslucent = false
    navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
    self.navigationController?.navigationBar.backgroundColor = DataManager.sharedInstance.interfaceColor.color
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- DATA FUNCTIONS ---
  ///////////////////////////////////////////////////////////
  
  func changeTableViewStatus() {
    let manager = RequestManager()
    if (selectedMode == .top) {
      selectedRadioArray = DataManager.sharedInstance.topRadios
      manager.requestTopLikesRadios(0, pageSize: 20, completion: { (resultTop) in
        DataManager.sharedInstance.topRadios = resultTop
        self.selectedRadioArray = DataManager.sharedInstance.topRadios
        self.tableView.reloadData()
      })
    } else if (selectedMode == .local) {
      selectedRadioArray = DataManager.sharedInstance.localRadios
      if let local = DataManager.sharedInstance.userLocation {
        let localRadioManager = RequestManager()
        localRadioManager.requestLocalRadios(CGFloat(local.coordinate.latitude), longitude: CGFloat(local.coordinate.longitude), pageNumber: 0, pageSize: 20, completion: { (resultHistoric) in
          DataManager.sharedInstance.localRadios = resultHistoric
          self.selectedRadioArray = DataManager.sharedInstance.localRadios
          self.tableView.reloadData()
        })
      }
    } else if (selectedMode == .favorite) {
      manager.requestUserFavorites({ (resultFav) in
        self.selectedRadioArray = DataManager.sharedInstance.favoriteRadios
        self.tableView.reloadData()
      })
      selectedRadioArray = DataManager.sharedInstance.favoriteRadios
    } else if (selectedMode == .recent) {
      selectedRadioArray = DataManager.sharedInstance.recentsRadios
      manager.requestHistoricRadios(0, pageSize: 20, completion: { (resultTop) in
        DataManager.sharedInstance.recentsRadios = resultTop
        self.selectedRadioArray = DataManager.sharedInstance.recentsRadios
        self.tableView.reloadData()
      })
    } else {
      print("A string ")
    }
    tableView.reloadData()
  }
  
  
  
  ///////////////////////////////////////////////////////////
  //MARK: --- OTHERS FUNCTIONS ---
  ///////////////////////////////////////////////////////////
  
  func showMenu () {
    self.performSegue(withIdentifier: "initialView", sender: self)
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let locValue:CLLocationCoordinate2D = manager.location!.coordinate
    let myLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
    DataManager.sharedInstance.userLocation = myLocation
    StreamingRadioManager.sharedInstance.adsInfo.updateCoord("\(locValue.latitude)", long: "\(locValue.longitude)")
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let backButton = UIBarButtonItem()
    backButton.title = "Voltar"
    navigationItem.backBarButtonItem = backButton
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- IBACTIONS ---
  ///////////////////////////////////////////////////////////
  
  
  @IBAction func searchButtonTap(_ sender: AnyObject) {
    DataManager.sharedInstance.instantiateSearch(self.navigationController!)
  }
  
  func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
    var str = ""
    if selectedMode == .favorite {
      str = "Sem Favoritos"
      if !DataManager.sharedInstance.isLogged {
        str = "Para utilizar este recurso é necessário fazer login"
      }
    } else if selectedMode == .recent {
      str = "Nenhuma rádio foi reproduzida"
      if !DataManager.sharedInstance.isLogged {
        str = "Para utilizar este recurso é necessário fazer login"
      }
    } else {
      str = "Nenhuma radio para mostrar"
    }
    let attr = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
    var str = ""
    if selectedMode == .local {
      if let _ = DataManager.sharedInstance.userLocation {
        str = "Não conseguimos obter radios próximas a sua localização"
      } else {
        str = "Não conseguimos obter sua localização, ative-a nos ajustes!"
      }
    }
    else if selectedMode == .favorite {
      str = "Você não marcou nenhuma rádio como favorita, retorne ao início e marque alguma!"
      if !DataManager.sharedInstance.isLogged {
        str = "Logue com sua conta no menu ao lado"
      }
    } else if selectedMode == .recent {
      str = "Selecione alguma rádio e as reproduza para que possamos gerar seu histórico"
      if !DataManager.sharedInstance.isLogged {
        str = "Logue com sua conta no menu ao lado"
      }
    } else {
      str = "Nenhuma radio para mostrar"
    }
    let attr = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  //  func imageForEmptyDataSet(scrollView: UIScrollView) -> UIImage? {
  //    return Util.imageResize(UIImage(named: "happy.jpg")!, sizeChange: CGSize(width: 100, height: 100))
  //  }
  
  func emptyDataSetDidTapButton(_ scrollView: UIScrollView) {
    print("Clicou aqui")
    dismiss(animated: true) {
    }
  }
  
}
