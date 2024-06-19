//
//  ContentView.swift
//  InstaFilter
//
//  Created by Mehmet Alp Sönmez on 19/06/2024.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
    @State private var image: Image?
    
    
    var body: some View {
        VStack {
            image?
                .resizable()
                .scaledToFit()
        }
        .onAppear(perform: loadImage)

    }
    
    func loadImage() {
        let inputImage = UIImage(resource: .example)
        let beginImage = CIImage(image: inputImage)
        
        let context = CIContext()
        let currentFilter = CIFilter.twirlDistortion()
        
        currentFilter.inputImage = beginImage
        let amount = 1.0
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(amount, forKey: kCIInputIntensityKey)}
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(amount * 200, forKey: kCIInputRadiusKey)}
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(amount * 10, forKey: kCIInputScaleKey)}
        
        
        currentFilter.radius = 2000
        currentFilter.center = CGPoint(x: inputImage.size.width / 2, y: inputImage.size.height / 2)
        
        guard let outputImage = currentFilter.outputImage else { return }
        guard let cgImg = context.createCGImage(outputImage, from: outputImage.extent)
        else { return }
        
        let uiImage = UIImage(cgImage: cgImg)
        image = Image(uiImage: uiImage)
    }
}

#Preview {
    ContentView()
}
