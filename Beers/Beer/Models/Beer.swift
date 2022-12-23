//
//  Beer.swift
//  Beers
//
//  Created by Felipe Leite on 19/12/22.
//

import Foundation

struct Beer: Codable {

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case tagline
        case imageUrl = "image_url"
        case abv
        case ibu
        case description
    }
    
    var id: Int
    var name: String
    var tagline: String
    var imageUrl: String
    var abv: Double
    var ibu: Double?
    var description: String
    var isFavorite = false

}
