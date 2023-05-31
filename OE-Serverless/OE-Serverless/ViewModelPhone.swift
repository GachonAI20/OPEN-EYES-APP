//
//  ViewModelPhone.swift
//  CounterConnect
//
//  Created by 서정덕 on 2023/04/06.
//

import Foundation
import WatchConnectivity

// ViewModelPhone 클래스: WatchConnectivity를 사용하여 iPhone과 Apple Watch 간 통신을 관리하는 뷰 모델
class ViewModelPhone : NSObject, WCSessionDelegate {
    
    // WCSession 인스턴스를 저장할 변수
    var session: WCSession
    
    // 초기화 메서드: 외부에서 WCSession을 전달하거나 기본값을 사용하여 ViewModelPhone 인스턴스를 생성.
    init(session: WCSession = .default){
        self.session = session
        super.init() // 상위 클래스인 NSObject의 초기화 메서드 호출
        self.session.delegate = self // WCSessionDelegate를 self로 설정
        session.activate() // WCSession을 활성화
    }
    
    // WCSessionDelegate 메서드: 세션 활성화가 완료되면 호출
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    // WCSessionDelegate 메서드: 세션이 비활성화된 경우 호출
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    // WCSessionDelegate 메서드: 세션이 비활성화된 후 다시 활성화되기 전에 호출
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
}


