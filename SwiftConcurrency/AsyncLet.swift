//
//  AsyncLet.swift
//  SwiftConcurrency
//
//  Created by CHI YU CHAN on 17/7/2023.
//

import SwiftUI

struct AsyncLet: View {
    
    @State private var images: [UIImage] = []
    let columns = [GridItem(.flexible()), GridItem(.flexible()) ]
    let url = URL(string: "https://picsum.photos/300")!
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Async Let 🥳")
            .onAppear {
                Task {
                    do {
                        
                        async let fetchImage1 = fetchImages()
                        async let fetchTitle1 = fetchTitle()
                        
                        let (image, title) = await (try fetchImage1, fetchTitle1)
                        
//                        async let fetchImage2 = fetchImages()
//                        async let fetchImage3 = fetchImages()
//                        async let fetchImage4 = fetchImages()
//
//                        let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
//                        self.images.append(contentsOf: [image1, image2, image3, image4])
//
//                        let image1 = try await fetchImages()
//                        self.images.append(image1)
//
//                        let image2 = try await fetchImages()
//                        self.images.append(image1)
//
//                        let image3 = try await fetchImages()
//                        self.images.append(image1)
//
//                        let image4 = try await fetchImages()
//                        self.images.append(image1)
                    } catch {
                        
                    }
                }
            }
        }
    }
    
    func fetchImages() async throws -> UIImage {
        do {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    
    func fetchTitle() async -> String {
        return "new Title"
    }
}

struct AsyncLet_Previews: PreviewProvider {
    static var previews: some View {
        AsyncLet()
    }
}
