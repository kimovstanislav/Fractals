//
//  ContentView.swift
//  Mandelbrot
//
//  Created by Stanislav Kimov on 30.05.23.
//

import SwiftUI
import CoreImage
import CoreGraphics

struct ContentView: View {
    var body: some View {
        VStack {
          createMandelbrotImage()
            Text("Hello, Mandelbrot!")
        }
        .padding()
    }
  
  func createMandelbrotImage() -> Image {
    let mandelbrotImage = MandelbrotDrawing().drawMandelbrotImage(width: 300, height: 300)!
    return Image(uiImage: mandelbrotImage)
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
