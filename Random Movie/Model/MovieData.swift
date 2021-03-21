//
//  MovieModel.swift
//  Random Movie
//
//  Created by Stefan Crudu on 16.02.2021.
//

import UIKit

struct MovieData: Codable {
    let results: [Row]

    struct Row: Codable {
        let imdbrating: Double?
        let released: Int?
        let synopsis: String?
        let title: String?
        let type: String?
        let genre: [String]?
        let imageurl: [String]?
    }
}
