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
  var switchTimer = NSTimer()
  let notificationCenter = NSNotificationCenter.defaultCenter()
  
  
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
    tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    self.navigationItem.setHidesBackButton(true, animated: false)
    
  }
  
  override func viewWillAppear(animated: Bool) {

    
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
            let indexPath = NSIndexPath(forItem: index, inSection: 0)
            //let cell = tableView.cellForRowAtIndexPath(indexPath)
            if index == 0 {
              let cell2 = tableView.cellForRowAtIndexPath(indexPath) as! TopMenuTableViewCell
              if !DataManager.sharedInstance.isLogged {
                cell2.nameUser.text = "Clique para logar"
                cell2.imageUser.image = UIImage(named: "avatar.png")
              } else {
                if DataManager.sharedInstance.myUser.name != "" {
                  if DataManager.sharedInstance.myUser.userImage == "avatar.png" {
                    cell2.imageUser.image = UIImage(named: "avatar.png")
                  } else {
                    cell2.imageUser.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(DataManager.sharedInstance.myUser.userImage)))
                  }
                  cell2.nameUser.text = DataManager.sharedInstance.myUser.name.componentsSeparatedByString(" ").first!
                } else {
                  cell2.nameUser.text = "Perfil"
                  cell2.imageUser.image = UIImage(named: "avatar.png")
                }
              }
              cell2.imageUser.layer.cornerRadius = cell2.imageUser.bounds.height / 4
              cell2.imageUser.layer.borderColor = UIColor.whiteColor().CGColor
              cell2.imageUser.layer.borderWidth = 0
              cell2.imageUser.clipsToBounds = true
            }
          }
      }
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    DataManager.sharedInstance.menuIsOpen = true
    notificationCenter.postNotificationName("freezeViews", object: nil)
    
    
    updateSwitch()
    switchTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(MenuTableViewController.updateInterfaceTimer), userInfo: nil, repeats: true)
    defineColors()
  }
  
  func updateInterfaceTimer() {
    updateSwitch()
  }
  
  override func viewDidDisappear(animated: Bool) {
    switchTimer.invalidate()
    DataManager.sharedInstance.menuIsOpen = false
    notificationCenter.postNotificationName("freezeViews", object: nil)
    
  }
  
  func updateSwitch() {
    let indexPath = NSIndexPath(forItem: 5, inSection: 0)
    let cell = tableView.cellForRowAtIndexPath(indexPath) as! SecondMenuTypeTableViewCell
    if DataManager.sharedInstance.isSleepModeEnabled {
      let interval = Double(NSDate().timeIntervalSinceDate(DataManager.sharedInstance.dateSleep))*(-1)
      if interval < 60 {
        cell.labelText.text = "Dormir em \(Int(interval)) seg"
      } else {
        cell.labelText.text = "Dormir em \(Int(interval/60)) min"
      }
      cell.switchStatus.enabled = true
      cell.switchStatus.setOn(true, animated: false)
    } else {
      cell.labelText.text = "Dormir"
      if StreamingRadioManager.sharedInstance.currentlyPlaying() {
        cell.switchStatus.enabled = true
        cell.switchStatus.setOn(false, animated: false)
      } else {
        cell.switchStatus.enabled = false
      }
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    if DataManager.sharedInstance.isLogged {
      return 10
    } else {
      return 9
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if (indexPath.row == 0) {
      let userCell = tableView.dequeueReusableCellWithIdentifier("TopCell", forIndexPath: indexPath) as! TopMenuTableViewCell
      if !DataManager.sharedInstance.isLogged {
        userCell.nameUser.text = "Clique para logar"
        userCell.imageUser.image = UIImage(named: "avatar.png")
      } else {
        if DataManager.sharedInstance.myUser.name != "" {
          if DataManager.sharedInstance.myUser.userImage == "avatar.png" {
            userCell.imageUser.image = UIImage(named: "avatar.png")
          } else {
            userCell.imageUser.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(DataManager.sharedInstance.myUser.userImage)))
          }
          userCell.nameUser.text = DataManager.sharedInstance.myUser.name.componentsSeparatedByString(" ").first!
        } else {
          userCell.nameUser.text = "Perfil"
          userCell.imageUser.image = UIImage(named: "avatar.png")
        }
      }
      
      userCell.imageUser.layer.cornerRadius = userCell.imageUser.bounds.height / 4
      userCell.imageUser.layer.borderColor = UIColor.whiteColor().CGColor
      userCell.imageUser.layer.borderWidth = 0
      userCell.imageUser.clipsToBounds = true
      userCell.selectionStyle = UITableViewCellSelectionStyle.None
      return userCell
      
    } else if indexPath.row == 5 {
      let secondTypeCell = tableView.dequeueReusableCellWithIdentifier("SecondCell", forIndexPath: indexPath) as! SecondMenuTypeTableViewCell
      secondTypeCell.tag = 102
      secondTypeCell.labelText.text = menuArray[4]
      secondTypeCell.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
      secondTypeCell.selectionStyle = UITableViewCellSelectionStyle.None
      return secondTypeCell
    }
    
    if DataManager.sharedInstance.isLogged {
      if (indexPath.row == 8) {
        let firstTypeCell = tableView.dequeueReusableCellWithIdentifier("FirstCell", forIndexPath: indexPath) as! FirstTypeMenuTableViewCell
        firstTypeCell.labelText.text = "Logout"
        firstTypeCell.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        firstTypeCell.selectionStyle = UITableViewCellSelectionStyle.None
        return firstTypeCell
      }
      if(indexPath.row != 5 && indexPath.row != 9) {
        let firstTypeCell = tableView.dequeueReusableCellWithIdentifier("FirstCell", forIndexPath: indexPath) as! FirstTypeMenuTableViewCell
        firstTypeCell.labelText.text = menuArray[indexPath.row - 1]
        firstTypeCell.selectionStyle = UITableViewCellSelectionStyle.None
        return firstTypeCell
      } else {
        let cell = UITableViewCell()
        cell.selectionStyle = .None
          cell.backgroundColor = DataManager.sharedInstance.interfaceColor.color
        return cell
      }
    } else {
      if(indexPath.row != 5 && indexPath.row != 8) {
        let firstTypeCell = tableView.dequeueReusableCellWithIdentifier("FirstCell", forIndexPath: indexPath) as! FirstTypeMenuTableViewCell
        firstTypeCell.labelText.text = menuArray[indexPath.row - 1]
        firstTypeCell.selectionStyle = UITableViewCellSelectionStyle.None
        return firstTypeCell
      } else {
        let cell = UITableViewCell()
        cell.selectionStyle = .None
        cell.backgroundColor = DataManager.sharedInstance.interfaceColor.color
        return cell
      }
    }

    

    
    
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if (indexPath.row == 0) {
      return 70
    }
    return 50
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    if (indexPath.row == 0) {
      self.performSegueWithIdentifier("profileScreen", sender: self)
    } else if (indexPath.row == 1) {
      //dismissViewControllerAnimated(true, completion: nil)
      self.performSegueWithIdentifier("initialScreen", sender: self)
    } else if (indexPath.row == 2) {
      self.performSegueWithIdentifier("genreScreen", sender: self)
    } else if (indexPath.row == 3) {
      self.performSegueWithIdentifier("localScreen", sender: self)
    } else if (indexPath.row == 4) {
      self.performSegueWithIdentifier("newsScreen", sender: self)
    } else if (indexPath.row == 6) {
      self.performSegueWithIdentifier("configScreen", sender: self)
    } else if (indexPath.row == 7) {
      self.performSegueWithIdentifier("aboutScreen", sender: self)
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
        notificationCenter.postNotificationName("backToInital", object: nil)
        DataManager.sharedInstance.favoriteRadios = []
        tableView.reloadData()
        defineColors()
        self.dismissViewControllerAnimated(true, completion: {
        })
        
      }
      func cancelAction() {
        self.dismissViewControllerAnimated(true, completion: nil)
      }
      self.displayAlert(title: "Atenção", message: "Você deseja fazer logout?", okTitle: "Sim", cancelTitle: "Cancelar", okAction: okAction, cancelAction: cancelAction)
    }
  }
  
  @IBAction func sleepFunction(sender: AnyObject) {
    if DataManager.sharedInstance.isSleepModeEnabled {
      for notification in UIApplication.sharedApplication().scheduledLocalNotifications! as [UILocalNotification] {
        if notification.alertTitle == "SleepMode" {
          UIApplication.sharedApplication().cancelLocalNotification(notification)
        }
      }
      DataManager.sharedInstance.isSleepModeEnabled = false
    } else {
      let sleepAlert = UIAlertController(title: "Função dormir", message: "Escolha um período e iremos parar a radio para você", preferredStyle: UIAlertControllerStyle.ActionSheet)
      
      var sheets = [UIAlertAction]()
      let values = ["15 min","30 min","45 min","60 min","90 min"]
      for value in values {
        let actionOption = UIAlertAction(title: value, style: UIAlertActionStyle.Default, handler: { (action) in
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
      
      let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
      sleepAlert.addAction(cancelAction)
      
      presentViewController(sleepAlert, animated: true, completion:nil)
    }
  }
  
  func defineColors() {
    let components = CGColorGetComponents(DataManager.sharedInstance.interfaceColor.color.CGColor)
    let colorRose = DataManager.sharedInstance.pinkColor.color
    let colorBlue = DataManager.sharedInstance.blueColor.color
    let colorBlack = DataManager.sharedInstance.interfaceColor.color
    let colorWhite =  ColorRealm(name: 45, red: components[0]+0.2, green: components[1]+0.2, blue: components[2]+0.2, alpha: 1).color

    
    
    
    if DataManager.sharedInstance.interfaceColor.color == colorBlue {
      self.tableView.backgroundColor = colorBlue
      viewTop.backgroundColor = UIColor(gradientStyle: .TopToBottom, withFrame: viewTop.frame, andColors: [colorRose,colorBlue])
    } else {
      self.tableView.backgroundColor = colorBlack
      viewTop.backgroundColor = UIColor(gradientStyle: .TopToBottom, withFrame: viewTop.frame, andColors: [colorWhite,colorBlack])
    }
    
    for cell in  tableView.visibleCells {
      if tableView.indexPathForCell(cell)?.row == 0 {
        if DataManager.sharedInstance.interfaceColor.color == colorBlue {
          cell.backgroundColor = colorBlue
          
        } else {
          cell.backgroundColor = colorBlack
        }
      } else {
        
        if DataManager.sharedInstance.interfaceColor.color == colorBlue {
          cell.backgroundColor = colorBlue
          
          if let cellAux = cell as? FirstTypeMenuTableViewCell {
            cellAux.labelText.textColor = UIColor.whiteColor()
          }
          if let cellAux = cell as? SecondMenuTypeTableViewCell {
            cellAux.labelText.textColor = UIColor.whiteColor()
          }
        } else {
          cell.backgroundColor = colorBlack
          if let cellAux = cell as? FirstTypeMenuTableViewCell {
            cellAux.labelText.textColor = UIColor.whiteColor()
          }
          if let cellAux = cell as? SecondMenuTypeTableViewCell {
            cellAux.labelText.textColor = UIColor.whiteColor()
          }
        }
      }
    }
    
    if self.navigationController?.navigationBar.backgroundColor != DataManager.sharedInstance.interfaceColor.color {
      self.navigationController?.navigationBar.backgroundColor = DataManager.sharedInstance.interfaceColor.color
    }

  }
  
  
  
}
