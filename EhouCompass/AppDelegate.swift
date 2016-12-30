//
//  AppDelegate.swift
//  EhouCompass
//
//  Created by 千葉 俊輝 on 2016/01/14.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        NADInterstitial.sharedInstance().loadAd(withApiKey: "b74a6b1080d9e02c05ffee0c3079bb20344a569a", spotId: "514837")
        InterstitialController.shared.reload()
        ADCheckManager.shared.reload()
        //Meyasubaco.setApiKey("a65df6c2beb11dad68b074a6aedab4ecaa837fefa0791f967f445716a23039a1")
        FIRApp.configure()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if ADCheckManager.shared.isAdMob {
            InterstitialController.shared.show(fromViewController: UIApplication.shared.keyWindow?.rootViewController)
        } else {
            NADInterstitial.sharedInstance().showAd(from: UIApplication.shared.keyWindow?.rootViewController)
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {}
}

