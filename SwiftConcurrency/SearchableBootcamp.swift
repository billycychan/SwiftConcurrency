//
//  SearchableBootcamp.swift
//  SwiftConcurrency
//
//  Created by CHI YU CHAN on 20/7/2023.
//

import SwiftUI
import Combine

struct Restaurant: Identifiable, Hashable {
    let id: String
    let title: String
    let cuisine: CuisineOption
}

enum CuisineOption: String {
    case american, italian, japanese
}

final class RestaurantManager {
    func getAllRestaurant() async throws -> [Restaurant] {
        [
            Restaurant(id: "1", title: "Burger Shack", cuisine: .american),
            Restaurant(id: "2", title: "Pasta Palace", cuisine: .italian),
            Restaurant(id: "3", title: "Sushi Heaven", cuisine: .japanese),
            Restaurant(id: "4", title: "Local Market", cuisine: .american)
        ]
    }
}

@MainActor
final class SearchableViewModel: ObservableObject {
    
    @Published private(set) var allRestaurants: [Restaurant] = []
    @Published private(set) var filteredRestaurants: [Restaurant] = []

    @Published var searchText: String = ""
    
    @Published var searchScope: SearchScopeOption = .all
    @Published private(set) var allSearchScopes: [SearchScopeOption] = []
    
    let manager = RestaurantManager()
    private var cancaellable = Set<AnyCancellable>()
    
    var isSearching: Bool {
        !searchText.isEmpty
    }
    
    var showSearchSuggestion:  Bool {
        searchText.count < 5
    }
    
    enum SearchScopeOption: Hashable {
        case all
        case cuisine(option: CuisineOption)
        
        var title: String {
            switch self {
            case .all: return "All"
            case .cuisine(option: let option): return option.rawValue.capitalized
            }
        }
    }
    
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        $searchText
            .combineLatest($searchScope)
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] (searchText, searchScope) in
                self?.filterRestaurants(searchText: searchText, currentSearchScope: searchScope)
            }
            .store(in: &cancaellable)
    }
    
    private func filterRestaurants(searchText: String, currentSearchScope: SearchScopeOption) {
        guard !searchText.isEmpty else {
            filteredRestaurants = []
            searchScope = .all
            return
        }
        
        // Filter on SearchScope
        var restaurantsInScope = allRestaurants
        switch currentSearchScope {
        case .all:
            break
        case .cuisine(option: let option):
            restaurantsInScope = allRestaurants.filter { $0.cuisine == option }
        }
        
        // Filter on searchText
        let search = searchText.lowercased()
        filteredRestaurants = restaurantsInScope.filter {
            let titleContainsSeach = $0.title.lowercased().contains(search)
            let cuisineeContainsSeach = $0.cuisine.rawValue.lowercased().contains(search)
            return titleContainsSeach || cuisineeContainsSeach
        }
    }
    
    func loadRestaurant() async {
        do {
            allRestaurants = try await manager.getAllRestaurant()
            let allCuisines = Set(allRestaurants.map { $0.cuisine })
            allSearchScopes = [.all] + allCuisines.map { SearchScopeOption.cuisine(option: $0)}
            
        } catch {
            print(error)
        }
    }
    
    func getSearchSuggestions() -> [String] {
        guard showSearchSuggestion else {
            return []
        }
        var suggestions: [String] = []
        
        let search = searchText.lowercased()
        if search.contains("pa") {
            suggestions.append("Pasta")
        }
        if search.contains("su") {
            suggestions.append("sushi")
        }
        if search.contains("bu") {
            suggestions.append("burger")
        }
        suggestions.append("Market")
        suggestions.append("Grocery")
        
        suggestions.append(CuisineOption.italian.rawValue.capitalized)
        suggestions.append(CuisineOption.american.rawValue.capitalized)
        suggestions.append(CuisineOption.japanese.rawValue.capitalized)
        
        return suggestions
    }
    
    func getRestaurantSuggestion() -> [Restaurant] {
        guard showSearchSuggestion else {
            return []
        }
        var suggestions: [Restaurant] = []
        
        let search = searchText.lowercased()
        if search.contains("ita") {
            suggestions.append(contentsOf: allRestaurants.filter({ $0.cuisine == .italian}))
        }
        if search.contains("jap") {
            suggestions.append(contentsOf: allRestaurants.filter({ $0.cuisine == .japanese}))
        }
        
        return suggestions
    }
    
}

struct SearchableBootcamp: View {
    
    @StateObject private var viewModel = SearchableViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(viewModel.isSearching ? viewModel.filteredRestaurants : viewModel.allRestaurants) { restaurant in
                        NavigationLink(value: restaurant) {
                            restaurantRow(restaurant: restaurant)
                        }
                    }
                }
                .padding()
                Text("ViewModel is searching: \(viewModel.isSearching.description)")
                SearchChildView()
            }
            .searchable(text: $viewModel.searchText, placement: .automatic, prompt: "Search restaurant")
            .searchScopes($viewModel.searchScope, scopes: {
                ForEach(viewModel.allSearchScopes, id: \.self) { scope in
                    Text(scope.title)
                        .tag(scope)
                }
            })
            .searchSuggestions({
                ForEach(viewModel.getSearchSuggestions(), id: \.self) { suggestion in
                    Text(suggestion)
                        .searchCompletion(suggestion)
                }
                
                ForEach(viewModel.getRestaurantSuggestion(), id: \.self) { suggestion in
                    NavigationLink(value: suggestion) {
                        Text(suggestion.title)
                    }
                }
            })
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Restaurants")
        }
        .task {
            await viewModel.loadRestaurant()
        }
        .navigationDestination(for: Restaurant.self) { restaurant in
            Text(restaurant.title.uppercased())
        }
    }
    
    private func restaurantRow(restaurant: Restaurant) -> some View  {
        VStack(alignment: .leading, spacing: 10) {
            Text(restaurant.title)
                .font(.headline)
                .foregroundColor(.red)
            Text(restaurant.cuisine.rawValue.capitalized)
                .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.05))
        .tint(.primary)
    }
}

struct SearchChildView: View {
    
    @Environment(\.isSearching) private var isSearching
    
    var body: some View {
        Text("Child View is searching: \(isSearching.description)")
    }
    
}

struct SearchableBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SearchableBootcamp()
        }
    }
}
