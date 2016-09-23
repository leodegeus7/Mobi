//
//  ConfigViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/11/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class ConfigViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var menuButton: UIBarButtonItem!
  
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
    self.view.userInteractionEnabled = true
    menuButton.target = self.revealViewController()
    menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
    
    self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
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
    
    self.title = "Configurações"
    
    // define audio tableview parameters
    tableViewAudio.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
    
    if (DataManager.sharedInstance.audioConfig.audioType == 1) {
      let indexPathTableView = NSIndexPath(forRow: 0, inSection: 0)
      tableViewAudio.selectRowAtIndexPath(indexPathTableView, animated: false, scrollPosition: UITableViewScrollPosition.None)
    } else if (DataManager.sharedInstance.audioConfig.audioType == 2) {
      let indexPathTableView = NSIndexPath(forRow: 1, inSection: 0)
      tableViewAudio.selectRowAtIndexPath(indexPathTableView, animated: false, scrollPosition: UITableViewScrollPosition.None)
    } else if (DataManager.sharedInstance.audioConfig.audioType == 0) {
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
      DataManager.sharedInstance.audioConfig.setAudioTypeQuality(2)
    } else if (indexPath.row == 1) {
      DataManager.sharedInstance.audioConfig.setAudioTypeQuality(1)
    } else if (indexPath.row == 2) {
      DataManager.sharedInstance.audioConfig.setAudioTypeQuality(0)
    }
  }
  
  //MARK: --- Button Color Click Function ---
  
  func buttonGridTapped(sender: UIButton?) { //to know the selected color
    let colorButton = sender?.backgroundColor
    let components = CGColorGetComponents(colorButton?.CGColor)
    let color = ColorRealm(name: 1, red: components[0], green: components[1], blue: components[2], alpha: CGColorGetAlpha(colorButton?.CGColor))
    
    DataManager.sharedInstance.interfaceColor = color
    self.navigationController?.navigationBar.barTintColor = DataManager.sharedInstance.interfaceColor.color
    
    let okimage = UIImageView(image: UIImage(named: "okImage.png"))
    okimage.frame = sender!.frame
    okimage.center = sender!.center
    sender!.addSubview(okimage)
    print("Selected Color \(sender?.backgroundColor)")
    DataManager.sharedInstance.existInterfaceColor = true
    print(sender?.tag)
  }
  
  
  //MARK: --- Slider Events Function ---
  
  @IBAction func sliderGraveChanged(sender: AnyObject) {
    let value = sliderGraves.value as Float
    let maxValueScroll = Float(sliderGraves.maximumValue)
    let minValueScroll = Float(sliderGraves.minimumValue)
    if value > 0 {
      let faixa0 = (24/maxValueScroll)*value
      let faixa1 = (16/maxValueScroll)*value
      let faixa2 = (8/maxValueScroll)*value
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(faixa0, forEqualizerBand: 0)
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(faixa1, forEqualizerBand: 1)
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(faixa2, forEqualizerBand: 2)
    } else {
      let faixa0 = (-96/minValueScroll)*value
      let faixa1 = (-64/minValueScroll)*value
      let faixa2 = (-32/minValueScroll)*value
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(faixa0, forEqualizerBand: 0)
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(faixa1, forEqualizerBand: 1)
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(faixa2, forEqualizerBand: 2)
    }
    let currentValue = Int(value)
    DataManager.sharedInstance.audioConfig.setGraveParameter(currentValue)
  }
  
  @IBAction func sliderMedioChanged(sender: AnyObject) {
    let value = sliderMedios.value as Float
    let maxValueScroll = Float(sliderMedios.maximumValue)
    let minValueScroll = Float(sliderMedios.minimumValue)
    
    if value > 0 {
      let faixa2 = (16/maxValueScroll)*value
      let faixa3 = (16/maxValueScroll)*value
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(faixa3, forEqualizerBand: 3)
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(faixa2, forEqualizerBand: 2)
    } else {
      let faixa2 = (-64/minValueScroll)*value
      let faixa3 = (-64/minValueScroll)*value
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(faixa2, forEqualizerBand: 2)
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(faixa3, forEqualizerBand: 3)
    }
    
    let currentValue = Int(value)
    DataManager.sharedInstance.audioConfig.setMedioParameter(currentValue)
  }
  
  @IBAction func sliderAgudoChanged(sender: AnyObject) {
    let value = sliderAgudos.value as Float
    let maxValueScroll = Float(sliderAgudos.maximumValue)
    let minValueScroll = Float(sliderAgudos.minimumValue)
    if value > 0 {
      let faixa5 = (24/maxValueScroll)*value
      let faixa4 = (16/maxValueScroll)*value
      let faixa3 = (8/maxValueScroll)*value
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(faixa5, forEqualizerBand: 5)
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(faixa4, forEqualizerBand: 4)
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(faixa3, forEqualizerBand: 3)
    } else {
      let faixa5 = (-96/minValueScroll)*value
      let faixa4 = (-64/minValueScroll)*value
      let faixa3 = (-32/minValueScroll)*value
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(faixa5, forEqualizerBand: 5)
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(faixa4, forEqualizerBand: 4)
      StreamingRadioManager.sharedInstance.audioPlayer.setGain(faixa3, forEqualizerBand: 3)
    }
    let currentValue = Int(value)
    DataManager.sharedInstance.audioConfig.setAgudoParameter(currentValue)
  }
  
  @IBAction func searchButtonTap(sender: AnyObject) {
    DataManager.sharedInstance.instantiateSearch(self.navigationController!)
  }
  
  
}
