//
//  BeerViewModel.swift
//  Beers
//
//  Created by Felipe Leite on 19/12/22.
//

import Foundation
import UIKit
import Combine

struct BeerViewModel {

    // MARK: Properties
    
    private let urlSession: URLSession
    
    var beer: Beer
    var name: String { self.beer.name }
    var abv: Double { self.beer.abv }
    var ibu: Double { self.beer.ibu ?? 0.0 }
    var tagline: String { self.beer.tagline }
    var imageUrl: String { self.beer.imageUrl }
    var isFavorite: Bool { self.beer.isFavorite }
    
    // MARK: Initializers

    init(beer: Beer, urlSession: URLSession = .shared) {
        self.beer = beer
        self.urlSession = urlSession
    }
    
    // MARK: Public methods
    
    func loadImage() -> AnyPublisher<(URL, UIImage?), Error> {
        guard let url = URL(string: beer.imageUrl) else { return Empty<(URL, UIImage?), Error>().eraseToAnyPublisher() }

        return self.urlSession
            .dataTaskPublisher(for: url)
            .map(\.data)
            .receive(on: DispatchQueue.main)
            .map { (url, UIImage(data: $0)) }
            .catch { error in Empty<(URL, UIImage?), Error>() }
            .eraseToAnyPublisher()
    }

}
