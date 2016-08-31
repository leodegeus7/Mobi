//
//  MyUser.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/8/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

class UserRealm: Object {
    dynamic var id = ""
    dynamic var name = ""
    dynamic var sex = ""
    dynamic var address:AddressRealm!
    var favoritesRadios:[RadioRealm]!
    dynamic var birthDate = ""
    dynamic var userImage = "profilePic.jpg"
    dynamic var following = -1
    dynamic var followers = -1
  dynamic var userUImage:UIImage!
  
    convenience init(id:String, name:String, sex: String, address:AddressRealm, birthDate:String, following:String, followers:String) {
        self.init()
        self.id = id
        self.name = name
        self.sex = sex
        self.address = address
        self.birthDate = birthDate
        self.followers = Int(followers)!
        self.following = Int(following)!
      
      if FileSupport.testIfFileExistInDocuments(self.userImage){
        userUImage = UIImage(contentsOfFile: "\(FileSupport.findDocsDirectory())\(userImage)")
      }
        try! DataManager.sharedInstance.realm.write {
            DataManager.sharedInstance.realm.add(self, update: true)
        }
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func updateFavorites(favorites:[RadioRealm]) {
        try! DataManager.sharedInstance.realm.write {
            self.favoritesRadios = favorites
        }
    }
  
  func updateImagePath(imagePath:String) {
    try! DataManager.sharedInstance.realm.write {
      self.userImage = imagePath
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

