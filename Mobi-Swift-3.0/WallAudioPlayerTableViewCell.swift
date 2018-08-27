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
  
  
  var audioToPlayUrl:URL!
  var identifier:String!
  var durationAudio = -1.0
  var timer = Timer()
  var actionDuration = 0.0
  
  
  
  var audioIsReproducing = false
  
  override func awakeFromNib() {
    super.awakeFromNib()
    let colorAlpha = DataManager.sharedInstance.interfaceColor.color.withAlphaComponent(0.2)
    let viewSelected = UIView()
    viewSelected.backgroundColor = colorAlpha
    self.selectedBackgroundView = viewSelected
    buttonPlay.backgroundColor = UIColor.clear
    activityIndicatorAudio.isHidden = true
    buttonPlay.setBackgroundImage(UIImage(named: "play3.png"), for: UIControlState())
    progressView.progressTintColor = DataManager.sharedInstance.interfaceColor.color
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  @IBAction func buttonPlayTapped(_ sender: AnyObject) {
    
    
    if !audioIsReproducing {
      activityIndicatorAudio.isHidden = false
      buttonPlay.alpha = 0.4
      
      
      self.buttonPlay.alpha = 1
      
      
      if !FileSupport.testIfFileExistInDocuments("\(self.identifier).m4a") {
        let requestAudio = RequestManager()
        requestAudio.downloadFileWithIdentifier(identifier, format: "m4a") { (url) in
          self.activityIndicatorAudio.isHidden = true
          self.buttonPlay.alpha = 1
          if FileSupport.testIfFileExistInDocuments("\(self.identifier).m4a") {
            DispatchQueue.main.async {
              self.activityIndicatorAudio.isHidden = true
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
      timer = Timer()
      audioIsReproducing = false
      durationAudio = 0.0
      actionDuration = 0.0
      buttonPlay.setBackgroundImage(UIImage(named: "play3.png"), for: UIControlState())
    }
  }
  
  func returnLinkAudio(_ identifier:String) -> Link {
    let URL = Link(link: "\(DataManager.sharedInstance.baseURL)app/file/download?identifier=\(identifier)", linkType: .audio)
    return URL
  }
  
  func playAudio() {
    activityIndicatorAudio.isHidden = true
    buttonPlay.alpha = 1
    self.buttonPlay.setBackgroundImage(UIImage(named: "pause2.png"), for: UIControlState())
    actionDuration = 0
    durationAudio = -1
    progressView.progress = 0
    timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(WallAudioPlayerTableViewCell.setProgress), userInfo: nil, repeats: true)
    DataManager.sharedInstance.avPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: "\(FileSupport.findDocsDirectory())\(self.identifier).m4a"))
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
    
    

  

  
  func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
    print("Aqui")
  }
  
  func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
    print("Erro ao reproduzir audio")
    audioIsReproducing = false
  }
  
  
  func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
    print("Aqui")
        audioIsReproducing = false
  }
  
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    print("Audio parou reprodução")
    progressView.progress = 1
    audioIsReproducing = false
    timer.invalidate()
    self.activityIndicatorAudio.isHidden = true
    self.buttonPlay.alpha = 1
          buttonPlay.setBackgroundImage(UIImage(named: "play3.png"), for: UIControlState())
  }
  
}
