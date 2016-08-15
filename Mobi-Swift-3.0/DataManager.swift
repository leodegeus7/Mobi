//
//  DataManager.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/8/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import CoreLocation

class DataManager: NSObject {
  
  var userLocation:CLLocation!
  
  var news = [New]()
  var audioConfig:AudioConfig!

  
  
  //Groups of radios
  var allRadios = [Radio]()
  var topRadios = [Radio]()
  var favoriteRadios = [Radio]()
  var recentsRadios = [Radio]()
  var localRadios = [Radio]()
  

  
  
  class var sharedInstance: DataManager {
    struct Static {
      static var instance: DataManager?
      static var token: dispatch_once_t = 0
    }
    
    dispatch_once(&Static.token) {
      Static.instance = DataManager()
    }
    return Static.instance!
  }
  
  
}
