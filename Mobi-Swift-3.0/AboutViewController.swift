//
//  AboutViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 11/18/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework

class AboutViewController: UIViewController {
  
  @IBOutlet weak var buttonLink: UIButton!
  @IBOutlet weak var openMenu: UIBarButtonItem!
  @IBOutlet weak var textViewAbout: UITextView!
  
  @IBOutlet weak var buttonTerms: UIButton!
  override func viewDidLoad() {
    super.viewDidLoad()
    openMenu.target = self.revealViewController()
    openMenu.action = #selector(SWRevealViewController.revealToggle(_:))
    if revealViewController() != nil {
      openMenu.target = self.revealViewController()
      openMenu.action = #selector(SWRevealViewController.revealToggle(_:))
    }
    buttonTerms.backgroundColor = UIColor.clearColor()
    self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    self.title = "Sobre"
    buttonLink.backgroundColor = UIColor.clearColor()
    let components = CGColorGetComponents(DataManager.sharedInstance.interfaceColor.color.CGColor)
    let colorRose = DataManager.sharedInstance.pinkColor.color
    let colorBlue = DataManager.sharedInstance.blueColor.color
    let colorBlack = DataManager.sharedInstance.interfaceColor.color
    let colorWhite =  ColorRealm(name: 45, red: components[0]+0.1, green: components[1]+0.1, blue: components[2]+0.1, alpha: 1).color
    
    if DataManager.sharedInstance.interfaceColor.color == colorBlue {
      
      self.view.backgroundColor = UIColor(gradientStyle: .TopToBottom, withFrame: self.view.frame, andColors: [colorBlue,colorRose])
      textViewAbout.textColor = UIColor.blackColor()
    } else {
      self.view.backgroundColor = UIColor(gradientStyle: .TopToBottom, withFrame: self.view.frame, andColors: [colorBlack,colorWhite])
      textViewAbout.textColor = UIColor.whiteColor()
    }
  }
  
  @IBAction func textTap(sender: AnyObject) {
    UIApplication.sharedApplication().openURL(NSURL(string: "http://mobilize-se.net.br")!)
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  @IBAction func termsTap(sender: AnyObject) {
    UIApplication.sharedApplication().openURL(NSURL(string: "http://mobilize-se.net.br/mobi/terms.pdf")!)
  }
}
