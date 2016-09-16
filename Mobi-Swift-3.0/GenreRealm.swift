//
//  Genre.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/26/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//  Criado por Leonardo de Geus // linkedin.com/leodegeus

import UIKit
import RealmSwift

class GenreRealm: Object {
  dynamic var id = ""
  dynamic var name = ""
  dynamic var image = ""
  var radios = List<RadioRealm>()
  
  
  convenience init(id:String, name:String, image:String) {
    self.init()
    self.id = id
    self.name = name
    self.image = image
    
    try! DataManager.sharedInstance.realm.write {
      DataManager.sharedInstance.realm.add(self, update: true)
    }
  }
  
  convenience init(id:String, name:String, radios:[RadioRealm], image:String) {
    self.init()
    self.name = name
    self.radios = List(radios)
    self.image = image
    try! DataManager.sharedInstance.realm.write {
      DataManager.sharedInstance.realm.add(self, update: true)
    }
  }
 
  func updateRadiosOfGenre(radios:[RadioRealm]) {
    try! DataManager.sharedInstance.realm.write {
      self.radios = List(radios)
    }
  }
  
  override class func primaryKey() -> String? {
    return "id"
  }
  
}
