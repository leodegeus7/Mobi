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
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.emptyDataSetSource = self
    tableView.emptyDataSetDelegate = self
    tableView.tableFooterView = UIView()
    
    activityIndicator.center = view.center
    activityIndicator.startAnimating()
    activityIndicator.isHidden = true
    organizeSchedule()
    self.title = "Programação"
    leftButtonWeek.backgroundColor = UIColor.clear
    rightButtonWeek.backgroundColor = UIColor.clear
    leftButtonWeek.setTitleColor(UIColor.black, for: UIControlState())
    rightButtonWeek.setTitleColor(UIColor.black, for: UIControlState())
    let dayOfWeekInt = Util.getDayOfWeek(Date())
    todayWeekDay = weekDays[dayOfWeekInt-1]
    weekDaysActualInt = dayOfWeekInt-1
    labelWeekend.text = todayWeekDay
    actualScheduleWeekday = todayWeekDay
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 400
    
    let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
    swipeRight.direction = UISwipeGestureRecognizerDirection.right
    self.view.addGestureRecognizer(swipeRight)
    let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
    swipeLeft.direction = UISwipeGestureRecognizerDirection.left
    self.view.addGestureRecognizer(swipeLeft)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    if actualSchedulePrograms.count == 0 {
      return 0
    } else {
      return actualSchedulePrograms.count + 1
    }
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func respondToSwipeGesture(_ gesture:UIGestureRecognizer) {
    
    if let swipeGesture = gesture as? UISwipeGestureRecognizer {
      switch swipeGesture.direction {
      case UISwipeGestureRecognizerDirection.right:
        if weekDaysActualInt >= 0 {
          if !(weekDaysActualInt-1 < 0) {
            weekDaysActualInt -= 1
          }
          updateInterface()
        }
      case UISwipeGestureRecognizerDirection.left:
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
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section <= actualSchedulePrograms.count-1 {
      if type(of: actualSchedulePrograms[indexPath.section]) == SpecialProgram.self {
        let cell = tableView.dequeueReusableCell(withIdentifier: "actualProgram", for: indexPath) as! ActualProgramTableViewCell
        
        let programSpecial2 = actualSchedulePrograms[indexPath.section] as! SpecialProgram
        
        cell.labelName.text = actualSchedulePrograms[indexPath.section].name
        cell.labelSecondName.text = ""
        let identifierImage = actualSchedulePrograms[indexPath.section].announcer.userImage
        if identifierImage == "avatar.png" {
          cell.imagePerson.image = UIImage(named: "avatar.png")
        } else {
          cell.imagePerson.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(identifierImage)))
        }
        cell.imagePerson.layer.cornerRadius = cell.imagePerson.bounds.height / 2
        cell.imagePerson.layer.borderColor = UIColor.black.cgColor
        cell.imagePerson.layer.borderWidth = 0
        cell.imagePerson.clipsToBounds = true
        cell.labelNamePerson.text = actualSchedulePrograms[indexPath.section].announcer.name
        cell.labelGuests.text = programSpecial2.guests
        cell.selectionStyle = .none
        return cell
      } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "normalProgram", for: indexPath) as! NormalProgramTableViewCell
        
        cell.labelName.text = actualSchedulePrograms[indexPath.section].name
        let identifierImage = actualSchedulePrograms[indexPath.section].announcer.userImage
        if identifierImage == "avatar.png" {
          cell.imagePerson.image = UIImage(named: "avatar.png")
        } else {
          cell.imagePerson.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(identifierImage)))
        }
        cell.imagePerson.layer.cornerRadius = cell.imagePerson.bounds.height / 2
        cell.imagePerson.layer.borderColor = UIColor.black.cgColor
        cell.imagePerson.layer.borderWidth = 0
        cell.imagePerson.clipsToBounds = true
        cell.labelNamePerson.text = actualSchedulePrograms[indexPath.section].announcer.name
        cell.selectionStyle = .none
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
    activityIndicator.isHidden = false
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
      
      let actualDayOfWeek = Util.getDayOfWeek(Date())
      let fistDayOfWeek = Date().addingTimeInterval(-Double(((actualDayOfWeek)))*60*60*24)
      let lastDayOfWeek = Date().addingTimeInterval(Double((7-(actualDayOfWeek-1)))*60*60*24)
      
      let requestSpecial = RequestManager()
      requestSpecial.requestSpecialProgramsOfRadio(self.actualRadio, pageNumber: 0, pageSize: 30, completion: { (resultSpecialPrograms) in
        for specialProgram in resultSpecialPrograms {
          
          if specialProgram.date.timeIntervalSince(fistDayOfWeek) > 0 && specialProgram.date.timeIntervalSince(lastDayOfWeek) < 0 {
            let dayOfWeekInt = Util.getDayOfWeek(specialProgram.date)
            let specialProgramAux = specialProgram
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
            dateFormatter.timeZone = TimeZone.autoupdatingCurrent
            print(dateFormatter.string(from: specialProgramAux.date))
            specialProgramAux.timeStart = dateFormatter.string(from: specialProgramAux.date)
            self.schedule[self.weekDays[dayOfWeekInt-1]]?.append(specialProgramAux)
            
            let programIdToDelete = specialProgram.referenceIdProgram
            var scheduleDay = (self.schedule[self.weekDays[dayOfWeekInt-1]])!
            var programToDelete = Program()
            for program in scheduleDay {
              if program.id == programIdToDelete && !Util.areTheySiblings(program, class2: SpecialProgram()) {
                programToDelete = program
                break
              }
            }
            scheduleDay.remove(at: scheduleDay.index(of: programToDelete)!)
            self.schedule[self.weekDays[dayOfWeekInt-1]] = scheduleDay
          }
        }
        
        for programsArray in self.schedule {
          var programs = programsArray.1
          programs.sort(by: { $0.sortVar < $1.sortVar })
          self.schedule[programsArray.0] = programs
          
        }
        
        self.tableView.allowsSelection = true
        self.activityIndicator.isHidden = true
        self.activityIndicator.removeFromSuperview()
        
        self.updateInterface()
      })
      
      
      
    }
  }
  
  @IBAction func leftMenuButtonClick(_ sender: AnyObject) {
    if !(weekDaysActualInt-1 < 0) {
      weekDaysActualInt -= 1
    }
    updateInterface()
  }
  
  @IBAction func rightMenuButtonClick(_ sender: AnyObject) {
    if !(weekDaysActualInt-1 > 6) {
      weekDaysActualInt += 1
    }
    updateInterface()
  }
  
  func updateInterface() {
    if weekDaysActualInt == 0 {
      leftButtonWeek.alpha = 0.5
      leftButtonWeek.isEnabled = false
    } else {
      leftButtonWeek.alpha = 1
      leftButtonWeek.isEnabled = true
    }
    if weekDaysActualInt == 6 {
      rightButtonWeek.alpha = 0.5
      rightButtonWeek.isEnabled = false
    }else {
      rightButtonWeek.alpha = 1
      rightButtonWeek.isEnabled = true
    }
    labelWeekend.text = weekDays[weekDaysActualInt]
    actualScheduleWeekday = weekDays[weekDaysActualInt]
    actualSchedulePrograms = schedule[weekDays[weekDaysActualInt]]!
    self.tableView.reloadData()
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section <= actualSchedulePrograms.count-1 {
        return actualSchedulePrograms[section].timeStart
      
    } else {
      return  ""
    }
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- EMPTY TABLE VIEW DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
    let str = "Sem Programação"
    let attr = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
    let str = "A rádio não disponibilizou nenhuma programação para o período"
    let attr = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func emptyDataSetDidTapButton(_ scrollView: UIScrollView) {
    dismiss(animated: true) {
    }
  }
  
}
