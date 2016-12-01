//
//  RSS.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 12/1/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class RSS: NSObject {
  var id = -1
  var desc = ""
  var link = ""
  
  convenience init(id:Int,desc:String,link:String) {
    self.init()
    self.id = id
    self.desc = desc
    self.link = link
  }
}
