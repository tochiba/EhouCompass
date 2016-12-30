//
//  SpriteScene.swift
//  EhouCompass
//
//  Created by Toshiki Chiba on 2016/12/30.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//
import SpriteKit

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
            catch _ {}
            
            let arch = NSKeyedUnarchiver(forReadingWith: data)
            arch.setClass(self, forClassName: "SKScene")
            
            let scene = arch.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? SKScene
            arch.finishDecoding()
            
            return scene
        }
        return nil
    }
}

