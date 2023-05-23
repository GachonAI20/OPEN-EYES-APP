//
//  SoundSetting.swift
//  OE_SwiftUI Watch App
//
//  Created by 서정덕 on 2023/04/29.
//

import SwiftUI
import AVFoundation

class SoundSetting: ObservableObject {
    
    static let shared = SoundSetting()
    
    var player: AVAudioPlayer?
    
    func playSound(){
        // Bundle 클래스를 사용하여 파일 경로 참조, 이를 url 변수에 할당. 실패시 else
        guard let url = Bundle.main.url(forResource: "vibration", withExtension: "m4a") else {
            print("사운드 재생 오류")
            return
        }
        // AVAudioPlayer 객체를 생성, contentsOf 메서드를 사용하여 url에 있는 파일 로드. 실패시 else
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch _ {
            print("사운드 재생 오류")
        }
    }
}
