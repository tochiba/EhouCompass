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
    var now = Date()
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPushShareButton(_ sender: AnyObject) {
        ActivityManager().showActivityView(self)
    }
    
    fileprivate func getEhouAngle() -> HitAngle {
        var yearNumber: Int = 999 // Error
        
        let date = Date()
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let comps: DateComponents = (calendar as NSCalendar).components(NSCalendar.Unit.year, from: date)
        yearNumber = comps.year!
        
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
    
    fileprivate func getAngle(_ year: Int) -> Int {
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
    
    fileprivate func setupLocationManager() {
        if CLLocationManager.headingAvailable() {
            self.locationManager.delegate = self
            self.locationManager.headingFilter = kCLHeadingFilterNone
            self.locationManager.headingOrientation = CLDeviceOrientation.portrait
            self.locationManager.startUpdatingHeading()
        }
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        if let _hitAngle = self.checkAngle {
            let heading = newHeading.magneticHeading
            
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.5)
            self.baseView.transform = CGAffineTransform(rotationAngle: CGFloat(-(M_PI * (heading / 165))))
            self.saraView.transform = CGAffineTransform(rotationAngle: CGFloat(-(M_PI * (heading / 165))))
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
        self.view.backgroundColor = UIColor.white
    }
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    fileprivate func showLight(_ on: Bool) {
        if let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) {
            do {
                try device.lockForConfiguration()
                
            }
            catch _ {
                return
            }
            
            if device.hasTorch {
                if on == false {
                    device.torchMode = AVCaptureTorchMode.off
                }
                else {
                    if device.torchMode == AVCaptureTorchMode.off {
                        device.torchMode = AVCaptureTorchMode.on
                    }
                    else {
                        device.torchMode = AVCaptureTorchMode.off
                    }
                }
            }
            device.unlockForConfiguration()
        }
    }
    
    // MARK: SpriteKit
    func showParticle(_ start: Bool) {
        
        if start == false {
            self.skView.isHidden = true
            return
        }
        
        self.skView.isHidden = false
        
        if self.skView.scene != nil {
            return
        }
        
        if let scene = SpriteScene.unarchiveFromFile("SpriteScene") as? SpriteScene {
            if scene.children.count == 0 {
                self.skView.isUserInteractionEnabled = false
                self.skView.allowsTransparency = true
                scene.backgroundColor = UIColor.clear
                scene.scaleMode = SKSceneScaleMode.aspectFill
                self.skView.presentScene(scene)
                
            }
        }
    }
}

class SpriteScene: SKScene {
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor.clear
        
        if self.children.count == 0 {
            if let path = Bundle.main.path(forResource: "SparkParticle", ofType: "sks") {
                if let particle = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? SKEmitterNode {
                    particle.position = CGPoint(x: self.frame.midX, y: self.frame.midX)
                    self.addChild(particle)
                }
            }
        }
    }
    
    class func unarchiveFromFile(_ file: String) -> AnyObject? {
        if let nodePath = Bundle.main.path(forResource: file, ofType: "sks") {
            var data: Data = Data()
            do {
                data = try Data(contentsOf: URL(fileURLWithPath: nodePath), options: NSData.ReadingOptions.mappedIfSafe)
            }
            catch _ {
            }
            
            let arch = NSKeyedUnarchiver(forReadingWith: data)
            arch.setClass(self, forClassName: "SKScene")
            
            let scene = arch.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? SKScene
            arch.finishDecoding()
            
            return scene
        }
        return nil
    }
}

import Accounts

class ActivityManager: NSObject {
    
    func getActivityVC(_ vc: ViewController?) -> UIActivityViewController {
        var yearStr = "今年の"
        var angleStr = ""
        var aa = ""
        let hash = "#恵方こっち #恵方🍣"
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let date = Date()
        let comps: DateComponents = (calendar as NSCalendar).components(NSCalendar.Unit.year, from: date)
        yearStr = String(describing: comps.year) + "年"
        angleStr = getAngleString(comps.year!) + "\n"
        
        let aaangle = (angleStr as NSString).substring(to: 3)
        aa =
            //"ﾊﾞｸﾊﾞｸﾑｼｬﾑｼｬ\n" +
            "　＿＿＿＿　＿_∧_∧\n" +
            "`｜\(aaangle)｜(三(ﾟ　　)\n" +
            "　￣ＴＴ￣　￣し　　)\n" +
            "　　｜｜　　　｜ ○｜\n" +
        "　　ﾞﾞﾞﾞ　　　 (＿|＿)\n"
        
        
        // 共有する項目
        let shareText = yearStr + "恵方は" + angleStr + aa + hash
        let shareWebsite = URL(string: "https://itunes.apple.com/us/app/ehou/id1075817264?l=ja&ls=1&mt=8")!
        
        var activityItems = [shareText, shareWebsite] as [Any]
        if let shareImage = vc?.shareView.getImage() {
            activityItems.append(shareImage)
        }
        
        // 初期化処理
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = vc?.view
        
        // 使用しないアクティビティタイプ
        let excludedActivityTypes = [
            UIActivityType.saveToCameraRoll,
            UIActivityType.print
        ]
        
        activityVC.excludedActivityTypes = excludedActivityTypes
        let completionHandler:UIActivityViewControllerCompletionWithItemsHandler = { (str, isFinish, arr, error) in
            NADInterstitial.sharedInstance().showAd()
        }
        activityVC.completionWithItemsHandler = completionHandler
        return activityVC
    }
    
    
    fileprivate func getAngleString(_ year: Int) -> String {
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
    
    func showActivityView(_ viewController: ViewController) {
        weak var vc = viewController
        vc?.present(getActivityVC(vc), animated: true, completion: nil)
    }
}

extension UIView {
    
    func getImage() -> UIImage {
        
        // キャプチャする範囲を取得.
        let rect = self.bounds
        
        // ビットマップ画像のcontextを作成.
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        if let context: CGContext = UIGraphicsGetCurrentContext() {
            
            // 対象のview内の描画をcontextに複写する.
            self.layer.render(in: context)
            
            // 現在のcontextのビットマップをUIImageとして取得.
            let capturedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            
            // contextを閉じる.
            UIGraphicsEndImageContext()
            
            return capturedImage
        }
        return UIImage()
    }
}
