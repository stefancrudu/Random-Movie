//
//  MovieManager.swift
//  Random Movie
//
//  Created by Stefan Crudu on 20.02.2021.
//

import Foundation

protocol MovieManagerProtocol {
    func getMovieList(searchModel: AdvancedSearchModel, completion: @escaping (Result<MovieData, MovieManagerError>) -> Void)
}

struct MovieManager: MovieManagerProtocol {    
    func getMovieList(searchModel: AdvancedSearchModel, completion: @escaping (Result<MovieData, MovieManagerError>) -> Void) {
        
        let pageNumber = Int.random(in: 1...20)
        let stringURL = "https://ott-details.p.rapidapi.com/advancedsearch?start_year=\(searchModel.fromYear)&end_year=\(searchModel.toYear)&min_imdb=\(searchModel.fromRating)&max_imdb=\(searchModel.toRating)&genre=\(searchModel.genersString)&type=movie&sort=latest&page=\(pageNumber)"
        
        guard let url = URL(string: stringURL) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = APIHeaders().data
        
        let dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                completion(.failure(.serverError(error)))
            } else {
                do {
                    let movie = try JSONDecoder().decode(MovieData.self, from: data!)
                    
                    completion(.success(movie))
                } catch let error {
                    completion(.failure(.decodeError(error)))
                }
            }
        })
        
        dataTask.resume()
    }
}

enum MovieManagerError: Error {
    case invalidURL
    case serverError(Error)
    case decodeError(Error)
}
