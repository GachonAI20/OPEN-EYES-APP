# OPEN-EYES

![Image 1](https://github.com/JDeoks/OPEN-EYES/blob/main/Images/OE1-6.5.jpeg) | ![Image 2](https://github.com/JDeoks/OPEN-EYES/blob/main/Images/OE2-6.5.jpeg) | ![Image 3](https://github.com/JDeoks/OPEN-EYES/blob/main/Images/OE3-6.5.jpeg)

## Intro

OPEN EYES is an app designed to protect visually impaired individuals in situations where they rely on auditory perception to understand their surroundings. Instead of using the TTS (Text-to-Speech) feature on a smartphone, which can potentially block the important sensory input of hearing and lead to accidents, OPEN EYES offers an alternative solution.

The app works by sending the visual information captured by the client's device to a server for object recognition and document scanning. The server then processes this information and converts it into a string of text. This text is subsequently translated into Braille, and the translation is conveyed to the client through vibrations on their Apple Watch.

In this way, OPEN EYES enables visually impaired individuals to access visual information through the sense of touch, providing them with a safer and more inclusive experience.

## 설치

앱스토어에서 OPEN-EYES 검색 후 설치

## 기본 설정

[애플워치 손쉬운 사용으로 앱 열기 단축어](https://www.icloud.com/shortcuts/8b58e7f1a03349e6ac8227780984804e)  
[단축어 다운로드가 안될 경우](https://wealthy-wasabi-c41.notion.site/b10e5a2f0d344b77ac50849c9e3f6611)

## 사용 라이브러리

- [SwiftUI](https://developer.apple.com/kr/xcode/swiftui/)
- [CoreML](https://developer.apple.com/kr/machine-learning/core-ml/)
- [Watch Connectivity](https://developer.apple.com/documentation/watchconnectivity)
- [KorToBraille](https://github.com/Bridge-NOONGIL/KorToBraille)
