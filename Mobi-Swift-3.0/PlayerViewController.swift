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

class PlayerViewController: UIViewController,UITableViewDelegate,UITableViewDataSource  {
  
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
  var tapCloseButtonActionHandler : (Void -> Void)?
//  var firstErrorSkip = true
//  var firstInstanceSkip = true
  
  let notificationCenter = NSNotificationCenter.defaultCenter()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateInfoOfView()
//    do {
//      try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//      print("AVAudioSession Category Playback OK")
//      do {
//        try AVAudioSession.sharedInstance().setActive(true)
//        print("AVAudioSession is Active")
//        
//      } catch let error as NSError {
//        print(error.localizedDescription)
//      }
//    } catch let error as NSError {
//      print(error.localizedDescription)
//    }
    
//    RadioPlayer.sharedInstance.errorDelegate = self
//    RadioPlayer.sharedInstance.instanceDelegate = self
    
//    if StreamingRadioManager.sharedInstance.currentlyPlaying() {
//      buttonPlay.imageView?.image = UIImage(named: "play.png")
//    }
    
    if !StreamingRadioManager.sharedInstance.actualRadio.isFavorite {
      imageLike.image = UIImage(named: "heart.png")
    } else {
      imageLike.image = UIImage(named: "heartRed.png")
    }
    
    let effect = UIBlurEffect(style: .Light)
    let blurView = UIVisualEffectView(effect: effect)
    blurView.frame = self.view.bounds
    self.view.addSubview(blurView)
    self.view.sendSubviewToBack(blurView)
    
    notificationCenter.addObserver(self, selector: #selector(PlayerViewController.updateIcons), name: "updateIcons", object: nil)
  }
  
  func toggle() {
    
    if StreamingRadioManager.sharedInstance.currentlyPlaying() {
      StreamingRadioManager.sharedInstance.stop() //se clicar no botão e estiver tocando algo, o player para.
    } else {
      StreamingRadioManager.sharedInstance.playActualRadio() //se clicar no botão e não estiver tocando algo, o player começa.
    }
    
//    
//    
//    
//    
//    
//    if (RadioPlayer.sharedInstance.actualRadio != DataManager.sharedInstance.radioInExecution) {
//        resetStream()
//    } else {
//      if RadioPlayer.sharedInstance.currentlyPlaying(){
//        pauseRadio()
//      } else {
//        playRadio()
//      }
//    }
//    DataManager.sharedInstance.radioInExecution = RadioPlayer.sharedInstance.actualRadio
    
  }
  
  func updateInfoOfView() {
    imageLogo.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(StreamingRadioManager.sharedInstance.actualRadio.thumbnail)))
    
    labelName.text = StreamingRadioManager.sharedInstance.actualRadio.name
    
    if let _ = StreamingRadioManager.sharedInstance.actualRadio.address {
      labelLocal.text = StreamingRadioManager.sharedInstance.actualRadio.address.formattedLocal
    }
    labelLikes.text = "\(StreamingRadioManager.sharedInstance.actualRadio.likenumber)"
    labelStars.text = "\(StreamingRadioManager.sharedInstance.actualRadio.score)"
    self.title = "Resumo"
    stars.append(starOne)
    stars.append(starTwo)
    stars.append(starThree)
    stars.append(starFive)
    stars.append(starFour)
    for star in stars  {
      star.image = UIImage(named: "starOFF.png")
    }
    if StreamingRadioManager.sharedInstance.actualRadio.score != 0 && StreamingRadioManager.sharedInstance.actualRadio.score != -1 {
      for index in 0...StreamingRadioManager.sharedInstance.actualRadio.score-1 {
        stars[index].image = UIImage(named: "star.png")
      }
    }
    if StreamingRadioManager.sharedInstance.currentlyPlaying()  {
      //so mostra o play para a radio que esta tocando
      buttonPlay.setImage(UIImage(named: "pause.png"), forState: .Normal)
    } else {
      buttonPlay.setImage(UIImage(named: "play.png"), forState: .Normal)
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
    toggle()
    StreamingRadioManager.sharedInstance.sendNotification()
  }
  
  override func viewWillAppear(animated: Bool) {
  }
  
  
//  func playRadio() {
//    firstErrorSkip = false
//    firstInstanceSkip = false
//    
//    if RadioPlayer.sharedInstance.errorMessage != "" || RadioPlayer.sharedInstance.bufferFull() {
//      resetStream()
//    } else {
//      RadioPlayer.sharedInstance.play()
//    }
//  }
//  
//  func pauseRadio() {
//    RadioPlayer.sharedInstance.pause()
//  }
//  
//  func resetStream() {
//    print("Reloading interrupted stream");
//    RadioPlayer.sharedInstance.resetPlayer()
//    RadioPlayer.sharedInstance.errorDelegate = self
//    RadioPlayer.sharedInstance.instanceDelegate = self
//    if RadioPlayer.sharedInstance.bufferFull() {
//      RadioPlayer.sharedInstance.play()
//    } else {
//      self.playRadio()
//    }
//    
//  }
  
//  func errorMessageChanged(newVal: String) {
//    if !firstErrorSkip {
//      print("Error changed to '\(newVal)'")
//      if RadioPlayer.sharedInstance.errorMessage != "" {
//        print("Showing Error Message")
//        let alertController = UIAlertController(title: "Stream Failure", message: RadioPlayer.sharedInstance.errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
//        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
//        
//        self.presentViewController(alertController, animated: true, completion: nil)
//        
//        pauseRadio()
//        
//      }
//    } else {
//      print("Skipping first init")
//      firstErrorSkip = false
//    }
//  }
  
//  func sharedInstanceChanged(newVal: Bool) {
//    if !firstInstanceSkip {
//      print("Detected New Instance")
//      if newVal {
//        RadioPlayer.sharedInstance.play()
//      }
//    } else {
//      firstInstanceSkip = false
//    }
//  }
  
  func updateIcons() {
    
    if StreamingRadioManager.sharedInstance.currentlyPlaying()  {
      //so mostra o play para a radio que esta tocando
      buttonPlay.setImage(UIImage(named: "pause.png"), forState: .Normal)
    } else {
      buttonPlay.setImage(UIImage(named: "play.png"), forState: .Normal)
    }
    updateInfoOfView()
  }
  
  
  
  @IBAction func hidePlayerAction(sender: AnyObject) {
    DataManager.sharedInstance.miniPlayerView.hidePlayer()
  }
  
  @IBAction func buttonFavTap(sender: AnyObject) {
    let manager = RequestManager()
    if StreamingRadioManager.sharedInstance.actualRadio.isFavorite {
      imageLike.image = UIImage(named: "heart.png")
      StreamingRadioManager.sharedInstance.actualRadio.updateIsFavorite(false)
      manager.deleteFavRadio(RadioPlayer.sharedInstance.actualRadio, completion: { (result) in
      })
    } else {
      imageLike.image = UIImage(named: "heartRed.png")
      StreamingRadioManager.sharedInstance.actualRadio.updateIsFavorite(true)
      manager.favRadio(StreamingRadioManager.sharedInstance.actualRadio, completion: { (resultFav) in
      })
    }
    
  }
  
}
