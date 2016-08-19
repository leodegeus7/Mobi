//
//  ProfileViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/9/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import Alamofire


class ProfileViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

  @IBOutlet weak var imageUser: UIImageView!
  @IBOutlet weak var labelName: UILabel!
  @IBOutlet weak var labelAddress: UILabel!
  @IBOutlet weak var labelCity: UILabel!
  @IBOutlet weak var labelState: UILabel!
  @IBOutlet weak var labelCountry: UILabel!
  @IBOutlet weak var labelGender: UILabel!
  @IBOutlet weak var labelDateBirth: UILabel!
  @IBOutlet weak var buttonEdit: UIButton!
  @IBOutlet weak var labelFollowing: UILabel!
  @IBOutlet weak var labelFollowers: UILabel!
  @IBOutlet weak var tableViewFavorites: FavoritesTableView!
  
    var selectedRadioArray = DataManager.sharedInstance.favoriteRadios
  
    override func viewDidLoad() {
        super.viewDidLoad()
      navigationController?.title = "Perfil"
      tableViewFavorites.rowHeight = 120
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return DataManager.sharedInstance.favoriteRadios.count
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("favoriteCell", forIndexPath: indexPath) as! FavoriteTableViewCell
    cell.labelName.text = selectedRadioArray[indexPath.row].name
    cell.labelLocal.text = selectedRadioArray[indexPath.row].address.formattedLocal
    cell.imageBig.image = UIImage(named: selectedRadioArray[indexPath.row].thumbnail)
    cell.imageSmallOne.image = UIImage(named: "heart.png")
    cell.labelDescriptionOne.text = "\(selectedRadioArray[indexPath.row].likenumber)"
    return cell
  }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
