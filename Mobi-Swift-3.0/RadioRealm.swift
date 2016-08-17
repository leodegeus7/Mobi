//
//  RadioRealm.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/16/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

class RadioRealm: Object {
  dynamic var id = -1
  dynamic var name = ""
  dynamic var likenumber = -1
  dynamic var distanceFromUser = -1
  dynamic var thumbnail:String!
  dynamic var formattedLocal = ""
  dynamic var streamingLink = ""
  dynamic var typeOfStreaming = ""
  dynamic var lastAccessDate:NSDate!
  dynamic var lastAccessString = ""
  dynamic var address:AddressRealm!
  
  
//  convenience init(id:String,name:String,lat:String,long:String) {
//    self.init()
//    self.name = name
//    self.id = Int(id)!
//    let address = AddressRealm(lat: lat, long: long, country: <#T##String#>, city: <#T##String#>, state: <#T##String#>, street: <#T##String#>, streetNumber: <#T##String#>, zip: <#T##String#>)
//    
//  }
  
  
  func setThumbnailImage(image:String) {
    self.thumbnail = image
  }
  
  func setFormattedLocalString(address:Address) -> String {
    return address.city + " - " + address.state
  }
  
  static func distanceBetweenTwoLocationsMeters(source:CLLocation,destination:CLLocation) -> Int{
    let distanceMeters = source.distanceFromLocation(destination)
    return Int(distanceMeters)
  }
  
  func resetDistanceFromUser() -> Bool{
    if let userLocation = DataManager.sharedInstance.userLocation {
      self.distanceFromUser = Radio.distanceBetweenTwoLocationsMeters(userLocation, destination: self.address.coordinates)
      return true
    } else {
      return false
    }
  }
  
  func updateOverdueInterval() {
    if let last = lastAccessDate {
      self.lastAccessString = Util.getOverdueInterval(last)}
  }

// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
