//
//  DotView.swift
//  OE_SwiftUI
//
//  Created by 서정덕 on 2023/05/19.
//

import SwiftUI
import UIKit
import Combine
struct DotView: View {
    
    /// 워치 통신 매니저
    @ObservedObject var counterManager = CounterManager.shared
    
    let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    /// 받은 일반 문자열 저장
     @Binding var str: String {
        didSet {
            brl2DArr = BrailleManager.shared.convert(str: str)
            counterManager.setCountZero()
        }
    }
    /// 변환한 이진 문자열
    @State var brl2DArr: [[Int]] = [[0,0,0,0,0,0]]
    /// 마지막으로 터치한 dot 정보
    @State var lastTouch: Int = -1
    /// 터치한 dot 정보 저장하는 배열
    @State var touchSet: Set<Int> = []

    var body: some View {
        HStack{
            VStack{
//                Text("\(counterManager.count)")
//                    .foregroundColor(.black)
                Button {
                    if counterManager.count < brl2DArr.count - 1 {
                        playVibrate()
                        counterManager.increaseCount()
                    }
                } label: {
                    Image(systemName: "arrowshape.right.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(30)
                        .foregroundColor(.black)
                        .frame(width: 150, height: 150)
                }
                Button {
                    if counterManager.count > 0 {
                        playVibrate()
                        counterManager.decreaseCount()
                    }
                } label: {
                    Image(systemName: "arrowshape.left.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(30)
                        .foregroundColor(.black)
                        .frame(width: 150, height: 150)
                }
            }
            Spacer()
            GeometryReader { geo in
                VStack{
//                    Text("\(str)\(crownIdx): \(String(str[crownIdx]))")
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
                                    .foregroundColor(.black)
                                    .opacity(brl2DArr[counterManager.count][5 - idx] == 1 ? 1 : 0.2)
                                    .frame(width: width, height: height)
                            }
                        }
                    }
                }
                // 뷰 제스처 감지
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged({ value in
                        vibrateOnTouch(value: value, geo: geo)
                    })
                    // 터치가 끝났을 때 lastTouch 초기화해서 같은 블록을 연속으로 클릭해도 진동하게 함
                    .onEnded { _ in
                        lastTouch = -1
                        // 한 글자를 다 읽었을 때 set 비우고 다음글자로 넘어감 오버플로우 해결
                        if touchSet.count == 6  && counterManager.count < brl2DArr.count - 1 {
                            touchSet = []
                            counterManager.increaseCount()
                        }
                        print(brl2DArr)
                    }
                )
            }
            
        }
            .onReceive(Just(str)) { newValue in
                if str != ""{
                    brl2DArr = BrailleManager.shared.convert(str: newValue)
                }
            }
    }
    
    /// 터치한 뷰갸 1일 경우, 진동
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
        }
        lastTouch = touchedIdx
    }

    func playVibrate() {
        impactFeedbackGenerator.impactOccurred()
    }
}
