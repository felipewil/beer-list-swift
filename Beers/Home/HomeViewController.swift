//
//  ViewController.swift
//  Beers
//
//  Created by Felipe Leite on 19/12/22.
//

import UIKit
import Combine

class HomeViewController: UIViewController {
    
    private struct Consts {
        static let cellEstimatedSize: CGFloat = 128.0
        static let loaderSize: CGFloat = 32.0
    }
    
    // MARK: Properties
    
    private let viewModel = HomeViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: Subviews
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Consts.cellEstimatedSize
        tableView.alpha = 0.0
        tableView.register(BeerCell.self, forCellReuseIdentifier: BeerCell.reuseIdentifier)

        return tableView
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    // MARK: Public methods

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.setup()
        self.viewModel.loadBeers()
        self.viewModel
            .$beers
            .receive(on: DispatchQueue.main)
            .sink { [ weak self ] _ in self?.reloadData() }
            .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: Helpers
    
    private func setup() {
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.activityIndicator)
        
        NSLayoutConstraint.activate([
            self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            self.activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
        
        self.activityIndicator.startAnimating()
    }
    
    private func reloadData() {
        guard self.viewModel.beers.count >= 0 else { return }

        self.tableView.reloadData()
        
        guard self.tableView.alpha == 0.0 else { return }
        
        UIView.animate(withDuration: 0.3, delay: 0.0) {
            self.activityIndicator.alpha = 0.0
            self.tableView.alpha = 1.0
        }
    }

}

// MARK: -

extension HomeViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.beers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = BeerViewModel(beer: self.viewModel.beers[indexPath.row])
        return BeerCell.dequeueReusableCell(from: tableView, viewModel: viewModel, for: indexPath)
    }
    
}

// MARK: -

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewModel = BeerViewModel(beer: self.viewModel.beers[indexPath.row])
        let vc = BeerDetailsViewController(viewModel: viewModel)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
