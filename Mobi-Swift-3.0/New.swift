//
//  New.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/11/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class New2 {
  dynamic var title = ""
  dynamic var img:String
  dynamic var type:String
  dynamic var newDescription: String
  dynamic var date: String
  
  required init() {
    self.title = ""
    self.newDescription = ""
    self.type = ""
    self.date = ""
    self.img = ""
  }
  
  convenience init(newTitle:String, newDescription: String, date:String) {
    self.init()
    self.title = newTitle
    self.newDescription = newDescription
    self.type = "Simple"
    self.date = date
  }
  
  convenience init(img:String, date:String) {
    self.init()
    self.img = img
    self.type = "JustImage"
    self.date = date
  }
  
  convenience init(newTitle: String, newDescription: String, img: String, date:String) {
    self.init()
    self.title = newTitle
    self.img = img
    self.newDescription = newDescription
    self.type = "Complex"
    self.date = date
  }
  
}
