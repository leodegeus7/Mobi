//
//  RadioViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/25/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class RadioViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
  
  @IBOutlet weak var imageLogo: UIImageView!
  @IBOutlet weak var labelName: UILabel!
  @IBOutlet weak var labelLocal: UILabel!
  @IBOutlet weak var labelLikes: UILabel!
  @IBOutlet weak var imageLike: UIImageView!
  @IBOutlet weak var labelStars: UILabel!
  @IBOutlet weak var starOne: UIImageView!
  @IBOutlet weak var starTwo: UIImageView!
  @IBOutlet weak var starThree: UIImageView!
  @IBOutlet weak var starFour: UIImageView!
  @IBOutlet weak var starFive: UIImageView!
  
  @IBOutlet weak var tableViewMusic: UITableView!
  
  var stars = [UIImageView]()
  var actualRadio = DataManager.sharedInstance.allRadios[0]
  override func viewDidLoad() {
    super.viewDidLoad()
    
    imageLogo.image = UIImage(named: "\(actualRadio.thumbnail)")
    labelName.text = actualRadio.name
    labelLocal.text = actualRadio.address.formattedLocal
    labelLikes.text = "\(actualRadio.likenumber)"
    labelStars.text = "\(actualRadio.stars)"

    stars.append(starOne)
    stars.append(starTwo)
    stars.append(starThree)
    stars.append(starFive)
    stars.append(starFour)
    for star in stars  {
      star.image = UIImage(named: "starOFF.png")
    }
    for index in 0...actualRadio.stars-1 {
      stars[index].image = UIImage(named: "star.png")
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView == tableViewMusic {
      return 1
    }
    return 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if tableView == tableViewMusic {
      let cell = tableView.dequeueReusableCellWithIdentifier("tableViewMusicCell", forIndexPath: indexPath) as! MusicTableViewCell
      cell.labelMusicName.text = "Happy"
      cell.labelAlbum.text = "G I R L"
      cell.labelArtist.text = "Pharell Willians"
      cell.buttonNLike.backgroundColor = UIColor.clearColor()
      cell.butonLike.backgroundColor = UIColor.clearColor()
      cell.imageMusic.image = UIImage(named: "happy.jpg")
      return cell
    }
    let cell = tableView.dequeueReusableCellWithIdentifier("tableViewMusicCell", forIndexPath: indexPath) as! MusicTableViewCell
    return  cell
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    print(indexPath.row)
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "AO VIVO"
  }
  
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  @IBAction func buttonFeedback(sender: AnyObject) {
  }
  
}
