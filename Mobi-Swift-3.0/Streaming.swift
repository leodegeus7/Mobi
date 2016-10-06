//
//  StreamingClass.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/6/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class Streaming: NSObject {
  dynamic var id = -1
  dynamic var linkHigh  = Link()
  dynamic var existHighLink = false
  dynamic var linkLow = Link()
  dynamic var existLowLink = false
  
  convenience init(id:Int,linkHigh:String,linkLow:String) {
    self.init()
    self.id = id
    if linkLow != ""{
      self.linkLow = Link(link: linkLow, linkType: .Low)
      self.existLowLink = true
    }
    if linkHigh != ""{
      self.linkHigh = Link(link: linkHigh, linkType: .High)
      self.existHighLink = true
    }
  }
}
