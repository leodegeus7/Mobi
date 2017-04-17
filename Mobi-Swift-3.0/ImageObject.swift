//
//  ImageIdentifier.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/11/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class ImageObject: NSObject {
  var id = -1
  var identifier100 = ""
  var identifier80 = ""
  var identifier60 = ""
  var identifier40 = ""
  var identifier20 = ""
  
  convenience init(id:Int,identifier100:String,identifier80:String,identifier60:String,identifier40:String,identifier20:String) {
    self.init()
    self.id = id
    self.identifier20 = identifier20
    self.identifier40 = identifier40
    self.identifier60 = identifier60
    self.identifier80 = identifier80
    self.identifier100 = identifier100
  }
  
  func getImageIdentifier() -> String {
    if id == -1 {
      return "avatar.png"
    }
    return identifier100
  }
}
