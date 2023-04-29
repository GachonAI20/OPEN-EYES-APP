//
//  ContentView.swift
//  CounterConnect
//
//  Created by 서정덕 on 2023/04/06.
//

import CoreML
import SwiftUI

struct ContentView: View {
    // ViewModelPhone 인스턴스를 생성
    var model = ViewModelPhone()
    
    // reachable: 연결 상태를 나타내는 문자열 변수. 초기값은 "No"
    @State var reachable = "No"
    
    // messageText: 사용자가 입력할 메시지를 저장하는 문자열 변수
    @State var messageText = ""
    
    var body: some View {
        VStack{
            // 연결 상태를 표시
            Text("Reachable \(reachable)")
            
            // "Update" 버튼: 클릭 시 Apple Watch와의 연결 상태를 확인하고 reachable 변수를 업데이트
            Button(action: {
                if self.model.session.isReachable {
                    self.reachable = "Yes"
                } else {
                    self.reachable = "No"
                }
                
            }) {
                Text("Update")
            }
            
            // 사용자가 메시지를 입력할 수 있는 텍스트 필드
            TextField("Input your message", text: $messageText)
            
            // "Send Message" 버튼: 클릭 시 입력한 메시지를 Apple Watch로 전송
            Button(action: {
                self.model.session.sendMessage(["message": self.messageText], replyHandler: nil) { (error) in
                    print(error.localizedDescription)
                }
            }) {
                Text("Send Message")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
