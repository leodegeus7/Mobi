//
//  Data.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/17/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class DataType: NSObject {
  static func response(_ dic:NSDictionary) -> NSDictionary {
    if let data = dic["data"] as? NSDictionary {
      return data
    } else {
      return ["":""]
    }
  }
  
}
