//
//  AddressRealm.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/16/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation


class AddressRealm: Object  {
  dynamic var id = ""
  dynamic var state = ""
  dynamic var city = ""
  dynamic var zip = ""
  dynamic var street = ""
  dynamic var streetNumber = ""
  dynamic var country = ""
  dynamic var lat = ""
  dynamic var long = ""
  dynamic var localName = ""
  dynamic var formattedLocal = ""
  dynamic var completeAddress = false
  var currentClassState = classState.Initial
  dynamic var coordinates:CLLocation!
  
  
  enum classState {
    case CompleteAddress
    case IncompleteAddressWithoutCoordinates
    case IncompleteAddressWithoutAddressJustCoordinates
    case InconclusiveClass
    case Initial
    case LocalJustWithLocalName
  }
  
  override static func ignoredProperties() -> [String] {
    return ["currentClassState","coordinates"]
  }
  
  convenience init(id: String,lat: String,long:String,country:String ,city:String, state:String, street:String, streetNumber:String,zip:String,repository:Bool) {
    self.init()
    self.id = id
    if (lat != "" && long != "") {
      coordinates = CLLocation(latitude: Double(lat)!, longitude: Double(long)!)
    }
    self.state = state
    self.country = country
    self.city = city
    self.street = street
    self.streetNumber = streetNumber
    self.zip = zip
    self.lat = lat
    self.long = long
    self.coordinates = CLLocation(latitude: Double(lat)!, longitude: Double(long)!)
    setFormattedLocalString()
    if verifyInformation() {
      completeAddress = true
    } else {
      completeAddress = false
    }
    if(repository) {
      try! DataManager.sharedInstance.realm.write {
        DataManager.sharedInstance.realm.add(self,update: true)
      }
    }
  }
  
  convenience init(id:String,latitude:String,longitude:String,convert:Bool,repository:Bool,completionSuper: (result: AddressRealm) -> Void) {
    self.init(id:id, lat: latitude,long:longitude,country:"" ,city:"", state:"", street:"", streetNumber:"",zip:"",repository:false)
    if (convert) {
      AddressRealm.getAddress(self, completion: { (resultAddress) in
        if resultAddress == true {
          if(repository) {
            try! DataManager.sharedInstance.realm.write {
              DataManager.sharedInstance.realm.add(self)
            }
          }
          completionSuper(result: self)
        } else {
          //completionSuper(result: completionSuper)
        }
      })
    } else {
      completionSuper(result: self)
    }
  }
  
  override class func primaryKey() -> String? {
    return "id"
  }
  
  func verifyInformation() -> Bool {
    if (lat != "" && long != "" && city != "" && state != "" && country != "") {
      self.currentClassState = .CompleteAddress
      self.completeAddress = true
      return true
    } else if (lat == "" && long == "" && city != "" && state != "" && country != "") {
      self.currentClassState = .IncompleteAddressWithoutCoordinates
      self.completeAddress = false
    } else if (lat != "" && long != "" && city == "" && state == "" && country == "") {
      self.currentClassState = .IncompleteAddressWithoutAddressJustCoordinates
      self.completeAddress = false
    } else if (lat != "" && long != "" && city == "" && state == "" && country == "" && localName != "") {
      self.currentClassState = .LocalJustWithLocalName
      self.completeAddress = false
    } else {
      self.currentClassState = .InconclusiveClass
      self.completeAddress = false
    }
    return false
  }
  
  static func getAddress(address:AddressRealm,completion: (resultAddress: Bool) -> Void) {
    if let coord = address.coordinates {
      Util.convertCoordinateToAddress(coord.coordinate.latitude, long: coord.coordinate.longitude, completion: { (result) in
        if result["City"] != nil {
          address.city = result["City"]!
        }
        if result["State"] != nil {
          address.state = result["State"]!
        }
        if result["ZIP"] != nil {
          address.zip = result["ZIP"]!
        }
        if result["Street"] != nil {
          address.street = result["Street"]!
        }
        if result["StreetNumber"] != nil {
          address.streetNumber = result["StreetNumber"]!
        }
        if result["Country"] != nil {
          address.country = result["Country"]!
        }
        if result["LocalName"] != nil {
          address.localName = result["LocalName"]!
        }
        
        if address.verifyInformation() {
          address.completeAddress = true
        } else {
          address.completeAddress = false
        }
        completion(resultAddress: true)
      })
    } else {
      completion(resultAddress: false)
    }
  }
  
  func setFormattedLocalString() {
    self.formattedLocal = city + " - " + state
  }

}
