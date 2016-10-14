//
//  ProgramsTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/3/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import Kingfisher

class ProgramsTableViewController: UITableViewController {
  
  @IBOutlet weak var leftButtonWeek: UIButton!
  @IBOutlet weak var labelWeekend: UILabel!
  @IBOutlet weak var rightButtonWeek: UIButton!
  
  var actualRadio = RadioRealm()
  var schedule = Dictionary<String,[Program]>()
  var weekDays = ["Domingo","Segunda-Feira","Terça-Feira","Quarta-Feira","Quinta-Feira","Sexta-Feira","Sábado"]
  var weekDaysActualInt = -1
  var todayWeekDay = ""
  var actualScheduleWeekday = ""
  var actualSchedulePrograms = [Program]()
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    activityIndicator.center = view.center
    activityIndicator.startAnimating()
    activityIndicator.hidden = true
    organizeSchedule()
    self.title = "Programação"
    leftButtonWeek.backgroundColor = UIColor.clearColor()
    rightButtonWeek.backgroundColor = UIColor.clearColor()
    leftButtonWeek.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
    rightButtonWeek.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
    let dayOfWeekInt = Util.getDayOfWeek(NSDate())
    todayWeekDay = weekDays[dayOfWeekInt-1]
    weekDaysActualInt = dayOfWeekInt-1
    labelWeekend.text = todayWeekDay
    actualScheduleWeekday = todayWeekDay
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 400
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return actualSchedulePrograms.count
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return 1
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if actualSchedulePrograms[indexPath.section].dynamicType == SpecialProgram.self {
      let cell = tableView.dequeueReusableCellWithIdentifier("actualProgram", forIndexPath: indexPath) as! ActualProgramTableViewCell
      
      let programSpecial2 = actualSchedulePrograms[indexPath.section] as! SpecialProgram
      
      cell.labelName.text = actualSchedulePrograms[indexPath.section].name
      cell.labelSecondName.text = ""
      let identifierImage = actualSchedulePrograms[indexPath.section].announcer.userImage
      cell.imagePerson.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(identifierImage)))
      cell.imagePerson.layer.cornerRadius = cell.imagePerson.bounds.height / 2
      cell.imagePerson.layer.borderColor = UIColor.blackColor().CGColor
      cell.imagePerson.layer.borderWidth = 0
      cell.imagePerson.clipsToBounds = true
      cell.labelNamePerson.text = actualSchedulePrograms[indexPath.section].announcer.name
      cell.labelGuests.text = programSpecial2.guests
      
      return cell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier("normalProgram", forIndexPath: indexPath) as! NormalProgramTableViewCell
      
      cell.labelName.text = actualSchedulePrograms[indexPath.section].name
      let identifierImage = actualSchedulePrograms[indexPath.section].announcer.userImage
      cell.imagePerson.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(identifierImage)))
      cell.imagePerson.layer.cornerRadius = cell.imagePerson.bounds.height / 2
      cell.imagePerson.layer.borderColor = UIColor.blackColor().CGColor
      cell.imagePerson.layer.borderWidth = 0
      cell.imagePerson.clipsToBounds = true
      cell.labelNamePerson.text = actualSchedulePrograms[indexPath.section].announcer.name
      
      return cell
    }
    
  }
  
  func organizeSchedule() {
    view.addSubview(activityIndicator)
    activityIndicator.hidden = false
    tableView.allowsSelection = false
    let requestProgramas = RequestManager()
    requestProgramas.requestProgramsOfRadio(actualRadio, pageNumber: 0, pageSize: 1000) { (resultPrograms) in
      
      let sunday = "Domingo"
      let monday = "Segunda-Feira"
      let tuesday = "Terça-Feira"
      let wedsnesday = "Quarta-Feira"
      let thursday = "Quinta-Feira"
      let friday = "Sexta-Feira"
      let saturday = "Sábado"
      
      var sundayProg = [Program]()
      var mondayProg = [Program]()
      var tuesdayProg = [Program]()
      var wedsnesdayProg = [Program]()
      var thursdayProg = [Program]()
      var fridayProg = [Program]()
      var saturdayProg = [Program]()
      
      for program in resultPrograms {
        if program.days.isSunday {
          sundayProg.append(program)
        }
        if program.days.isMonday {
          mondayProg.append(program)
        }
        if program.days.isTuesday {
          tuesdayProg.append(program)
        }
        if program.days.isWednesday {
          wedsnesdayProg.append(program)
        }
        if program.days.isThursday {
          thursdayProg.append(program)
        }
        if program.days.isFriday {
          fridayProg.append(program)
        }
        if program.days.isSaturday {
          saturdayProg.append(program)
        }
      }
      
      self.schedule[sunday] = sundayProg
      self.schedule[monday] = mondayProg
      self.schedule[tuesday] = tuesdayProg
      self.schedule[wedsnesday] = wedsnesdayProg
      self.schedule[thursday] = thursdayProg
      self.schedule[friday] = fridayProg
      self.schedule[saturday] = saturdayProg
      
      let requestSpecial = RequestManager()
      requestSpecial.requestSpecialProgramsOfRadio(self.actualRadio, pageNumber: 0, pageSize: 30, completion: { (resultSpecialPrograms) in
        for specialProgram in resultSpecialPrograms {
          let dayOfWeekInt = Util.getDayOfWeek(specialProgram.date)
          self.schedule[self.weekDays[dayOfWeekInt-1]]?.append(specialProgram)

          let programIdToDelete = specialProgram.referenceIdProgram
          var scheduleDay = (self.schedule[self.weekDays[dayOfWeekInt-1]])!
          var programToDelete = Program()
          for program in scheduleDay {
            if program.id == programIdToDelete && !Util.areTheySiblings(program, class2: SpecialProgram()) {
              programToDelete = program
              break
            }
          }
          scheduleDay.removeAtIndex(scheduleDay.indexOf(programToDelete)!)
          self.schedule[self.weekDays[dayOfWeekInt-1]] = scheduleDay

        }
        
        for programsArray in self.schedule {
          var programs = programsArray.1
          programs.sortInPlace({ $0.timeStart < $1.timeStart })
          self.schedule[programsArray.0] = programs
          
        }
        
        self.tableView.allowsSelection = true
        self.activityIndicator.hidden = true
        self.activityIndicator.removeFromSuperview()
        
        self.updateInterface()
      })
      
      
      
    }
  }
  
  @IBAction func leftMenuButtonClick(sender: AnyObject) {
    if !(weekDaysActualInt-1 < 0) {
      weekDaysActualInt -= 1
    }
    updateInterface()
  }
  
  @IBAction func rightMenuButtonClick(sender: AnyObject) {
    if !(weekDaysActualInt-1 > 6) {
      weekDaysActualInt += 1
    }
    updateInterface()
  }
  
  func updateInterface() {
    if weekDaysActualInt == 0 {
      leftButtonWeek.alpha = 0.5
      leftButtonWeek.enabled = false
    } else {
      leftButtonWeek.alpha = 1
      leftButtonWeek.enabled = true
    }
    if weekDaysActualInt == 6 {
      rightButtonWeek.alpha = 0.5
      rightButtonWeek.enabled = false
    }else {
      rightButtonWeek.alpha = 1
      rightButtonWeek.enabled = true
    }
    labelWeekend.text = weekDays[weekDaysActualInt]
    actualScheduleWeekday = weekDays[weekDaysActualInt]
    actualSchedulePrograms = schedule[weekDays[weekDaysActualInt]]!
    self.tableView.reloadData()
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return actualSchedulePrograms[section].timeStart
  }
  
}
