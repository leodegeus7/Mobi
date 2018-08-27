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
  
    static let sharedInstance = StreamingRadioManager()
  
  var options = STKAudioPlayerOptions()
  var audioPlayer = STKAudioPlayer()
  var isPlaying = false
  var actualRadio = RadioRealm()
  internal var predecessorRadio = RadioRealm()
  var notificationCenter = NotificationCenter.default
    
    enum Mode {
        case m3U8
        case normal
        case unknown
    }
    
    var mode:Mode = .unknown
    
    //M3U8
    var audioPlayerAux = AVPlayer()
    

  
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
    
    UIApplication.shared.beginReceivingRemoteControlEvents()
    
    audioPlayer = STKAudioPlayer(options: options)
    audioPlayer.equalizerEnabled = true
    audioPlayer.meteringEnabled = true
    audioPlayer.volume = 1
    audioPlayer.delegate = self
    
    audioPlayerAux.volume = 1
    
    
  }
  
  func audioPlayer(_ audioPlayer: STKAudioPlayer, didStartPlayingQueueItemId queueItemId: NSObject) {
    
  }
  
  func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishPlayingQueueItemId queueItemId: NSObject, with stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double) {
    
  }
  
  func audioPlayer(_ audioPlayer: STKAudioPlayer, stateChanged state: STKAudioPlayerState, previousState: STKAudioPlayerState) {
    //let stateMine:STKAudioPlayerState = state
    if audioPlayer.state == .error {
      audioPlayer.stop()
      let link = actualRadio.audioChannels.first!.linkIsWrongReturnOther()
      playWithLink(actualRadio,link: link)
      print("Nao conseguiu rodar")
    }
    
  }
  
  func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject) {
    
  }
  
  
  func audioPlayer(_ audioPlayer: STKAudioPlayer, unexpectedError errorCode: STKAudioPlayerErrorCode) {
    print("Erro ao reproduzir o  streaming")
    Util.displayAlert(title: "Erro", message: "Não foi possível iniciar o streaming - ErroCode: \(errorCode)", action: "Ok")
  }
  
  func audioPlayer(_ audioPlayer: STKAudioPlayer, logInfo line: String) {
    if line == "" {
      
    }
  }
  
  func stop() {
    if mode == .m3U8 {
        audioPlayerAux.pause()
    } else if mode == .normal {
        audioPlayer.stop()
    }
    isPlaying = false
  }
  
  func play(_ radio:RadioRealm) {
    predecessorRadio = actualRadio
    actualRadio = radio
    
    
    
    let link = actualRadio.audioChannels[0].returnLink()
    
    
    if (testIfLinkIsM3U8(link)) {
        if isPlaying && mode == .normal {
            audioPlayer.pause()
        }
        
        mode = .m3U8

        let url = URL(string: link)!
        audioPlayerAux = AVPlayer(url: url)
        audioPlayerAux.play()
    } else {
        
        if isPlaying && mode == .m3U8 {
            audioPlayerAux.pause()
        }
        
        mode = .normal
        audioPlayer.play(link)
    }
    
    defineInfoCenter()
    isPlaying = true
    let historicManager = RequestManager()
    historicManager.markRadioHistoric(radio) { (resultFav) in
    }
  }
    
    func testIfLinkIsM3U8(_ link:String) -> Bool {
        let components = link.components(separatedBy: ".")
        if components.count > 1 {
            let last = components.last
            print(components.last)
            if last == "m3u8" {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
  
  func playWithLink(_ radio:RadioRealm,link:String) {
    
    
    defineInfoCenter()
    
    if (testIfLinkIsM3U8(link)) {
        if isPlaying && mode == .normal {
            audioPlayer.pause()
        }
        
        mode = .m3U8
        
        let url = URL(string: link)!
        audioPlayerAux = AVPlayer(url: url)
        audioPlayerAux.play()
    } else {
        
        if isPlaying && mode == .m3U8 {
            audioPlayerAux.pause()
        }
        
        mode = .normal
        audioPlayer.play(link)
    }

    
    isPlaying = true
    let historicManager = RequestManager()
    historicManager.markRadioHistoric(radio) { (resultFav) in
    }
  }
  
  func playActualRadio() -> Bool {
    if actualRadio.name != "" {
        let link = actualRadio.audioChannels[0].returnLink()
        if (testIfLinkIsM3U8(link)) {
            if isPlaying && mode == .normal {
                audioPlayer.pause()
            }
            
            mode = .m3U8
            
            let url = URL(string: link)!
            audioPlayerAux = AVPlayer(url: url)
            audioPlayerAux.play()
        } else {
            
            if isPlaying && mode == .m3U8 {
                audioPlayerAux.pause()
            }
            
            mode = .normal
            audioPlayer.play(link)
        }


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
  
  func isRadioInViewCurrentyPlaying(_ radioInView:RadioRealm) -> Bool {
    if radioInView == actualRadio {
      return true
    } else {
      return false
    }
  }
  
  func sendNotification() {
    notificationCenter.post(name: Notification.Name(rawValue: "updateIcons"), object: nil)
  }
  
  func defineInfoCenter() {
    let albumDict = [MPMediaItemPropertyTitle: "\(self.actualRadio.name)"]
    let thumbnailRadio = self.actualRadio.thumbnail
    let nameRadio = self.actualRadio.name
    MPNowPlayingInfoCenter.default().nowPlayingInfo = albumDict
    DispatchQueue.global().async {
        ImageDownloader.default.downloadImage(with: URL(string: RequestManager.getLinkFromImageWithIdentifierString(thumbnailRadio!))!, retrieveImageTask: nil, options: [], progressBlock: nil, completionHandler: { (image, error, imageURL, originalData) in
            if let imageAux = image {
                let albumArt = MPMediaItemArtwork(image: imageAux)
                let albumDict = [MPMediaItemPropertyTitle: "\(nameRadio)", MPMediaItemPropertyArtwork: albumArt] as [String : Any]
                MPNowPlayingInfoCenter.default().nowPlayingInfo = albumDict
            }

        })
        
    }
  }
  
  var adsInfo = AdsInfo()
  
}
