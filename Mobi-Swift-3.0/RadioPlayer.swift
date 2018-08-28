//
//  RadioPlayer.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/12/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import AVFoundation

protocol errorMessageDelegate {
  func errorMessageChanged(_ newVal: String)
}

class RadioPlayer : NSObject {
  
  var actualRadio = RadioRealm()
  
  static let sharedInstance = RadioPlayer()
  var instanceDelegate:sharedInstanceDelegate? = nil
  var sharedInstanceBool = false {
    didSet {
      if let delegate = self.instanceDelegate {
        delegate.sharedInstanceChanged(self.sharedInstanceBool)
      }
    }
  }
  
  fileprivate var player = AVPlayer()
  fileprivate var isPlaying = false
  var notificationCenter = NotificationCenter.default
  
  var errorDelegate:errorMessageDelegate? = nil
  var errorMessage = "" {
    didSet {
      if let delegate = self.errorDelegate {
        delegate.errorMessageChanged(self.errorMessage)
      }
    }
  }
  
  override init() {
    super.init()
    
    errorMessage = ""
//    let url = DataManager.sharedInstance.radioInExecution.streamingLinks[0].link
    let asset: AVURLAsset = AVURLAsset(url: URL(string: "")!, options: nil)
    
    let statusKey = "tracks"
    
    asset.loadValuesAsynchronously(forKeys: [statusKey], completionHandler: {
      var error: NSError? = nil
      
      DispatchQueue.main.async(execute: {
        let status: AVKeyValueStatus = asset.statusOfValue(forKey: statusKey, error: &error)
        
        if status == AVKeyValueStatus.loaded{
          
          let playerItem = AVPlayerItem(asset: asset)
          
          self.player = AVPlayer(playerItem: playerItem)
          self.sharedInstanceBool = true
          
        } else {
          self.errorMessage = error!.localizedDescription
          print(error!)
        }
        
      })
      
      
    })
    
    NotificationCenter.default.addObserver(
      forName: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime,
      object: nil,
      queue: nil,
      using: { notification in
        print("Status: Failed to continue")
        self.errorMessage = "Stream was interrupted"
    })
    
    print("Initializing new player")
    
  }
  
  
  
  func resetPlayer() {
    errorMessage = ""
    
    let link = actualRadio.audioChannels[0].returnLink()
    let asset: AVURLAsset = AVURLAsset(url: URL(string: link)!, options: nil)
    
    let statusKey = "tracks"
    
    asset.loadValuesAsynchronously(forKeys: [statusKey], completionHandler: {
      var error: NSError? = nil
      
      DispatchQueue.main.async(execute: {
        let status: AVKeyValueStatus = asset.statusOfValue(forKey: statusKey, error: &error)
        
        if status == AVKeyValueStatus.loaded{
          
          let playerItem = AVPlayerItem(asset: asset)
          //playerItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: &ItemStatusContext)
          
          
          self.player = AVPlayer(playerItem: playerItem)
        
          
          self.sharedInstanceBool = true
          
        } else {
          self.errorMessage = error!.localizedDescription
          print(error!)
        }
        
        
      })
    })
  }
  

  

  
  func play() {
    player.play()
    isPlaying = true
    print("Radio is \(isPlaying ? "" : "not ")playing")
  }
  
  func pause() {
    player.pause()
    isPlaying = false
    print("Radio is \(isPlaying ? "" : "not ")playing")
  }
  
  func currentlyPlaying() -> Bool {
    return isPlaying
  }
  
  func sendNotification() {
    notificationCenter.post(name: Notification.Name(rawValue: "updateIcons"), object: nil)
  }
  
}
protocol sharedInstanceDelegate {
  func sharedInstanceChanged(_ newVal: Bool)
}
