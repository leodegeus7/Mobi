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

class WallAudioPlayerTableViewCell: UITableViewCell {
  
  @IBOutlet weak var textViewWall: UITextView!
  @IBOutlet weak var labelDate: UILabel!
  @IBOutlet weak var labelName: UILabel!
  @IBOutlet weak var imageUser: UIImageView!
  
  
  @IBOutlet weak var buttonZoomImage: UIButton!
  @IBOutlet weak var imageAttachment: UIImageView!
  @IBOutlet weak var audioProgressView: UIProgressView!
  @IBOutlet weak var buttonPlay: UIButton!
  @IBOutlet weak var activityIndicatorAudio: UIActivityIndicatorView!
  
  
  var audioToPlayUrl:NSURL!
  var identifier:String!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    let colorAlpha = DataManager.sharedInstance.interfaceColor.color.colorWithAlphaComponent(0.2)
    let viewSelected = UIView()
    viewSelected.backgroundColor = colorAlpha
    self.selectedBackgroundView = viewSelected
    buttonPlay.backgroundColor = UIColor.clearColor()
    activityIndicatorAudio.hidden = true
    buttonPlay.setBackgroundImage(UIImage(named: "play3.png"), forState: .Normal)
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  @IBAction func buttonPlayTapped(sender: AnyObject) {
    
    activityIndicatorAudio.hidden = false
    buttonPlay.alpha = 0.4
    
    let link = returnLinkAudio(identifier)
    self.buttonPlay.alpha = 1
    
//    let audioPlayer = AudioManager()
//    audioPlayer.play(link, cell: self)
//    var player = AVPlayer()
//    player = AVPlayer(URL: NSURL(string: link.link)!)
//    player.rate = 1
//    player.play()
    let requestAudio = RequestManager()
    requestAudio.downloadFileWithIdentifier(identifier, format: "m4a") { (url) in
      self.activityIndicatorAudio.hidden = true
      self.buttonPlay.alpha = 1
      if FileSupport.testIfFileExistInDocuments("\(self.identifier).m4a") {
        dispatch_async(dispatch_get_main_queue()) {
          FileSupport.playAudioFromBundle("download")
          //FileSupport.playAudioFromDocs("\(self.identifier).m4a")
          //          let file = try! AKAudioFile(forReading: NSURL(fileURLWithPath: "\(FileSupport.findDocsDirectory())\(self.identifier).m4a"))
          //
          //          let player = try! AKAudioPlayer(file: file)
          //          player.start()
        }
        
        //let audioPlayer = try! AVAudioPlayer(contentsOfURL: url)
        //audioPlayer.play()
        //print(audioPlayer.duration)
        
        self.buttonPlay.setBackgroundImage(UIImage(named: "pause2.png"), forState: .Normal)
      } else {
        print("Arquivo não existe")
        
      }
      
      
    }
  }
  
  func returnLinkAudio(identifier:String) -> Link {
    let URL = Link(link: "\(DataManager.sharedInstance.baseURL)app/file/download?identifier=\(identifier)", linkType: .Audio)
    return URL
  }
  
  
}
