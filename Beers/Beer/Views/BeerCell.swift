//
//  BeerCell.swift
//  Beers
//
//  Created by Felipe Leite on 19/12/22.
//

import UIKit
import Combine

class BeerCell: UITableViewCell {
    
    private struct Consts {
        static let imageSize: CGFloat = 96.0
        static let padding: CGFloat = 16.0
        static let buttonSize: CGFloat = 48.0
    }

    // MARK: Properties
    
    static let reuseIdentifier = "BeerCell"
    private var cancellables: Set<AnyCancellable> = []
    private var viewModel: BeerViewModel?
    
    // MARK: Subviews
    
    lazy var beerImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var abvLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var favoriteButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        
        return button
    }()
    
    // MARK: Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    // MARK: Public methods
    
    static func dequeueReusableCell(from tableView: UITableView, viewModel: BeerViewModel, for indexPath: IndexPath) -> BeerCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as! BeerCell

        cell.viewModel = viewModel
        cell.nameLabel.text = "Name: \(viewModel.name)"
        cell.abvLabel.text = "Abv: \(viewModel.abv) %"

        if viewModel.isFavorite {
            cell.favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            cell.favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        
        cell.loadImage(viewModel: viewModel)

        return cell
    }
    
    override func prepareForReuse() {
        cancellables.forEach { $0.cancel() }
        cancellables = []
        self.beerImageView.image = nil
    }
    
    // MARK: Helpers
    
    private func setup() {
        self.contentView.addSubview(self.beerImageView)
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.abvLabel)
        self.contentView.addSubview(self.favoriteButton)
        
        NSLayoutConstraint.activate([
            self.beerImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: Consts.padding),
            self.beerImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: Consts.padding),
            self.beerImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -Consts.padding),
            self.beerImageView.heightAnchor.constraint(equalToConstant: Consts.imageSize),
            self.beerImageView.widthAnchor.constraint(equalToConstant: Consts.imageSize),
        ])
        
        NSLayoutConstraint.activate([
            self.nameLabel.topAnchor.constraint(equalTo: self.beerImageView.topAnchor),
            self.nameLabel.leftAnchor.constraint(equalTo: self.beerImageView.rightAnchor, constant: Consts.padding),
            self.nameLabel.rightAnchor.constraint(equalTo: self.favoriteButton.leftAnchor, constant: -Consts.padding),
        ])
        
        NSLayoutConstraint.activate([
            self.abvLabel.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor, constant: Consts.padding * 0.5),
            self.abvLabel.leftAnchor.constraint(equalTo: self.beerImageView.rightAnchor, constant: Consts.padding),
            self.abvLabel.rightAnchor.constraint(equalTo: self.favoriteButton.leftAnchor, constant: -Consts.padding),
        ])
        
        NSLayoutConstraint.activate([
            self.favoriteButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.favoriteButton.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -Consts.padding),
            self.favoriteButton.widthAnchor.constraint(equalToConstant: Consts.buttonSize),
            self.favoriteButton.heightAnchor.constraint(equalToConstant: Consts.buttonSize),
        ])
    }
    
    private func loadImage(viewModel: BeerViewModel) {
        guard let url = URL(string: viewModel.imageUrl) else { return }

        self.beerImageView.loadImage(url: url).store(in: &cancellables)
    }
    
    @objc private func toggleFavorite() {
        guard let name = viewModel?.name else { return }
        NotificationCenter.default.post(name: .beerFavoriteToggled, object: nil, userInfo: [ "beer": name ])
    }

}
