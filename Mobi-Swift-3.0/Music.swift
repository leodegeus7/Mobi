//
//  Music.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/21/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import RealmSwift

class Music: Object {
  var id = ""
  var name:String!
  var albumName:String!
  var composer:String!
  var isPositive = false
  var isNegative = false
  var coverArt:String!
  var timeWasDiscovered:NSDate!
  
  convenience init(id:String,name:String,albumName:String,composer:String,coverArt:String) {
    self.init()
    self.id = id
    self.name = name
    self.albumName = albumName
    self.composer = composer
    self.coverArt = coverArt
    self.timeWasDiscovered = NSDate()
    try! DataManager.sharedInstance.realm.write {
      DataManager.sharedInstance.realm.add(self, update: true)
    }
  }
  
  override class func primaryKey() -> String? {
    return "id"
  }
  
  func isMusicOld() -> Bool {
    if let date = timeWasDiscovered {
      if NSDate().timeIntervalSinceDate(date) >= 26 {
        return true
      } else {
        return false
      }
    } else {
      return true
    }
  }
  
  func setPositive() {
    try! DataManager.sharedInstance.realm.write {
      self.isPositive = true
      self.isNegative = false
    }
  }
  
  func setNegative() {
    try! DataManager.sharedInstance.realm.write {
      self.isPositive = false
      self.isNegative = true
    }
  }
}
