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

struct ContentView: View {
    // ViewModelPhone 인스턴스를 생성
    var model = ViewModelPhone()
    /// ML 모드 
    @State private var mode = DetectMode.ocr
    /// 이미지 피커를 보여줄지 여부를 결정하는 State
    @State private var showingImagePicker = false
    /// 선택한 이미지를 저장하는 State
    @State private var inputImage: UIImage?
    /// 디바이스 id 저장하는 변수
    @State private var uid: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
    /// 인터넷 연결 여부
    @State private var isInternetConnected: Bool = false
    ///   ML결과 저장하는 변수
    @State var messageText = ""
    
    var body: some View {
        VStack{
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
            
            Spacer()

            Button(action: {
                // 이미지 피커 불러오기
                showingImagePicker = true
                print("이미지 피커 버튼")
            }) {
                Image(uiImage: inputImage ?? UIImage(systemName: "camera")!)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.black)
                            .frame(width: 150, height: 150)
            }
            
            Spacer()
            
            DotView(str: $messageText)
                .frame(height: 300)
            
            Spacer()

        }
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

}

// MARK: - 머신러닝

extension ContentView {
    func loadML() {
        print("loadML\n인터넷:\(isInternetConnected), 모드:\(mode)")
        // 인터넷 연결 되어있으면 서버ML 호출
        if isInternetConnected {
            mode == .object ? serverObjDetect() : serverOCR()
        } else {
            mode == .object ? edgeObjDetect() : edgeOCR()
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
            messageText = recognizedText
            sendMessage2Watch(messageText: messageText)
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
    
// MARK: - 서버ML
    
    /// 서버 물체인식
    func serverObjDetect(){
        print("serverObjDetect")
    }
    
    /// 서버 문서인식
    func serverOCR(){
        print("serverOCR")
        
    }
    
    /// 파이어 베이스로 업로드
    func uploadImage2FB() {
        print("uploadImage2FB")
        guard let image = inputImage else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let uniqueFilename = UUID().uuidString + ".jpg" // 유니크한 파일 이름 생성
        let imagePath = "Original/\(mode)/\(uid)/\(uniqueFilename)" // 이미지 파일 경로 구성
        
        let imageRef = storageRef.child(imagePath)
        
        imageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("이미지 업로드 실패: \(error.localizedDescription)")
            } else {
                print("이미지 업로드 성공!")
            }
        }
    }
}

// MARK: - 폰 - 워치간 통신

extension ContentView {
    func sendMessage2Watch(messageText: String){
        print("sendMessage2Watch")
        self.model.session.sendMessage(["message": messageText], replyHandler: nil) { (error) in
            print(error.localizedDescription)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
