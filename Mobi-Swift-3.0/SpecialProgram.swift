//
//  SpecialProgram.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/13/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class SpecialProgram: Program {
  var guests = ""
  var specialTitle = ""
  var referenceIdProgram = -1
  var date = NSDate()
  
  convenience init(id:Int,name:String,date:NSDate,referenceIdProgram:Int,announcer:UserRealm,timeStart:String,timeEnd:String,guests:String,active:Bool) {
    self.init()
    self.id = id
    self.name = name
    self.announcer = announcer
    self.timeStart = timeStart
    self.timeEnd = timeEnd
    self.active = active
    self.guests = guests
    self.referenceIdProgram = referenceIdProgram
    self.date = date
    
    let compo = NSCalendar.currentCalendar().components([.Hour,.Minute], fromDate: date)
    let hour = compo.hour
    let minut:Float = Float(compo.minute)/60.0
    sortVar = Float(hour) + minut
  }
  
}
