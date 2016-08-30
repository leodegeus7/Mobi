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
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    
    var selectedRadioArray:[RadioRealm]!
    var myUser = DataManager.sharedInstance.myUser
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        completeProfileViewInfo()
        navigationController?.title = "Perfil"
        tableViewFavorites.rowHeight = 120
        
        backButton.target = self.revealViewController()
        backButton.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        imageUser.layer.cornerRadius = imageUser.bounds.height / 2
        imageUser.layer.borderColor = UIColor.blackColor().CGColor
        imageUser.layer.borderWidth = 3.0
        imageUser.clipsToBounds = true
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myUser.favoritesRadios.count
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
    
    func completeProfileViewInfo() {
        labelName.text = myUser.name
        labelCity.text = myUser.address.city
        labelState.text = myUser.address.state
        labelGender.text = myUser.sex
        labelCountry.text = myUser.address.country
        labelDateBirth.text = myUser.birthDate
        labelFollowers.text = "\(myUser.followers)"
        labelFollowing.text = "\(myUser.following)"
        imageUser.image = UIImage(named: myUser.userImage)
        selectedRadioArray = myUser.favoritesRadios
    }
    
    
    
}
