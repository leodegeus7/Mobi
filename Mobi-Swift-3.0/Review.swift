//
//  Review.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/11/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class Review: NSObject {
  var id = -1
  var score = -1
  var date = Date()
  var text = ""
  var user = UserRealm()
  var radio = RadioRealm()
  init(id:Int,date:Date,user:UserRealm,text:String,score:Int,radio:RadioRealm) {
    super.init()
    self.id = id
    self.date = date
    self.user = user
    self.text = text
    self.score = score
    self.radio = radio
  }
}
