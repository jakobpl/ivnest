//
//  WatchlistViewController.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import UIKit
import Combine

class WatchlistViewController: UIViewController {
    
    // MARK: - UI Components (Layered Design)
    
    // Layer 1: Watchlist Content (Bottom Layer)
    private let contentContainer = UIView()
    private let tableView = UITableView()
    private let emptyStateLabel = UILabel()
    
    // Layer 2: Blur Overlay (Middle Layer)
    private let blurOverlay = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    // Layer 3: Search Bar (Top Layer - Highest Z-Index)
    private let searchBarView = SearchBarView()
    
    // MARK: - Services
    private let portfolioManager = PortfolioManager.shared
    private let marketDataService = MarketDataService.shared
    
    // MARK: - State
    private var isSearchFocused = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        updateEmptyState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Clean up focused state when leaving the view
        if isSearchFocused {
            searchBarView.unfocusSearch()
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .black
        title = ""
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.barStyle = .black
        
        // Setup layers in order (bottom to top)
        setupContentLayer()
        setupBlurOverlay()
        setupSearchLayer()
        
        // Add tap gesture to handle tapping outside text field
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupContentLayer() {
        // Content container
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentContainer)
        
        // Table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(WatchlistTableViewCell.self, forCellReuseIdentifier: "WatchlistCell")
        tableView.delegate = self
        tableView.dataSource = self
        contentContainer.addSubview(tableView)
        
        // Empty state label
        emptyStateLabel.text = "Your watchlist is empty\nSearch to add stocks or crypto"
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        emptyStateLabel.font = .systemFont(ofSize: 16, weight: .medium)
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(emptyStateLabel)
    }
    
    private func setupBlurOverlay() {
        blurOverlay.translatesAutoresizingMaskIntoConstraints = false
        blurOverlay.alpha = 0 // Start hidden
        view.addSubview(blurOverlay)
    }
    
    private func setupSearchLayer() {
        // Configure search bar
        searchBarView.setPlaceholder("Search watchlist...")
        searchBarView.delegate = self
        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to view (highest z-index)
        view.addSubview(searchBarView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Layer 3: Search Bar (Top - Highest Z-Index)
            searchBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            searchBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchBarView.heightAnchor.constraint(equalToConstant: 50),
            
            // Layer 1: Content Container (Bottom) - Properly spaced below search bar
            contentContainer.topAnchor.constraint(equalTo: searchBarView.bottomAnchor, constant: 40),
            contentContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            // Table view
            tableView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
            
            // Empty state label
            emptyStateLabel.centerXAnchor.constraint(equalTo: contentContainer.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: contentContainer.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 32),
            emptyStateLabel.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -32),
            
            // Layer 2: Blur Overlay (Middle)
            blurOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            blurOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Search Focus Handling
    @objc private func handleTapOutside(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        let searchFrame = searchBarView.convert(searchBarView.bounds, to: view)
        
        // If tap is outside the search container, unfocus
        if !searchFrame.contains(location) && isSearchFocused {
            searchBarView.unfocusSearch()
            // Also resign first responder to ensure keyboard is dismissed
            searchBarView.searchTextField.resignFirstResponder()
        }
    }
    
    // MARK: - Data Loading
    private func setupObservers() {
        // Observe watchlist changes
        portfolioManager.$watchlist
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.updateEmptyState()
            }
            .store(in: &cancellables)
    }
    
    private func updateEmptyState() {
        let isEmpty = portfolioManager.watchlist.isEmpty
        emptyStateLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - SearchBarViewDelegate
extension WatchlistViewController: SearchBarViewDelegate {
    func searchBarDidBeginEditing(_ searchBar: SearchBarView) {
        isSearchFocused = true
        
        // Animate blur overlay
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
            self.blurOverlay.alpha = 0.6
        })
    }
    
    func searchBarDidEndEditing(_ searchBar: SearchBarView) {
        isSearchFocused = false
        
        // Animate blur overlay back
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
            self.blurOverlay.alpha = 0
        })
    }
    
    func searchBar(_ searchBar: SearchBarView, textDidChange text: String) {
        // Filter watchlist based on search text
        // For now, just reload the table view
        // In the future, you can implement actual filtering logic
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension WatchlistViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return portfolioManager.watchlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WatchlistCell", for: indexPath) as! WatchlistTableViewCell
        let watchlistItem = portfolioManager.watchlist[indexPath.row]
        cell.configure(with: watchlistItem)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension WatchlistViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let watchlistItem = portfolioManager.watchlist[indexPath.row]
        
        // Show detail view or trade view
        let alert = UIAlertController(title: watchlistItem.symbol, message: "Choose action", preferredStyle: .actionSheet)
        
        let tradeAction = UIAlertAction(title: "Trade", style: .default) { [weak self] _ in
            self?.navigateToTrade(with: watchlistItem)
        }
        
        let removeAction = UIAlertAction(title: "Remove from Watchlist", style: .destructive) { [weak self] _ in
            self?.portfolioManager.removeFromWatchlist(symbol: watchlistItem.symbol, assetType: watchlistItem.assetType)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(tradeAction)
        alert.addAction(removeAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func navigateToTrade(with watchlistItem: WatchlistItem) {
        let tradeVC = TradeViewController()
        navigationController?.pushViewController(tradeVC, animated: true)
        // TODO: Pre-select the asset in trade view
    }
} 