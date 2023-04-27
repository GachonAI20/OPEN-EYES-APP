//
//  ContentView.swift
//  CounterConnect Watch App
//
//  Created by 서정덕 on 2023/04/06.
//

import SwiftUI
import WatchKit



struct ContentView: View {
    @ObservedObject var model = ViewModelWatch()
    @State var str: String = ""
    @State private var crownValue = 0.0
    @State var crownIndex: Int = 0
    @State var lastCrown = 0.0
    @State var braille2DArr: [[Int]] = [[0,0,0,0,0,0]]


    var body: some View {
        Text("값: \(str)")
            // 변화를 감지할 변수이름에 $를 붙여 감시, 파라미터는 변화한 값
            .onReceive(self.model.$messageText) { message in
                self.str = message
                if message != "" {
                    braille2DArr = convert(str: message)
                    print(braille2DArr)
                }
            }

        Text("\(crownIndex): \(String(str[crownIndex]))")
//            .font(.largeTitle)
            .focusable()
            // $crownValue 위치에 값 받을 변수 넣음
            .digitalCrownRotation($crownValue) { DigitalCrownEvent in
                // DigitalCrownEvent.offset 으로 크라운값 받기 가능
                if crownValue > lastCrown + 20 {
                    lastCrown = crownValue
                    if crownIndex < braille2DArr.count - 1 {
                        //진동
                        crownIndex += 1
                    }
                    
                }
                else if crownValue <  lastCrown - 20 {
                    lastCrown = crownValue
                    if crownIndex > 0 {
                        //진동
                        crownIndex -= 1
                    }
                }
//                crownIndex = Int(DigitalCrownEvent.offset)/10
            }
        
//        Text("\(braille2DArr[crownIndex].map(String.init).joined())")

//        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
//            ForEach(0..<3) { row in
//                ForEach(0..<2) { col in
//                    let index = row + (col * 3)
//                    GeometryReader { geo in
//                        Text("\(index + 1)")
//                            .font(.largeTitle)
//                            .opacity(braille2DArr[crownIndex][5 - index] == 1 ? 1 : 0.1)
//                            .frame(width: geo.size.width, height: geo.size.height)
//                            .onTapGesture {
//                                print("Tapped index: \(index + 1)")
//                            }
//                    }
//                }
//            }
//        }
        
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(0..<3) { row in
                ForEach(0..<2) { col in
                    let index = row + (col * 3)
                    GeometryReader { geo in
                        Text("\(index + 1)")
                            .font(.largeTitle)
                            .opacity(braille2DArr[crownIndex][5 - index] == 1 ? 1 : 0.1)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .onTapGesture {
                                print("Tapped index: \(index + 1)")
                            }
                    }
                }
            }
        }

        



        
    }
    /// 일반 String 받아서 점자 Int arr로 반환. 입력: "Hello", 출력: [[0,1,1,0,0,0],[0,0,0,1,1,0]]
    func convert(str string: String) -> [[Int]]{
        /// 소문자로 저장된 일반 String
        var str = string.lowercased()
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
        
        // 글자 -> 점자 -> IntArr
        for i in 0..<str.count {
            let char: Character = str.getChar(at: i)
            // braille: "⠗"
            if let braille: Character = eng2Braille[char] {
                print(braille)
                returnValue.append(braille2IntArr[braille]!)
            }
        }
        
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
