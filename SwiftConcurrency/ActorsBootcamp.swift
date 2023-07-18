//
//  ActorsBootcamp.swift
//  SwiftConcurrency
//
//  Created by CHI YU CHAN on 18/7/2023.
//

import SwiftUI

// 1. What is the problem that actor are solving
// 2. How was this problem solved prior to actors?
// 3. Actors can solve the problem


class MyDataManager {
    
    static let instance = MyDataManager()
    private init() { }
    
    var data: [String] = []
    private let lock = DispatchQueue(label: "com.myApp.MyDataManager")
    
    func getRandomData(completionHandler: @escaping
                       (_ title: String?) -> Void) {
        lock.async {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            completionHandler(self.data.randomElement())
        }
    }
}

actor MyActorDataManager {
    
    static let instance = MyActorDataManager()
    private init() { }
    
    var data: [String] = []
    
    nonisolated let myRandomText = "djlfkasjdlkfm,23123"
    
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return self.data.randomElement()
    }
    
    // no need the `await` keyword
   nonisolated func getSavedData() -> String {
        return "NEW DATA"
       
//       let data = getRandomData()
    }
}

struct HomeView: View {
    
    let manager = MyActorDataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.1, tolerance: nil, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onAppear {
            Task {
                let data = manager.getSavedData()
                let text = manager.myRandomText
            }
        }
        .onReceive(timer) { _ in
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run(body: {
                        self.text = data
                    })
                }
            }
//            DispatchQueue.global(qos: .background).async {
//                manager.getRandomData { title in
//                    if let title = title {
//                        DispatchQueue.main.async {
//                            self.text = title
//                        }
//                    }
//                }
//            }
        }
    }
}

struct BrowseView: View {
    
    let manager = MyActorDataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.01, tolerance: nil, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.8).ignoresSafeArea()
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run(body: {
                        self.text = data
                    })
                }
            }
//            DispatchQueue.global(qos: .default).async {
//                manager.getRandomData { title in
//                    if let title = title {
//                        DispatchQueue.main.async {
//                            self.text = title
//                        }
//                    }
//                }
//            }
        }
    }
}

struct ActorsBootcamp: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}

struct ActorsBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        ActorsBootcamp()
    }
}
