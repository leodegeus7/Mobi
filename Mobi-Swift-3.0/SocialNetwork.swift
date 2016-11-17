//
//  SocialNetwork.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 11/11/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class SocialNetwork: NSObject {
  var id = -1
  var type = ""
  var text = ""
  
  convenience init(id:Int,type:String,text:String) {
    self.init()
    self.id = id
    self.text = text
    self.type = type
  }
}

