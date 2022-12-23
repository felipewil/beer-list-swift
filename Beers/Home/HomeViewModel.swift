//
//  HomeViewModel.swift
//  Beers
//
//  Created by Felipe Leite on 19/12/22.
//

import Foundation
import Combine

class HomeViewModel {
    
    private struct Consts {
        static let baseURL = URL(string: "https://api.punkapi.com/v2/")
    }
    
    private enum Endpoint {
        case beers(page: Int)
        
        var url: URL? {
            switch self {
            case .beers(let page):
                return Consts.baseURL?
                    .appending(path: "beers")
                    .appending(queryItems: [ URLQueryItem(name: "page", value: "\(page)") ])
            }
        }
    }
    
    // MARK: Properties
    
    private let urlSession: URLSession
    private var currentPage = 0
    private var cancellables: Set<AnyCancellable> = []
    private(set) var hasMore = true
    @Published private(set) var isLoading = false
    @Published private(set) var beers: [ Beer ] = []
    
    // MARK: Initialization
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
        self.setupNotifications()
    }
    
    // MARK: Public methods
    
    /// Load beers from API.
    func loadBeers() {
        guard !self.isLoading, self.hasMore else { return }

        self.currentPage += 1
        
        guard let url = Endpoint.beers(page: self.currentPage).url else { return }

        self.isLoading = true
        self.urlSession
            .dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [ Beer ].self, decoder: JSONDecoder())
            .catch { error in
                self.currentPage -= 1
                self.isLoading = false

                return Empty<[ Beer ], Error>()
            }
            .receive(on: RunLoop.main)
            .sink { _ in } receiveValue: { result in
                self.beers.append(contentsOf: result)
                self.isLoading = false
                self.hasMore = self.currentPage < 4
            }
            .store(in: &cancellables)
    }
    
    /// Informs view model that favorite status of a beer at the given index changed.
    func beerFavoriteChanged(at index: Int) {
        self.beers[index].isFavorite.toggle()
    }
    
    // MARK: Helpers
    
    private func setupNotifications() {
        NotificationCenter.default
            .publisher(for: .beerFavoriteToggled)
            .sink { [ weak self ] not in
                if let id = not.userInfo?["id"] as? Int {
                    self?.toggleFavorite(beerId: id)
                }
            }
            .store(in: &cancellables)
    }
    
    private func toggleFavorite(beerId: Int) {
        guard let index = self.beers.firstIndex(where: { $0.id == beerId }) else { return }
        self.beers[index].isFavorite.toggle()
    }

}
