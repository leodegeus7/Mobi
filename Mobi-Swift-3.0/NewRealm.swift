//
//  NewRealm.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/18/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import Foundation
import RealmSwift


public enum newType {
  case inProcess
  case Simple
  case JustImage
  case Complex
}

class NewRealm: Object {

  dynamic var id = ""
  dynamic var title = ""
  dynamic var img:String!
  dynamic var type:String!
  var typeCase = newType.inProcess
  dynamic var newDescription: String!
  dynamic var date: String!
  
  convenience init(id:String, newTitle:String, newDescription: String, date:String) {
    self.init()
    self.id = id
    self.title = newTitle
    self.newDescription = newDescription
    self.type = "Simple"
    self.date = date
    separateType()
    
    try! DataManager.sharedInstance.realm.write {
      DataManager.sharedInstance.realm.add(self, update: true)
    }
  }
  
  override class func primaryKey() -> String? {
    return "id"
  }
  
  convenience init(id:String, img:String, date:String) {
    self.init()
    self.id = id
    self.img = img
    self.type = "JustImage"
    self.date = date
    separateType()
    
    try! DataManager.sharedInstance.realm.write {
      DataManager.sharedInstance.realm.add(self, update: true)
    }
  }
  
  convenience init(id:String, newTitle: String, newDescription: String, img: String, date:String) {
    self.init()
    self.id = id
    self.title = newTitle
    self.img = img
    self.newDescription = newDescription
    self.type = "Complex"
    self.date = date
    separateType()
    
    try! DataManager.sharedInstance.realm.write {
      DataManager.sharedInstance.realm.add(self, update: true)
    }
  }

  
  func separateType() {
    if (self.type == "Simple") {
      typeCase = .Simple
    } else if (self.type == "JustImage") {
      typeCase = .JustImage
    } else if (self.type == "Complex") {
      typeCase = .Complex
    }
  }

  override static func ignoredProperties() -> [String] {
    return ["typeCase"]
  }
}
