//
//  Comment.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 9/15/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class Comment: NSObject {
  var id = ""
  var date = NSDate()
  var postType = PostType.Undefined
  var text = ""
  var image = ""
  var video = ""
  var audio = ""
  var user = UserRealm()
  
  init(id:String,date:NSDate,user:UserRealm,text:String) {
    super.init()
    self.id = id
    self.date = date
    self.user = user
    self.text = text
    self.postType = .Text
  }
  
  func updateText(text:String) {
    self.text = text
    self.postType = .Text
  }
  
  func addImageReference(image:String) {
    self.image = image
    self.postType = .Image
  }
  
  func addAudioReference(audio:String) {
    self.audio = audio
    self.postType = .Audio
  }
  
  func addVideoReference(video:String) {
    self.video = video
    self.postType = .Video
  }
}
