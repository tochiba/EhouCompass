//
//  ViewController.swift
//  EhouCompass
//
//  Created by 千葉 俊輝 on 2016/01/14.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import UIKit
import CoreLocation

struct HitAngle {
    var leftAngle: Int
    var rightAngle: Int
}

class ViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    var checkAngle: HitAngle?
    
    @IBOutlet weak var nadView: NADView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.checkAngle = getEhouAngle()
        setupLocationManager()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func getEhouAngle() -> HitAngle {
        var yearNumber: Int = 999 // Error
        
        let date = NSDate()
        if let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian) {
            let comps: NSDateComponents = calendar.components(NSCalendarUnit.Year, fromDate: date)
            yearNumber = comps.year
        }
        
        // Error
        if yearNumber == 999 {
            return HitAngle.init(leftAngle: yearNumber, rightAngle: yearNumber)
        }
        
        let number = yearNumber % 10
        let angle = getAngle(number)
        return HitAngle.init(leftAngle: angle - 5, rightAngle: angle + 5)
    }
    
    private func getAngle(number: Int) -> Int {
        var _angle: Int = 0
        switch number {
        case 4,9:
            _angle = 75
            break
        case 0,5:
            _angle = 255
            break
        case 1,6,3,8:
            _angle = 165
            break
        case 2,7:
            _angle = 345
            break
        default:
            break
        }
        return _angle
    }
    
    private func setupLocationManager() {
        if CLLocationManager.headingAvailable() {
            self.locationManager.delegate = self
            self.locationManager.headingFilter = kCLHeadingFilterNone
            self.locationManager.headingOrientation = CLDeviceOrientation.Portrait
            self.locationManager.startUpdatingHeading()
        }
    }

    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        //print(heading)
        if let _hitAngle = self.checkAngle {
            let heading = newHeading.magneticHeading
            if Double(_hitAngle.leftAngle) < heading && heading < Double(_hitAngle.rightAngle) {
                print("HIT!! \n")
                print(heading)
                print("\n")
                self.view.backgroundColor = UIColor.redColor()
                return
            }
        }

        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    func locationManagerShouldDisplayHeadingCalibration(manager: CLLocationManager) -> Bool {
        return true
    }
}

