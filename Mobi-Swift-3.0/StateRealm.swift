//
//  StateRealm.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 9/14/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//  Criado por Leonardo de Geus // linkedin.com/leodegeus

import Foundation
import RealmSwift

class StateRealm: Object {
  
  dynamic var name = ""
  dynamic var id = ""
  dynamic var acronym = ""
  var radios = List<RadioRealm>()
  var cities = List<CityRealm>()
  
  convenience init(id:String, name:String, acronym:String) {
    self.init()
    self.id = id
    self.name = name
    self.acronym = acronym
    try! DataManager.sharedInstance.realm.write {
      DataManager.sharedInstance.realm.add(self, update: true)
    }
  }
  
  convenience init(id:String, name:String, acronym:String, radios:[RadioRealm]) {
    self.init()
    self.name = name
    self.radios = List(radios)
    self.acronym = acronym
    try! DataManager.sharedInstance.realm.write {
      DataManager.sharedInstance.realm.add(self, update: true)
    }
  }
  
  func updateRadiosOfState(radios:[RadioRealm]) {
    try! DataManager.sharedInstance.realm.write {
      self.radios = List(radios)
    }
  }
  
  func updateCityOfState(cities:[CityRealm]) {
    try! DataManager.sharedInstance.realm.write {
      self.cities = List(cities)
    }
  }
  
  override class func primaryKey() -> String? {
    return "id"
  }
}
