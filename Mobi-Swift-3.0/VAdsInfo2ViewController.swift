//
//  AdsInfo2ViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 2/9/17.
//  Copyright © 2017 Access Mobile. All rights reserved.
//

import UIKit
import MapKit

class VAdsInfo2ViewController: UIViewController, MKMapViewDelegate {
  
  @IBOutlet weak var viewMap: MKMapView!
  
  var initialCoordinate:CLLocation!
  var adsInfo:[AdsInfo]!
  var local:[LocalVAds]!
  var titleVar = ""
  override func viewDidLoad() {
    super.viewDidLoad()
    if initialCoordinate == nil {
      initialCoordinate = CLLocation(latitude: Double(adsInfo.first!.la)!, longitude: Double(adsInfo.first!.lo)!)
    }
    viewMap.delegate = self
    putMarker()
    self.title = titleVar
    center(initialCoordinate)
    if let _ = local {
      self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: #selector(VAdsInfo2ViewController.goView))
    }
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  let regionRadious:CLLocationDistance = 300
  
  func center(location:CLLocation) {
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadious * 2.0, regionRadious * 2.0)
    viewMap.setRegion(coordinateRegion, animated: true)
  }
  
  func goView() {
    self.performSegueWithIdentifier("show", sender: self)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "show" {
      let createVC = (segue.destinationViewController as! VAdsInfo3TableViewController)
      createVC.local = local
      createVC.viewBack = self
    }
  }
  
  func putMarker() {
    if let local = local {
      for localU in local {
        if localU.long != "" && localU.lat != "" {
          let coord = CLLocationCoordinate2D(latitude: Double(localU.lat)!, longitude: Double(localU.long)!)
          let anno = Artwork(title: "\(Util.getOverdueInterval(Util.convertStringToNSDate(localU.date)))", locationName: localU.date, discipline: "", coordinate: coord)
          viewMap.addAnnotation(anno)
          
        }
      }
    } else {
      for adInfo in adsInfo {
        if adInfo.lo != "" && adInfo.la != "" {
          let coord = CLLocationCoordinate2D(latitude: Double(adInfo.la)!, longitude: Double(adInfo.lo)!)
          let anno = Artwork(title: "\(adInfo.server) - \(adInfo.name))", locationName: Util.getOverdueInterval(Util.convertStringToNSDate(adInfo.lastCoordUpdate)), discipline: adInfo.lastCoordUpdate, coordinate: coord)
          viewMap.addAnnotation(anno)
        }
      }
    }
  }
  
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    if let annotation = annotation as? Artwork {
      let identifier = "pin"
      var view: MKPinAnnotationView
      if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        as? MKPinAnnotationView { // 2
        dequeuedView.annotation = annotation
        view = dequeuedView
      } else {
        // 3
        view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        view.canShowCallout = true
        view.calloutOffset = CGPoint(x: -5, y: 5)
        view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
      }
      return view
    }
    return nil
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
