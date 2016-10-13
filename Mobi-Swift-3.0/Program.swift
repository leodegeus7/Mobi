//
//  Program.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/10/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class Program: NSObject {
  var id = -1
  var name = ""
  var timeStart = ""
  var timeEnd = ""
  var announcer = UserRealm()
  var active = false
  var days:DataManager.ProgramDays!

  
  convenience init(id:Int,name:String,announcer:UserRealm,timeStart:String,timeEnd:String,days:DataManager.ProgramDays,active:Bool) {
    self.init()
    self.id = id
    self.name = name
    self.announcer = announcer
    self.timeStart = timeStart
    self.timeEnd = timeEnd
    self.days = days
    self.active = active
  }
  
}
