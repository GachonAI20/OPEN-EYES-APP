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

struct ContentView: View {
    // ViewModelPhone 인스턴스를 생성
    var model = ViewModelPhone()
    /// 문서: 0, 물체: 1
    @State private var mode = 1
    /// 이미지 피커를 보여줄지 여부를 결정하는 State
    @State private var showingImagePicker = false
    /// 선택한 이미지를 저장하는 State
    @State private var inputImage: UIImage?
    /// 디바이스 id 저장하는 변수
    @State private var uid: String = UIDevice.current.identifierForVendor?.uuidString ?? ""


    
    // reachable: 연결 상태를 나타내는 문자열 변수. 초기값은 "No"
    @State var reachable = "No"
    
    // messageText: 사용자가 입력할 메시지를 저장하는 문자열 변수
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
                    .tag(1)
                Text("물체 인식")
                    .tag(0)
            }
                .pickerStyle(SegmentedPickerStyle())
                .padding([.leading, .trailing],40)
            Text(messageText)
            
            Spacer()

            Button(action: {
                // 이미지 피커 불러오기
                showingImagePicker = true
                print("이미지 피커 버튼 눌림")
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
        .fullScreenCover(isPresented: $showingImagePicker, onDismiss: loadEdgeML) {
            // 이미지 피커를 표시

            ImagePickerView(selectedImage: self.$inputImage, sourceType: .photoLibrary)
        }
    }
    
    

}

// MARK: - 엣지 머신러닝
extension ContentView {

    func loadEdgeML() {
        if mode == 1 {
            edgeOCR()
        }else {
//            objDetect()
        }
    }
    
    /// 엣지 OCR
    func edgeOCR() {
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
            uploadImage2FB()
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
            print(error) // 에러가 발생한 경우 출력합니다.
        }
    }

}

// MARK: - ML 서버 사용
extension ContentView {
    /// 파이어 베이스로 업로드
    func uploadImage2FB() {
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
