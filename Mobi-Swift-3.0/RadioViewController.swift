//
//  RadioViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/25/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import AVFoundation

class RadioViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, errorMessageDelegate, sharedInstanceDelegate {
  
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
  
  var stars = [UIImageView]()
  var actualRadio = DataManager.sharedInstance.allRadios[0]
  var tapCloseButtonActionHandler : (Void -> Void)?
  var firstErrorSkip = true
  var firstInstanceSkip = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    DataManager.sharedInstance.radioVC = self
    imageLogo.image = UIImage(named: "\(actualRadio.thumbnail)")
    labelName.text = actualRadio.name
    labelLocal.text = actualRadio.address.formattedLocal
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
    if actualRadio.stars != 0 {
      for index in 0...actualRadio.stars-1 {
        stars[index].image = UIImage(named: "star.png")
      }
    }
    
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
      print("AVAudioSession Category Playback OK")
      do {
        try AVAudioSession.sharedInstance().setActive(true)
        print("AVAudioSession is Active")
        
      } catch let error as NSError {
        print(error.localizedDescription)
      }
    } catch let error as NSError {
      print(error.localizedDescription)
    }
    
    RadioPlayer.sharedInstance.errorDelegate = self
    RadioPlayer.sharedInstance.instanceDelegate = self
    
    if RadioPlayer.sharedInstance.currentlyPlaying() {
        buttonPlay.imageView?.image = UIImage(named: "play.png")
    }
    
    let effect = UIBlurEffect(style: .Light)
    let blurView = UIVisualEffectView(effect: effect)
    blurView.frame = self.view.bounds
    self.view.addSubview(blurView)
    self.view.sendSubviewToBack(blurView)
    changeButtonIcon()
  }
  
  func toggle() {
    if RadioPlayer.sharedInstance.currentlyPlaying() {
      pauseRadio()
    } else {
      playRadio()
    }
    changeButtonIcon()
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
    toggle()
    if DataManager.sharedInstance.isPlay {
      DataManager.sharedInstance.isPlay = false
      
    } else {
      DataManager.sharedInstance.isPlay = true
    }

    if !DataManager.sharedInstance.playerIsLoaded {
      let viewOne = DataManager.sharedInstance.viewOne
      viewOne.tapMiniPlayerButton(viewOne)
      DataManager.sharedInstance.playerIsLoaded = true
    }

  }
  
  override func viewWillAppear(animated: Bool) {
    changeButtonIcon()
  }
  
  
  func playRadio() {
    firstErrorSkip = false
    firstInstanceSkip = false
    
    if RadioPlayer.sharedInstance.errorMessage != "" || RadioPlayer.sharedInstance.bufferFull() {
      resetStream()
    } else {
      RadioPlayer.sharedInstance.play()
    }
  }
  
  func pauseRadio() {
    RadioPlayer.sharedInstance.pause()
  }
  
  func resetStream() {
    print("Reloading interrupted stream");
    RadioPlayer.sharedInstance.resetPlayer()
    //RadioPlayer.sharedInstance = RadioPlayer();
    RadioPlayer.sharedInstance.errorDelegate = self
    RadioPlayer.sharedInstance.instanceDelegate = self
    if RadioPlayer.sharedInstance.bufferFull() {
      RadioPlayer.sharedInstance.play()
    } else {
      playRadio()
    }
  }
  
  func errorMessageChanged(newVal: String) {
    if !firstErrorSkip {
      print("Error changed to '\(newVal)'")
      if RadioPlayer.sharedInstance.errorMessage != "" {
        print("Showing Error Message")
        let alertController = UIAlertController(title: "Stream Failure", message: RadioPlayer.sharedInstance.errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
        pauseRadio()
        
      }
    } else {
      print("Skipping first init")
      firstErrorSkip = false
    }
  }
  
  func sharedInstanceChanged(newVal: Bool) {
    if !firstInstanceSkip {
      print("Detected New Instance")
      if newVal {
        RadioPlayer.sharedInstance.play()
      }
    } else {
      firstInstanceSkip = false
    }
  }

  func changeButtonIcon() {
    if DataManager.sharedInstance.isPlay {
      DataManager.sharedInstance.radioVC.buttonPlay.setImage(UIImage(named: "play.png"), forState: .Normal)
    } else if !DataManager.sharedInstance.isPlay {
      DataManager.sharedInstance.radioVC.buttonPlay.setImage(UIImage(named: "pause.png"), forState: .Normal)
    }
  }
  
  
}
