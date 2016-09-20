//
//  RadioViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/25/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import AVFoundation
import Kingfisher

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
  @IBOutlet weak var buttonPlay: UIButton!
  @IBOutlet weak var buttonFav: UIButton!
  
  var stars = [UIImageView]()
  var actualRadio = DataManager.sharedInstance.allRadios[0]
  var tapCloseButtonActionHandler : (Void -> Void)?
  
  let notificationCenter = NSNotificationCenter.defaultCenter()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //DataManager.sharedInstance.radioVC = self
    imageLogo.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(actualRadio.thumbnail)))
    labelName.text = actualRadio.name
    if let _ = actualRadio.address {
      labelLocal.text = actualRadio.address.formattedLocal
    }
    labelLikes.text = "\(actualRadio.likenumber)"
    labelStars.text = "\(actualRadio.stars)"
    self.title = "Resumo"
    stars.append(starOne)
    stars.append(starTwo)
    stars.append(starThree)
    stars.append(starFive)
    stars.append(starFour)
    for star in stars  {
      star.image = UIImage(named: "starOFF.png")
    }
    if actualRadio.stars != 0 && actualRadio.stars != -1 {
      for index in 0...actualRadio.stars-1 {
        stars[index].image = UIImage(named: "star.png")
      }
    }
    
    if !actualRadio.isFavorite {
      imageLike.image = UIImage(named: "heart.png")
    } else {
      imageLike.image = UIImage(named: "heartRed.png")
    }
    
    
    if StreamingRadioManager.sharedInstance.currentlyPlaying() && StreamingRadioManager.sharedInstance.isRadioInViewCurrentyPlaying(actualRadio) {
      buttonPlay.setImage(UIImage(named: "pause.png"), forState: .Normal)
    } else {
      buttonPlay.setImage(UIImage(named: "play.png"), forState: .Normal)
    }
    
    let effect = UIBlurEffect(style: .Light)
    let blurView = UIVisualEffectView(effect: effect)
    blurView.frame = self.view.bounds
    self.view.addSubview(blurView)
    self.view.sendSubviewToBack(blurView)
    
    notificationCenter.addObserver(self, selector: #selector(PlayerViewController.updateIcons), name: "updateIcons", object: nil)
    
    buttonPlay.hidden = true
    let manager = RequestManager()
    manager.getAudioChannelsFromRadio(actualRadio) { (result) in
      self.buttonPlay.hidden = false
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
  
  
  
  
  @IBAction func buttonFeedback(sender: AnyObject) {
  }
  
  @IBAction func buttonPlayTap(sender: AnyObject) {
    if (StreamingRadioManager.sharedInstance.isRadioInViewCurrentyPlaying(actualRadio)) {
      if StreamingRadioManager.sharedInstance.currentlyPlaying() {
        StreamingRadioManager.sharedInstance.stop()
      } else {
        StreamingRadioManager.sharedInstance.play(actualRadio)
        DataManager.sharedInstance.miniPlayerView.miniPlayerView.hidden = false
        DataManager.sharedInstance.miniPlayerView.tapMiniPlayerButton(DataManager.sharedInstance.miniPlayerView)
      }
    } else {
      StreamingRadioManager.sharedInstance.play(actualRadio)
      DataManager.sharedInstance.miniPlayerView.miniPlayerView.hidden = false
      DataManager.sharedInstance.miniPlayerView.tapMiniPlayerButton(DataManager.sharedInstance.miniPlayerView)
    }
    

    
    StreamingRadioManager.sharedInstance.sendNotification()

  }
  
  
  func updateIcons() {
    if (StreamingRadioManager.sharedInstance.currentlyPlaying()) {
      if (StreamingRadioManager.sharedInstance.isRadioInViewCurrentyPlaying(actualRadio)) {
        buttonPlay.setImage(UIImage(named: "pause.png"), forState: .Normal)
      } else {
        buttonPlay.setImage(UIImage(named: "play.png"), forState: .Normal)
      }
    } else {
        buttonPlay.setImage(UIImage(named: "play.png"), forState: .Normal)
    }
    
  }
  
  @IBAction func buttonFavTap(sender: AnyObject) {
    let manager = RequestManager()
    if actualRadio.isFavorite {
      imageLike.image = UIImage(named: "heart.png")
      actualRadio.updateIsFavorite(false)
      manager.deleteFavRadio(actualRadio, completion: { (result) in
      })
    } else {
      imageLike.image = UIImage(named: "heartRed.png")
      actualRadio.updateIsFavorite(true)
      manager.favRadio(actualRadio, completion: { (resultFav) in
      })
    }
  }
  
  
  
}
