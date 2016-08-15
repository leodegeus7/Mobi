//
//  ConfigViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/11/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class ConfigViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  @IBOutlet weak var tableViewAudio: UITableView!
  @IBOutlet weak var sliderGraves: UISlider!
  @IBOutlet weak var sliderMedios: UISlider!
  @IBOutlet weak var sliderAgudos: UISlider!
  
  //BOTTOES DE COR PARA PICKER COLOR
  @IBOutlet weak var colorView: UIView!
  @IBOutlet weak var button1X1: UIButton!
  @IBOutlet weak var button1x2: UIButton!
  @IBOutlet weak var button1x3: UIButton!
  @IBOutlet weak var button1x4: UIButton!
  @IBOutlet weak var button2x1: UIButton!
  @IBOutlet weak var button2x2: UIButton!
  @IBOutlet weak var button2x3: UIButton!
  @IBOutlet weak var button2x4: UIButton!
  var colorButtons = [UIButton]()
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
        //define color buttons in bottom of view
        colorButtons.append(button1X1)
        colorButtons.append(button1x2)
        colorButtons.append(button1x3)
        colorButtons.append(button1x4)
        colorButtons.append(button2x1)
        colorButtons.append(button2x2)
        colorButtons.append(button2x3)
        colorButtons.append(button2x4)
        for button in colorButtons {
          button.frame.size.width = colorView.bounds.width/4
          button.frame.size.height = colorView.bounds.height/2
          button.backgroundColor = Util.getRandomColor()
          button.titleLabel?.text = ""
          button.addTarget(self, action: #selector(ConfigViewController.buttonGridTapped), forControlEvents: .TouchUpInside)

        }
      
        // define audio tableview parameters
        tableViewAudio.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
      
        if (DataManager.sharedInstance.audioConfig.audioQuality == "Baixo") {
          let indexPathTableView = NSIndexPath(forRow: 0, inSection: 0)
          tableViewAudio.selectRowAtIndexPath(indexPathTableView, animated: false, scrollPosition: UITableViewScrollPosition.None)
        } else if (DataManager.sharedInstance.audioConfig.audioQuality == "Alto") {
          let indexPathTableView = NSIndexPath(forRow: 1, inSection: 0)
          tableViewAudio.selectRowAtIndexPath(indexPathTableView, animated: false, scrollPosition: UITableViewScrollPosition.None)
        } else if (DataManager.sharedInstance.audioConfig.audioQuality == "Automático") {
          let indexPathTableView = NSIndexPath(forRow: 2, inSection: 0)
          tableViewAudio.selectRowAtIndexPath(indexPathTableView, animated: false, scrollPosition: UITableViewScrollPosition.None)
        }
      
        //define sliders config
        sliderGraves.value = Float(DataManager.sharedInstance.audioConfig.grave)
        sliderAgudos.value = Float(DataManager.sharedInstance.audioConfig.agudo)
        sliderMedios.value = Float(DataManager.sharedInstance.audioConfig.medio)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  //MARK: --- Table View DataSource and Table View Delegate Function ---
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("audioCell", forIndexPath: indexPath) as! AudioConfigTableViewCell
    if (indexPath.row == 0) {
      cell.labelAudio.text = "Baixa"
    } else if (indexPath.row == 1) {
      cell.labelAudio.text = "Alta"
    } else if (indexPath.row == 2) {
      cell.labelAudio.text = "Automática"
    }
    cell.labelAudio.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if (indexPath.row == 0) {
      DataManager.sharedInstance.audioConfig.audioQuality = "Baixo"
    } else if (indexPath.row == 1) {
      DataManager.sharedInstance.audioConfig.audioQuality = "Alto"
    } else if (indexPath.row == 2) {
      DataManager.sharedInstance.audioConfig.audioQuality = "Automático"
    }
  }
  
  //MARK: --- Button Color Click Function ---
  
  func buttonGridTapped(sender: UIButton?) { //to know the selected color
    var color = ""
    switch sender!.tag {
    case 11:
      color = ""
    case 12:
      color = ""
    case 13:
      color = ""
    case 14:
      color = ""
    case 21:
      color = ""
    case 22:
      color = ""
    case 23:
      color = ""
    case 24:
      color = ""
    default:
      color = ""
    }
    let button = sender! as UIButton
    button.imageView?.image = UIImage(contentsOfFile: "okImage")
    print("Selected Color \(color)")
  }

  
  //MARK: --- Slider Events Function ---
  
  @IBAction func sliderGraveChanged(sender: AnyObject) {
    let value = sliderGraves.value
    let currentValue = Int(value)
    DataManager.sharedInstance.audioConfig.setGraveParameter(currentValue)
  }

  @IBAction func sliderMedioChanged(sender: AnyObject) {
    let value = sliderMedios.value
    let currentValue = Int(value)
    DataManager.sharedInstance.audioConfig.setMedioParameter(currentValue)
  }

  @IBAction func sliderAgudoChanged(sender: AnyObject) {
    let value = sliderAgudos.value
    let currentValue = Int(value)
    DataManager.sharedInstance.audioConfig.setAgudoParameter(currentValue)
  }
  
  
}
