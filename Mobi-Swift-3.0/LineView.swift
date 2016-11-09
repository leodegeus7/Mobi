//
//  LineView.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/22/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//  Criado por Leonardo de Geus // linkedin.com/leodegeus

import UIKit

class LineView: UIView {

  override func drawRect(rect: CGRect) {
    let topLine = UIBezierPath(rect: CGRectMake(0, 0, self.frame.size.width, 0.5))
    UIColor.grayColor().setStroke()
    topLine.lineWidth = 0.2
    topLine.stroke()
    
    let bottomLine = UIBezierPath(rect: CGRectMake(0, self.frame.size.height - 0.5, self.frame.size.width, 0.5))
    UIColor.lightGrayColor().setStroke()
    bottomLine.lineWidth = 0.2
    bottomLine.stroke()
  }


}
