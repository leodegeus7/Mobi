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
import RealmSwift
import Firebase


struct City {
  var cityName : String!
  var radios : [RadioRealm]!
}

struct Genre {
  var genreName : String!
  var radios : [RadioRealm]!
}
struct State {
  var stateName : String!
  var radios : [RadioRealm]!
}

enum NSComparisonResult : Int {
  case OrderedAscending
  case OrderedSame
  case OrderedDescending
}

enum searchMode {
  case All
  case Radios
  case Genre
  case Local
}


class DataManager: NSObject {
  
  let baseURL = "http://homolog.feroxsolutions.com.br:8080/radiocontrole-web/api/"
  var userToken:String!
  var myUser = UserRealm()
  var userLocation:CLLocation!
  var audioConfig:AudioConfig!
  var realm:Realm!
  
  
  //Groups of radios
  var allRadios = [RadioRealm]()
  var topRadios = [RadioRealm]()
  var favoriteRadios = [RadioRealm]()
  var recentsRadios = [RadioRealm]()
  var localRadios = [RadioRealm]()
  
  var isPlay = false
  var radioInExecution = RadioRealm()
  
  var allNews = [New]()
  var addressId = 0
  
  var isLogged = false
  
  enum actualCondition {
    case Ok
    case Without
  }
  
  var miniPlayerView = MiniPlayerViewController()
  var playerClass:PlayerViewController!
  
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
  
  func updateAllOverdueInterval() {
    for radio in recentsRadios {
      radio.updateOverdueInterval()
    }
    if recentsRadios.count > 0 {
      if let _ = recentsRadios[0].lastAccessDate {
        recentsRadios.sortInPlace({ $0.lastAccessDate.compare($1.lastAccessDate) == .OrderedDescending })
      }
    }
  }
  
  
  func instantiateSearch(navigation:UINavigationController) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewControllerWithIdentifier("searchView") as? SearchTableViewController
    navigation.pushViewController(vc!, animated: true)

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

