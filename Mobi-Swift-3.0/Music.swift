//
//  Music.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/21/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class Music: NSObject {
  var name:String!
  var albumName:String!
  var composer:String!
  var isPositive = false
  var isNegative = false
  var coverArt:UIImage!
  
  convenience init(name:String,albumName:String,composer:String,coverArt:UIImage) {
    self.init()
    self.name = name
    self.albumName = albumName
    self.composer = composer
    self.coverArt = coverArt
  }
}
