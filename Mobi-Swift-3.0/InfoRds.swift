//
//  InfoRds.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/21/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class InfoRds: NSObject {
  var title:String!
  var artist:String!
  var breakString:String!
  var existData = false
  
  convenience init(title:String,artist:String,breakString:String) {
    self.init()
    existData = true
    self.title = title
    self.artist = artist
    self.breakString = breakString
  }
}
