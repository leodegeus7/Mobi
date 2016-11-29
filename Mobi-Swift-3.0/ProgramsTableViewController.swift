//
//  ProgramsTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/3/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import Kingfisher

class ProgramsTableViewController: UITableViewController,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate {
  
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
    
    tableView.emptyDataSetSource = self
    tableView.emptyDataSetDelegate = self
    tableView.tableFooterView = UIView()
    
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
    
    let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
    swipeRight.direction = UISwipeGestureRecognizerDirection.Right
    self.view.addGestureRecognizer(swipeRight)
    let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
    swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
    self.view.addGestureRecognizer(swipeLeft)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return actualSchedulePrograms.count + 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func respondToSwipeGesture(gesture:UIGestureRecognizer) {
    
    if let swipeGesture = gesture as? UISwipeGestureRecognizer {
      switch swipeGesture.direction {
      case UISwipeGestureRecognizerDirection.Right:
        if weekDaysActualInt >= 0 {
          if !(weekDaysActualInt-1 < 0) {
            weekDaysActualInt -= 1
          }
          updateInterface()
        }
      case UISwipeGestureRecognizerDirection.Left:
        if weekDaysActualInt < 6 {
          if !(weekDaysActualInt-1 > 6) {
            weekDaysActualInt += 1
          }
          updateInterface()
        }
      default:
        break
      }
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.section <= actualSchedulePrograms.count-1 {
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
        cell.selectionStyle = .None
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
        cell.selectionStyle = .None
        return cell
      }
    } else {
      let cell = UITableViewCell()
      cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
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
      
      let actualDayOfWeek = Util.getDayOfWeek(NSDate())
      let fistDayOfWeek = NSDate().dateByAddingTimeInterval(-Double(((actualDayOfWeek)))*60*60*24)
      let lastDayOfWeek = NSDate().dateByAddingTimeInterval(Double((7-(actualDayOfWeek-1)))*60*60*24)
      
      let requestSpecial = RequestManager()
      requestSpecial.requestSpecialProgramsOfRadio(self.actualRadio, pageNumber: 0, pageSize: 30, completion: { (resultSpecialPrograms) in
        for specialProgram in resultSpecialPrograms {
          
          if specialProgram.date.timeIntervalSinceDate(fistDayOfWeek) > 0 && specialProgram.date.timeIntervalSinceDate(lastDayOfWeek) < 0 {
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
    if section <= actualSchedulePrograms.count-1 {
      return actualSchedulePrograms[section].timeStart
    } else {
      return  ""
    }
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- EMPTY TABLE VIEW DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  func titleForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
    let str = "Sem Programação"
    let attr = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func descriptionForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
    let str = "A rádio não disponibilizou nenhuma programação para o período"
    let attr = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func emptyDataSetDidTapButton(scrollView: UIScrollView) {
    dismissViewControllerAnimated(true) {
    }
  }
  
}
