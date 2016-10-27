//
//  FileSupport.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/31/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import AVFoundation

class FileSupport: NSObject {
  
  static func findDocsDirectory() -> String{
    return "\(NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])/"
  }
  
  static func saveJPGImageInDocs(image:UIImage, name:String) -> String {
    let destinationPath = FileSupport.findDocsDirectory().stringByAppendingString("\(name).jpg")
    UIImageJPEGRepresentation(image, 1.0)?.writeToFile(destinationPath, atomically: true)
    return "\(name).jpg"
  }
  
  static func testIfFileExistInDocuments (name:String) -> Bool {
    let docs = findDocsDirectory()
    let destinatonPath = docs.stringByAppendingString("/\(name)")
    let fileManager = NSFileManager.defaultManager()
    if fileManager.fileExistsAtPath(destinatonPath) {
      return true
    } else {
      return false
    }
  }
  
  static func playAudioFromDocs(name:String) {
    var player:AVAudioPlayer?
    try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
    try! AVAudioSession.sharedInstance().setActive(true)
    print("url")
    let urlAudio = NSURL(fileURLWithPath: "\(FileSupport.findDocsDirectory())\(name)")
    player = try! AVAudioPlayer(contentsOfURL: urlAudio, fileTypeHint: AVFileTypeAppleM4A)
    //guard let player = self.player else { print("Nao carregou o audio") }
    player!.prepareToPlay()
    player!.play()
  }
  
  
  

}
