//
//  SpeechController.swift
//  EhouCompass
//
//  Created by Toshiki Chiba on 2017/01/28.
//  Copyright © 2017年 Toshiki Chiba. All rights reserved.
//

import Foundation
import AVFoundation

final class SpeechController: NSObject {
    static let shared = SpeechController()
    private let speechSynthesizer = AVSpeechSynthesizer()

    enum SpeechType {
        case left, right, ehou, stop
        var text: String {
            switch self {
            case .left:
                return "ひだり"
            case .right:
                return "みぎ"
            case .ehou:
                return "そこ"
            case .stop:
                return ""
            }
        }
    }
    
    private func speechStop() {
        self.speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        let utterance = AVSpeechUtterance(string: "")
        self.speechSynthesizer.speak(utterance)
        self.speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
    }
    
    func speech(type: SpeechType) {
        if type == .stop {
            speechStop()
            return
        }
        if self.speechSynthesizer.isSpeaking {
//            speechStop()
            return
        }
        
        let targetText = type.text
        let utterance = AVSpeechUtterance(string: targetText)
        let jVoice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.voice = jVoice
        utterance.rate = 0.4
        utterance.pitchMultiplier = 0.7
        self.speechSynthesizer.delegate = self
        self.speechSynthesizer.speak(utterance)
    }
}

extension SpeechController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
    }
}
