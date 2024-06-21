//
//  ContentView.swift
//  InstaFilter
//
//  Created by Mehmet Alp Sönmez on 19/06/2024.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import StoreKit
import SwiftUI

struct ContentView: View {
    @State private var processedImage: Image?
    @State private var filterIntensity = 0.5
    @State private var filterRadius = 0.5
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingFilters = false
    
    @AppStorage("filterCount") var filterCount = 0
    @Environment(\.requestReview) var requestView
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    
    let context = CIContext()
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                HStack {
                    PhotosPicker(selection: $selectedItem) {
                        
                        if let processedImage {
                            processedImage
                                .resizable()
                                .scaledToFit()
                        } else {
                            ContentUnavailableView("No Picture", systemImage: "photo.badge.plus", description: Text("Tap to import a photo"))
                        }
                    }
                    .buttonStyle(.plain)
                    .onChange(of: selectedItem, loadImage)
                    
                    if processedImage == nil {
                        ContentUnavailableView("Use Camera", systemImage: "camera", description: Text("Tap to take a photo"))
                    }
                }
                .background(Color.white.opacity(0.7))
                .foregroundStyle(.black)
                
                Spacer()
                
                HStack {
                    Text("Intensity")
                    Slider(value: $filterIntensity, in: 0...1)
                        .onChange(of:filterIntensity, applyProcessing)
                }
                .disabled(processedImage == nil)
                
                HStack {
                    Text("Radius")
                    Slider(value: $filterRadius, in: 0...100)
                        .onChange(of:filterRadius, applyProcessing)
                }
                .disabled(processedImage == nil)
                
                HStack {
                    Button("Change Filter", action: changeFilter)
                        .foregroundStyle(.blue)
                    
                    Spacer()
                    
                    if let processedImage {
                        ShareLink(item: processedImage, preview: SharePreview("Instafilter image", image: processedImage))
                    }
                    
                }
                .disabled(processedImage == nil)
            }
            .padding([.horizontal, .bottom])
            .background(LinearGradient(colors: [.cyan, .black], startPoint: .topLeading, endPoint: .bottomTrailing))
            .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
            .navigationTitle("InstaFilter")
            .confirmationDialog("Select a Filter", isPresented: $showingFilters) {
                Button("Crystallize") { setFilter(CIFilter.crystallize())}
                Button("Edges") { setFilter(CIFilter.edges())}
                Button("Gaussian Blur")  { setFilter(CIFilter.gaussianBlur())}
                Button("Pixellate") { setFilter(CIFilter.pixellate())}
                Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask())}
                Button("Sepia Tone") { setFilter(CIFilter.sepiaTone())}
                Button("Vignette") { setFilter(CIFilter.vignette())}
                Button("Bookeh Blur") { setFilter(CIFilter.bokehBlur())}
                Button("Comic Effect") { setFilter(CIFilter.comicEffect())}
                Button("Gloom") { setFilter(CIFilter.gloom())}
                Button("Pointillize") { setFilter(CIFilter.pointillize())}
                Button("Cancel", role: .cancel) { }
            }
        }
    }
    
    func changeFilter() {
        showingFilters = true
    }
    
    func loadImage() {
        Task {
            guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else { return }
            guard let inputImage = UIImage(data: imageData) else { return }
            
            let beginImage = CIImage(image: inputImage)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            applyProcessing()
        }
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterRadius, forKey: kCIInputRadiusKey)
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey)
        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        
        let uiImage = UIImage(cgImage: cgImage)
        processedImage = Image(uiImage: uiImage)
    }
    
    @MainActor func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
        
        filterCount += 1
        
        if filterCount >= 3 {
            requestView()
            filterCount = 0
        }
    }
}

#Preview {
    ContentView()
}
