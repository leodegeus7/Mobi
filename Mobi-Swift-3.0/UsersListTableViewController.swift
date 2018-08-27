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
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return actualUsers.count + 1
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row <= actualUsers.count-1 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
      
      if actualUsers[indexPath.row].userImage == "avatar.png" {
        cell.imageUser.image = UIImage(named: "avatar.png")
      } else {
        cell.imageUser.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(actualUsers[indexPath.row].userImage)))
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
      cell.selectionStyle = .none
      return cell
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.row <= actualUsers.count-1 {
      DataManager.sharedInstance.instantiateUserDetail(navigationController!, user: actualUsers[indexPath.row])
    }
  }
  
  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let manager = RequestManager()
    actualUsers.remove(at: indexPath.row)
    tableView.reloadData()
    let favorite = UITableViewRowAction(style: .normal, title: "Desfavoritar") { action, index in
      manager.unfollowUser(self.actualUsers[indexPath.row], completion: { (follow) in
        if !follow {
          self.displayAlert(title: "Probelam", message: "Ocorreu um problema ao desfavoritar o usuario", action: "Ok")
        }
      })
      
    }
    favorite.backgroundColor = UIColor.orange
    return [favorite]
    
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
}
