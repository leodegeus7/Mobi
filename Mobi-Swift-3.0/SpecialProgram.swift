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
  
  convenience init(id:Int,name:String,specialTitle:String,announcer:UserRealm,timeStart:String,timeEnd:String,days:DataManager.ProgramDays,guests:String,active:Bool) {
    self.init()
    self.id = id
    self.name = name
    self.announcer = announcer
    self.timeStart = timeStart
    self.timeEnd = timeEnd
    self.days = days
    self.active = active
    self.guests = guests
    self.specialTitle = specialTitle
  }
}
