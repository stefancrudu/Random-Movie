//
//  AdvancedSearchModel.swift
//  Random Movie
//
//  Created by Stefan Crudu on 20.02.2021.
//

import Foundation

struct AdvancedSearchModel: Codable {
    var fromYear: String
    var toYear: String
    var fromRating: String
    var toRating: String
    var geners: [Int: String]
    
    var genersString: String {
        return geners.values.joined(separator: ",")
    }
    
    static var randomModel: AdvancedSearchModel {
        return AdvancedSearchModel(
            fromYear: "1970",
            toYear: "2020",
            fromRating: "0",
            toRating: "10",
            geners: [:]
        )
    }
    
    static var `default`: AdvancedSearchModel {
        return AdvancedSearchModel(
            fromYear: "1970",
            toYear: "2020",
            fromRating: "5",
            toRating: "10",
            geners: [:]
        )
    }
    
    static let genersList =  ["Action",
                                 "Adventure",
                                 "Animation",
                                 "Biography",
                                 "Comedy",
                                 "Crime",
                                 "Documentary",
                                 "Drama",
                                 "Family",
                                 "Fantasy",
                                 "Film Noir",
                                 "History",
                                 "Horror",
                                 "Music",
                                 "Musical",
                                 "Mystery",
                                 "Romance",
                                 "Sci-Fi",
                                 "Short",
                                 "Sport",
                                 "Superhero",
                                 "Thriller",
                                 "War",
                                 "Western"]
}
