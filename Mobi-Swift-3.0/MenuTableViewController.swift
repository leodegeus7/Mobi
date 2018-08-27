//
//  MenuTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/8/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import SideMenu
import Firebase
import FirebaseAuthUI
import ChameleonFramework

class MenuTableViewController: UITableViewController {
  var menuArray = ["Início","Gêneros","Estados","Notícias","Dormir","Configurações","Sobre"]
  var switchTimer = Timer()
  let notificationCenter = NotificationCenter.default
  
  
  @IBOutlet weak var viewTop: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard tableView.backgroundView == nil else {
      return
    }
    
    
    //    let imageView = UIImageView(image: UIImage(named: "backgroungMenu.jpg"))
    //    imageView.contentMode = .ScaleAspectFit
    //    imageView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
    //    tableView.backgroundView = imageView    
    tableView.estimatedRowHeight = 40
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.separatorStyle = UITableViewCellSeparatorStyle.none
    self.navigationItem.setHidesBackButton(true, animated: false)
    
  }
  
  override func viewWillAppear(_ animated: Bool) {

    
    if tableView.visibleCells.count == 8 && !DataManager.sharedInstance.isLogged {
      tableView.reloadData()
    }
    if DataManager.sharedInstance.needUpdateMenu {
      tableView.reloadData()
      DataManager.sharedInstance.needUpdateMenu = false
    } else {

      if tableView.visibleCells.count > 0 {
          defineColors()
          for index in 0...7 {
            let indexPath = IndexPath(item: index, section: 0)
            //let cell = tableView.cellForRowAtIndexPath(indexPath)
            if index == 0 {
              let cell2 = tableView.cellForRow(at: indexPath) as! TopMenuTableViewCell
              if !DataManager.sharedInstance.isLogged {
                cell2.nameUser.text = "Clique para logar"
                cell2.imageUser.image = UIImage(named: "avatar.png")
              } else {
                if DataManager.sharedInstance.myUser.name != "" {
                  if DataManager.sharedInstance.myUser.userImage == "avatar.png" {
                    cell2.imageUser.image = UIImage(named: "avatar.png")
                  } else {
                    cell2.imageUser.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(DataManager.sharedInstance.myUser.userImage)))
                  }
                  cell2.nameUser.text = DataManager.sharedInstance.myUser.name.components(separatedBy: " ").first!
                } else {
                  cell2.nameUser.text = "Perfil"
                  cell2.imageUser.image = UIImage(named: "avatar.png")
                }
              }
              cell2.imageUser.layer.cornerRadius = cell2.imageUser.bounds.height / 4
              cell2.imageUser.layer.borderColor = UIColor.white.cgColor
              cell2.imageUser.layer.borderWidth = 0
              cell2.imageUser.clipsToBounds = true
            }
          }
      }
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    DataManager.sharedInstance.menuIsOpen = true
    notificationCenter.post(name: Notification.Name(rawValue: "freezeViews"), object: nil)
    
    
    updateSwitch()
    switchTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MenuTableViewController.updateInterfaceTimer), userInfo: nil, repeats: true)
    defineColors()
  }
  
  func updateInterfaceTimer() {
    updateSwitch()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    switchTimer.invalidate()
    DataManager.sharedInstance.menuIsOpen = false
    notificationCenter.post(name: Notification.Name(rawValue: "freezeViews"), object: nil)
    
  }
  
  func updateSwitch() {
    let indexPath = IndexPath(item: 5, section: 0)
    let cell = tableView.cellForRow(at: indexPath) as! SecondMenuTypeTableViewCell
    if DataManager.sharedInstance.isSleepModeEnabled {
      let interval = Double(Date().timeIntervalSince(DataManager.sharedInstance.dateSleep as Date))*(-1)
      if interval < 60 && interval >= 0 {
        cell.labelText.text = "Dormir em \(Int(interval)) seg"
      } else if interval >= 60 {
        cell.labelText.text = "Dormir em \(Int(interval/60)) min"
      }
      cell.switchStatus.isEnabled = true
      cell.switchStatus.setOn(true, animated: false)
    } else {
      cell.labelText.text = "Dormir"
      if StreamingRadioManager.sharedInstance.currentlyPlaying() {
        cell.switchStatus.isEnabled = true
        cell.switchStatus.setOn(false, animated: false)
      } else {
        cell.switchStatus.isEnabled = false
      }
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    if DataManager.sharedInstance.isLogged {
      return 10
    } else {
      return 9
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if (indexPath.row == 0) {
      let userCell = tableView.dequeueReusableCell(withIdentifier: "TopCell", for: indexPath) as! TopMenuTableViewCell
      if !DataManager.sharedInstance.isLogged {
        userCell.nameUser.text = "Clique para logar"
        userCell.imageUser.image = UIImage(named: "avatar.png")
      } else {
        if DataManager.sharedInstance.myUser.name != "" {
          if DataManager.sharedInstance.myUser.userImage == "avatar.png" {
            userCell.imageUser.image = UIImage(named: "avatar.png")
          } else {
            userCell.imageUser.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(DataManager.sharedInstance.myUser.userImage)))
          }
          userCell.nameUser.text = DataManager.sharedInstance.myUser.name.components(separatedBy: " ").first!
        } else {
          userCell.nameUser.text = "Perfil"
          userCell.imageUser.image = UIImage(named: "avatar.png")
        }
      }
      
      userCell.imageUser.layer.cornerRadius = userCell.imageUser.bounds.height / 4
      userCell.imageUser.layer.borderColor = UIColor.white.cgColor
      userCell.imageUser.layer.borderWidth = 0
      userCell.imageUser.clipsToBounds = true
      userCell.selectionStyle = UITableViewCellSelectionStyle.none
      return userCell
      
    } else if indexPath.row == 5 {
      let secondTypeCell = tableView.dequeueReusableCell(withIdentifier: "SecondCell", for: indexPath) as! SecondMenuTypeTableViewCell
      secondTypeCell.tag = 102
      secondTypeCell.labelText.text = menuArray[4]
      secondTypeCell.backgroundColor = DataManager.sharedInstance.interfaceColor.color
      secondTypeCell.selectionStyle = UITableViewCellSelectionStyle.none
      return secondTypeCell
    }
    
    if DataManager.sharedInstance.isLogged {
      if (indexPath.row == 8) {
        let firstTypeCell = tableView.dequeueReusableCell(withIdentifier: "FirstCell", for: indexPath) as! FirstTypeMenuTableViewCell
        firstTypeCell.labelText.text = "Logout"
        firstTypeCell.backgroundColor = DataManager.sharedInstance.interfaceColor.color
        firstTypeCell.selectionStyle = UITableViewCellSelectionStyle.none
        return firstTypeCell
      }
      if(indexPath.row != 5 && indexPath.row != 9) {
        let firstTypeCell = tableView.dequeueReusableCell(withIdentifier: "FirstCell", for: indexPath) as! FirstTypeMenuTableViewCell
        firstTypeCell.labelText.text = menuArray[indexPath.row - 1]
        firstTypeCell.selectionStyle = UITableViewCellSelectionStyle.none
        return firstTypeCell
      } else {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
          cell.backgroundColor = DataManager.sharedInstance.interfaceColor.color
        return cell
      }
    } else {
      if(indexPath.row != 5 && indexPath.row != 8) {
        let firstTypeCell = tableView.dequeueReusableCell(withIdentifier: "FirstCell", for: indexPath) as! FirstTypeMenuTableViewCell
        firstTypeCell.labelText.text = menuArray[indexPath.row - 1]
        firstTypeCell.selectionStyle = UITableViewCellSelectionStyle.none
        return firstTypeCell
      } else {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.backgroundColor = DataManager.sharedInstance.interfaceColor.color
        return cell
      }
    }

    

    
    
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if (indexPath.row == 0) {
      return 70
    }
    return 50
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if (indexPath.row == 0) {
      self.performSegue(withIdentifier: "profileScreen", sender: self)
    } else if (indexPath.row == 1) {
      //dismissViewControllerAnimated(true, completion: nil)
      self.performSegue(withIdentifier: "initialScreen", sender: self)
    } else if (indexPath.row == 2) {
      self.performSegue(withIdentifier: "genreScreen", sender: self)
    } else if (indexPath.row == 3) {
      self.performSegue(withIdentifier: "localScreen", sender: self)
    } else if (indexPath.row == 4) {
      self.performSegue(withIdentifier: "newsScreen", sender: self)
    } else if (indexPath.row == 6) {
      self.performSegue(withIdentifier: "configScreen", sender: self)
    } else if (indexPath.row == 7) {
      self.performSegue(withIdentifier: "aboutScreen", sender: self)
    } else if (indexPath.row == 8) {
      func okAction() {
        try! FIRAuth.auth()?.signOut()
        DataManager.sharedInstance.isLogged = false
        DataManager.sharedInstance.userToken = ""
        DataManager.sharedInstance.configApp.updateUserToken("")
        RealmWrapper.deleteMyUserRealm()
        DataManager.sharedInstance.myUser = UserRealm()
        let logoutManger = RequestManager()
        logoutManger.logoutInServer(DataManager.sharedInstance.userToken, completion: { (result) in
        })
        notificationCenter.post(name: Notification.Name(rawValue: "backToInital"), object: nil)
        DataManager.sharedInstance.favoriteRadios = []
        tableView.reloadData()
        defineColors()
        self.dismiss(animated: true, completion: {
        })
        
      }
      func cancelAction() {
        self.dismiss(animated: true, completion: nil)
      }
      self.displayAlert(title: "Atenção", message: "Você deseja fazer logout?", okTitle: "Sim", cancelTitle: "Cancelar", okAction: okAction, cancelAction: cancelAction)
    }
  }
  
  @IBAction func sleepFunction(_ sender: AnyObject) {
    if DataManager.sharedInstance.isSleepModeEnabled {
      for notification in UIApplication.shared.scheduledLocalNotifications! as [UILocalNotification] {
        if notification.alertTitle == "Modo Dormir" {
          UIApplication.shared.cancelLocalNotification(notification)
        }
      }
      DataManager.sharedInstance.isSleepModeEnabled = false
    } else {
      let sleepAlert = UIAlertController(title: "Função dormir", message: "Escolha um período de tempo e iremos parar a radio para você", preferredStyle: UIAlertControllerStyle.actionSheet)
      
      var sheets = [UIAlertAction]()
      let values = ["15 min","30 min","45 min","60 min","90 min"]
      for value in values {
        let actionOption = UIAlertAction(title: value, style: UIAlertActionStyle.default, handler: { (action) in
          switch action.title! {
          case "15 min":
            Util.sleepNotification(15*60)
            break
          case "30 min":
            Util.sleepNotification(30*60)
            break
          case "45 min":
            Util.sleepNotification(45*60)
            break
          case "60 min":
            Util.sleepNotification(60*60)
            break
          case "90 min":
            Util.sleepNotification(90*60)
            break
          default:
            break
          }
        })
        sleepAlert.addAction(actionOption)
        sheets.append(actionOption)
      }
      
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
      sleepAlert.addAction(cancelAction)
      
      present(sleepAlert, animated: true, completion:nil)
    }
  }
  
  func defineColors() {
    let components = DataManager.sharedInstance.interfaceColor.color.cgColor.components
    let colorRose = DataManager.sharedInstance.pinkColor.color
    let colorBlue = DataManager.sharedInstance.blueColor.color
    let colorBlack = DataManager.sharedInstance.interfaceColor.color
    let colorWhite =  ColorRealm(name: 45, red: (components?[0])!+0.2, green: (components?[1])!+0.2, blue: (components?[2])!+0.2, alpha: 1).color

    
    
    
    if DataManager.sharedInstance.interfaceColor.color == colorBlue {
      self.tableView.backgroundColor = colorBlue
      viewTop.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: viewTop.frame, andColors: [colorRose,colorBlue])
    } else {
      self.tableView.backgroundColor = colorBlack
      viewTop.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: viewTop.frame, andColors: [colorWhite,colorBlack])
    }
    
    for cell in  tableView.visibleCells {
      if tableView.indexPath(for: cell)?.row == 0 {
        if DataManager.sharedInstance.interfaceColor.color == colorBlue {
          cell.backgroundColor = colorBlue
          
        } else {
          cell.backgroundColor = colorBlack
        }
      } else {
        
        if DataManager.sharedInstance.interfaceColor.color == colorBlue {
          cell.backgroundColor = colorBlue
          
          if let cellAux = cell as? FirstTypeMenuTableViewCell {
            cellAux.labelText.textColor = UIColor.white
          }
          if let cellAux = cell as? SecondMenuTypeTableViewCell {
            cellAux.labelText.textColor = UIColor.white
          }
        } else {
          cell.backgroundColor = colorBlack
          if let cellAux = cell as? FirstTypeMenuTableViewCell {
            cellAux.labelText.textColor = UIColor.white
          }
          if let cellAux = cell as? SecondMenuTypeTableViewCell {
            cellAux.labelText.textColor = UIColor.white
          }
        }
      }
    }
    
    if self.navigationController?.navigationBar.backgroundColor != DataManager.sharedInstance.interfaceColor.color {
      self.navigationController?.navigationBar.backgroundColor = DataManager.sharedInstance.interfaceColor.color
    }

  }
  
  
  
}
