//
//  ShakeUtil.swift
//  OE-Serverless
//
//  Created by 서정덕 on 2023/06/02.
//

import Foundation
import UIKit
import SwiftUI

// MARK: - 모션 쉐이크
// 흔들기 동작이 발생할 때 전달할 알림입니다.
extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

// 기본적인 흔들기 동작의 동작을 우리의 알림으로 오버라이드합니다.
extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}

// 흔들기를 감지하고 원하는 동작을 호출하는 뷰 수정자입니다.
struct DeviceShakeViewModifier: ViewModifier {
    let action: () -> Void

    // 뷰에 수정자를 적용합니다.
    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                action()
            }
    }
}

// 수정자를 사용하기 쉽게 하는 View 확장입니다.
extension View {
    // 뷰에 onShake 수정자를 적용합니다.
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(DeviceShakeViewModifier(action: action))
    }
}


