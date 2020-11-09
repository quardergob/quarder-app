//
//  SpeechManager.swift
//  quarder-app
//
//  Created by Lou Batier on 05/11/2020.
//

import Foundation
import AVFoundation

class SpeechManager {
    
    static let instance = SpeechManager()
    
    var langUsed:String = "fr-FR"
    var voiceRate:Float = 0.5
    
    func setLangUsed(lang: String) {
        langUsed = lang
    }
    func setVoiceRate(rate: Float) {
        voiceRate = rate
    }
    
    func speak(string: String) {
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: langUsed)
        utterance.rate = voiceRate

        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}
