//
//  AsyncPublisherBootCamp.swift
//  SwiftConcurrency
//
//  Created by CHI YU CHAN on 19/7/2023.
//

import SwiftUI
import Combine

class AsyncPublisherDataManager {
    
    @Published var myData: [String] = []
    
    func addData() async {
        myData.append("Apple")
        try? await Task.sleep(for: .nanoseconds(2_000_000_000))
        myData.append("Banana")
        try? await Task.sleep(for: .nanoseconds(2_000_000_000))
        myData.append("Orange")
        try? await Task.sleep(for: .nanoseconds(2_000_000_000))
        myData.append("Waterlemon")
        try? await Task.sleep(for: .nanoseconds(2_000_000_000))
    }
}

class AsyncPublisherBootCampViewModel: ObservableObject {
    
    @Published var dataArray: [String] = []
    let manager = AsyncPublisherDataManager()
    var canellable = Set<AnyCancellable>()
    
    
    init() {
        addSubscribers()
    }
    
    func start() async {
        await manager.addData()
    }
    
    private func addSubscribers() {
        Task {
            for await value in manager.$myData.values {
                await MainActor.run(body: {
                    self.dataArray = value
                })
            }
        }
        
//        manager.$myData
//            .receive(on: DispatchQueue.main, options: nil)
//            .sink { dataArray in
//                self.dataArray = dataArray
//            }
//            .store(in: &canellable)
    }
}

struct AsyncPublisherBootCamp: View {
    
    @StateObject private var viewModel = AsyncPublisherBootCampViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task {
           await viewModel.start()
        }
    }
}

struct AsyncPublisherBootCamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncPublisherBootCamp()
    }
}
