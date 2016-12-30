//
//  ADCheckManager.swift
//  EhouCompass
//
//  Created by Toshiki Chiba on 2016/12/30.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import SwiftyJSON

final class ADCheckManager {
    static let shared = ADCheckManager()
    
    var isAdMob: Bool = false
    
    init() {
        isAdMob = ADCheckManager.neededAdMob()
    }
    
    func reload() {
        isAdMob = ADCheckManager.neededAdMob()
    }

    private class func neededAdMob() -> Bool {
        //https://raw.githubusercontent.com/tochiba/EhouCompass/master/config.json
        let urlStr = "https://raw.githubusercontent.com/tochiba/EhouCompass/master/config.json"
        if let url = URL(string: urlStr) {
            if let data = try? Data(contentsOf: url) {
                let json = JSON(data: data)
                return json["IsAdMob"].boolValue
            }
        }
        return false
    }
}
