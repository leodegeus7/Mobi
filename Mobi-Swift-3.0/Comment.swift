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
  var date = Date()
  var postType = PostType.undefined
  var text = ""
  var image = ""
  var video = ""
  var audio = ""
  var user = UserRealm()
  var radio:RadioRealm!
  
  init(id:String,date:Date,user:UserRealm,text:String,radio:RadioRealm) {
    super.init()
    self.id = id
    self.date = date
    self.user = user
    self.text = text
    self.postType = .text
    self.radio = radio
  }
  
  func updateText(_ text:String) {
    self.text = text
    self.postType = .text
  }
  
  func addImageReference(_ image:String) {
    self.image = image
    self.postType = .image
  }
  
  func addAudioReference(_ audio:String) {
    self.audio = audio
    self.postType = .audio
  }
  
  func addVideoReference(_ video:String) {
    self.video = video
    self.postType = .video
  }
}
