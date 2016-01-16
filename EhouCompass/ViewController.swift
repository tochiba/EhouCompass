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
    @IBOutlet weak var nadTopView: NADView!
    @IBOutlet weak var baseView: UIImageView!
    @IBOutlet weak var rollView: UIImageView!
    @IBOutlet weak var shareView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.checkAngle = getEhouAngle()
        setupLocationManager()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //Meyasubaco.showCommentViewController(self)
        ActivityManager().showActivityView(self)
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
        
        let angle = getAngle(yearNumber)
        
        // Error
        if angle == 0 {
            return HitAngle.init(leftAngle: 0, rightAngle: 0)
        }
        
        return HitAngle.init(leftAngle: angle - 5, rightAngle: angle + 5)
    }
    
    private func getAngle(year: Int) -> Int {
        let number = year % 10
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
            
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.5)
            //            self.rollView.transform = CGAffineTransformMakeRotation(CGFloat(-(M_PI * (heading / 180))))
            self.baseView.transform = CGAffineTransformMakeRotation(CGFloat(-(M_PI * (heading / 180))))
            UIView.commitAnimations()
            
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

import Accounts

class ActivityManager: NSObject {
    
    func getActivityVC(vc: ViewController?) -> UIActivityViewController {
        var yearStr = "今年の"
        var angleStr = ""
        var aa = ""
        if let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian) {
            let date = NSDate()
            let comps: NSDateComponents = calendar.components(NSCalendarUnit.Year, fromDate: date)
            yearStr = String(comps.year) + "年の"
            angleStr = getAngleString(comps.year) + "\n"
            
            let aaangle = (angleStr as NSString).substringToIndex(3)
            aa =
            "ﾊﾞｸﾊﾞｸﾑｼｬﾑｼｬ\n" +
            "　＿＿＿＿　＿_∧_∧\n" +
            "`｜\(aaangle)｜(三(ﾟ　　)\n" +
            "　￣ＴＴ￣　￣し　　)\n" +
            "　　｜｜　　　｜ ○｜\n" +
            "　　ﾞﾞﾞﾞ　　　(＿|＿)\n"
        }
        
        // 共有する項目
        let shareText = yearStr + "恵方は" + angleStr + aa
        let shareWebsite = NSURL(string: "https://itunes.apple.com/us/app/ehou/id1075817264?l=ja&ls=1&mt=8")!

        var activityItems = [shareText, shareWebsite]
        if let shareImage = vc?.shareView.getImage() {
            activityItems.append(shareImage)
        }
        
        // 初期化処理
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = vc?.view
        
        // 使用しないアクティビティタイプ
        let excludedActivityTypes = [
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypePrint
        ]
        
        activityVC.excludedActivityTypes = excludedActivityTypes
        return activityVC
    }
    
    
    private func getAngleString(year: Int) -> String {
        let number = year % 10
        var _angle = ""
        switch number {
        case 4,9:
            _angle = "東北東やや東"
            break
        case 0,5:
            _angle = "西南西やや西"
            break
        case 1,6,3,8:
            _angle = "南南東やや南"
            break
        case 2,7:
            _angle = "北北西やや北"
            break
        default:
            break
        }
        return _angle
    }
    
    func showActivityView(viewController: ViewController) {
        weak var vc = viewController
        vc?.presentViewController(getActivityVC(vc), animated: true, completion: nil)
    }
}

extension UIView {
    
    func getImage() -> UIImage {
        
        // キャプチャする範囲を取得.
        let rect = self.bounds
        
        // ビットマップ画像のcontextを作成.
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        if let context: CGContextRef = UIGraphicsGetCurrentContext() {
            
            // 対象のview内の描画をcontextに複写する.
            self.layer.renderInContext(context)
            
            // 現在のcontextのビットマップをUIImageとして取得.
            let capturedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
            
            // contextを閉じる.
            UIGraphicsEndImageContext()
            
            return capturedImage
        }
        return UIImage()
    }
}