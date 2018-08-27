//
//  AdClass.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/25/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class Advertisement: NSObject {
  var id = -1
  var image:String!
  var url = ""
  var datetimeEnd:Date!
  var datetimeStart:Date!
  var descriptionAd:String!
  var playerScreen = false
  var profileScreen = false
  var searchScreen = false
  
  convenience init(id:Int,image:ImageObject,datetimeStart:String,datetimeEnd:String,description:String,playerScreen:Bool,profileScreen:Bool,searchScreen:Bool) {
    self.init()
    self.id = id
    self.image = image.getImageIdentifier()
    self.datetimeStart = Util.convertStringToNSDate(datetimeStart)
    self.datetimeEnd = Util.convertStringToNSDate(datetimeEnd)
    self.descriptionAd = description
    self.playerScreen = playerScreen
    self.profileScreen = profileScreen
    self.searchScreen = searchScreen
  }
}
