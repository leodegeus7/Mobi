//
//  PhoneNumber.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 11/10/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class PhoneType: NSObject {
  var id = -1
  var name = ""
  
  convenience init(id:Int,name:String) {
    self.init()
    self.id = id
    self.name = name
  }
}

class PhoneNumber: NSObject {
  var id = -1
  var phoneTypeCustom:String!
  var phoneNumber:String!
  var phoneType:PhoneType!
  
  convenience init(id:Int,phoneTypeCustom:String,phoneNumber:String,phoneType:PhoneType) {
    self.init()
    self.id = id
    self.phoneTypeCustom = phoneTypeCustom
    self.phoneNumber = phoneNumber
    self.phoneType = phoneType
  }
}
