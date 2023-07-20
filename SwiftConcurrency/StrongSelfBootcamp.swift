//
//  StrongSelfBootcamp.swift
//  SwiftConcurrency
//
//  Created by CHI YU CHAN on 20/7/2023.
//

import SwiftUI

final class StrongSelfDataService {
    
    func getData() async -> String {
        "Update data"
    }
}

final class StrongSelfBootcampViewModel: ObservableObject {
    
    @Published var data: String = "Some title!"
    let dataService = StrongSelfDataService()
    
    private var someTask: Task<Void, Never>? = nil
    private var myTasks: [Task<Void, Never>] = []
    
    func cancelTasks() {
        someTask?.cancel()
        someTask = nil
        
        myTasks.forEach { $0.cancel() }
        myTasks = []
    }
    
    // This implies a strong reference
    func updateData() {
        Task {
            self.data = await dataService.getData()
        }
    }
    
    // This is a strong reference
    func updateData2() {
        Task {
            self.data = await dataService.getData()
        }
    }
    
    
    // This is a strong reference
    func updateData3() {
        Task { [self] in
            self.data = await dataService.getData()
        }
    }
    
    // This is a weak reference
    func updateData4() {
        Task { [weak self] in
            if let data = await self?.dataService.getData() {
                self?.data = data
            }
        }
    }
    
    // This dont need to managet weak/strong
    // We can mangage the Task.
    func updateData5() {
        someTask = Task {
            self.data = await self.dataService.getData()
        }
    }
    
    func updateData6() {
        let task1 = Task {
            self.data = await self.dataService.getData()
        }
        myTasks.append(task1)
        
        let task2 = Task {
            self.data = await self.dataService.getData()
        }
        myTasks.append(task2)
    }
    
    func updateData7() {
        Task {
            self.data = await self.dataService.getData()
        }
        
        Task.detached {
            self.data = await self.dataService.getData()
        }
    }
    
    func updateData8() async {
        Task { [self] in
            self.data = await dataService.getData()
        }
    }
}

struct StrongSelfBootcamp: View {
    
    @StateObject private var viewModel = StrongSelfBootcampViewModel()
    
    var body: some View {
        Text(viewModel.data)
            .onAppear {
                viewModel.updateData()
            }
            .onDisappear {
                viewModel.cancelTasks()
            }
            .task {
                await viewModel.updateData8()
            }
    }
}

struct StrongSelfBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        StrongSelfBootcamp()
    }
}
