//: Playground - noun: a place where people can play

import UIKit


let dateFormatter = NSDateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'.000'Z"
let now = dateFormatter.stringFromDate(NSDate())