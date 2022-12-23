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
        tableView.sectionFooterHeight = 0.0
        tableView.sectionHeaderHeight = 0.0
        tableView.alpha = 0.0
        tableView.register(BeerCell.self, forCellReuseIdentifier: BeerCell.reuseIdentifier)
        tableView.register(LoadingCell.self, forCellReuseIdentifier: LoadingCell.reuseIdentifier)
        
        return tableView
    }()
    
    // MARK: Public methods

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.setup()
        self.viewModel.loadBeers()
        self.viewModel
            .$beers
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [ weak self ] _ in self?.reloadData() }
            .store(in: &cancellables)
        
        self.viewModel
            .$isLoading
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [ weak self ] isLoading in self?.showLoading(isLoading) }
            .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: Helpers
    
    private func setup() {
        self.view.addSubview(self.tableView)
        
        NSLayoutConstraint.activate([
            self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }
    
    private func reloadData() {
        self.tableView.reloadData()
        
        guard self.tableView.alpha == 0.0 else { return }
        
        UIView.animate(withDuration: 0.3, delay: 0.0) {
            self.tableView.alpha = 1.0
        }
    }
    
    private func showLoading(_ show: Bool) {
        let indexPath = IndexPath(row: 0, section: 1)

        if show {
            self.tableView.insertRows(at: [ indexPath ], with: .automatic)
        } else if self.tableView(self.tableView, numberOfRowsInSection: 1) > 0 {
            self.tableView.deleteRows(at: [ indexPath ], with: .automatic)
        }
    }

}

// MARK: -

extension HomeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.viewModel.beers.count
        } else if section == 1 {
            return self.viewModel.isLoading ? 1 : 0
        }

        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let viewModel = BeerViewModel(beer: self.viewModel.beers[indexPath.row])
            let cell = BeerCell.dequeueReusableCell(from: tableView, viewModel: viewModel, for: indexPath)

            cell.eventPublisher
                .sink { [ weak self, indexPath ] event in self?.handleEvent(event, indexPath: indexPath) }
                .store(in: &cell.cancellables)

            return cell
        } else {
            return LoadingCell.dequeueReusableCell(from: tableView, for: indexPath)
        }
    }
    
    // MARK: Helpers
    
    private func handleEvent(_ event: BeerCellEvent, indexPath: IndexPath) {
        switch event {
        case .favoriteChanged:
            self.viewModel.beerFavoriteChanged(at: indexPath.row)
        }
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !self.viewModel.isLoading, indexPath.row > self.viewModel.beers.count - 3 else { return }
        self.viewModel.loadBeers()
    }

}
