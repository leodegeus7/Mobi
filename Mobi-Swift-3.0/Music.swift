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
  dynamic var id = ""
  dynamic var name:String!
  dynamic var albumName:String!
  dynamic var composer:String!
  dynamic var isPositive = false
  dynamic var isNegative = false
  dynamic var coverArt:String!
  dynamic var timeWasDiscovered:NSDate!
  
  convenience init(id:String,name:String,albumName:String,composer:String,coverArt:String) {
    self.init()
    self.id = "\(name)\(composer)"
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
