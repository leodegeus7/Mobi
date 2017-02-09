//
//  Artwork.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 2/9/17.
//  Copyright © 2017 Access Mobile. All rights reserved.
//

import MapKit

class Artwork: NSObject, MKAnnotation {
  let title: String?
  let locationName: String
  let discipline: String
  let coordinate: CLLocationCoordinate2D
  
  init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
    self.title = title
    self.locationName = locationName
    self.discipline = discipline
    self.coordinate = coordinate
    
    super.init()
  }
  
  var subtitle: String? {
    return locationName
  }
}