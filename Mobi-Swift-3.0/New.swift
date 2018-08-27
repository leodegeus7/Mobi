//
//  New.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/11/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//  Criado por Leonardo de Geus // linkedin.com/leodegeus

import UIKit

import Foundation

class New {
  dynamic var id = ""
  dynamic var title = ""
  dynamic var img = ""
  dynamic var type = ""
  dynamic var newDescription = ""
  dynamic var date = ""
  dynamic var link = ""
  

  convenience init(title:String, descr:String,link:String,date:Date) {
    self.init()
    self.newDescription = descr
    self.type = "Simple"
    self.title = title
    self.link = link
    self.date = Util.convertDateToShowStringWithHour(date)
  }
  
  convenience init(id:String,newTitle:String, newDescription: String, date:String) {
    self.init()
    self.id = id
    self.title = newTitle
    self.newDescription = newDescription
    self.type = "Simple"
    self.date = date
    

  }
  
  convenience init(id:String,img:String, date:String) {
    self.init()
        self.id = id
    self.img = img
    self.type = "JustImage"
    self.date = date
    

  }
  
  convenience init(id:String,newTitle: String, newDescription: String, img: String, date:String) {
    self.init()
        self.id = id
    self.title = newTitle
    self.img = img
    self.newDescription = newDescription
    self.type = "Complex"
    self.date = date

  }
  
  
  
}
