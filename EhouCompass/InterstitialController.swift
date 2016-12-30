//
//  InterstitialController.swift
//  EhouCompass
//
//  Created by Toshiki Chiba on 2016/12/30.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import GoogleMobileAds

final class InterstitialController: NSObject {
    static let shared = InterstitialController()
    private var interstitial: GADInterstitial
    
    override init() {
        interstitial = InterstitialController.createInterstitial()
    }
    
    func reload() {
        interstitial = InterstitialController.createInterstitial()
    }
    
    func show(fromViewController viewController: UIViewController?) {
        guard let viewController = viewController else {
            return
        }
        weak var vc = viewController
        interstitial.delegate = self
        interstitial.present(fromRootViewController: vc!)
    }
    
    
    private class func createInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-6250716823416917/3030309189")
        let request = GADRequest()
        interstitial.load(request)
        return interstitial
    }
}

extension InterstitialController: GADInterstitialDelegate {
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        reload()
    }
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        reload()
    }
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        reload()
    }
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        reload()
    }
}
