//
//  MenuTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/8/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import SideMenu

class MenuTableViewController: UITableViewController {
  var menuArray = ["Início","Gêneros","Locais","Notícias","Dormir","Configurações"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard tableView.backgroundView == nil else {
      return
    }
    
//    let imageView = UIImageView(image: UIImage(named: "backgroungMenu.jpg"))
//    imageView.contentMode = .ScaleAspectFit
//    imageView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
//    tableView.backgroundView = imageView
    tableView.backgroundColor = UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 1)
    tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
    self.navigationItem.setHidesBackButton(true, animated: false)

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
    return 7
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if (indexPath.row == 0) {
      let userCell = tableView.dequeueReusableCellWithIdentifier("TopCell", forIndexPath: indexPath) as! TopMenuTableViewCell
      userCell.nameUser.text = "Fulano"
      if FileSupport.testIfFileExistInDocuments("profilePic.jpg") {
        userCell.imageUser.image = UIImage(contentsOfFile: "\(FileSupport.findDocsDirectory())profilePic.jpg")
      }
      if DataManager.sharedInstance.myUser.name != "" {
        userCell.nameUser.text = DataManager.sharedInstance.myUser.name
      }
      userCell.imageUser.layer.cornerRadius = userCell.imageUser.bounds.height / 4
      userCell.imageUser.layer.borderColor = UIColor.blackColor().CGColor
      userCell.imageUser.layer.borderWidth = 3.0
      userCell.imageUser.clipsToBounds = true
      //let imageUserVar = UIImage()
      //cell.imageUser.image =
      userCell.backgroundColor = UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 1)
      return userCell
      
    } else if(indexPath.row != 5) {
      let firstTypeCell = tableView.dequeueReusableCellWithIdentifier("FirstCell", forIndexPath: indexPath) as! FirstTypeMenuTableViewCell
      firstTypeCell.labelText.text = menuArray[indexPath.row - 1]
      firstTypeCell.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
      return firstTypeCell
    }
    
    let secondTypeCell = tableView.dequeueReusableCellWithIdentifier("SecondCell", forIndexPath: indexPath) as! SecondMenuTypeTableViewCell
    secondTypeCell.labelText.text = menuArray[4]
    secondTypeCell.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    return secondTypeCell
    
    
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if (indexPath.row == 0) {
      return 70
    }
    return 40
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
    }
  }
  
  @IBAction func sleepFunction(sender: AnyObject) {
    let sleepAlert = UIAlertController(title: "Escolha um período", message: "hello", preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    var sheets = [UIAlertAction]()
    let values = ["15 min","30 min","45 min","60 min","90 min"]
    for value in values {
      let actionOption = UIAlertAction(title: value, style: UIAlertActionStyle.Default, handler: { (action) in
        
      })
      sleepAlert.addAction(actionOption)
      sheets.append(actionOption)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
    sleepAlert.addAction(cancelAction)
    
    presentViewController(sleepAlert, animated: true, completion:nil)
  }
}
