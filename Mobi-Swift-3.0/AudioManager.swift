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

class AudioManager: NSObject,STKAudioPlayerDelegate {
  
  var options = STKAudioPlayerOptions()
  var audioPlayer = STKAudioPlayer()
  var isPlaying = false
  var actualLink = Link()
  var cellToReproduce:WallAudioPlayerTableViewCell!
  
  override init() {
    super.init()
    ///////////////////////////////////////////////////////////
    //MARK: --- OPTIONS CONFIG ABOUT FREQUENCY ---
    ///////////////////////////////////////////////////////////
    
    options.flushQueueOnSeek = true
    options.enableVolumeMixer = true
    
    ///////////////////////////////////////////////////////////
    //MARK: --- AUDIOPLAYER CONFIG ---
    ///////////////////////////////////////////////////////////
    
    
    audioPlayer = STKAudioPlayer()
    audioPlayer.equalizerEnabled = false
    audioPlayer.meteringEnabled = false
    audioPlayer.volume = 1
    audioPlayer.delegate = self
  }
  
  
  func audioPlayer(audioPlayer: STKAudioPlayer, didStartPlayingQueueItemId queueItemId: NSObject) {
    cellToReproduce.buttonPlay.setBackgroundImage(UIImage(named: "pause4.png"), forState: .Normal)
    isPlaying = false
  }
  
  func audioPlayer(audioPlayer: STKAudioPlayer, didFinishPlayingQueueItemId queueItemId: NSObject, withReason stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double) {
    cellToReproduce.buttonPlay.setBackgroundImage(UIImage(named: "play3.png"), forState: .Normal)
    isPlaying = false
  }
  
  func audioPlayer(audioPlayer: STKAudioPlayer, stateChanged state: STKAudioPlayerState, previousState: STKAudioPlayerState) {
//    if audioPlayer.state == .Error {
//      audioPlayer.stop()
//      print("Nao conseguiu rodar")
//      cellToReproduce.buttonPlay.setBackgroundImage(UIImage(named: "play3.png"), forState: .Normal)
//      isPlaying = false
//    } else if audioPlayer.state == .Paused {
//      cellToReproduce.buttonPlay.setBackgroundImage(UIImage(named: "play3.png"), forState: .Normal)
//      isPlaying = false
//    } else if audioPlayer.state == .Stopped {
//      cellToReproduce.buttonPlay.setBackgroundImage(UIImage(named: "play3.png"), forState: .Normal)
//      isPlaying = false
//    } else if audioPlayer.state == .Playing {
//      cellToReproduce.buttonPlay.setBackgroundImage(UIImage(named: "pause4.png"), forState: .Normal)
//    } else if audioPlayer.state == .Running {
//      cellToReproduce.buttonPlay.setBackgroundImage(UIImage(named: "pause4.png"), forState: .Normal)
//    }
    
  }
  
  func audioPlayer(audioPlayer: STKAudioPlayer, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject) {
    
  }
  
  
  func audioPlayer(audioPlayer: STKAudioPlayer, unexpectedError errorCode: STKAudioPlayerErrorCode) {
    print("Erro ao reproduzir o  streaming")
    Util.displayAlert(title: "Erro", message: "Erro ao reproduzir o audio - ErroCode: \(errorCode)", action: "Ok")
  }
  
  func audioPlayer(audioPlayer: STKAudioPlayer, logInfo line: String) {
  }
  
  
  func play(link:Link,cell:WallAudioPlayerTableViewCell) {
    
    let playerItem = AVPlayerItem(URL: NSURL(string: link.link)!)
    var player = AVPlayer()
    player = AVPlayer(playerItem: playerItem)
    player.rate = 1
    player.play()
    
    self.cellToReproduce = cell
    cell.buttonPlay.setBackgroundImage(UIImage(named: "pause4.png"), forState: .Normal)
//    audioPlayer.play(link.link)
    isPlaying = true
  }
  
  func stop() {
    audioPlayer.pause()
  }
  
  
  func currentlyPlaying() -> Bool {
    if isPlaying {
      return true
    } else {
      return false
    }
  }
  
  
}
