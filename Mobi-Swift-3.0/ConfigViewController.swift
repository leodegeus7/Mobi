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
  @IBOutlet weak var button3x1: UIButton!
  @IBOutlet weak var button3x2: UIButton!
  @IBOutlet weak var button3x3: UIButton!
  @IBOutlet weak var button3x4: UIButton!
  @IBOutlet weak var button3x5: UIButton!
  
  @IBOutlet weak var stackColors: UIStackView!
  
  var imageCheckView = UIImageView()
  var colorButtons = [UIButton]()
  let colorRose = DataManager.sharedInstance.pinkColor
  let colorBlue = DataManager.sharedInstance.blueColor
  let colorArray1:[UIColor] = [FlatLimeDark(),FlatOrangeDark(),FlatBlackDark(),FlatPinkDark(),FlatPlumDark(),FlatLime(),FlatPowderBlue(),FlatBlue(),FlatWhite(),FlatSand(),FlatMint(),FlatGreen(),FlatYellow(),FlatOrange(),FlatGray()]
  let colorArray2:[UIColor] = [DataManager.sharedInstance.blueColor.color,FlatWatermelonDark(),FlatPinkDark(),FlatRed(),FlatPurple(),FlatPlumDark(),FlatNavyBlue(),FlatTealDark(),FlatSkyBlueDark(),FlatBlackDark(),FlatMint(),FlatGreen(),FlatYellowDark(),FlatOrange(),FlatGray()]
  var colorArray:[UIColor] = []
  var notificationCenter = NotificationCenter.default
  
  @IBOutlet weak var scrollView: UIScrollView!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    colorArray = colorArray2
    self.view.isUserInteractionEnabled = true
    menuButton.target = self.revealViewController()
    menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
    
    self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    //define color buttons in bottom of view
    
    notificationCenter.addObserver(self, selector: #selector(ConfigViewController.freezeView), name: NSNotification.Name(rawValue: "freezeViews"), object: nil)
    
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
    colorButtons.append(button3x1)
    colorButtons.append(button3x2)
    colorButtons.append(button3x3)
    colorButtons.append(button3x4)
    colorButtons.append(button3x5)
    var i = 0
    for button in colorButtons {
      button.frame.size.width = colorView.bounds.width/4
      button.frame.size.height = colorView.bounds.height/2
      button.titleLabel?.text = ""
      button.backgroundColor = colorArray[i]
      
      
      button.backgroundColor = colorArray[i]
      button.addTarget(self, action: #selector(ConfigViewController.buttonGridTapped), for: .touchUpInside)
      i += 1
    }
    
    self.title = "Configurações"
    
    // define audio tableview parameters
    tableViewAudio.separatorStyle = UITableViewCellSeparatorStyle.singleLine
    
    if (DataManager.sharedInstance.audioConfig.audioType == 1) {
      let indexPathTableView = IndexPath(row: 0, section: 0)
      tableViewAudio.selectRow(at: indexPathTableView, animated: false, scrollPosition: UITableViewScrollPosition.none)
    } else if (DataManager.sharedInstance.audioConfig.audioType == 2) {
      let indexPathTableView = IndexPath(row: 1, section: 0)
      tableViewAudio.selectRow(at: indexPathTableView, animated: false, scrollPosition: UITableViewScrollPosition.none)
    } else if (DataManager.sharedInstance.audioConfig.audioType == 0) {
      let indexPathTableView = IndexPath(row: 2, section: 0)
      tableViewAudio.selectRow(at: indexPathTableView, animated: false, scrollPosition: UITableViewScrollPosition.none)
    }
    
    //define sliders config
    sliderGraves.value = Float(DataManager.sharedInstance.audioConfig.grave)
    sliderAgudos.value = Float(DataManager.sharedInstance.audioConfig.agudo)
    sliderMedios.value = Float(DataManager.sharedInstance.audioConfig.medio)
    
    
    let imageCheck = UIImage(named: "check.png")
    let imageCheckSized = Util.imageResize(imageCheck!, sizeChange: CGSize(width: 0.5*CGFloat(stackColors.frame.width/((CGFloat(colorButtons.count)/2.0)-1.0)), height: 0.5*(stackColors.frame.height/3)))
    imageCheckView = UIImageView(image: imageCheckSized)
    
    
    
    for button in colorButtons {
      button.setImage(UIImage(), for: UIControlState())
      button.setBackgroundImage(UIImage(), for: UIControlState())
      if button.tag == DataManager.sharedInstance.configApp.coordColorConfig {
        
        let image = UIImageView(frame: button.frame)
        image.image = UIImage(named: "check.png")
        image.frame = button.frame
        
        button.setBackgroundImage(image.image, for: UIControlState())
      }
    }
    
    
    
    
    
    
    
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func freezeView() {
    
    if DataManager.sharedInstance.menuIsOpen {
      scrollView.isScrollEnabled = false
      scrollView.isUserInteractionEnabled = false
    } else {
      scrollView.isScrollEnabled = true
      scrollView.isUserInteractionEnabled = true
    }
  }
  
  //MARK: --- Table View DataSource and Table View Delegate Function ---
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "audioCell", for: indexPath) as! AudioConfigTableViewCell
    if (indexPath.row == 0) {
      cell.labelAudio.text = "Baixa"
    } else if (indexPath.row == 1) {
      cell.labelAudio.text = "Alta"
    } else if (indexPath.row == 2) {
      cell.labelAudio.text = "Automática"
    }
    cell.labelAudio.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
    let colorAlpha = DataManager.sharedInstance.interfaceColor.color.withAlphaComponent(0.2)
    let viewSelected = UIView()
    viewSelected.backgroundColor = colorAlpha
    cell.selectedBackgroundView = viewSelected
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if (indexPath.row == 0) {
      DataManager.sharedInstance.audioConfig.setAudioTypeQuality(2)
    } else if (indexPath.row == 1) {
      DataManager.sharedInstance.audioConfig.setAudioTypeQuality(1)
    } else if (indexPath.row == 2) {
      DataManager.sharedInstance.audioConfig.setAudioTypeQuality(0)
    }
  }
  
  //MARK: --- Button Color Click Function ---
  
  func buttonGridTapped(_ sender: UIButton?) { //to know the selected color
    DataManager.sharedInstance.interfaceColor = ColorRealm(name: 1, color: (sender?.backgroundColor)!)
    
    
    switch (sender?.tag)! {
    case 11:
      if colorArray2 == colorArray {
        Chameleon.setGlobalThemeUsingPrimaryColor(colorBlue?.color, with: UIContentStyle.contrast)

        DataManager.sharedInstance.interfaceColor = colorBlue!
        self.setStatusBarStyle(.lightContent)
        
        if ContrastColorOf((colorBlue?.color)!, returnFlat: true) == FlatWhite() {
          print("branco")
        } else {
        print("nao")
        }
      }
      else {
        Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[0], with: UIContentStyle.contrast)
      }
    case 12:
      Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[1], with: UIContentStyle.contrast)
      if ContrastColorOf((colorBlue?.color)!, returnFlat: true) == FlatWhite() {
        print("branco")
      } else {
        print("nao")
      }
    case 13:
      Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[2], with: UIContentStyle.contrast)
    case 14:
      Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[3], with: UIContentStyle.contrast)
    case 15:
      Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[4], with: UIContentStyle.contrast)
    case 21:
      Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[5], with: UIContentStyle.contrast)
    case 22:
      Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[6], with: UIContentStyle.contrast)
    case 23:
      Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[7], with: UIContentStyle.contrast)
    case 24:
      Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[8], with: UIContentStyle.contrast)
    case 25:
      Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[9],  with: UIContentStyle.contrast)
    case 31:
      Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[10],  with: UIContentStyle.contrast)
    case 32:
      Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[11],  with: UIContentStyle.contrast)
    case 33:
      Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[12],  with: UIContentStyle.contrast)
    case 34:
      Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[13],  with: UIContentStyle.contrast)
    case 35:
      Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[14],  with: UIContentStyle.contrast)
    default:
      Chameleon.setGlobalThemeUsingPrimaryColor(colorArray[0],  with: UIContentStyle.contrast)
    }
    
    
    self.navigationController?.navigationBar.barTintColor = DataManager.sharedInstance.interfaceColor.color
    print("Selected Color \(sender?.backgroundColor)")
    DataManager.sharedInstance.existInterfaceColor = true

    
    tableViewAudio.reloadData()
    sliderAgudos.thumbTintColor = DataManager.sharedInstance.interfaceColor.color
    sliderGraves.thumbTintColor = DataManager.sharedInstance.interfaceColor.color
    sliderMedios.thumbTintColor = DataManager.sharedInstance.interfaceColor.color
    sliderAgudos.minimumTrackTintColor = DataManager.sharedInstance.interfaceColor.color
    sliderGraves.minimumTrackTintColor = DataManager.sharedInstance.interfaceColor.color
    sliderMedios.minimumTrackTintColor = DataManager.sharedInstance.interfaceColor.color
    
    StreamingRadioManager.sharedInstance.sendNotification()
    DataManager.sharedInstance.configApp.updatecoordColorConfig((sender?.tag)!)
    //    imageCheckView.frame = (sender?.frame)!
    //    if (sender?.tag)! > 20 {
    //      imageCheckView.center.y = sender!.center.y + (sender?.frame)!.maxY - (sender?.frame)!.minY
    //    }
    for button in colorButtons {
      button.setImage(UIImage(), for: UIControlState())
      button.setBackgroundImage(UIImage(), for: UIControlState())
      if button.tag == DataManager.sharedInstance.configApp.coordColorConfig {
        
        // button.setImage(UIImage"check.png"), forState: .Normal)
        let image = UIImageView(frame: button.frame)
        image.image = UIImage(named: "check.png")
        image.frame = button.frame
        
        button.setBackgroundImage(image.image, for: UIControlState())
      }
    }
    
    if (DataManager.sharedInstance.audioConfig.audioType == 1) {
      let indexPathTableView = IndexPath(row: 0, section: 0)
      tableViewAudio.selectRow(at: indexPathTableView, animated: false, scrollPosition: UITableViewScrollPosition.none)
    } else if (DataManager.sharedInstance.audioConfig.audioType == 2) {
      let indexPathTableView = IndexPath(row: 1, section: 0)
      tableViewAudio.selectRow(at: indexPathTableView, animated: false, scrollPosition: UITableViewScrollPosition.none)
    } else if (DataManager.sharedInstance.audioConfig.audioType == 0) {
      let indexPathTableView = IndexPath(row: 2, section: 0)
      tableViewAudio.selectRow(at: indexPathTableView, animated: false, scrollPosition: UITableViewScrollPosition.none)
    }
    //stackColors.addSubview(imageCheckView)
    self.setStatusBarStyle(.lightContent)
  }
  
  
  //MARK: --- Slider Events Function ---
  
  @IBAction func sliderGraveChanged(_ sender: AnyObject) {
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
  
  @IBAction func sliderMedioChanged(_ sender: AnyObject) {
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
  
  @IBAction func sliderAgudoChanged(_ sender: AnyObject) {
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
  
  @IBAction func searchButtonTap(_ sender: AnyObject) {
    DataManager.sharedInstance.instantiateSearch(self.navigationController!)
  }
  
  override var canBecomeFirstResponder : Bool {
    return true
  }
  
  
  
  override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
    //if motion == .MotionShake {
    if motion == .motionShake {
      if colorArray == colorArray2 {
        colorArray = colorArray1
      } else if colorArray == colorArray1 {
        colorArray = colorArray2
      }
      
      var i = 0
      for button in colorButtons {
        
        
        
        button.backgroundColor = colorArray[i]
        
        
        
        i += 1
      }
      
      let randomColor = UIColor.init(randomColorIn: colorArray)
      Chameleon.setGlobalThemeUsingPrimaryColor(randomColor, with: UIContentStyle.contrast)
      
      DataManager.sharedInstance.interfaceColor = ColorRealm(name: 2, color: randomColor!)
      self.navigationController?.navigationBar.barTintColor = DataManager.sharedInstance.interfaceColor.color
      DataManager.sharedInstance.existInterfaceColor = true
      
      tableViewAudio.reloadData()
      
      if (DataManager.sharedInstance.audioConfig.audioType == 1) {
        let indexPathTableView = IndexPath(row: 0, section: 0)
        tableViewAudio.selectRow(at: indexPathTableView, animated: false, scrollPosition: UITableViewScrollPosition.none)
      } else if (DataManager.sharedInstance.audioConfig.audioType == 2) {
        let indexPathTableView = IndexPath(row: 1, section: 0)
        tableViewAudio.selectRow(at: indexPathTableView, animated: false, scrollPosition: UITableViewScrollPosition.none)
      } else if (DataManager.sharedInstance.audioConfig.audioType == 0) {
        let indexPathTableView = IndexPath(row: 2, section: 0)
        tableViewAudio.selectRow(at: indexPathTableView, animated: false, scrollPosition: UITableViewScrollPosition.none)
      }
      
      sliderAgudos.thumbTintColor = randomColor
      sliderGraves.thumbTintColor = randomColor
      sliderMedios.thumbTintColor = randomColor
      sliderAgudos.minimumTrackTintColor = randomColor
      sliderGraves.minimumTrackTintColor = randomColor
      sliderMedios.minimumTrackTintColor = randomColor
      
      var tagButton = -1
      for button in colorButtons {
        if button.backgroundColor == randomColor {
          tagButton = button.tag
        }
      }
      
      

        
        
      DataManager.sharedInstance.configApp.updatecoordColorConfig(tagButton)
      StreamingRadioManager.sharedInstance.sendNotification()
      
      for button in colorButtons {
        button.setImage(UIImage(), for: UIControlState())
        button.setBackgroundImage(UIImage(), for: UIControlState())
        if button.tag == DataManager.sharedInstance.configApp.coordColorConfig {
          
          // button.setImage(UIImage"check.png"), forState: .Normal)
          let image = UIImageView(frame: button.frame)
          image.image = UIImage(named: "check.png")
          image.frame = button.frame
          
          button.setBackgroundImage(image.image, for: UIControlState())
        }
      }
    }
    
  }
  
  
}
