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
        VStack {
            HStack {
                Button("Take Photo") {
                    sourceType = .camera
                    showImagePicker = true
                }
                .padding()

                Button("Pick from Library") {
                    sourceType = .photoLibrary
                    showImagePicker = true
                }
                .padding()
            }

            if let selectedImage = image {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .padding()
            }

            if !classificationResult.isEmpty {
                Text("Prediction: \(classificationResult)")
                    .font(.headline)
                    .padding()
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: $sourceType,
                        image: $image,
                        onImagePicked: classifyImage)
        }
    }

    func classifyImage(_ uiImage: UIImage) {
        guard let model = try? VNCoreMLModel(for: MobileNetV2().model),
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
