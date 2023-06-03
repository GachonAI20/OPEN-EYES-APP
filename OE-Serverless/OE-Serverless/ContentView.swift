//
//  ContentView.swift
//  CounterConnect
//
//  Created by 서정덕 on 2023/04/06.
//

import CoreML
import SwiftUI
import Vision
import AVFoundation

struct ContentView: View {
    
    /// 진동 구현 인스턴스
    let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    /// tts 인스턴스
    let speechSynthesizer = AVSpeechSynthesizer()
    /// 워치 통신 매니저
    @ObservedObject var counterManager = CounterManager.shared
    /// ML 모드 
    @State private var mode = DetectMode.ocr
    /// 이미지 피커를 보여줄지 여부를 결정하는 State
    @State private var showingImagePicker = false
    /// 선택한 이미지를 저장하는 State
    @State private var inputImage: UIImage? = nil
    ///   ML결과 저장하는 변수
    @State var messageText = ""

    var longPressGesture: some Gesture {
        LongPressGesture()
            .onEnded { _ in
                // 실행될 함수 호출
                playTTS()
            }
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            VStack{
                VStack {
                    ZStack {
                        Color.white
                            .ignoresSafeArea()
                        VStack{
                            Image("OpenEyes16_9")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .padding([.top ,.bottom],10)
                            
                            
                            Text(messageText)
                                .foregroundColor(.black)
                            Spacer()
                            
                            Button(action: {
                                // 이미지 피커 불러오기
                                showingImagePicker = true
                                print("이미지 피커 버튼")
                            }) {
                                if inputImage == nil{
                                    Image(uiImage: UIImage(systemName: "camera")!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.black)
                                        .padding(20)
                                        .frame(width: 150, height: 150)
                                } else {
                                    Image(uiImage: inputImage!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.black)
                                        .frame(width: 150, height: 150)
                                }
                            }
                            Spacer()
                        }
                    }
                }
                .gesture(longPressGesture)
                
                DotView(str: $messageText)
                    .frame(height: 250)
                
                Spacer()

            }
            .background(Color.white) // Set the background color to white

            // .sheet를 .fullScreenCover로 변경
            // present 여부를 $showingImagePicker로 결정함
            // .sheet나 .fullScreenCover를 사용하면, 해당 뷰를 닫을 때 자동으로 isPresented와 연결된 변수 false로 설정
            .fullScreenCover(isPresented: $showingImagePicker, onDismiss: loadML) {
                // 이미지 피커를 표시
                ImagePickerView(selectedImage: self.$inputImage, sourceType: .camera)
                    .edgesIgnoringSafeArea(.all)
            }
            .onAppear{
                show()
            }
            .onShake {
                showingImagePicker.toggle()
        }
        }
    }

    
    

}

extension ContentView {
// MARK: -  ContentView.onAppear
    func show(){
        print("show")
    }

// MARK: - 머신러닝
    func loadML() {
        print("loadML")
        edgeOCR()
    }
    
// MARK: - 엣지ML
    
    /// 엣지 물체인식
    func edgeObjDetect(){
        print("edgeObjDetect")
    }
    
    /// 엣지 OCR
    func edgeOCR() {
        print("edgeOCR")
        
        // VNRecognizeTextRequest를 생성
        let request = VNRecognizeTextRequest(completionHandler: { (request, error) in
            // 결과값 변수에 저장
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            /// 읽은 String 저장할 변수
            var recognizedText = ""
            // 결과값 순회
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                recognizedText += topCandidate.string + " " // 결과값을 recognizedText 변수에 추가합니다.
            }
            // recognizedText 변수를 출력합니다.
            print("ocr 결과: \(recognizedText)")
            // 워치로 입력된 String 전송
            messageText = recognizedText
            counterManager.sendMessage2Watch(messageText: messageText)
            // uploadImage2FB()// 오프라인 상태에서는 파이어베이스에 업로드 하지 않음
        })
        // 텍스트 인식 정확도를 설정
        request.recognitionLevel = .accurate
        // 이미지 CGImage 형식으로 변환
        guard let cgImage = inputImage?.cgImage else { return }
        // VNImageRequestHandler를 생성
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([request]) // 이미지를 처리합니다.
        } catch {
            print(error)
        }
    }
    
    // MARK: - 유틸리티

    func playVibrate() {
        impactFeedbackGenerator.impactOccurred()
    }
    
    func playTTS() {
        print("playTTS")
        let utterance = AVSpeechUtterance(string: messageText)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR") // 음성 언어 설정 (예: 한국어)
        utterance.rate = 0.6 // 읽는 속도 설정 (0.0 ~ 1.0 사이 값)

        speechSynthesizer.speak(utterance)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
