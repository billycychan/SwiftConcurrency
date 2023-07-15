//
//  DoCatchTryThrow.swift
//  SwiftConcurrency
//
//  Created by CHI YU CHAN on 14/7/2023.
//

import SwiftUI


class DoCatchTryThrowDataManager {
    
    let isActive: Bool = true
    
    func getTitle() -> (title: String?, error: Error?) {
        
        if isActive {
            return ("NEW TEXT", nil)
        } else {
            return (nil, URLError(.badURL))
        }
    }
    
    func getTitle2() -> Result<String, Error> {
        if isActive {
            return .success("NEW TEXT!")
        } else {
            return .failure(URLError(.appTransportSecurityRequiresSecureConnection))
        }
    }
    
    func getTitle3() throws -> String {
//        if isActive {
//            return "NEW TEXT"
//        } else {
            throw URLError(.badServerResponse)
//        }
    }
    
    func getTitle4() throws -> String {
        if isActive {
            return "FINAL TEXT"
        } else {
            throw URLError(.badServerResponse)
        }
    }
    
}

class DoCatchTryThrowViewModel: ObservableObject {
    
    @Published var text: String = "Starting text"
    let manager = DoCatchTryThrowDataManager()
    
    func fetchTitle() {
        /*
        let returnedValue = manager.getTitle()
        if let newTitle = returnedValue.title {
            self.text = newTitle
        } else if let error = returnedValue.error {
            self.text = error.localizedDescription
        }
         */
        
        /*
        let result = manager.getTitle2()
        
        switch result {
        case .success(let newtitle):
            self.text = newtitle
        case .failure(let error):
            self.text = error.localizedDescription
         */
        
//
//        let newTitle = try? manager.getTitle4()
//        if let newTitle = newTitle {
//            self.text = newTitle
//        }
//
        do {
            let newTitle = try? manager.getTitle3()
            if let newTitle = newTitle {
                self.text = newTitle
            }
            
            let finalText = try manager.getTitle4()
            self.text = finalText

        } catch {
            self.text = error.localizedDescription
        }
    }
}


struct DoCatchTryThrow: View {
    
    @StateObject private var viewModel = DoCatchTryThrowViewModel()
    
    var body: some View {
        Text(viewModel.text)
            .frame(width: 300, height: 300)
            .background(Color.blue)
            .onTapGesture {
                viewModel.fetchTitle()
            }
    }
}

struct DoCatchTryThrow_Previews: PreviewProvider {
    static var previews: some View {
        DoCatchTryThrow()
    }
}
