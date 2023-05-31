//
//  Extentions.swift
//  OE_SwiftUI
//
//  Created by 서정덕 on 2023/05/02.
//
import SwiftUI
import Foundation
import CoreVideo

extension UIImage {
    func toCVPixelBuffer(width: Int = 299, height: Int = 299) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer? = nil

        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, nil, &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        let context = CGContext(data: pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer), space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return pixelBuffer
    }
}

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
