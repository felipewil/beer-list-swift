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
        case beers
        
        var url: URL? {
            switch self {
            case .beers:
                return Consts.baseURL?.appending(path: "beers")
            }
        }
    }
    
    // MARK: Properties
    
    private let urlSession: URLSession
    
    // MARK: Initialization
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
        self.setupNotifications()
    }

    // MARK: Properties
    
    private var cancellables: Set<AnyCancellable> = []
    @Published private(set) var beers: [ Beer ] = []
    
    // MARK: Public methods
    
    func loadBeers() {
        guard let url = Endpoint.beers.url else { return }
        
        self.urlSession
            .dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [ Beer ].self, decoder: JSONDecoder())
            .catch { error in Empty<[ Beer ], Error>() }
            .receive(on: RunLoop.main)
            .sink { _ in } receiveValue: { result in
                self.beers = result
            }
            .store(in: &cancellables)
    }
    
    // MARK: Helpers
    
    private func setupNotifications() {
        NotificationCenter.default
            .publisher(for: .beerFavoriteToggled)
            .sink { [ weak self ] not in
                if let name = not.userInfo?["beer"] as? String {
                    self?.toggleFavorite(beerName: name)
                }
            }
            .store(in: &cancellables)
    }
    
    private func toggleFavorite(beerName: String) {
        guard let index = self.beers.firstIndex(where: { $0.name == beerName }) else { return }
        self.beers[index].isFavorite.toggle()
    }

}
