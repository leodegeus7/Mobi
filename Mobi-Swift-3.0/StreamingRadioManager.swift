//
//  StreamingRadioManager.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 9/20/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import MediaPlayer
import Kingfisher

class StreamingRadioManager: NSObject,STKAudioPlayerDelegate {
  
  var options = STKAudioPlayerOptions()
  var audioPlayer = STKAudioPlayer()
  var isPlaying = false
  var actualRadio = RadioRealm()
  internal var predecessorRadio = RadioRealm()
  var notificationCenter = NSNotificationCenter.defaultCenter()
  
  class var sharedInstance: StreamingRadioManager {
    struct Static {
      static var instance: StreamingRadioManager?
      static var token: dispatch_once_t = 0
    }
    
    dispatch_once(&Static.token) {
      Static.instance = StreamingRadioManager()
    }
    return Static.instance!
  }
  
  override init() {
    super.init()
    ///////////////////////////////////////////////////////////
    //MARK: --- OPTIONS CONFIG ABOUT FREQUENCY ---
    ///////////////////////////////////////////////////////////

    let equalizerFrequency:(Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32) = (60, 150, 400, 1000, 2400, 15000, 0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
    options.equalizerBandFrequencies = equalizerFrequency
    options.flushQueueOnSeek = true
    options.enableVolumeMixer = true
    
    ///////////////////////////////////////////////////////////
    //MARK: --- AUDIOPLAYER CONFIG ---
    ///////////////////////////////////////////////////////////
    
    UIApplication.sharedApplication().beginReceivingRemoteControlEvents()

    audioPlayer = STKAudioPlayer(options: options)
    audioPlayer.equalizerEnabled = true
    audioPlayer.meteringEnabled = true
    audioPlayer.volume = 1
    audioPlayer.delegate = self
  }
  
  func audioPlayer(audioPlayer: STKAudioPlayer, didStartPlayingQueueItemId queueItemId: NSObject) {
    
  }
  
  func audioPlayer(audioPlayer: STKAudioPlayer, didFinishPlayingQueueItemId queueItemId: NSObject, withReason stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double) {
    
  }
  
  func audioPlayer(audioPlayer: STKAudioPlayer, stateChanged state: STKAudioPlayerState, previousState: STKAudioPlayerState) {
    
  }
  
  func audioPlayer(audioPlayer: STKAudioPlayer, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject) {
    
  }
  
  func audioPlayer(audioPlayer: STKAudioPlayer, unexpectedError errorCode: STKAudioPlayerErrorCode) {
    print("Erro ao reproduzir o  stremaing \(RadioPlayer.sharedInstance.actualRadio.audioChannels[0].returnLink())")
    Util.displayAlert(title: "Erro", message: "Não foi possível iniciar o streamign - ErroCode: \(errorCode)", action: "Ok")
  }
  func stop() {
    audioPlayer.stop()
    isPlaying = false
  }
  
  func play(radio:RadioRealm) {
    predecessorRadio = actualRadio
    actualRadio = radio
    audioPlayer.play(actualRadio.audioChannels[0].returnLink())
    
    defineInfoCenter()



    isPlaying = true
    let historicManager = RequestManager()
    historicManager.markRadioHistoric(radio) { (resultFav) in
    }
  }
  
  func playActualRadio() -> Bool {
    if actualRadio.name != "" {
      audioPlayer.play(actualRadio.audioChannels[0].returnLink())
      isPlaying = true
      let historicManager = RequestManager()
        historicManager.markRadioHistoric(actualRadio) { (resultFav) in
      }
      return true
    } else {
      return false
    }
  }
  
  
  func currentlyPlaying() -> Bool {
    if isPlaying {
      return true
    } else {
      return false
    }
  }
  
  func isRadioInViewCurrentyPlaying(radioInView:RadioRealm) -> Bool {
    if radioInView == actualRadio {
      return true
    } else {
      return false
    }
  }
  
  func sendNotification() {
    notificationCenter.postNotificationName("updateIcons", object: nil)
  }
  
  func defineInfoCenter() {
    let albumDict = [MPMediaItemPropertyTitle: "\(self.actualRadio.name)"]
    MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = albumDict
    
    ImageDownloader.defaultDownloader.downloadImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(actualRadio.thumbnail))!, options: [], progressBlock: nil) { (image, error, imageURL, originalData) in
      let albumArt = MPMediaItemArtwork(image: image!)
      let albumDict = [MPMediaItemPropertyTitle: "\(self.actualRadio.name)", MPMediaItemPropertyArtwork: albumArt]
      MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = albumDict
    }
  }

}
