//
//  ConfigViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/11/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework


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
  @IBOutlet weak var button1x5: UIButton!
  @IBOutlet weak var button2x1: UIButton!
  @IBOutlet weak var button2x2: UIButton!
  @IBOutlet weak var button2x3: UIButton!
  @IBOutlet weak var button2x4: UIButton!
  @IBOutlet weak var button2x5: UIButton!
  
  @IBOutlet weak var stackColors: UIStackView!
  
  var imageCheckView = UIImageView()
  var colorButtons = [UIButton]()
  
  let colorArray:[UIColor] = [FlatRed(),FlatOrange(),FlatYellow(),FlatMint(),FlatPurple(),FlatRedDark(),FlatOrangeDark(),FlatYellowDark(),FlatMintDark(),FlatPurpleDark()]
  
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
    colorButtons.append(button1x5)
    colorButtons.append(button2x1)
    colorButtons.append(button2x2)
    colorButtons.append(button2x3)
    colorButtons.append(button2x4)
    colorButtons.append(button2x5)
    
    var i = 0
    for button in colorButtons {
      button.frame.size.width = colorView.bounds.width/4
      button.frame.size.height = colorView.bounds.height/2
      button.titleLabel?.text = ""
      button.backgroundColor = colorArray[i]
      button.addTarget(self, action: #selector(ConfigViewController.buttonGridTapped), forControlEvents: .TouchUpInside)
      i += 1
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
    
    
    let imageCheck = UIImage(named: "okImage.png")
    let imageCheckSized = Util.imageResize(imageCheck!, sizeChange: CGSize(width: 0.5*CGFloat(stackColors.frame.width/((CGFloat(colorButtons.count)/2.0)-1.0)), height: 0.5*(stackColors.frame.height/3)))
    imageCheckView = UIImageView(image: imageCheckSized)
    
    
    
    for button in colorButtons {
      button.setImage(UIImage(), forState: .Normal)
      button.setBackgroundImage(UIImage(), forState: .Normal)
      if button.tag == DataManager.sharedInstance.configApp.coordColorConfig {
        
        let image = UIImageView(frame: button.frame)
        image.image = UIImage(named: "okImage.png")
        image.frame = button.frame
        
        button.setBackgroundImage(image.image, forState: .Normal)
      }
    }
    
    
    
    
    
    
    
    
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
    
    switch (sender?.tag)! {
    case 11:
      Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[0], withContentStyle: UIContentStyle.Contrast)
    case 12:
      Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[1], withContentStyle: UIContentStyle.Contrast)
    case 13:
      Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[2], withContentStyle: UIContentStyle.Contrast)
    case 14:
      Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[3], withContentStyle: UIContentStyle.Contrast)
    case 15:
      Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[4], withContentStyle: UIContentStyle.Contrast)
    case 21:
      Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[5], withContentStyle: UIContentStyle.Contrast)
    case 22:
      Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[6], withContentStyle: UIContentStyle.Contrast)
    case 23:
      Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[7], withContentStyle: UIContentStyle.Contrast)
    case 24:
      Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[8], withContentStyle: UIContentStyle.Contrast)
    case 25:
      Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[9],  withContentStyle: UIContentStyle.Contrast)
    default:
      Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[0],  withContentStyle: UIContentStyle.Contrast)
    }
    
    DataManager.sharedInstance.interfaceColor = ColorRealm(name: 1, color: (sender?.backgroundColor)!)
    self.navigationController?.navigationBar.barTintColor = DataManager.sharedInstance.interfaceColor.color
    print("Selected Color \(sender?.backgroundColor)")
    DataManager.sharedInstance.existInterfaceColor = true
    print(sender?.tag)
    
    tableViewAudio.reloadData()
    sliderAgudos.reloadInputViews()
    sliderGraves.reloadInputViews()
    sliderMedios.reloadInputViews()
    
    DataManager.sharedInstance.configApp.updatecoordColorConfig((sender?.tag)!)
//    imageCheckView.frame = (sender?.frame)!
//    if (sender?.tag)! > 20 {
//      imageCheckView.center.y = sender!.center.y + (sender?.frame)!.maxY - (sender?.frame)!.minY
//    }
    for button in colorButtons {
      button.setImage(UIImage(), forState: .Normal)
      button.setBackgroundImage(UIImage(), forState: .Normal)
      if button.tag == DataManager.sharedInstance.configApp.coordColorConfig {
        
       // button.setImage(UIImage"okImage.png"), forState: .Normal)
        let image = UIImageView(frame: button.frame)
        image.image = UIImage(named: "okImage.png")
        image.frame = button.frame
        
        button.setBackgroundImage(image.image, forState: .Normal)
      }
    }
    
    //stackColors.addSubview(imageCheckView)
    
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
