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
    return "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/"
  }
  
  static func saveJPGImageInDocs(_ image:UIImage, name:String) -> String {
    let destinationPath = FileSupport.findDocsDirectory() + "\(name).jpg"
    try? UIImageJPEGRepresentation(image, 1.0)?.write(to: URL(fileURLWithPath: destinationPath), options: [.atomic])
    return "\(name).jpg"
  }
  
  static func testIfFileExistInDocuments (_ name:String) -> Bool {
    let docs = findDocsDirectory()
    let destinatonPath = docs + "/\(name)"
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: destinatonPath) {
      return true
    } else {
      return false
    }
  }
  
  static func playAudioFromDocs(_ name:String) {
    var player:AVAudioPlayer?
    try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
    try! AVAudioSession.sharedInstance().setActive(true)
    print("url")
    let urlAudio = URL(fileURLWithPath: "\(FileSupport.findDocsDirectory())\(name)")
    player = try! AVAudioPlayer(contentsOf: urlAudio, fileTypeHint: AVFileTypeAppleM4A)
    //guard let player = self.player else { print("Nao carregou o audio") }
    player!.prepareToPlay()
    player!.play()
  }
  

  
  

}
