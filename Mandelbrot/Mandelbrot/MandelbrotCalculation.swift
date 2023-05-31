//
//  MandelbrotImplementation.swift
//  Mandelbrot
//
//  Created by Stanislav Kimov on 30.05.23.
//

import Foundation

class Mandelbrot {
  static func calculatePixelColor(pixelX: Float80, pixelY: Float80, maxIteration: Int) -> Int {
    let x0: Float80 = pixelX
    let y0: Float80 = pixelY
      
    var x: Float80 = 0
    var y: Float80 = 0
      
    var iteration = 0
      
    while (x*x + y*y <= 2*2 && iteration < maxIteration) {
      let xTemp = x*x - y*y + x0
      y = 2*x*y + y0
      x = xTemp
      
      iteration += 1
    }
    
    return iteration
  }
}
