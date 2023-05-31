//
//  MandelbrotDrawing.swift
//  Mandelbrot
//
//  Created by Stanislav Kimov on 30.05.23.
//

import Foundation
import UIKit

class MandelbrotDrawing {
  let rect: CGRect = CGRect(x: 0, y: 0, width: 300, height: 300)
  var randomColorList: [Int: UIColor] = [:]
  let maxIterations = 500
  
  init() {
    for i in 0...maxIterations {
        self.randomColorList[i] = UIColor(
            red: CGFloat(arc4random()) / CGFloat(UInt32.max),
            green: CGFloat(arc4random()) / CGFloat(UInt32.max),
            blue: CGFloat(arc4random()) / CGFloat(UInt32.max),
            alpha: CGFloat(arc4random()) / CGFloat(UInt32.max))
    }
  }
  
  private func goodBytesPerRow(_ width: Int) -> Int {
      return (((width * 4) + 15) / 16) * 16
  }

  private func drawEmptyImage(width: Int, height: Int) -> CGImage? {
      let bounds = CGRect(x: 0, y: 0, width: width, height: height)
      let intWidth = Int(ceil(bounds.width))
      let intHeight = Int(ceil(bounds.height))
      let bitmapContext = CGContext(data: nil,
                                    width: intWidth, height: intHeight,
                                    bitsPerComponent: 8,
                                    bytesPerRow: goodBytesPerRow(intWidth),
                                    space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                    bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)

      if let cgContext = bitmapContext {
          cgContext.saveGState()
          cgContext.setFillColor(gray: 0, alpha: 1.0)
          cgContext.fill(bounds)

          cgContext.restoreGState()

          return cgContext.makeImage()
      }

      return nil
  }
  
  func drawMandelbrotImage(width: Int, height: Int) -> UIImage? {
    guard let cgImage = drawEmptyImage(width: width, height: height) else { return nil }
    
    // Redraw image for correct pixel format
    var colorSpace = CGColorSpaceCreateDeviceRGB()
    
    var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
    bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
    
    var bytesPerRow = width * 4
    
    let imageData = UnsafeMutablePointer<Pixel>.allocate(capacity: width * height)
    
    guard let imageContext = CGContext(
        data: imageData,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerRow,
        space: colorSpace,
        bitmapInfo: bitmapInfo
    ) else { return nil }
    
    imageContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    let pixels = UnsafeMutableBufferPointer<Pixel>(start: imageData, count: width * height)
    
    for y in 0..<height {
      for x in 0..<width {
        let index = y * width + x
        var pixel = pixels[index]
        
        let calculateX = -2 + Float80(x) / Float80(self.rect.width) * 4
        let calculateY = -2 + Float80(y) / Float80(self.rect.height) * 4
        
        let iteration = Mandelbrot.calculatePixelColor(
          pixelX: calculateX,
          pixelY: calculateY,
          maxIteration: self.maxIterations
        )
        
        let color = self.randomColorList[iteration]!
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
        pixel.red = UInt8(red * CGFloat(UInt8.max))
        pixel.green = UInt8(green * CGFloat(UInt8.max))
        pixel.blue = UInt8(blue * CGFloat(UInt8.max))
          
        pixels[index] = pixel
      }
    }
    
    colorSpace = CGColorSpaceCreateDeviceRGB()
    bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue
    bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
    
    bytesPerRow = width * 4
    
    guard let context = CGContext(
        data: pixels.baseAddress,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerRow,
        space: colorSpace,
        bitmapInfo: bitmapInfo,
        releaseCallback: nil,
        releaseInfo: nil
    ) else { return nil }
    
    guard let newCGImage = context.makeImage() else { return nil }
    return UIImage(cgImage: newCGImage)
  }
  
  struct Pixel {
      public var value: UInt32
      
      public var red: UInt8 {
          get {
              return UInt8(value & 0xFF)
          } set {
              value = UInt32(newValue) | (value & 0xFFFFFF00)
          }
      }
      
      public var green: UInt8 {
          get {
              return UInt8((value >> 8) & 0xFF)
          } set {
              value = (UInt32(newValue) << 8) | (value & 0xFFFF00FF)
          }
      }
      
      public var blue: UInt8 {
          get {
              return UInt8((value >> 16) & 0xFF)
          } set {
              value = (UInt32(newValue) << 16) | (value & 0xFF00FFFF)
          }
      }
      
      public var alpha: UInt8 {
          get {
              return UInt8((value >> 24) & 0xFF)
          } set {
              value = (UInt32(newValue) << 24) | (value & 0x00FFFFFF)
          }
      }
  }
}

