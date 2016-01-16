//
//  ViewController.swift
//  EhouCompass
//
//  Created by 千葉 俊輝 on 2016/01/14.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import UIKit
import CoreLocation
import SpriteKit
import AudioToolbox
import AVFoundation

struct HitAngle {
    var leftAngle: Int
    var rightAngle: Int
}

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var checkAngle: HitAngle?
    var now = NSDate()
    
    @IBOutlet weak var nadView: NADView!
    @IBOutlet weak var nadTopView: NADView!
    @IBOutlet weak var saraView: UIImageView!
    @IBOutlet weak var baseView: UIImageView!
    @IBOutlet weak var rollView: UIImageView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.checkAngle = getEhouAngle()
        setupLocationManager()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //Meyasubaco.showCommentViewController(self)
        //ActivityManager().showActivityView(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPushShareButton(sender: AnyObject) {
        ActivityManager().showActivityView(self)
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
            self.baseView.image = UIImage(named: "a")
            break
        case 0,5:
            _angle = 255
            self.baseView.image = UIImage(named: "c")
            break
        case 1,6,3,8:
            _angle = 165
            self.baseView.image = UIImage(named: "d")
            break
        case 2,7:
            _angle = 345
            self.baseView.image = UIImage(named: "b")
            break
        default:
            self.baseView.image = UIImage(named: "non")
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
        
            if let _hitAngle = self.checkAngle {
            let heading = newHeading.magneticHeading
            
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.5)
            //            self.rollView.transform = CGAffineTransformMakeRotation(CGFloat(-(M_PI * (heading / 180))))
            self.baseView.transform = CGAffineTransformMakeRotation(CGFloat(-(M_PI * (heading / 165))))
            self.saraView.transform = CGAffineTransformMakeRotation(CGFloat(-(M_PI * (heading / 165))))
            UIView.commitAnimations()
            
            if Double(_hitAngle.leftAngle) < heading && heading < Double(_hitAngle.rightAngle) {
                showLight(true)
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                showParticle(true)
                return
            }
        }
        
        showLight(false)
        showParticle(false)
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    func locationManagerShouldDisplayHeadingCalibration(manager: CLLocationManager) -> Bool {
        return true
    }
    
    private func showLight(on: Bool) {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do {
            try device.lockForConfiguration()
            
        }
        catch _ {
            return
        }
        
        if on == false {
            device.torchMode = AVCaptureTorchMode.Off
        }
        else {
            if device.torchMode == AVCaptureTorchMode.Off {
                device.torchMode = AVCaptureTorchMode.On
            }
            else {
                device.torchMode = AVCaptureTorchMode.Off
            }
        }
        
        device.unlockForConfiguration()
        
    }
    
    // MARK: SpriteKit
    func showParticle(start: Bool) {
        
        if start == false {
            self.skView.hidden = true
            return
        }
        
        self.skView.hidden = false
        
        if self.skView.scene != nil {
            return
        }
        
        //self.skView.hidden = false
        //if NSDate().timeIntervalSinceDate(self.now) > Double(2) {
            if let scene = SpriteScene.unarchiveFromFile("SpriteScene") as? SpriteScene {
                if scene.children.count == 0 {
                    self.skView.userInteractionEnabled = false
                    self.skView.allowsTransparency = true
                    scene.backgroundColor = UIColor.clearColor()
                    scene.scaleMode = SKSceneScaleMode.AspectFill
                    self.skView.presentScene(scene)
                    
                    //self.now = NSDate()
                }
            }
        //}
        
    }
}

class SpriteScene: SKScene {
    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor.clearColor()
        
        if self.children.count == 0 {
            if let path = NSBundle.mainBundle().pathForResource("SparkParticle", ofType: "sks") {
                if let particle = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? SKEmitterNode {
                    particle.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidX(self.frame))
                    
//                    let scale = SKAction.scaleTo(2.0, duration: 2)
//                    let fadeout = SKAction.fadeOutWithDuration(2)
//                    let remove = SKAction.removeFromParent()
//                    let sequence = SKAction.sequence([scale, fadeout, remove])
//                    particle.runAction(sequence)
                    
                    self.addChild(particle)
                }
            }
        }
    }
    
    class func unarchiveFromFile(file: String) -> AnyObject? {
        if let nodePath = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var data: NSData = NSData()
            do {
                data = try NSData(contentsOfFile: nodePath, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            }
            catch _ {
            }
            
            let arch = NSKeyedUnarchiver(forReadingWithData: data)
            arch.setClass(self, forClassName: "SKScene")
            
            let scene = arch.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as? SKScene
            arch.finishDecoding()
            
            return scene
        }
        return nil
    }
}

import Accounts

class ActivityManager: NSObject {
    
    func getActivityVC(vc: ViewController?) -> UIActivityViewController {
        var yearStr = "今年の"
        var angleStr = ""
        var aa = ""
        let hash = "#恵方こっち #恵方🍣"
        if let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian) {
            let date = NSDate()
            let comps: NSDateComponents = calendar.components(NSCalendarUnit.Year, fromDate: date)
            yearStr = String(comps.year) + "年"
            angleStr = getAngleString(comps.year) + "\n"
            
            let aaangle = (angleStr as NSString).substringToIndex(3)
            aa =
            //"ﾊﾞｸﾊﾞｸﾑｼｬﾑｼｬ\n" +
            "　＿＿＿＿　＿_∧_∧\n" +
            "`｜\(aaangle)｜(三(ﾟ　　)\n" +
            "　￣ＴＴ￣　￣し　　)\n" +
            "　　｜｜　　　｜ ○｜\n" +
            "　　ﾞﾞﾞﾞ　　　 (＿|＿)\n"
        }
        
        // 共有する項目
        let shareText = yearStr + "恵方は" + angleStr + aa + hash
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
        let completionHandler:UIActivityViewControllerCompletionWithItemsHandler = { (str, isFinish, arr, error) in
            NADInterstitial.sharedInstance().showAd()
        }
        activityVC.completionWithItemsHandler = completionHandler
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