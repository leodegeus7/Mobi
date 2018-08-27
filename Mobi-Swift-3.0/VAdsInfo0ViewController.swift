//
//  AdsInfo0ViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 2/9/17.
//  Copyright © 2017 Access Mobile. All rights reserved.
//

import UIKit

class VAdsInfo0ViewController: UIViewController {

  @IBOutlet weak var testLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
      let request = RequestManager()
      request.testApp { (result) in
        if result {
          self.testLabel.text = "This is a only a test"
          let timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(VAdsInfo0ViewController.segue), userInfo: nil, repeats: false)
        }
      }
      
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func segue() {
    self.performSegue(withIdentifier: "show", sender: self)
  }
  
  override func viewDidAppear(_ animated: Bool) {
            self.navigationController?.setToolbarHidden(true, animated: true)
  }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
