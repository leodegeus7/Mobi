//
//  StreamingManager.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 9/16/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class StreamingManager: NSObject {
  
  var audioPlayer = STKAudioPlayer()
  
  override init() {
    let equalizer:(Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32) = (50, 100, 200, 400, 800, 600, 2600, 16000, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
    let options = STKAudioPlayerOptions(flushQueueOnSeek: true, enableVolumeMixer: true, equalizerBandFrequencies: equalizer, readBufferSize: 50, bufferSizeInSeconds: 10, secondsRequiredToStartPlaying: 3, gracePeriodAfterSeekInSeconds: 3, secondsRequiredToStartPlayingAfterBufferUnderun: 3)
    audioPlayer = STKAudioPlayer(options: options)
    audioPlayer.equalizerEnabled = true

  }
  
  func play(radio:RadioRealm,streamingType:StreamingLinkType) {
    audioPlayer.play(radio.streamingLinks[streamingType.rawValue].link)
    UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
  }
  
  func stop(radio:RadioRealm,streamingType:StreamingLinkType) {
    audioPlayer.stop()
  }
  
  
  func mudeOn() {
    audioPlayer.mute()
  }
  
  func mudeOff() {
    audioPlayer.muted = false
  }
  
  func isMude() -> Bool{
    return audioPlayer.muted
  }
}
