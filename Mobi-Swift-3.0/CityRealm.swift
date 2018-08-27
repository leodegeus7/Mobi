//
//  CityRealm.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 9/14/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//  Criado por Leonardo de Geus // linkedin.com/leodegeus

import Foundation
import RealmSwift

class CityRealm: Object {
  
  dynamic var name = ""
  dynamic var id = ""
  var radios = List<RadioRealm>()
  
  convenience init(id:String, name:String) {
    self.init()
    self.id = id
    self.name = name
    try! DataManager.sharedInstance.realm.write {
      DataManager.sharedInstance.realm.add(self, update: true)
    }
  }
  
  convenience init(id:String, name:String, acronym:String, radios:[RadioRealm]) {
    self.init()
    self.name = name
    self.radios = List(radios)
    try! DataManager.sharedInstance.realm.write {
      DataManager.sharedInstance.realm.add(self, update: true)
    }
  }
  
  func updateRadiosOfCity(_ radios:[RadioRealm]) {
    try! DataManager.sharedInstance.realm.write {
      self.radios = List(radios)
    }
  }
  
  override class func primaryKey() -> String? {
    return "id"
  }

}
