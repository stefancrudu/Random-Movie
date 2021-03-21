//
//  ViewController.swift
//  Random Movie
//
//  Created by Stefan Crudu on 16.02.2021.
//
//   40
//
                                                                                                    
import UIKit
import SkeletonView


class ViewController: UIViewController{
    
    private var movieManger: MovieManagerProtocol = MovieManager()
    private var advancedSearchForm: AdvancedSearchModel? = nil {
        didSet {
            cacheMovieList = nil
        }
    }
    private var cacheMovieList: MovieData? = nil
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var rateLabel: UILabel!
    @IBOutlet var genreLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var button: UIButton!{
        didSet{
            button.layer.cornerRadius = 6
            addPulseAnimation(view: button)
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showSkeleton()
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        showSkeleton()
        toggleButtonStatus()
        displayRandomMovie()
    }
}

// MARK: - AdvancedSearchDelegate -

extension ViewController: AdvancedSearchDelegate {
    func didChangeAdvancedSearch(with model: AdvancedSearchModel) {
        advancedSearchForm = model
    }
}

// MARK: - Skeletons -

extension ViewController {
    private func showSkeleton() {
        imageView.showAnimatedGradientSkeleton()
        titleLabel.showAnimatedGradientSkeleton()
        dateLabel.showAnimatedGradientSkeleton()
        rateLabel.showAnimatedGradientSkeleton()
        genreLabel.showAnimatedGradientSkeleton()
        descriptionLabel.showAnimatedGradientSkeleton()
    }
    
    private func hideSkeleton() {
        imageView.hideSkeleton()
        titleLabel.hideSkeleton()
        dateLabel.hideSkeleton()
        rateLabel.hideSkeleton()
        genreLabel.hideSkeleton()
        descriptionLabel.hideSkeleton()
    }
}

// MARK: - Privates -

extension ViewController {
    
    private func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        
        let app = UINavigationBarAppearance()
        app.configureWithTransparentBackground()
        
        navigationController?.navigationBar.standardAppearance = app
        navigationController?.navigationBar.scrollEdgeAppearance = app
        navigationController?.navigationBar.compactAppearance = app
            
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(showMoreSettings))
        
    }
    
    @objc private func showMoreSettings() {
        if let vc = storyboard?.instantiateViewController(identifier: "AdvancedSearch") as? AdvancedSearchViewController {
            vc.delegate = self
            vc.searchModel = advancedSearchForm ?? .default
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func addPulseAnimation(view: UIView) {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.99
        pulse.fromValue = 0.85
        pulse.toValue = 1
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.initialVelocity = 1
        view.layer.add(pulse, forKey: nil)
    }
    
    private func toggleButtonStatus() {
        if button.isEnabled {
            button.isEnabled = false
            button.layer.removeAllAnimations()
            button.backgroundColor = .systemGray
            button.setTitle("I try to find a good movie for you", for: .normal)
        } else {
            button.isEnabled = true
            addPulseAnimation(view: button)
            button.backgroundColor = UIColor(named: "MainColor")
            button.tintColor = .white
            button.setTitle("Find my a new movie", for: .normal)
        }
    }
    
    
    private func displayRandomMovie() {
        guard cacheMovieList == nil else {
            displayMovie(cacheMovieList!)
            return
        }
        
        movieManger.getMovieList(searchModel: advancedSearchForm ?? AdvancedSearchModel.randomModel) { (result) in
            switch result {
            case .failure(let error):
                self.displayFailureMessage(with: error.localizedDescription)
            case .success(let movieData):
                self.cacheMovieList = movieData
                self.displayMovie(movieData)
            }
        }
    }
    
    private func displayMovie(_ response: MovieData) {
        guard let movie = getRandomMovieModel(from: response) else { return }
        
        var imageData: Data?
        if let movieImageURL = URL(string: movie.imageURL) {
            imageData = try? Data(contentsOf: movieImageURL)
        }
        
        DispatchQueue.main.async {
            self.hideSkeleton()
            self.titleLabel.text = movie.title
            self.dateLabel.text = movie.year
            self.rateLabel.text = "IMDB Rating: \(movie.rank) / 10"
            self.genreLabel.text = movie.genre
            self.descriptionLabel.text = movie.description
            if let imageData = imageData {
                self.imageView.isHidden = false
                self.imageView.image = UIImage(data: imageData)
            }
            self.toggleButtonStatus()
        }
    }
    
    private func getRandomMovieModel(from moviesData: MovieData) -> MovieModel? {
        guard moviesData.results.count > 1 else { return nil }

        let movieFromData = moviesData.results[Int.random(in: 0...(moviesData.results.count-1))]
        let genresFromData = movieFromData.genre?.joined(separator: ",")

        return MovieModel(
            title: movieFromData.title ?? "",
            year: "\(movieFromData.released ?? 0)",
            genre: genresFromData ?? "",
            description: movieFromData.synopsis ?? "No description",
            rank: "\(movieFromData.imdbrating ?? 0)",
            imageURL: movieFromData.imageurl?.first ?? "https://st.depositphotos.com/1987177/3470/v/600/depositphotos_34700099-stock-illustration-no-photo-available-or-missing.jpg"
        )
    }
    
    private func displayFailureMessage(with message: String) {
        DispatchQueue.main.async {
            self.hideSkeleton()
            self.titleLabel.text = "We have a problem"
            self.dateLabel.text = ""
            self.rateLabel.text = ""
            self.genreLabel.text = ""
            self.descriptionLabel.text = message
            self.imageView.isHidden = true
            self.toggleButtonStatus()
        }
    }
}
