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
import RealmSwift

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
  
  
  convenience init(id:String,name:String,country:String,city:String,state:String,street:String,streetNumber:String,zip:String,lat:String,long:String,thumbnail:String,likenumber:String,lastAccessDate:NSDate,repository:Bool) {
    self.init()
    self.name = name
    self.id = Int(id)!
    self.thumbnail = thumbnail
    self.lastAccessDate = lastAccessDate
    self.likenumber = Int(likenumber)!
    let addressVar = AddressRealm(lat: lat, long: long, country: country, city: city, state: state, street: street, streetNumber: streetNumber, zip: zip,repository: true)
    self.address = addressVar
    
    
    if(repository) {
      try! DataManager.sharedInstance.realm.write {
        if let add = (self.address) {
          DataManager.sharedInstance.realm.add(self)
        }
      }
    }
    
    try! DataManager.sharedInstance.realm.write {
      self.address = addressVar
    }
    
    
  }
  
  
  func setThumbnailImage(image:String) {
    try! DataManager.sharedInstance.realm.write {
        self.thumbnail = image
    }
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
      try! DataManager.sharedInstance.realm.write {
        self.distanceFromUser = Radio.distanceBetweenTwoLocationsMeters(userLocation, destination: self.address.coordinates)
      }
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
