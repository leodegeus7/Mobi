//
//  Address.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/12/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import MapKit

class Address: NSObject {
  dynamic var state = ""
  dynamic var city = ""
  dynamic var zip = ""
  dynamic var street = ""
  dynamic var streetNumber = ""
  dynamic var country = ""
  dynamic var lat = ""
  dynamic var long = ""
  dynamic var completeAddress = false
  dynamic var currentClassState = ""
  dynamic var coordinates = CLLocation()
  
  required init(lat: String,long:String,country:String ,city:String, state:String, street:String, streetNumber:String,zip:String) {
    super.init()
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
    if verifyInformation() {
      completeAddress = true
    } else {
      completeAddress = false
    }
  }
  
  convenience init(lat:String,long:String,convert:Bool) {
    self.init(lat: lat,long:long,country:"" ,city:"", state:"", street:"", streetNumber:"",zip:"")
    if (convert) {
      let myLatitute = Double(lat)! as CLLocationDegrees
      let myLongitude = Double(long)! as CLLocationDegrees
      Util.convertCoordinateToAddress(myLatitute, long: myLongitude, completion: { (result) in
        self.city = result["City"]!
        self.state = result["State"]!
        self.zip = result["ZIP"]!
        if result["Street"] != nil {
          self.street = result["Street"]!
        }
        if result["StreetNumber"] != nil {
          self.streetNumber = result["StreetNumber"]!
        }
        self.country = result["Country"]!
        if self.verifyInformation() {
          self.completeAddress = true
        } else {
          self.completeAddress = false
        }
      })
    } else {
      self.completeAddress = false
    }
  }
  
  func verifyInformation() -> Bool {
    if (lat != "" && long != "" && street != "" && city != "" && state != "" && country != "") {
      self.currentClassState = "CompleteAddress"
      return true
    } else if (lat == "" && long == "" && street != "" && city != "" && state != "" && country != "") {
      self.currentClassState = "IncompleteAddressWithoutCoordinates"
    } else if (lat != "" && long != "" && street == "" && city == "" && state == "" && country == "") {
      self.currentClassState = "IncompleteAddressWithoutAddressJustCoordinates"
    } else {
      self.currentClassState = "InconclusiveClass"
    }
    return false
  }
  

}
