//
//  ContentView.swift
//  CounterConnect Watch App
//
//  Created by 서정덕 on 2023/04/06.
//

import SwiftUI
import WatchKit


struct ContentView: View {

    @ObservedObject var counterManager = CounterManager.shared
    /// 받은 일반 문자열 저장
    @State var str: String = ""
    // 크라운입력값 받는 변수
    @State private var crownValue = 0.0
    /// 현재 읽고있는 글자의 인덱스
//    @State var charIdx: Int = 0
    /// 마지막 크라운 입력값. 변화량 비교위해 필요
    @State var lastCrown = 0.0
    /// 변환한 이진 문자열
    @State var brl2DArr: [[Int]] = [[0,0,0,0,0,0]]
    /// 마지막으로 터치한 dot 정보
    @State var lastTouch: Int = -1
    /// 터치한 dot 정보 저장하는 배열
    @State var touchSet: Set<Int> = []
    /// 크라운이 회전 여부 저장 변수
    @State var isCrownRotated: Bool = false
    
    
    var body: some View {
        GeometryReader { geo in
            VStack{
                // Text("\(str)\(crownIdx): \(String(str[crownIdx]))")
                LazyVGrid(columns: [
                    GridItem(.flexible()), GridItem(.flexible())
                ], spacing: 0) {
                    ForEach(0..<3) { row in
                        ForEach(0..<2) { col in
                            let idx = row + (col * 3)
                            let width = geo.size.width / 2
                            let height = geo.size.height / 3
                            
                            Text("\(idx + 1)")
                                .font(.largeTitle)
                                .opacity(brl2DArr[counterManager.count][5 - idx] == 1 ? 1 : 0.2)
                                .frame(width: width, height: height)
                        }
                    }
                }
            }
            // 뷰에 제스처 감지
            .gesture(DragGesture(minimumDistance: 0)
                     // 터치 좌표값이 변화했을 때 변화한 값을 파라미터로 받는 클로저
                .onChanged({ value in
                    vibrateOnTouch(value: value, geo: geo)
                })
                     //터치가 끝났을 때 lastTouch초기화 해서 같은 블록을 연속으로 클릭해도 진동하게 함
                .onEnded { _ in
                    lastTouch = -1
                    // 한 글자를 다 읽었을 때 set 비우고 다음글자로 넘어감 오버플로우 해결
                    if touchSet.count == 6  && counterManager.count < brl2DArr.count - 1 {
                        touchSet = []
                        counterManager.increaseCount()
                        //                        SoundSetting.instance.playSound()
                    }
                }
            )
        }
        // 워치 통신 감지.  변화를 감지할 변수이름에 $를 붙여 감시, 파라미터는 변화한 값
        .onReceive(counterManager.$message) { message in
            self.str = message
            print("폰으로 부터 받은 String: \(message)")
            if message != "" {
                playVibrate()
                brl2DArr = BrailleManager.shared.convert(str: str)
                print("\n",brl2DArr)
            }
        }
        // 크라운 입력 받기
        // 뷰에 포커스를 설정할 수 있으며, Digital Crown 회전 이벤트가 발생할 때마다 이를 감지하고 처리한다.
        .focusable()
        // $crownValue 위치에 값 받을 변수 넣음
        .digitalCrownRotation($crownValue,
                              onChange: { DigitalCrownEvent in
            // DigitalCrownEvent.offset 으로 크라운값 받기 가능
            if isCrownRotated != true {
                if crownValue > lastCrown + 20 {
                    lastCrown = crownValue
                    if counterManager.count < brl2DArr.count - 1 {
                        playVibrate()
                        counterManager.increaseCount()
                        // 크라운 돌아감 표시
                        isCrownRotated = true
                    }
                }
                else if crownValue <  lastCrown - 10 {
                    lastCrown = crownValue
                    if counterManager.count > 0 {
                        playVibrate()
                        counterManager.decreaseCount()
                        // 크라운 돌아감 표시
                        isCrownRotated = true
                    }
                }
            }
            // crownIndex = Int(DigitalCrownEvent.offset)/10
        },
            onIdle: {
            // Digital Crown이 idle 상태일 때 실행되는 코드
            isCrownRotated = false
        })
    }

    func vibrateOnTouch(value: DragGesture.Value, geo: GeometryProxy) {
        /// 터치 좌표 저장 변수
        let loc: CGPoint = value.location
        /// 터치 좌표를 통해 누른 셀의 인덱스 가져와서 저장
        let touchedIdx = BrailleManager.shared.getIdx(loc, geo: geo)
        touchSet.insert(touchedIdx)
        // 누른 인덱스에 해당하는 점자이진 배열값이 1이고, 손을 떼기 전 마지막 터치한 인덱스가 같지 않을 때 진동
        if brl2DArr[counterManager.count][5 - touchedIdx] == 1 && lastTouch != touchedIdx {
            print("\(touchedIdx + 1) / 6")
            // 진동 구현 부분
            
            playVibrate()
            // SoundSetting.instance.playSound()
        }
        // lastTouch 업데이트
        lastTouch = touchedIdx
    }
    
    func playVibrate() {
        WKInterfaceDevice.current().play(.ㅇ)// 약하게 뚜둑
//        SoundSetting.instance.playSound()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

