//
//  ObjectVC.swift
//  OE
//
//  Created by 서정덕 on 2022/12/14.
//

import Foundation
import UIKit
import AVFoundation
import KorToBraille
import FirebaseCore
import FirebaseStorage
import Alamofire


class ObjectVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let storage = Storage.storage()

    var lastTouch: Int = -1
    //마지막으로 터치한 칸 번호
    var strIdx: Int = 0
    // 현재 읽고 있는 점자의 인덱스
    var brlnumArr: [String] = []
    // 점자 번호 이진수로 갖고있는 배열 ex) ["100011", "010010", "001001", "101100", "000000"]
    
    @IBOutlet var dot0: UIImageView!
    @IBOutlet var dot1: UIImageView!
    @IBOutlet var dot2: UIImageView!
    @IBOutlet var dot4: UIImageView!
    @IBOutlet var dot5: UIImageView!
    @IBOutlet var dot3: UIImageView!
    
    @IBOutlet var text: UILabel!
    @IBOutlet var imgView: UIImageView!
    
    var normalText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        strIdx = 0
    
        uploadImg()
        // 데이터 받아와서 라벨에 저장
        
    }
    // 사진 올리기
    func uploadImg() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
//        picker.allowsEditing = true
        self.present(picker, animated: false)
        
    }
    // 이미지 피커 취소했을 때
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: false)
    }
    // 이미지 피커 성공 했을 때
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: false) { () in
            let img = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            self.imgView.image = img
            // 이미지 뷰에 이미지 저장
            
            //이미지 파이어베이스 스토리지에 업로드
            let storageRef = self.storage.reference()
            // Data in memory
            let data = self.imgView.image!.jpegData(compressionQuality: 0.9)!

            // Create a reference to the file you want to upload
            let riversRef = storageRef.child("object.jpg")

            // Upload the file to the path "images/rivers.jpg"
            let uploadTask = riversRef.putData(data, metadata: nil) { (metadata, error) in
              guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
              }
              // Metadata contains file metadata such as size, content-type.
              let size = metadata.size
              // You can also access to download URL after upload.
              riversRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                  // Uh-oh, an error occurred!
                  return
                }
                  
                  //문제
                  var image = "\(downloadURL)"
//                  image = image.trimmingCharacters(in: ["\\"])
                  self.req(image: image)
                  print(downloadURL.absoluteString)
              }
            }
        }
//        convert()
    }
    // 점자 앞글자로 이동
    @IBAction func forward(_ sender: Any) {
        if strIdx < brlnumArr.count - 1{
            UIDevice.vibrate()
            strIdx += 1
            // 표시되는 점자 변경
        }
        print("forward\nstrIdx: \(strIdx)")
        changeColor()
    }
    // 점자 뒷글자로 이동
    @IBAction func backward(_ sender: Any) {
        if 0 < strIdx{
            UIDevice.vibrate()
            strIdx -= 1
            // 표시되는 점자 변경
        }
        print("backward\nstrIdx: \(strIdx)")
        changeColor()
    }
    // imgURL로 리퀘스트
    func req(image imgURL:String){
        let url = "https://oe-ocr-firebase.herokuapp.com/home/"
        let parameters : Parameters = [
            "image": imgURL
        ]
        AF.request(url,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding(options: []),
                   headers: ["Content-Type":"application/json", "Accept":"application/json"])
            .responseJSON { response in
                debugPrint(response)
            /** 서버로부터 받은 데이터 활용 */
            switch response.result {
            case .success(let data):
                print("성공", data)
                /** 정상적으로 reponse를 받은 경우 */
            case .failure(let error):
                /** 그렇지 않은 경우 */
                print("실패", error)
            }
        }
    }
    
    // 입력받은 노말 스트링 점자로 변환
    func convert() {

        let str: String = "의자10 화분3 식탁2 우산1"
        // 입력받은 텍스트 소문자로 저장
        var rValue:String = ""
        // 반환할 점자 스트링
        
        strIdx = 0
        // 새로운 str 들어와서 strIdx 초기화 해줘야함
        
        // 입력받은 stirng 점자로 변환
//        let alpBrl: [Character] = ["⠁", "⠃", "⠉", "⠙", "⠑", "⠋", "⠛", "⠓", "⠊", "⠚", "⠅", "⠇", "⠍", "⠝","⠕", "⠏", "⠟", "⠗", "⠎", "⠞", "⠥", "⠧", "⠺", "⠭", "⠽", "⠵", ]
        
//        for i in 0..<str.count{
//
//            let char: Character = String.getChar(at: i)
//            if let firstIndex = alpBrl.firstIndex(of: char) {
//                brlNumArr.append(String(String( format:"%06d", Int(String(firstIndex, radix: 2))!).reversed()))
//
//            }
            // Char Arr에서 찾은 인덱스를 brlNumArr에 추가
//        }
        for i in 0..<str.count{
            let char:Character = str.getChar(at: i)
            switch char {
            case "a":rValue.append("⠁")
            case "b":rValue.append("⠃")
            case "c":rValue.append("⠉")
            case "d":rValue.append("⠙")
            case "e":rValue.append("⠑")
            case "f":rValue.append("⠋")
            case "g":rValue.append("⠛")
            case "h":rValue.append("⠓")
            case "i":rValue.append("⠊")
            case "j":rValue.append("⠚")
            case "k":rValue.append("⠅")
            case "l":rValue.append("⠇")
            case "m":rValue.append("⠍")
            case "n":rValue.append("⠝")
            case "o":rValue.append("⠕")
            case "p":rValue.append("⠏")
            case "q":rValue.append("⠟")
            case "r":rValue.append("⠗")
            case "s":rValue.append("⠎")
            case "t":rValue.append("⠞")
            case "u":rValue.append("⠥")
            case "v":rValue.append("⠧")
            case "w":rValue.append("⠺")
            case "x":rValue.append("⠭")
            case "y":rValue.append("⠽")
            case "z":rValue.append("⠵")
            case " ":rValue.append("\n")
            default:
                rValue=KorToBraille.korTranslate(str)
                break
            }
            
        }// 점자로 변환해서 rValue에 저장
        sleep(5)

        text.text = str
        
        print(rValue)
        brlnumArr = brlToBin(brlStr: rValue)
        // 점자 이진수 str으로 바꿔서 배열에 저장
        print(brlnumArr)
        view.endEditing(true)
        changeColor()
    }
    
    func brlToBin (brlStr bs: String) -> [String] {

        var brlNumArr: [String] = []
        let brl: [Character] = ["⠀","⠁","⠂","⠃","⠄","⠅","⠆","⠇","⠈","⠉","⠊","⠋","⠌","⠍","⠎","⠏","⠐","⠑","⠒","⠓","⠔","⠕","⠖","⠗","⠘","⠙","⠚","⠛","⠜","⠝","⠞","⠟","⠠","⠡","⠢","⠣","⠤","⠥","⠦","⠧","⠨","⠩","⠪","⠫","⠬","⠭","⠮","⠯","⠰","⠱","⠲","⠳","⠴","⠵","⠶","⠷","⠸","⠹","⠺","⠻","⠼","⠽","⠾","⠿"]
        

        for i in 0..<bs.count{
            
            let char: Character = bs.getChar(at: i)
            if let firstIndex = brl.firstIndex(of: char) {
                brlNumArr.append(String(String( format:"%06d", Int(String(firstIndex, radix: 2))!).reversed()))
                // https://gonslab.tistory.com/36 숫자 자릿수 있게 나타내기 ex) 000213
                // https://eunjin3786.tistory.com/497 2진수로 변환
            }
            // Char Arr에서 찾은 인덱스를 brlNumArr에 추가
            
        }
        return brlNumArr
    }
    
    func changeColor() {
        if brlnumArr[strIdx].getChar(at: 0) == "1"{
            dot0.tintColor  = .black
        }
        else{
            dot0.tintColor  = .lightGray
        }
        if brlnumArr[strIdx].getChar(at: 1) == "1"{
            dot1.tintColor  = .black
        }
        else{
            dot1.tintColor  = .lightGray
        }
        if brlnumArr[strIdx].getChar(at: 2) == "1"{
            dot2.tintColor  = .black
        }
        else{
            dot2.tintColor  = .lightGray
        }
        if brlnumArr[strIdx].getChar(at: 3) == "1"{
            dot3.tintColor  = .black
        }
        else{
            dot3.tintColor  = .lightGray
        }
        if brlnumArr[strIdx].getChar(at: 4) == "1"{
            dot4.tintColor  = .black
        }
        else{
            dot4.tintColor  = .lightGray
        }
        if brlnumArr[strIdx].getChar(at: 5) == "1"{
            dot5.tintColor  = .black
        }
        else{
            dot5.tintColor  = .lightGray
        }
    }

    
    // 터치가 시작 될 때 좌표 GCPoint로 얻어오는 함수
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let point = touch.location(in: touch.view)
        if brlnumArr.count == 0 { return }
        if dot0.frame.origin.x < point.x && point.x < dot0.frame.origin.x + dot0.frame.width{
            if dot0.frame.origin.y < point.y && point.y < dot0.frame.origin.y + dot0.frame.height {
                if brlnumArr[strIdx].getChar(at: 0) == "1"{
                    UIDevice.vibrate()
                    print("1")
                }
                lastTouch = 0
            }
            else if dot1.frame.origin.y < point.y && point.y < dot1.frame.origin.y + dot1.frame.height{
                if brlnumArr[strIdx].getChar(at: 1) == "1"{
                    UIDevice.vibrate()
                    print("2")
                }
                lastTouch = 1
            }
            else if dot2.frame.origin.y < point.y && point.y < dot2.frame.origin.y + dot2.frame.height{
                if brlnumArr[strIdx].getChar(at: 2) == "1"{
                    UIDevice.vibrate()
                    print("3")
                }
                lastTouch = 2
            }
        }
        else if dot3.frame.origin.x < point.x && point.x < dot3.frame.origin.x + dot3.frame.width{
            if dot3.frame.origin.y < point.y && point.y < dot3.frame.origin.y + dot1.frame.height {
                if brlnumArr[strIdx].getChar(at: 3) == "1"{
                    UIDevice.vibrate()
                    print("4")
                    lastTouch = 3
                }
            }
            else if dot4.frame.origin.y < point.y && point.y < dot4.frame.origin.y + dot4.frame.height{
                if brlnumArr[strIdx].getChar(at: 4) == "1"{
                    UIDevice.vibrate()
                    print("5")
                }
                lastTouch = 4
            }
            else if dot5.frame.origin.y < point.y && point.y < dot5.frame.origin.y + dot5.frame.height{
                if brlnumArr[strIdx].getChar(at: 5) == "1"{
                    UIDevice.vibrate()
                    print("6")
                }
                lastTouch = 5
            }
        }
    }

    // 터치한 상태에서 움직일 때마다 좌표 GCPoint로 얻어오는 함수
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let point = touch.location(in: touch.view)
        
        if brlnumArr.count == 0 { return }
        if dot0.frame.origin.x < point.x && point.x < dot0.frame.origin.x + dot0.frame.width{
            if dot0.frame.origin.y < point.y && point.y < dot0.frame.origin.y + dot0.frame.height {
                if brlnumArr[strIdx].getChar(at: 0) == "1" && lastTouch != 0{
                    UIDevice.vibrate()
                    print("1")
                }
                lastTouch = 0
            }
            else if dot1.frame.origin.y < point.y && point.y < dot1.frame.origin.y + dot1.frame.height{
                if brlnumArr[strIdx].getChar(at: 1) == "1" && lastTouch != 1{
                    UIDevice.vibrate()
                    print("2")
                }
                lastTouch = 1
            }
            else if dot2.frame.origin.y < point.y && point.y < dot2.frame.origin.y + dot2.frame.height{
                if brlnumArr[strIdx].getChar(at: 2) == "1" && lastTouch != 2{
                    UIDevice.vibrate()
                    print("3")
                }
                lastTouch = 2
            }
        }
        else if dot3.frame.origin.x < point.x && point.x < dot3.frame.origin.x + dot3.frame.width{
            if dot3.frame.origin.y < point.y && point.y < dot3.frame.origin.y + dot1.frame.height {
                if brlnumArr[strIdx].getChar(at: 3) == "1" && lastTouch != 3{
                    UIDevice.vibrate()
                    print("4")
                }
                lastTouch = 3
            }
            else if dot4.frame.origin.y < point.y && point.y < dot4.frame.origin.y + dot4.frame.height{
                if brlnumArr[strIdx].getChar(at: 4) == "1" && lastTouch != 4{
                    UIDevice.vibrate()
                    print("5")
                }
                lastTouch = 4
            }
            else if dot5.frame.origin.y < point.y && point.y < dot5.frame.origin.y + dot5.frame.height{
                if brlnumArr[strIdx].getChar(at: 5) == "1" && lastTouch != 5{
                    UIDevice.vibrate()
                    print("6")
                }
                lastTouch = 5
            }
        }
        
    }
    
}


// #################### extension ###################
extension String {
    func getChar(at index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
}

extension UIDevice {

    static func vibrate() {
        print("진동")
//        AudioServicesPlaySystemSound(4095)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    // https://lxxyeon.tistory.com/124 진동
}
