//
//  LineView.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/22/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//  Criado por Leonardo de Geus // linkedin.com/leodegeus

import UIKit

class LineView: UIView {

  override func draw(_ rect: CGRect) {
    let topLine = UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 0.5))
    UIColor.gray.setStroke()
    topLine.lineWidth = 0.2
    topLine.stroke()
    
    let bottomLine = UIBezierPath(rect: CGRect(x: 0, y: self.frame.size.height - 0.5, width: self.frame.size.width, height: 0.5))
    UIColor.lightGray.setStroke()
    bottomLine.lineWidth = 0.2
    bottomLine.stroke()
  }


}
