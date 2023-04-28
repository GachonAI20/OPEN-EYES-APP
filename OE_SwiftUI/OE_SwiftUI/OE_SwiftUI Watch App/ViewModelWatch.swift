//
//  ViewModelWatch.swift
//  CounterConnect Watch App
//
//  Created by 서정덕 on 2023/04/06.
//

import Foundation
import WatchConnectivity

// ViewModelWatch 클래스: WatchConnectivity를 사용하여 Apple Watch와 iPhone 간 통신을 관리하는 뷰 모델
class ViewModelWatch : NSObject, WCSessionDelegate, ObservableObject {
    // WCSession 인스턴스를 저장할 변수
    var session: WCSession
    
    // messageText 프로퍼티: iPhone으로부터 받은 메시지를 저장하는 문자열 변수, 초기값은 빈 문자열
    @Published var messageText = ""
    
    // 초기화 메서드: 외부에서 WCSession을 전달하거나 기본값을 사용하여 ViewModelWatch 인스턴스를 생성
    init(session: WCSession = .default){
        self.session = session
        super.init()
        self.session.delegate = self // WCSessionDelegate를 self로 설정
        
        session.activate() // WCSession을 활성화
    }
    
    // WCSessionDelegate 메서드: 세션 활성화가 완료되면 호출
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    // WCSessionDelegate 메서드: iPhone으로부터 메시지를 받으면 호출
    // 메시지에 포함된 "message"라는 key를 가진 문자열을 messageText 프로퍼티에 할당
    // 메시지에 "message" key가 없으면 빈 문자열을 messageText에 할당
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.messageText = message["message"] as? String ?? ""
        }
    }
    
}

