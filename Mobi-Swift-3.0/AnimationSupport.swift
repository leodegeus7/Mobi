//
//  AnimationSupport.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 9/2/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class AnimationSupport: NSObject {
  static func shakeTextField(_ textField:UITextField) {
    let animation = CABasicAnimation(keyPath: "position")
    animation.duration = 0.07
    animation.repeatCount = 4
    animation.autoreverses = true
    animation.fromValue = NSValue(cgPoint: CGPoint(x: textField.center.x - 10, y: textField.center.y))
    animation.toValue = NSValue(cgPoint: CGPoint(x: textField.center.x - 10, y: textField.center.y))
    textField.layer.add(animation, forKey: "position")
  }
}
