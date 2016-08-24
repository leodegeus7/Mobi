//
//  ModalViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/22/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import AVFoundation

class ModalViewController: UIViewController, errorMessageDelegate, sharedInstanceDelegate {

    var tapCloseButtonActionHandler : (Void -> Void)?
  var firstErrorSkip = true
  var firstInstanceSkip = true
  
  
    @IBOutlet weak var listenLabel: UILabel!
    @IBOutlet weak var radioSwitch: UIImageView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
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
        radioSwitch.image = UIImage(named: "Radio_Switch_Active")
        listenLabel.text = "Click to Pause Radio Stream:"
      }
      
      let effect = UIBlurEffect(style: .Light)
      let blurView = UIVisualEffectView(effect: effect)
      blurView.frame = self.view.bounds
      self.view.addSubview(blurView)
      self.view.sendSubviewToBack(blurView)
    }
  
  func toggle() {
    if RadioPlayer.sharedInstance.currentlyPlaying() {
      pauseRadio()
    } else {
      playRadio()
    }
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  @IBAction func back(sender: AnyObject) {
    print("Dismissing radio view")
    if let navigationController = self.navigationController
    {
      navigationController.popViewControllerAnimated(true)
    }
  }
  
  @IBAction func switched(sender: AnyObject) {
    toggle()
  }
  
  @IBAction func tapCloseButton(sender: AnyObject) {
    self.tapCloseButtonActionHandler?()
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    print("ModalViewController viewWillAppear")
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    print("ModalViewController viewWillDisappear")
  }
  
  func playRadio() {
    firstErrorSkip = false
    firstInstanceSkip = false
    
    if RadioPlayer.sharedInstance.errorMessage != "" || RadioPlayer.sharedInstance.bufferFull() {
      resetStream()
    } else {
      radioSwitch.image = UIImage(named: "Radio_Switch_Active")
      listenLabel.text = "Click to Pause Radio Stream:"
      RadioPlayer.sharedInstance.play()
    }
  }
  
  func pauseRadio() {
    RadioPlayer.sharedInstance.pause()
    radioSwitch.image = UIImage(named: "Radio_Switch_Inactive")
    listenLabel.text = "Click to Play Radio Stream:"
  }
  
  func resetStream() {
    print("Reloading interrupted stream");
    RadioPlayer.sharedInstance.resetPlayer()
    //RadioPlayer.sharedInstance = RadioPlayer();
    RadioPlayer.sharedInstance.errorDelegate = self
    RadioPlayer.sharedInstance.instanceDelegate = self
    if RadioPlayer.sharedInstance.bufferFull() {
      radioSwitch.image = UIImage(named: "Radio_Switch_Active")
      listenLabel.text = "Click to Pause Radio Stream:"
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




}
