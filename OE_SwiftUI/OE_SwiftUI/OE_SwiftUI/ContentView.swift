//
//  ContentView.swift
//  CounterConnect
//
//  Created by 서정덕 on 2023/04/06.
//

import CoreML
import SwiftUI
import Vision


struct ContentView: View {
    // ViewModelPhone 인스턴스를 생성
    var model = ViewModelPhone()
    /// 문서: 0, 물체: 1
    @State private var mode = 0
    /// 이미지 피커를 보여줄지 여부를 결정하는 State
    @State private var showingImagePicker = false
    /// 선택한 이미지를 저장하는 State
    @State private var inputImage: UIImage?

    
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
                    .tag(0)
                Text("물체 인식")
                    .tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.leading, .trailing],40)
            
//            // 연결 상태를 표시
//            Text("Reachable \(reachable)")
//
//            // "Update" 버튼: 클릭 시 Apple Watch와의 연결 상태를 확인하고 reachable 변수를 업데이트
//            Button(action: {
//                if self.model.session.isReachable {
//                    self.reachable = "Yes"
//                } else {
//                    self.reachable = "No"
//                }
//
//            }) {
//                Text("Update")
//            }
            
            Spacer()

            Button(action: {
                // 이미지 피커 불러오기
                showingImagePicker = true
                print("버튼 눌림")
            }) {
                Image(systemName: "camera")
                    .resizable() // 크기 조정 가능하도록 resizable modifier 추가
                    .scaledToFit() // 이미지 비율 유지
                    .foregroundColor(.black) // 검은색 틴트 컬러 적용
                    .frame(width: 150) // 크기 조정
            }

            if let inputImage = inputImage {
                // 선택한 이미지가 있으면 화면에 표시
                Image(uiImage: inputImage)
                    .resizable()
                    .scaledToFit()
                    .padding(60)
            }
            else {
                Spacer()
            }
            Spacer()


//            // 사용자가 메시지를 입력할 수 있는 텍스트 필드
//            TextField("Input your message", text: $messageText)
//
//            // "Send Message" 버튼: 클릭 시 입력한 메시지를 Apple Watch로 전송
//            Button(action: {
//                self.model.session.sendMessage(["message": self.messageText], replyHandler: nil) { (error) in
//                    print(error.localizedDescription)
//                }
//            }) {
//                Text("Send Message")
//            }
        }
        // .sheet를 .fullScreenCover로 변경
        // present 여부를 $showingImagePicker로 결정함
        // .sheet나 .fullScreenCover를 사용하면, 해당 뷰를 닫을 때 자동으로 isPresented와 연결된 변수 false로 설정
        .fullScreenCover(isPresented: $showingImagePicker, onDismiss: loadML) {
            // 이미지 피커를 표시
//            ImagePicker(image: $inputImage)
            ImagePickerView(selectedImage: self.$inputImage, sourceType: .camera)
        }
    }
    func sendMessage(messageText: String){
        self.model.session.sendMessage(["message": messageText], replyHandler: nil) { (error) in
            print(error.localizedDescription)
        }
    }


    func loadML() {
        if mode == 0 {
            OCR()
        }else {
//            objDetect()
        }
    }
    func OCR() {
        let request = VNRecognizeTextRequest(completionHandler: { (request, error) in // VNRecognizeTextRequest를 생성합니다.
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return } // 결과값을 확인합니다.
            
            var recognizedText = ""
            for observation in observations { // 결과값을 순회합니다.
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                recognizedText += topCandidate.string + " " // 결과값을 recognizedText 변수에 추가합니다.
            }
            print("ocr 결과")
            print(recognizedText) // recognizedText 변수를 출력합니다.
            // 워치로 입력된 String 전송
            sendMessage(messageText: recognizedText)
        })
        request.recognitionLevel = .accurate // 텍스트 인식 정확도를 설정합니다.
        
        guard let cgImage = inputImage?.cgImage else { return } // 이미지를 CGImage 형식으로 변환합니다.
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:]) // VNImageRequestHandler를 생성합니다.
        
        do {
            try requestHandler.perform([request]) // 이미지를 처리합니다.
        } catch {
            print(error) // 에러가 발생한 경우 출력합니다.
        }
    }
    /// 이미지가 선택되고, ImagePicker가 dismiss되면 실행되는 함수
//    func loadML() {
//        // 이미지를 저장하거나 처리하려면 여기에서 수행
//        print("loadML")
//        if mode == 0 {
//            guard let inputImage = inputImage,
//                  let pixelBuffer = inputImage.toCVPixelBuffer() else {
//                        print("이미지 변환 실패")
//                        return
//                    }
//            do {
//                let config = MLModelConfiguration()
//                // 1. OCR_Test 모델 인스턴스 생성하기
//                let model = try OCR_Test(configuration: config)
//                print("모델 성공")
//                // 2. 입력 이미지를 사용하여 OCR_TestInput 인스턴스 생성하기
//                // 여기에서 image 변수는 CVPixelBuffer 형식의 이미지 데이터여야 합니다.
//                let input = OCR_TestInput(image: pixelBuffer)
//
//                // 3. 생성된 OCR_TestInput 인스턴스를 사용하여 예측 수행하기
//                let output = try model.prediction(input: input)
//                print("예측 실행")
//
//                // 4. 예측 결과를 OCR_TestOutput 인스턴스로 받아와서 원하는 출력값 확인하기
//                let classLabelProbs = output.classLabelProbs // 각 카테고리의 확률을 딕셔너리 형태로 얻기
//                let classLabel = output.classLabel // 가장 확률이 높은 카테고리 레이블 얻기
//
//                // 출력값 출력
//                print("Class Label Probs: \(classLabelProbs)")
//                print("Class Label: \(classLabel)")
//            } catch {
//                print("Error: \(error.localizedDescription)")
//            }
//        }
//    }
}

struct ImagePicker: UIViewControllerRepresentable {
    /// 뷰의 presentation 상태에 접근하는 데 사용된다. 뷰를 닫는 동작을 처리하기 위해 사용
    @Environment(\.presentationMode) var presentationMode
    /// 선택한 이미지를 저장하는  변수. 다른 뷰와 값이 동기화되어야 하므로 @Binding이 사용됨
    @Binding var image: UIImage?

    // UIViewControllerRepresentable에 정의되어 있음
    // UIViewController 객체가 생성됨과 동시에 호출, Coordinator 객체를 생성
    func makeCoordinator() -> Coordinator {
        // init 메서드에 자신(ImagePicker)넣음
        Coordinator(self)
    }

    // UIViewControllerRepresentable을 채택한 뷰가 생성될 때 호출
    // UIImagePickerController를 생성하고 반환
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) ->
    UIImagePickerController {
        
        print("makeUIViewController")
        let picker = UIImagePickerController()
        // delegate를
        picker.delegate = context.coordinator
        // picker.sourceType = .camera
        picker.sourceType = .photoLibrary // 앨범에서 이미지를 선택하도록 설정
        return picker
    }

    // 이미지 피커를 업데이트하는 함수 (본 예제에서는 필요하지 않음)
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}

    // UIImagePickerControllerDelegate와 UINavigationControllerDelegate를 구현하는 Coordinator 클래스
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        // 이미지가 선택되면 호출되는 함수
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            print("사진 고름")
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            print("화면 꺼짐")
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
