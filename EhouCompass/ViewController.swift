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
import GoogleMobileAds


class ViewController: UIViewController {
    
    @IBOutlet weak var nadView: NADView!
    @IBOutlet weak var nadTopView: NADView!
    
    @IBOutlet weak var gadTopBannerView: GADBannerView!
    @IBOutlet weak var gadUnderBannerView: GADBannerView!
    
    @IBOutlet weak var saraView: UIImageView!
    @IBOutlet weak var baseView: UIImageView!
    @IBOutlet weak var rollView: UIImageView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var skView: SKView!
    
    @IBAction func didPushShareButton(_ sender: AnyObject) {
        ActivityViewController().show(self)
    }
    
    struct HitAngle {
        var leftAngle: Int
        var rightAngle: Int
    }
    
    private let locationManager = CLLocationManager()
    
    fileprivate var checkAngle: HitAngle? {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let comps: DateComponents = (calendar as NSCalendar).components(NSCalendar.Unit.year, from: Date())
        
        guard let yearNumber = comps.year, let angle = getAngle(yearNumber) else {
            // Error
            return HitAngle.init(leftAngle: 0, rightAngle: 0)
        }
        return HitAngle.init(leftAngle: angle - 5, rightAngle: angle + 5)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundColor()
        setupAD()
        setupLocationManager()
    }
    
    private func setupAD() {
        let request = GADRequest()
        
        gadTopBannerView.adUnitID = "ca-app-pub-6250716823416917/4507042380"
        gadTopBannerView.rootViewController = self
        gadTopBannerView.load(request)
        
        gadUnderBannerView.adUnitID = "ca-app-pub-6250716823416917/4764394386"
        gadUnderBannerView.rootViewController = self
        gadUnderBannerView.load(request)
        
        nadView.isHidden = ADCheckManager.shared.isAdMob
        nadTopView.isHidden = ADCheckManager.shared.isAdMob
    }
    
    private func setupLocationManager() {
        if CLLocationManager.headingAvailable() {
            self.locationManager.delegate = self
            self.locationManager.headingFilter = kCLHeadingFilterNone
            self.locationManager.headingOrientation = CLDeviceOrientation.portrait
            self.locationManager.startUpdatingHeading()
        }
    }

    private func getAngle(_ year: Int) -> Int? {
        let number = year % 10
        var angle: Int?
        switch number {
        case 4,9:
            angle = 70
            self.baseView.image = UIImage(named: "a")
            break
        case 0,5:
            angle = 250
            self.baseView.image = UIImage(named: "c")
            break
        case 1,6,3,8:
            angle = 160
            self.baseView.image = UIImage(named: "d")
            break
        case 2,7:
            angle = 340
            self.baseView.image = UIImage(named: "b")
            break
        default:
            self.baseView.image = UIImage(named: "non")
            break
        }
        return angle
    }
    
    
    fileprivate func showLight(on: Bool) {
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
    
    fileprivate func showParticle(start: Bool) {
        
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
    
    fileprivate func setBackgroundColor() {
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "icon-bg")!)
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        if let _hitAngle = self.checkAngle {
            let heading = newHeading.magneticHeading
            
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.5)
            self.baseView.transform = CGAffineTransform(rotationAngle: CGFloat(-(M_PI * (heading / 165))))
            self.saraView.transform = CGAffineTransform(rotationAngle: CGFloat(-(M_PI * (heading / 165))))
            UIView.commitAnimations()
            
            let bunkiAngle = abs((_hitAngle.leftAngle + 5) - 165)
            if Double(_hitAngle.leftAngle) < heading && heading < Double(_hitAngle.rightAngle) {
                SpeechController.shared.speech(type: .ehou)
                showLight(on: true)
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                showParticle(start: true)
                return
            }
            else if Double(bunkiAngle) < heading {
                SpeechController.shared.speech(type: .right)
            } else {
                SpeechController.shared.speech(type: .left)
            }
            
        }
        
//        SpeechController.shared.speech(type: .stop)
        showLight(on: false)
        showParticle(start: false)
        setBackgroundColor()
//        self.view.backgroundColor = UIColor.white
    }
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
}
