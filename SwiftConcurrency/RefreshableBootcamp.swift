//
//  RefreshableBootcamp.swift
//  SwiftConcurrency
//
//  Created by CHI YU CHAN on 20/7/2023.
//

import SwiftUI

final class RefreshableDataService {
    
    func getData() async throws -> [String] {
        try? await Task.sleep(for: .seconds(2))
        return ["Apple", "Banana", "Orange"].shuffled()
    }
}

@MainActor
final class RefreshableBootcampViewMdel: ObservableObject {
    @Published private(set) var items: [String] = []
    let manager = RefreshableDataService()
    
    func loadData() async {
        do {
            items = try await manager.getData()
        } catch {
            print(error)
        }
    }
}

struct RefreshableBootcamp: View {
    
    @StateObject private var viewModel = RefreshableBootcampViewMdel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(viewModel.items, id: \.self) { item in
                        Text(item)
                    }
                }
            }
            .refreshable {
                await viewModel.loadData()
            }
            .navigationTitle("Refreshable")
            .task {
               await viewModel.loadData()
            }
        }
    }
}

struct RefreshableBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        RefreshableBootcamp()
    }
}
