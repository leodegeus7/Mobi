//
//  MiniPlayerViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/22/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//  Criado por Leonardo de Geus // linkedin.com/leodegeus

import UIKit
import ARNTransitionAnimator

class MiniPlayerViewController: UIViewController {
  
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var miniPlayerButton: UIButton!
  @IBOutlet weak var miniPlayerView: LineView!
  @IBOutlet weak var labelFirst: UILabel!
  @IBOutlet weak var labelSecond: UILabel!
  @IBOutlet weak var imageRadio: UIImageView!
  @IBOutlet weak var tabBar: UITabBar!
  @IBOutlet weak var playButton: UIButton!
  
  private var animator : ARNTransitionAnimator!
  private var modalVC : PlayerViewController!
  var notificationCenter = NSNotificationCenter.defaultCenter()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ///////////////////////////////////////////////////////////
    //MARK: --- BASIC CONFIG ---
    ///////////////////////////////////////////////////////////
    DataManager.sharedInstance.miniPlayerView = self
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    self.modalVC = (storyboard.instantiateViewControllerWithIdentifier("ModalViewController") as? PlayerViewController)
    self.modalVC.modalPresentationStyle = .OverFullScreen
    DataManager.sharedInstance.playerClass = modalVC
    let color = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.3)
    self.miniPlayerButton.setBackgroundImage(self.generateImageWithColor(color), forState: .Highlighted)
    self.miniPlayerButton.backgroundColor = UIColor.clearColor()
    labelFirst.text = "Oi"
    notificationCenter.addObserver(self, selector: #selector(MiniPlayerViewController.updatePlayerIcons), name: "updateIcons", object: nil)
    self.setupAnimator()
    self.miniPlayerView.hidden = true
    self.modalVC.tapCloseButtonActionHandler = { [unowned self] in
      self.animator.interactiveType = .None
    }
    playButton.backgroundColor = UIColor.clearColor()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- OTHERS CONFIG ---
  ///////////////////////////////////////////////////////////
  
  @IBAction func tapMiniPlayerButton(sender: AnyObject) {
    
    self.animator.interactiveType = .None
    self.presentViewController(self.modalVC, animated: true, completion: nil)
    
  }
  
  func dismissPlayer() {
    modalVC.dismissViewControllerAnimated(true) {
      
    }
  }
  
  override func viewWillLayoutSubviews() {
        miniPlayerView.alpha = 0.94
  }
  
  func setupAnimator() {
    self.animator = ARNTransitionAnimator(operationType: .Present, fromVC: self, toVC: self.modalVC)
    self.animator.usingSpringWithDamping = 0.8
    self.animator.gestureTargetView = self.miniPlayerView
    self.animator.interactiveType = .Present
    self.animator.presentationBeforeHandler = { [unowned self] containerView, transitionContext in
      self.beginAppearanceTransition(false, animated: false)
      self.animator.direction = .Top
      self.modalVC.view.frame.origin.y = self.miniPlayerView.frame.origin.y + self.miniPlayerView.frame.size.height
      self.view.insertSubview(self.modalVC.view, belowSubview: self.tabBar)
      //self.view.insertSubview(self.modalVC.view, atIndex: 0)
      self.view.layoutIfNeeded()
      self.modalVC.view.layoutIfNeeded()
      // miniPlayerView
      let startOriginY = self.miniPlayerView.frame.origin.y
      let endOriginY = -self.miniPlayerView.frame.size.height
      let diff = -endOriginY + startOriginY
      // tabBar
      let tabStartOriginY = self.tabBar.frame.origin.y
      let tabEndOriginY = containerView.frame.size.height
      let tabDiff = tabEndOriginY - tabStartOriginY
      self.animator.presentationCancelAnimationHandler = { containerView in
        self.miniPlayerView.frame.origin.y = startOriginY
        self.modalVC.view.frame.origin.y = self.miniPlayerView.frame.origin.y + self.miniPlayerView.frame.size.height
        self.tabBar.frame.origin.y = tabStartOriginY
        self.containerView.alpha = 1.0
        self.tabBar.alpha = 1.0
        self.miniPlayerView.alpha = 1.0
        for subview in self.miniPlayerView.subviews {
          subview.alpha = 1.0
        }
      }
      self.animator.presentationAnimationHandler = { [unowned self] containerView, percentComplete in
        let _percentComplete = percentComplete >= 0 ? percentComplete : 0
        self.miniPlayerView.frame.origin.y = startOriginY - (diff * _percentComplete)
        if self.miniPlayerView.frame.origin.y < endOriginY {
          self.miniPlayerView.frame.origin.y = endOriginY
        }
        self.modalVC.view.frame.origin.y = self.miniPlayerView.frame.origin.y + self.miniPlayerView.frame.size.height
        self.tabBar.frame.origin.y = tabStartOriginY + (tabDiff * _percentComplete)
        if self.tabBar.frame.origin.y > tabEndOriginY {
          self.tabBar.frame.origin.y = tabEndOriginY
        }
        let alpha = 1.0 - (1.0 * _percentComplete)
        self.containerView.alpha = alpha + 0.5
        self.tabBar.alpha = alpha
        for subview in self.miniPlayerView.subviews {
          subview.alpha = alpha
        }
      }
      self.animator.presentationCompletionHandler = { containerView, completeTransition in
        self.endAppearanceTransition()
        if completeTransition {
          self.miniPlayerView.alpha = 0.0
          //self.modalVC.view.removeFromSuperview()
          containerView.addSubview(self.modalVC.view)
          self.animator.interactiveType = .Dismiss
          self.animator.gestureTargetView = self.modalVC.view
          self.animator.direction = .Bottom
        } else {
          self.beginAppearanceTransition(true, animated: false)
          self.endAppearanceTransition()
        }
      }
    }
    // Dismiss
    self.animator.dismissalBeforeHandler = { [unowned self] containerView, transitionContext in
      self.beginAppearanceTransition(true, animated: false)
      self.view.insertSubview(self.modalVC.view, belowSubview: self.tabBar)
      self.view.layoutIfNeeded()
      self.modalVC.view.layoutIfNeeded()
      // miniPlayerView
      let startOriginY = 0 - self.miniPlayerView.bounds.size.height
      let endOriginY = self.containerView.bounds.size.height - self.tabBar.bounds.size.height - self.miniPlayerView.frame.size.height
      let diff = -startOriginY + endOriginY
      // tabBar
      let tabStartOriginY = containerView.bounds.size.height
      let tabEndOriginY = containerView.bounds.size.height - self.tabBar.bounds.size.height
      let tabDiff = tabStartOriginY - tabEndOriginY
      self.tabBar.frame.origin.y = containerView.bounds.size.height
      self.containerView.alpha = 0.5
      self.animator.dismissalCancelAnimationHandler = { containerView in
        self.miniPlayerView.frame.origin.y = startOriginY
        self.modalVC.view.frame.origin.y = self.miniPlayerView.frame.origin.y + self.miniPlayerView.frame.size.height
        self.tabBar.frame.origin.y = tabStartOriginY
        self.containerView.alpha = 0.5
        self.tabBar.alpha = 0.0
        self.miniPlayerView.alpha = 0.0
        for subview in self.miniPlayerView.subviews {
          subview.alpha = 0.0
        }
      }
      self.animator.dismissalAnimationHandler = { containerView, percentComplete in
        let _percentComplete = percentComplete >= -0.05 ? percentComplete : -0.05
        self.miniPlayerView.frame.origin.y = startOriginY + (diff * _percentComplete)
        self.modalVC.view.frame.origin.y = self.miniPlayerView.frame.origin.y + self.miniPlayerView.frame.size.height
        self.tabBar.frame.origin.y = tabStartOriginY - (tabDiff *  _percentComplete)
        
        let alpha = 1.0 * _percentComplete
        self.containerView.alpha = alpha + 0.5
        self.tabBar.alpha = alpha
        self.miniPlayerView.alpha = 1.0
        for subview in self.miniPlayerView.subviews {
          subview.alpha = alpha
        }
      }
      self.animator.dismissalCompletionHandler = { containerView, completeTransition in
        self.endAppearanceTransition()
        
        if completeTransition {
          //self.modalVC.view.removeFromSuperview()
          self.animator.gestureTargetView = self.miniPlayerView
          self.animator.interactiveType = .Present
        } else {
          //self.modalVC.view.removeFromSuperview()
          containerView.addSubview(self.modalVC.view)
          self.beginAppearanceTransition(false, animated: false)
          self.endAppearanceTransition()
        }
      }
    }
    
    self.modalVC.transitioningDelegate = self.animator
  }
  
  func hidePlayer() {
    self.endAppearanceTransition()
  }
  
  private func generateImageWithColor(color: UIColor) -> UIImage {
    let rect = CGRectMake(0, 0, 1, 1)
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    CGContextSetFillColorWithColor(context, color.CGColor)
    CGContextFillRect(context, rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }
  
  func updatePlayerIcons() {
    miniPlayerView.alpha = 0.94
    labelFirst.text = StreamingRadioManager.sharedInstance.actualRadio.name
    if let _ = StreamingRadioManager.sharedInstance.actualRadio.address {
      labelSecond.text = StreamingRadioManager.sharedInstance.actualRadio.address.formattedLocal
    }
    imageRadio.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(StreamingRadioManager.sharedInstance.actualRadio.thumbnail)))
    
    imageRadio.layer.cornerRadius = imageRadio.bounds.height / 6
    imageRadio.layer.borderColor = DataManager.sharedInstance.interfaceColor.color.CGColor
    imageRadio.layer.backgroundColor = UIColor.whiteColor().CGColor
    imageRadio.layer.borderWidth = 1
    labelFirst.textColor = UIColor.whiteColor()
    labelSecond.textColor = UIColor.whiteColor()
    if StreamingRadioManager.sharedInstance.currentlyPlaying() {
      playButton.setImage(UIImage(named: "StopButton@2x.png"), forState: .Normal)
    } else {
      playButton.setImage(UIImage(named: "PlayButton@2x.png"), forState: .Normal)
    }
    let components = CGColorGetComponents(DataManager.sharedInstance.interfaceColor.color.CGColor)
    let colorWhite =  ColorRealm(name: 45, red: components[0]+0.05, green: components[1]+0.05, blue: components[2]+0.05, alpha: 1).color
    miniPlayerView.backgroundColor = colorWhite
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- IBACTIONS ---
  ///////////////////////////////////////////////////////////
  
  @IBAction func buttonPlayTap(sender: AnyObject) {
    modalVC.buttonPlayTapped(self)
    StreamingRadioManager.sharedInstance.sendNotification()
    updatePlayerIcons()
  }
}