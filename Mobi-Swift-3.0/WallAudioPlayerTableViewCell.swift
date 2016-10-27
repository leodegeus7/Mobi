//
//  AudioPlayerTableViewCell.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/26/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import AVFoundation
import AudioKit

class WallAudioPlayerTableViewCell: UITableViewCell, AVAudioPlayerDelegate {
  
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
    buttonPlay.setImage(UIImage(named: "play3.png"), forState: .Normal)
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  @IBAction func buttonPlayTapped(sender: AnyObject) {
    
    activityIndicatorAudio.hidden = false
    buttonPlay.alpha = 0.4
    let requestAudio = RequestManager()
    requestAudio.downloadFileWithIdentifier(identifier, format: "m4a") { (url) in
      self.activityIndicatorAudio.hidden = true
      self.buttonPlay.alpha = 1
      if FileSupport.testIfFileExistInDocuments("\(self.identifier).m4a") {
        dispatch_async(dispatch_get_main_queue()) {
          FileSupport.playAudioFromDocs("\(self.identifier).m4a")
          //          let file = try! AKAudioFile(forReading: NSURL(fileURLWithPath: "\(FileSupport.findDocsDirectory())\(self.identifier).m4a"))
          //
          //          let player = try! AKAudioPlayer(file: file)
          //          player.start()
        }
        
        //let audioPlayer = try! AVAudioPlayer(contentsOfURL: url)
        //audioPlayer.play()
        //print(audioPlayer.duration)
        
        self.buttonPlay.setImage(UIImage(named: "pause2.png"), forState: .Normal)
      } else {
        print("Arquivo não existe")
        
      }
      
      
    }
  }
  
  func audioPlayerEndInterruption(player: AVAudioPlayer) {
    buttonPlay.setImage(UIImage(named: "play3.png"), forState: .Normal)
  }
  func audioPlayerBeginInterruption(player: AVAudioPlayer) {
    
  }
  func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
    
  }
  func audioPlayerEndInterruption(player: AVAudioPlayer, withFlags flags: Int) {
    buttonPlay.setImage(UIImage(named: "play3.png"), forState: .Normal)
  }
  func audioPlayerEndInterruption(player: AVAudioPlayer, withOptions flags: Int) {
    buttonPlay.setImage(UIImage(named: "play3.png"), forState: .Normal)
  }
  func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
    buttonPlay.setImage(UIImage(named: "play3.png"), forState: .Normal)
  }
  
}
