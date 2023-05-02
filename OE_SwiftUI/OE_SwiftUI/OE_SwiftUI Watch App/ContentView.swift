//
//  ContentView.swift
//  CounterConnect Watch App
//
//  Created by 서정덕 on 2023/04/06.
//

import SwiftUI
import WatchKit


struct ContentView: View {
    
    /// 뷰모델 인스턴스 생성
    @ObservedObject var model = ViewModelWatch()
    /// 받은 일반 문자열 저장
    @State var str: String = ""
    // 크라운입력값 받는 변수
    @State private var crownValue = 0.0
    /// 현재 읽고있는 글자의 인덱스
    @State var crownIdx: Int = 0
    /// 마지막 크라운 입력값. 변화량 비교위해 필요
    @State var lastCrown = 0.0
    /// 변환한 이진 문자열
    @State var brl2DArr: [[Int]] = [[0,0,0,0,0,0]]
    /// 마지막으로 터치한 dot 정보
    @State var lastTouch: Int = -1
    /// 터치한 dot 정보 저장하는 배열
    @State var touchSet: Set<Int> = []


    var body: some View {
        GeometryReader { geo in
            VStack{
//                Text("\(str)\(crownIdx): \(String(str[crownIdx]))")
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
                                .opacity(brl2DArr[crownIdx][5 - idx] == 1 ? 1 : 0.2)
                                .frame(width: width, height: height)
                        }
                    }
                }
            }
            // 뷰에 제스처 감지
            .gesture(DragGesture(minimumDistance: 0)
                // 터치 좌표값이 변화했을 때 변화한 값을 파라미터로 받는 클로저
                .onChanged({ value in
                    /// 터치 좌표 저장 변수
                    let loc: CGPoint = value.location
                    /// 터치 좌표를 통해 누른 셀의 인덱스 가져와서 저장
                    let touchedIdx = getIdx(loc, geo: geo)
                    touchSet.insert(touchedIdx)
                    // 누른 인덱스에 해당하는 점자이진 배열값이 1이고, 손을 떼기 전 마지막 터치한 인덱스가 같지 않을 때 진동
                    if brl2DArr[crownIdx][5 - touchedIdx] == 1 && lastTouch != touchedIdx {
                        print("\(touchedIdx + 1) / 6")
                        // 진동 구현 부분
                        SoundSetting.instance.playSound()
                    }
                    // lastTouch 업데이트
                    lastTouch = touchedIdx
                })
                //터치가 끝났을 때 lastTouch초기화 해서 같은 블록을 연속으로 클릭해도 진동하게 함
                .onEnded { _ in
                    lastTouch = -1
                    // 한 글자를 다 읽었을 때 set 비우고 다음글자로 넘어감 오버플로우 해결
                    if touchSet.count == 6  && crownIdx < brl2DArr.count - 1 {
                        touchSet = []
                        crownIdx += 1
//                        SoundSetting.instance.playSound()
                    }
                }
            )
        }
        // 워치 통신 감지.  변화를 감지할 변수이름에 $를 붙여 감시, 파라미터는 변화한 값
        .onReceive(self.model.$messageText) { message in
            self.str = message
            print("폰으로 부터 받은 String: \(message)")
            if message != "" {
                SoundSetting.instance.playSound()
                brl2DArr = convert(str: str)
                print("\n",brl2DArr)
            }
        }
        // 크라운 입력 받기
        // 뷰에 포커스를 설정할 수 있으며, Digital Crown 회전 이벤트가 발생할 때마다 이를 감지하고 처리한다.
        .focusable()
        // $crownValue 위치에 값 받을 변수 넣음
        .digitalCrownRotation($crownValue) { DigitalCrownEvent in
            // DigitalCrownEvent.offset 으로 크라운값 받기 가능
            if crownValue > lastCrown + 20 {
                lastCrown = crownValue
                if crownIdx < brl2DArr.count - 1 {
                    //진동
                    crownIdx += 1
                    SoundSetting.instance.playSound()
                }

            }
            else if crownValue <  lastCrown - 20 {
                lastCrown = crownValue
                if crownIdx > 0 {
                    //진동
                    crownIdx -= 1
                }
            }
//                crownIndex = Int(DigitalCrownEvent.offset)/10
        }
    }
    /// 일반 String 받아서 점자 Int arr로 반환. 입력: "Hello", 출력: [[0,1,1,0,0,0],[0,0,0,1,1,0]]
    func convert(str string: String) -> [[Int]]{
        /// 소문자로 저장된 일반 String
        let str = string.lowercased()
        /// 반환할 배열, ["100011", "010010"]의 형식을 갖고있음
        var returnValue: [[Int]] = []
        /// [글자: 점자] 딕셔너리
        let eng2Braille: [Character: Character] = [
                "a": "⠁", "b": "⠃", "c": "⠉", "d": "⠙",
                "e": "⠑", "f": "⠋", "g": "⠛", "h": "⠓",
                "i": "⠊", "j": "⠚", "k": "⠅", "l": "⠇",
                "m": "⠍", "n": "⠝", "o": "⠕", "p": "⠏",
                "q": "⠟", "r": "⠗", "s": "⠎", "t": "⠞",
                "u": "⠥", "v": "⠧", "w": "⠺", "x": "⠭",
                "y": "⠽", "z": "⠵",
                " ": "⠀", ".": "⠲", ",": "⠂",
                "?": "⠦", "!": "⠖", ";": "⠆",
                ":": "⠒", "-": "⠤", "/": "⠌",
                "0": "⠴", "1": "⠂", "2": "⠆", "3": "⠒",
                "4": "⠲", "5": "⠢", "6": "⠖", "7": "⠶",
                "8": "⠦", "9": "⠔"
            ]
        ///  [점자: 이진수] 딕셔너리
        let braille2IntArr: [Character: [Int]] = [
            "⠀": [0,0,0,0,0,0], "⠁": [0,0,0,0,0,1],
            "⠂": [0,0,0,0,1,0], "⠃": [0,0,0,0,1,1],
            "⠄": [0,0,0,1,0,0], "⠅": [0,0,0,1,0,1],
            "⠆": [0,0,0,1,1,0], "⠇": [0,0,0,1,1,1],
            "⠈": [0,0,1,0,0,0], "⠉": [0,0,1,0,0,1],
            "⠊": [0,0,1,0,1,0], "⠋": [0,0,1,0,1,1],
            "⠌": [0,0,1,1,0,0], "⠍": [0,0,1,1,0,1],
            "⠎": [0,0,1,1,1,0], "⠏": [0,0,1,1,1,1],
            "⠐": [0,1,0,0,0,0], "⠑": [0,1,0,0,0,1],
            "⠒": [0,1,0,0,1,0], "⠓": [0,1,0,0,1,1],
            "⠔": [0,1,0,1,0,0], "⠕": [0,1,0,1,0,1],
            "⠖": [0,1,0,1,1,0], "⠗": [0,1,0,1,1,1],
            "⠘": [0,1,1,0,0,0], "⠙": [0,1,1,0,0,1],
            "⠚": [0,1,1,0,1,0], "⠛": [0,1,1,0,1,1],
            "⠜": [0,1,1,1,0,0], "⠝": [0,1,1,1,0,1],
            "⠞": [0,1,1,1,1,0], "⠟": [0,1,1,1,1,1],
            "⠠": [1,0,0,0,0,0], "⠡": [1,0,0,0,0,1],
            "⠢": [1,0,0,0,1,0], "⠣": [1,0,0,0,1,1],
            "⠤": [1,0,0,1,0,0], "⠥": [1,0,0,1,0,1],
            "⠦": [1,0,0,1,1,0], "⠧": [1,0,0,1,1,1],
            "⠨": [1,0,1,0,0,0], "⠩": [1,0,1,0,0,1],
            "⠪": [1,0,1,0,1,0], "⠫": [1,0,1,0,1,1],
            "⠬": [1,0,1,1,0,0], "⠭": [1,0,1,1,0,1],
            "⠮": [1,0,1,1,1,0], "⠯": [1,0,1,1,1,1],
            "⠰": [1,1,0,0,0,0], "⠱": [1,1,0,0,0,1],
            "⠲": [1,1,0,0,1,0], "⠳": [1,1,0,0,1,1],
            "⠴": [1,1,0,1,0,0], "⠵": [1,1,0,1,0,1],
            "⠶": [1,1,0,1,1,0], "⠷": [1,1,0,1,1,1],
            "⠸": [1,1,1,0,0,0], "⠹": [1,1,1,0,0,1],
            "⠺": [1,1,1,0,1,0], "⠻": [1,1,1,0,1,1],
            "⠼": [1,1,1,1,0,0], "⠽": [1,1,1,1,0,1],
            "⠾": [1,1,1,1,1,0], "⠿": [1,1,1,1,1,1]
        ]
        
        // 입력받은 문자열의 각 글자를 순회하면서 점자로 변환하고,
        // 점자를 이진 숫자 배열로 변환하여 반환할 배열에 추가
        print("점자로 변환:")
        for i in 0..<str.count {
            // 입력받은 문자열에서 i번째 글자를 가져옴
            let char: Character = str.getChar(at: i)
            // i번째 글자에 해당하는 점자 문자를 딕셔너리에서 찾음 braille: "⠗"
            if let braille: Character = eng2Braille[char] {
                print(braille, terminator: " ")
                // 점자 문자에 해당하는 이진 숫자 배열을 반환할 배열에 추가
                returnValue.append(braille2IntArr[braille]!)
            }
        }
        // 변환된 이진 숫자 2DArr을 반환
        return returnValue
    }

    /// 터치좌표값을 받아서 0~5 인덱스 반환
    func getIdx(_ location: CGPoint, geo: GeometryProxy) -> Int {
        let cellWidth = geo.size.width / 2
        let cellHeight = geo.size.height / 3
        let col = Int(location.x / cellWidth)
        let row = Int(location.y / cellHeight)
        // 오버플로우 막음
        var returnValue: Int = row + col * 3
        if returnValue < 0 { returnValue = 0 }
        if returnValue > 5 { returnValue = 5 }
        return returnValue
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


// #################### extension ###################

extension String {
    subscript(_ index: Int) -> Character {
        if 0 <= index && index < self.count  {
            return self[self.index(self.startIndex, offsetBy: index)]
        }
       return Character(" ")
    }
    
    func getChar(at index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
}
