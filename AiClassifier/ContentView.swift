//
//  ContentView.swift
//  AiClassifier
//
//  Created by Sharath Badam on 5/30/25.
//

import SwiftUI
import Vision
import CoreML

struct ContentView: View {
    @State private var image: UIImage?
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var classificationResult = ""

    var body: some View {
        ZStack {
            // Background wallpaper image
            Image("Background") // Add an image named "background" to your Assets.xcassets
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer() // Push content to center vertically

                HStack(spacing: 20) {
                    Button(action: {
                        sourceType = .camera
                        showImagePicker = true
                    }) {
                        Text("Take Photo")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(10)
                    }

                    Button(action: {
                        sourceType = .photoLibrary
                        showImagePicker = true
                    }) {
                        Text("Pick from Library")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green.opacity(0.8))
                            .cornerRadius(10)
                    }
                }

                if let selectedImage = image {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 10)
                        .padding()
                }

                if !classificationResult.isEmpty {
                    Text("Prediction: \(classificationResult)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(10)
                }

                Spacer() // Push content to center vertically
            }
            .padding()

        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: $sourceType,
                        image: $image,
                        onImagePicked: classifyImage)
        }
    }

    func classifyImage(_ uiImage: UIImage) {
        guard let model = try? VNCoreMLModel(for: Resnet50().model),
              let ciImage = CIImage(image: uiImage) else {
            classificationResult = "Failed to classify image"
            return
        }

        let request = VNCoreMLRequest(model: model) { request, error in
            if let results = request.results as? [VNClassificationObservation],
               let topResult = results.first {
                DispatchQueue.main.async {
                    classificationResult = "\(topResult.identifier.capitalized) (\(Int(topResult.confidence * 100))%)"
                }
            }
        }

        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
}
