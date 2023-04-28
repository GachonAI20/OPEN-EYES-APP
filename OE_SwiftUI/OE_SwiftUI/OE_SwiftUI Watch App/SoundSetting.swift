//
//  SoundSetting.swift
//  OE_SwiftUI Watch App
//
//  Created by 서정덕 on 2023/04/29.
//

import SwiftUI
import AVFoundation

class SoundSetting: ObservableObject {
    
    //1. soundSetting의 단일 인스턴스를 만듬
    /// singleton ? :
    /*싱글 톤은 한 번만 생성 된 다음 사용해야하는 모든 곳에서 공유해야하는 객체입니다 */
    static let instance = SoundSetting()
    
    var player: AVAudioPlayer?
    
    func playSound(){
        guard let url = Bundle.main.url(forResource: "vibration", withExtension: "m4a") else {
            print("사운드 재생 오류")
            return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch _ {
            print("사운드 재생 오류")
        }
    }
}
