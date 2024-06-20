//
//  ContentView.swift
//  InstaFilter
//
//  Created by Mehmet Alp Sönmez on 19/06/2024.
//

import PhotosUI
import StoreKit
import SwiftUI

struct ContentView: View {
    @Environment(\.requestReview) var requestView
    @State private var pickerItems = [PhotosPickerItem]()
    @State private var selectedImages = [Image]()

    var body: some View {
        VStack {
            PhotosPicker( selection: $pickerItems, maxSelectionCount: 3, matching: .any(of: [
                .images, .not(.screenshots)])) {
                Label("Select a picture", systemImage: "photo")
            }
            
            ScrollView(.horizontal) {
                ForEach(0..<selectedImages.count, id:\.self) { i in
                    selectedImages[i]
                        .resizable()
                        .scaledToFit()
                }
            }
            
            ShareLink(item: URL(string: "https://www.hackingwithswift.com")!) {
                Label("Spread the word about Swift", systemImage: "swift")
            }
            
            let example = Image(.example)
            
            ShareLink(item: example, preview: SharePreview("House", image: example)) {
                Label("Click to share", systemImage: "airplane")
            }
            
            Button ("Leave a review") {
                requestView()
            }
        }
        .onChange(of: pickerItems) {
            Task {
                selectedImages.removeAll()
                
                for item in pickerItems {
                    if let loadedImage = try await item.loadTransferable(type: Image.self) {
                        selectedImages.append(loadedImage)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
