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
  dynamic var respectiveRadio:RadioRealm!
  dynamic var isPositive = false
  dynamic var isNegative = false
  dynamic var coverArt:String!
  dynamic var timeWasDiscovered:Date!
  dynamic var imageCover:UIImage!
  
  convenience init(id:String,name:String,albumName:String,composer:String,coverArt:String) {
    self.init()
    self.id = "\(name)\(composer)"
    self.name = name
    self.albumName = albumName
    self.composer = composer
    self.coverArt = coverArt
    self.timeWasDiscovered = Date()
    try! DataManager.sharedInstance.realm.write {
      DataManager.sharedInstance.realm.add(self, update: true)
    }
  }
  
  override static func ignoredProperties() -> [String] {
    return ["imageCover"]
  }
  
  override class func primaryKey() -> String? {
    return "id"
  }
  
  func isMusicOld() -> Bool {
    if let _ = timeWasDiscovered {
      if timeWasDiscovered.timeIntervalSinceNow > 20 {
        return true
      } else {
        return false
      }
    } else {
      return true
    }
  }
  
  func updateDate() {
    try! DataManager.sharedInstance.realm.write {
      self.timeWasDiscovered = Date()
    }
  }
  
  func updateImage(_ image:UIImage) {
    try! DataManager.sharedInstance.realm.write {
      self.imageCover = image
    }
  }
  
  func updateRadio(_ radio:RadioRealm) {
    try! DataManager.sharedInstance.realm.write {
      self.respectiveRadio = radio
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
