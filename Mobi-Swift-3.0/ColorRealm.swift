//
//  ColorRealm.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 9/16/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//  Criado por Leonardo de Geus // linkedin.com/leodegeus

import UIKit
import Foundation
import RealmSwift


class ColorRealm: Object {
  dynamic var red:CGFloat = -1.0
  dynamic var green:CGFloat = -1.0
  dynamic var blue:CGFloat = -1.0
  dynamic var alpha:CGFloat = -1.0
  dynamic var color = UIColor()
  dynamic var id = ""
  dynamic var name = Int()
  
  convenience init(name:Int,red:CGFloat,green:CGFloat,blue:CGFloat,alpha:CGFloat) {
    self.init()
    self.name = name
    self.red = red
    self.blue = blue
    self.green = green
    self.alpha = alpha
    color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
    id = "\(red)\(green)\(blue)\(alpha)"
    try! DataManager.sharedInstance.realm.write {
      DataManager.sharedInstance.realm.add(self, update: true)
    }
  }
  
  convenience init(name:Int,color:UIColor) {
    self.init()
    self.name = name
    self.color = color
    let components = CGColorGetComponents(color.CGColor)
    self.red = components[0]
    self.green = components[1]
    self.blue = components[2]
    self.alpha = CGColorGetAlpha(color.CGColor)
    try! DataManager.sharedInstance.realm.write {
      DataManager.sharedInstance.realm.add(self, update: true)
    }
  }
  
  

  
  override class func primaryKey() -> String? {
    return "name"
  }
  
  override static func ignoredProperties() -> [String] {
    return ["color"]
  }
}
