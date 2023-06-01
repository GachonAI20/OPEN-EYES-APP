//
//  ContentView.swift
//  CounterConnect
//
//  Created by 서정덕 on 2023/04/06.
//

import CoreML
import SwiftUI
import Vision
import FirebaseStorage
import Firebase
import Network
import UIKit
import Combine
import AVFoundation

struct ContentView: View {
    
    /// 진동 구현 인스턴스
    let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    /// 워치 통신 매니저
    @ObservedObject var counterManager = CounterManager.shared
    /// ML 모드 
    @State private var mode = DetectMode.ocr
    /// 이미지 피커를 보여줄지 여부를 결정하는 State
    @State private var showingImagePicker = false
    /// 선택한 이미지를 저장하는 State
    @State private var inputImage: UIImage? = nil
    /// 디바이스 id 저장하는 변수
    @State private var uid: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
    /// 인터넷 연결 여부
    @State private var isInternetConnected: Bool = false
    ///   ML결과 저장하는 변수
    @State var messageText = ""
    /// tts 인스턴스
    let speechSynthesizer = AVSpeechSynthesizer()
    // get 요청 결과 저장
    @State var getReqError: String = ""
    @State var getReqInfo: String = ""
    @State var getReqSummary: String = ""
    
    var swipeGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                if value.translation.width > 0 {
                    if mode == .ocr {
                        mode = .object
                        playVibrate()
                    }
                } else {
                    if mode == .object {
                        mode = .ocr
                        playVibrate()
                    }
                }
            }
    }
    
    var longPressGesture: some Gesture {
        LongPressGesture()
            .onEnded { _ in
                // 실행될 함수 호출
                playTTS()
            }
    }
    
    // 피커 색상 조정
    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.gray
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white
        ]
        UISegmentedControl.appearance().setTitleTextAttributes(attributes, for: .selected)
        
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black
        ]
        UISegmentedControl.appearance().setTitleTextAttributes(normalAttributes, for: .normal)
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            VStack{
                VStack {
                    ZStack {
                        Color.white
//                            .gesture(swipeGesture)
                        VStack {
                            Image("OpenEyes16_9")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .padding([.top ,.bottom],10)
                            
                            
                            Picker(selection: $mode, label: Text("모드선택")) {
                                Text("문서 인식")
                                    .tag(DetectMode.ocr)
                                Text("물체 인식")
                                    .tag(DetectMode.object)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding([.leading, .trailing],40)
                            
                            Text(messageText)
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            // 이미지 피커 불러오기
                            Button(action: {
                                playVibrate()
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
    //                    .gesture(swipeGesture)
                    }
                }
                    .gesture(swipeGesture)
                    .gesture(longPressGesture)

                
                DotView(str: $messageText)
                    .frame(height: 250)
                
                Spacer()

            }
            

//            .background(Color.white) // Set the background color to white

            // .sheet를 .fullScreenCover로 변경
            // present 여부를 $showingImagePicker로 결정함
            // .sheet나 .fullScreenCover를 사용하면, 해당 뷰를 닫을 때 자동으로 isPresented와 연결된 변수 false로 설정
            .fullScreenCover(isPresented: $showingImagePicker, onDismiss: loadML) {
                // 이미지 피커를 표시
                ImagePickerView(selectedImage: self.$inputImage, sourceType: .photoLibrary)
            }
            .onAppear{
                show()
        }
        }
    }

    
    

}



// MARK: -  ContentView.onAppear
extension ContentView {
    func show(){
        print("appearFunc")
        ///인터넷 연결 확인
        checkInternetConnectionOnce()
    }
    
    /// 네트워크 상태 확인하는 함수, 처음 한번만 실행하고 모니터링 캔슬함
    func checkInternetConnectionOnce() {
        print("checkInternetConnectionOnce")
        // NWPathMonitor 인스턴스 생성하여 네트워크 경로 모니터링
        let monitor = NWPathMonitor()
        // 모니터링을 위한 디스패치 큐 생성
        let queue = DispatchQueue(label: "NetworkMonitor")
        // 초기 네트워크 경로 상태를 확인하고, 그 후 네트워크 경로의 상태가 업데이트될 때 호출되는 클로저
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                // 경로 상태가 satisfied인 경우 인터넷 연결됨
                if path.status == .satisfied {
                    isInternetConnected = true
                } else {
                    isInternetConnected = false
                }
            }
            // 상태 확인 후 모니터링 중지
            monitor.cancel()
        }
        monitor.start(queue: queue)
    }

// MARK: - 머신러닝

    func loadML() {
        print("loadML\n인터넷:\(isInternetConnected), 모드:\(mode)")
        // 인터넷 연결 되어있으면 서버ML 호출
        if isInternetConnected {
            let path = uploadImage2FB()
            print("경로: ",path)
        } else {
//            mode == .object ? edgeObjDetect() : edgeOCR()
            edgeOCR()
        }
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
            messageText = recognizedText + " "
            counterManager.sendMessage2Watch(messageText: messageText)
            playVibrate()
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
    
// MARK: - 서버ML
    
//    /// 서버 물체인식
//    func serverObjDetect() {
//        print("serverObjDetect")
//        getByPath(path: path)
//    }
//
//    /// 서버 문서인식
//    func serverOCR() {
//        print("serverOCR")
//        let path = uploadImage2FB()
//        print("경로: ",path)
//        getByPath(path: path)
//    }
    
    func getByPath(path: String) {
        var urlComponents = URLComponents(string: "https://port-0-flask-test1-4c7jj2blhexg5l8.sel4.cloudtype.app/")
        urlComponents?.queryItems = [URLQueryItem(name: "id", value: path)]
        
        if let url = urlComponents?.url {
            let request = URLRequest(url: url)
            
            let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("HTTP GET 요청 실패. 에러: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("유효하지 않은 HTTP 응답")
                    return
                }
                
                if (200..<300).contains(httpResponse.statusCode) {
                    if let responseData = data {
                        if let resultString = String(data: responseData, encoding: .utf8) {
                            print("HTTP GET 요청 성공")
                            print("상태 코드: \(httpResponse.statusCode)")
                            print("응답 데이터: \(resultString)")
                            
                            // JSON 디코딩
                            do {
                                let decoder = JSONDecoder()
                                let responseData = try decoder.decode(ResponseData.self, from: responseData)
                                getReqError = responseData.error
                                getReqInfo = responseData.info
                                getReqSummary = responseData.summary
                                messageText = getReqInfo + " "
                                counterManager.sendMessage2Watch(messageText: messageText)
                                playVibrate()
                                // 사용할 데이터를 처리하거나 UI에 반영하는 로직 추가
                                // 예: DispatchQueue.main.async { ... }
                            } catch {
                                print("JSON 디코딩 실패. Error: \(error)")
                            }
                        }
                    }
                } else {
                    print("HTTP GET 요청 에러. 상태 코드: \(httpResponse.statusCode)")
                }
            }
            dataTask.resume()
        } else {
            print("유효하지 않은 URL")
        }
    }


    
    /// 파이어 베이스로 업로드후 업로드 디렉토리 반환
    func uploadImage2FB() -> String{
        print("uploadImage2FB")
        guard let image = inputImage else { return ""}
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return ""}
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let uniqueFilename = UUID().uuidString + ".jpg" // 유니크한 파일 이름 생성
        let imagePath = "Original/\(mode.rawValue)/\(uid)/\(uniqueFilename)" // 이미지 파일 경로 구성
        
        let imageRef = storageRef.child(imagePath)
        
        imageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("이미지 업로드 실패: \(error.localizedDescription)")
            } else {
                
                print("이미지 업로드 성공!")
                // 성공시에 get 요청
                getByPath(path: imagePath)
            }
        }
        
        return imagePath
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
