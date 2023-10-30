# OPEN-EYES

### Presentation

[![Presentation_video](presentation_thumbnail.jpg)](https://youtu.be/YORpgvFTvq0?si=bonLfO1YvJ70FhfE)

## iPhone

| ![phone1](https://github.com/JDeoks/OPEN-EYES/blob/main/Images/OE1-6.5.jpeg) | ![phone2](https://github.com/JDeoks/OPEN-EYES/blob/main/Images/OE2-6.5.jpeg) | ![phone3](https://github.com/JDeoks/OPEN-EYES/blob/main/Images/OE3-6.5.jpeg) |
| ---------------------------------------------------------------------------- | ---------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |

## Apple Watch

| ![watch1](https://github.com/JDeoks/OPEN-EYES/blob/main/Images/watch1.png) | ![watch2](https://github.com/JDeoks/OPEN-EYES/blob/main/Images/watch2.png) | ![watch3](https://github.com/JDeoks/OPEN-EYES/blob/main/Images/watch3.png) |
| -------------------------------------------------------------------------- | -------------------------------------------------------------------------- | -------------------------------------------------------------------------- |

## Intro

OPEN EYES is an app designed to protect visually impaired individuals in situations where they rely on auditory perception to understand their surroundings. Instead of using the TTS (Text-to-Speech) feature on a smartphone, which can potentially block the important sensory input of hearing and lead to accidents, OPEN EYES offers an alternative solution.

The app works by sending the visual information captured by the client's device to a server for object recognition and document scanning. The server then processes this information and converts it into a string of text. This text is subsequently translated into Braille, and the translation is conveyed to the client through vibrations on their Apple Watch.

Object Recognition: The app utilizes object recognition technology to identify and describe objects in real-time. This enables users to better understand their surroundings and interact with their environment more independently.

Document Scanning: OPEN EYES can scan and convert printed text into digital text using optical character recognition (OCR) technology. This allows users to access information from books, documents, and other printed materials by translating the text into Braille.

The six cells, divided into six sections, correspond to the six dots in Braille that represent a single character. When your finger touches the raised portion, it will vibrate to indicate the presence of a raised dot.

In this way, OPEN EYES enables visually impaired individuals to access visual information through the sense of touch, providing them with a safer and more inclusive experience.

## Installation

Search for [OPEN-EYES](https://apps.apple.com/kr/app/open-eyes/id6449876591) in the App Store and install it.

## Basic Configuration

[Shortcut to Open the App with AssistiveTouch on Apple Watch](https://www.icloud.com/shortcuts/8b58e7f1a03349e6ac8227780984804e)  
[If the Shortcut Download Doesn't Work](https://wealthy-wasabi-c41.notion.site/b10e5a2f0d344b77ac50849c9e3f6611)

## How to use

1. Open the Watch app using AssistiveTouch.
2. Use Siri to open the app on your iPhone.
3. Shake your phone to launch the camera.
4. Receive the text recognition results from the photo through vibrations on your watch or phone.  
   You can use the crown on your Apple Watch to navigate to the previous or next characters of the text.
5. If the document is long, long-press the screen on your iPhone to listen to the text recognition results through audio.

## Used Libraries

- [SwiftUI](https://developer.apple.com/documentation/swiftui/)
- [CoreML](https://developer.apple.com/documentation/coreml/)
- [Watch Connectivity](https://developer.apple.com/documentation/watchconnectivity/)
- [KorToBraille](https://github.com/Bridge-NOONGIL/KorToBraille)
