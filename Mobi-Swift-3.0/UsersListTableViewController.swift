//
//  UsersListTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/14/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import Kingfisher

class UsersListTableViewController: UITableViewController {
  
  var actualUsers = [UserRealm]()
  var viewTitle = ""
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = viewTitle
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return actualUsers.count + 1
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.row <= actualUsers.count-1 {
      let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! UserTableViewCell
      
      if actualUsers[indexPath.row].userImage == "avatar.png" {
        cell.imageUser.image = UIImage(named: "avatar.png")
      } else {
        cell.imageUser.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(actualUsers[indexPath.row].userImage)))
      }
      cell.nameUser.text = actualUsers[indexPath.row].name
      cell.localUser.text = actualUsers[indexPath.row].shortAddress
      //    if actualUsers[indexPath.row].address.formattedLocal != ""{
      //      cell.localUser.text = actualUsers[indexPath.row].address.formattedLocal
      //    } else {
      //      cell.localUser.text = ""
      //    }
      return cell
    } else {
      let cell = UITableViewCell()
      cell.selectionStyle = .None
      return cell
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row <= actualUsers.count-1 {
      DataManager.sharedInstance.instantiateUserDetail(navigationController!, user: actualUsers[indexPath.row])
    }
  }
  
  override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    let manager = RequestManager()
    actualUsers.removeAtIndex(indexPath.row)
    tableView.reloadData()
    let favorite = UITableViewRowAction(style: .Normal, title: "Desfavoritar") { action, index in
      manager.unfollowUser(self.actualUsers[indexPath.row], completion: { (follow) in
        if !follow {
          self.displayAlert(title: "Probelam", message: "Ocorreu um problema ao desfavoritar o usuario", action: "Ok")
        }
      })
      
    }
    favorite.backgroundColor = UIColor.orangeColor()
    return [favorite]
    
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
}
