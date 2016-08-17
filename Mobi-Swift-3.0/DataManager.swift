//
//  DataManager.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/8/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

class DataManager: NSObject {
  
  var userToken:String!
  
  var userLocation:CLLocation!
  
  var news = [New]()
  var audioConfig:AudioConfig!
  
  
  //Groups of radios
  var allRadios = [Radio]()
  var topRadios = [Radio]()
  var favoriteRadios = [Radio]()
  var recentsRadios = [Radio]()
  var localRadios = [Radio]()
  
  enum actualCondition {
    case Ok
    case Without
  }
  

  
  
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
  
  func updateRadioDistance() {
    for radio in localRadios {
      radio.resetDistanceFromUser()
    }
    localRadios.sortInPlace({ $0.distanceFromUser < $1.distanceFromUser })
  }
  
  func updateOverdueInterval() {
    for radio in recentsRadios {
      radio.updateOverdueInterval()
    }
  }
  
  func requestJson(link:String,completion: (result: NSDictionary) -> Void) {
    if let userTokenString = userToken {
      let headers = ["userToken": userTokenString]
      Alamofire.request(.GET, "http://homolog.feroxsolutions.com.br:8080/radiocontrole-web/api/\(link)", headers: headers).responseJSON { (response) in
        if let JSON = response.result.value {
          if let dic2 = JSON as? NSDictionary {
            if let data = dic2["data"] as? NSArray {
              if let data2 = data[0] as? NSDictionary {
                completion(result: data2)
              }
            }
          }
        }
      }
    }
    
    
  }
  
//  func updateAddressFromRadios(index:Int,radios:[Radio],completion: (resultAddress: Bool) -> Void) -> Bool { //sempre mandar 0 no index para chamar esta função
//    if radios.count < index {
//      if radios[index].address.currentClassState != .CompleteAddress {
//        Address.getAddress(radios[index].address, completion: { (resultAddress) in
//          self.updateAddressFromRadios(index+1, radios: radios, completion: completion)
//      })
//      }
//      return false
//    } else {
//      return true
//    }
//  }
  
}
