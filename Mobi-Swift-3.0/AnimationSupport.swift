//
//  AnimationSupport.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 9/2/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class AnimationSupport: NSObject {
  static func shakeTextField(textField:UITextField) {
    let animation = CABasicAnimation(keyPath: "position")
    animation.duration = 0.07
    animation.repeatCount = 4
    animation.autoreverses = true
    animation.fromValue = NSValue(CGPoint: CGPointMake(textField.center.x - 10, textField.center.y))
    animation.toValue = NSValue(CGPoint: CGPointMake(textField.center.x - 10, textField.center.y))
    textField.layer.addAnimation(animation, forKey: "position")
  }
}
