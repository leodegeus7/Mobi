//
//  Link.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 9/13/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class Link: NSObject {
  var type :String!
  var link :String!
  
  init(type:String,link:String) {
    self.type = type
    self.link = link
  }
}
