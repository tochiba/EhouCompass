//
//  ActivityViewController.swift
//  EhouCompass
//
//  Created by Toshiki Chiba on 2016/12/30.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Accounts

final class ActivityViewController {
    
    private func getActivityVC(_ vc: ViewController?) -> UIActivityViewController {
        var yearStr = "今年の"
        var angleStr = ""
        var aa = ""
        let hash = "#恵方こっち #恵方🍣"
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let comps: DateComponents = (calendar as NSCalendar).components(NSCalendar.Unit.year, from: Date())
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
            if ADCheckManager.shared.isAdMob {
                InterstitialController.shared.show(fromViewController: vc)
            } else {
                NADInterstitial.sharedInstance().showAd(from: vc)
            }
            
        }
        activityVC.completionWithItemsHandler = completionHandler
        return activityVC
    }
    
    private func getAngleString(_ year: Int) -> String {
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
    
    func show(_ viewController: ViewController) {
        weak var vc = viewController
        vc?.present(getActivityVC(vc), animated: true, completion: nil)
    }
}

fileprivate extension UIView {
    func getImage() -> UIImage {
        let rect = self.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        if let context: CGContext = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            let capturedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return capturedImage
        }
        return UIImage()
    }
}


