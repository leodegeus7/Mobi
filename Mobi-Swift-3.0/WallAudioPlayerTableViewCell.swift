//
//  AudioPlayerTableViewCell.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/26/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class WallAudioPlayerTableViewCell: UITableViewCell, AVAudioPlayerDelegate {
  
  @IBOutlet weak var textViewWall: UITextView!
  @IBOutlet weak var labelDate: UILabel!
  @IBOutlet weak var labelName: UILabel!
  @IBOutlet weak var imageUser: UIImageView!
  
  
  @IBOutlet weak var progressView: UIProgressView!
  @IBOutlet weak var buttonZoomImage: UIButton!
  @IBOutlet weak var imageAttachment: UIImageView!
  @IBOutlet weak var audioProgressView: UIProgressView!
  @IBOutlet weak var buttonPlay: UIButton!
  @IBOutlet weak var activityIndicatorAudio: UIActivityIndicatorView!
  
  
  var audioToPlayUrl:NSURL!
  var identifier:String!
  var durationAudio = -1.0
  var timer = NSTimer()
  var actionDuration = 0.0
  
  
  
  var audioIsReproducing = false
  
  override func awakeFromNib() {
    super.awakeFromNib()
    let colorAlpha = DataManager.sharedInstance.interfaceColor.color.colorWithAlphaComponent(0.2)
    let viewSelected = UIView()
    viewSelected.backgroundColor = colorAlpha
    self.selectedBackgroundView = viewSelected
    buttonPlay.backgroundColor = UIColor.clearColor()
    activityIndicatorAudio.hidden = true
    buttonPlay.setBackgroundImage(UIImage(named: "play3.png"), forState: .Normal)
    progressView.progressTintColor = DataManager.sharedInstance.interfaceColor.color
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  @IBAction func buttonPlayTapped(sender: AnyObject) {
    
    
    if !audioIsReproducing {
      activityIndicatorAudio.hidden = false
      buttonPlay.alpha = 0.4
      
      
      self.buttonPlay.alpha = 1
      
      
      if !FileSupport.testIfFileExistInDocuments("\(self.identifier).m4a") {
        let requestAudio = RequestManager()
        requestAudio.downloadFileWithIdentifier(identifier, format: "m4a") { (url) in
          self.activityIndicatorAudio.hidden = true
          self.buttonPlay.alpha = 1
          if FileSupport.testIfFileExistInDocuments("\(self.identifier).m4a") {
            dispatch_async(dispatch_get_main_queue()) {
              self.activityIndicatorAudio.hidden = true
              self.buttonPlay.alpha = 1
              self.playAudio()
              
            }
            
            

          } else {
            print("Arquivo não existe")
            
          }
        }
      } else {
        playAudio()
      }
    } else {
      DataManager.sharedInstance.avPlayer.pause()
      timer.invalidate()
      timer = NSTimer()
      audioIsReproducing = false
      durationAudio = 0.0
      actionDuration = 0.0
      buttonPlay.setBackgroundImage(UIImage(named: "play3.png"), forState: .Normal)
    }
  }
  
  func returnLinkAudio(identifier:String) -> Link {
    let URL = Link(link: "\(DataManager.sharedInstance.baseURL)app/file/download?identifier=\(identifier)", linkType: .Audio)
    return URL
  }
  
  func playAudio() {
    activityIndicatorAudio.hidden = true
    buttonPlay.alpha = 1
    self.buttonPlay.setBackgroundImage(UIImage(named: "pause2.png"), forState: .Normal)
    actionDuration = 0
    durationAudio = -1
    progressView.progress = 0
    timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(WallAudioPlayerTableViewCell.setProgress), userInfo: nil, repeats: true)
    DataManager.sharedInstance.avPlayer = try! AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: "\(FileSupport.findDocsDirectory())\(self.identifier).m4a"))
    durationAudio = DataManager.sharedInstance.avPlayer.duration
    print("Reproduzindo audio \(self.identifier) de duração de \(durationAudio) segundos")
    DataManager.sharedInstance.avPlayer.delegate = self
    DataManager.sharedInstance.avPlayer.play()
    audioIsReproducing = true
  }
  
  func setProgress() {
    progressView.progress = Float(actionDuration)/Float(durationAudio)
    actionDuration += 0.1
  }
  //  func playAudioFromBundle(name:String) {
  //    try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
  //    try! AVAudioSession.sharedInstance().setActive(true)
  //
  //        //avPlayer.delegate = self
  //    let urlAudio = NSBundle.mainBundle().pathForResource("\(name)", ofType: "m4a")
  //    print("\(urlAudio)")
  //    do {
  //      DataManager.sharedInstance.avPlayer = try AVAudioPlayer(contentsOfURL: NSURL(string: urlAudio!)!)
  //      DataManager.sharedInstance.avPlayer.play()
  //      print("TOCOU \(name)")
  //    } catch {
  //      print("Error")
  //    }
  //
  //
  //
  //    //guard let player = self.player else { print("Nao carregou o audio") }
  //
  //
  //  }
  
  func audioPlayerEndInterruption(player: AVAudioPlayer) {
    print("Aqui")
    audioIsReproducing = false
  }
  
  func audioPlayerBeginInterruption(player: AVAudioPlayer) {
    print("Aqui")
  }
  
  func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
    print("Erro ao reproduzir audio")
    audioIsReproducing = false
  }
  
  func audioPlayerEndInterruption(player: AVAudioPlayer, withFlags flags: Int) {
    print("Aqui")
  }
  
  func audioPlayerEndInterruption(player: AVAudioPlayer, withOptions flags: Int) {
    print("Aqui")
  }
  
  func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
    print("Audio parou reprodução")
    progressView.progress = 1
    audioIsReproducing = false
    timer.invalidate()
    self.activityIndicatorAudio.hidden = true
    self.buttonPlay.alpha = 1
          buttonPlay.setBackgroundImage(UIImage(named: "play3.png"), forState: .Normal)
  }
  
}
