//
//  BeerDetailsViewController.swift
//  Beers
//
//  Created by Felipe Leite on 19/12/22.
//

import UIKit
import Combine

class BeerDetailsViewController: UIViewController {
    
    private struct Consts {
        static let imageSize: CGFloat = 96.0
        static let padding: CGFloat = 16.0
    }

    // MARK: Properties
    
    private var viewModel: BeerViewModel?
    private var cancellables: Set<AnyCancellable> = []

    // MARK: Subviews
    
    lazy var beerImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    lazy var taglineLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var abvLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // MARK: Initialization
    
    init(viewModel: BeerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: Public methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.cancellables.forEach { $0.cancel() }
    }
    
    // MARK: Helpers
    
    private func setup() {
        self.title = self.viewModel?.name
        self.view.backgroundColor = .white
        
        self.view.addSubview(self.beerImageView)
        self.view.addSubview(self.taglineLabel)
        self.view.addSubview(self.abvLabel)
        
        NSLayoutConstraint.activate([
            self.beerImageView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: Consts.padding),
            self.beerImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: Consts.padding),
            self.beerImageView.heightAnchor.constraint(equalToConstant: Consts.imageSize),
            self.beerImageView.widthAnchor.constraint(equalToConstant: Consts.imageSize),
        ])
        
        NSLayoutConstraint.activate([
            self.abvLabel.topAnchor.constraint(equalTo: self.beerImageView.topAnchor),
            self.abvLabel.leftAnchor.constraint(equalTo: self.beerImageView.rightAnchor, constant: Consts.padding),
            self.abvLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -Consts.padding),
        ])
        
        NSLayoutConstraint.activate([
            self.taglineLabel.topAnchor.constraint(equalTo: self.abvLabel.bottomAnchor, constant: Consts.padding * 0.5),
            self.taglineLabel.leftAnchor.constraint(equalTo: self.beerImageView.rightAnchor, constant: Consts.padding),
            self.taglineLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -Consts.padding),
        ])
        
        guard let viewModel else { return }

        if let url = URL(string: viewModel.imageUrl) {
            self.beerImageView.loadImage(url: url).store(in: &cancellables)
        }
        
        self.taglineLabel.text = "Tagline: \(viewModel.tagline)"
        self.abvLabel.text = "Abv: \(viewModel.abv)%"
    }
    
}
