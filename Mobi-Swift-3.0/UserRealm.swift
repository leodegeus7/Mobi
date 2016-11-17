//
//  MyUser.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/8/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//  Criado por Leonardo de Geus // linkedin.com/leodegeus

import Foundation
import RealmSwift
import CoreLocation

class UserRealm: Object {
  dynamic var id = ""
  dynamic var name = ""
  dynamic var gender = ""
  dynamic var address:AddressRealm!
  var favoritesRadios:[RadioRealm]!
  dynamic var birthDate:NSDate!
  dynamic var userImage = ""
  dynamic var following = -1
  dynamic var followers = -1
  dynamic var email =  ""
  dynamic var password = ""
  dynamic var isFollowing = false
  dynamic var shortAddress = ""
  
  dynamic var isMineProfile = false
  
  convenience init(id:String, email:String, name:String, gender: String, address:AddressRealm, birthDate:String, following:String, followers:String,userImage:ImageObject) {
    self.init()
    self.email = email
    self.id = id
    self.name = name
    self.gender = gender
    self.address = address
    self.isMineProfile = true
    if birthDate == "" {
      self.birthDate = nil
    } else {
      self.birthDate = Util.convertStringToNSDate(birthDate)
    }
    
    self.followers = Int(followers)!
    self.following = Int(following)!
    self.password = ""
    self.userImage = userImage.getImageIdentifier()
    try! DataManager.sharedInstance.realm.write {
      DataManager.sharedInstance.realm.add(self, update: true)
    }
  }
  
  convenience init(id:String,email:String,name:String, image:ImageObject) {
    self.init()
    self.email = email
    self.name = name
    self.id = id
    self.userImage = image.getImageIdentifier()
    try! DataManager.sharedInstance.realm.write {
      DataManager.sharedInstance.realm.add(self, update: true)
    }
  }
  
  convenience init(id:String,name:String,image:ImageObject,following:Bool,shortAddress:String) {
    self.init()
    self.id = id
    self.name = name
    self.userImage = image.getImageIdentifier()
    self.isFollowing = following
    self.shortAddress = shortAddress
  }
  
  override static func primaryKey() -> String? {
    return "id"
  }
  
  func updateFavorites(favorites:[RadioRealm]) {
      self.favoritesRadios = favorites
  }
  
  func updatePassword(password:String) -> UserRealm {
    DataManager.sharedInstance.realm.beginWrite()
       self.password = password
    try! DataManager.sharedInstance.realm.commitWrite()
    return self
  }
  
  func updateImageIdentifier(imageID:String) {
    try! DataManager.sharedInstance.realm.write {
      self.userImage = imageID
    }
  }
  
  func updateFollowers(following:String,followers:String) {
    try! DataManager.sharedInstance.realm.write {
      self.followers = Int(followers)!
      self.following = Int(following)!
    }
  }
  
  
  
  override static func ignoredProperties() -> [String] {
    return ["favoritesRadios","userUImage"]
  }
  
}

