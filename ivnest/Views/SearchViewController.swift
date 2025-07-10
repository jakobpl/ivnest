//
//  SearchViewController.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import UIKit
import Combine

class SearchViewController: UIViewController {
    
    // MARK: - UI Components
    private let searchBarView = SearchBarView()
    private let tableView = UITableView()
    private let segmentedControl = UISegmentedControl(items: ["Stocks", "Crypto"])
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let noResultsLabel = UILabel()
    
    // MARK: - Properties
    private let marketDataService = MarketDataService.shared
    private let portfolioManager = PortfolioManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    private var searchResults: [SearchResult] = []
    private var currentSearchType: SearchType = .stocks
    private var searchTask: AnyCancellable?
    
    enum SearchType {
        case stocks
        case crypto
    }
    

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupTableView()
        setupSearchBar()
        setupSegmentedControl()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
        
        // Search bar
        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        searchBarView.delegate = self
        searchBarView.setPlaceholder("Search stocks and crypto...")
        view.addSubview(searchBarView)
        
        // Segmented control
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1.0)
        segmentedControl.selectedSegmentTintColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        view.addSubview(segmentedControl)
        
        // Table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        view.addSubview(tableView)
        
        // Loading indicator
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.color = .white
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        
        // No results label
        noResultsLabel.translatesAutoresizingMaskIntoConstraints = false
        noResultsLabel.text = "No results found"
        noResultsLabel.textColor = .white
        noResultsLabel.textAlignment = .center
        noResultsLabel.font = .systemFont(ofSize: 16, weight: .medium)
        noResultsLabel.isHidden = true
        view.addSubview(noResultsLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Search bar
            searchBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            searchBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBarView.heightAnchor.constraint(equalToConstant: 50),
            
            // Segmented control
            segmentedControl.topAnchor.constraint(equalTo: searchBarView.bottomAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 40),
            
            // Table view
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // No results label
            noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: "SearchResultCell")
    }
    
    private func setupSearchBar() {
        // Search bar is already configured in setupUI
    }
    
    private func setupSegmentedControl() {
        // Segmented control is already configured in setupUI
    }
    
    // MARK: - Actions
    @objc private func segmentedControlChanged() {
        currentSearchType = segmentedControl.selectedSegmentIndex == 0 ? .stocks : .crypto
        performSearch()
    }
    
    // MARK: - Search Methods
    private func performSearch() {
        let query = searchBarView.getText().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            searchResults = []
            tableView.reloadData()
            return
        }
        
        // Cancel previous search
        searchTask?.cancel()
        
        // Show loading
        loadingIndicator.startAnimating()
        noResultsLabel.isHidden = true
        
        // Perform search based on type
        if currentSearchType == .stocks {
            searchTask = marketDataService.searchStocks(query: query)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        self?.loadingIndicator.stopAnimating()
                        if case .failure(let error) = completion {
                            self?.showError("Search failed: \(error.localizedDescription)")
                        }
                    },
                    receiveValue: { [weak self] stocks in
                        self?.handleStockSearchResults(stocks)
                    }
                )
        } else {
            searchTask = marketDataService.searchCrypto(query: query)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        self?.loadingIndicator.stopAnimating()
                        if case .failure(let error) = completion {
                            self?.showError("Search failed: \(error.localizedDescription)")
                        }
                    },
                    receiveValue: { [weak self] cryptos in
                        self?.handleCryptoSearchResults(cryptos)
                    }
                )
        }
    }
    
    private func handleStockSearchResults(_ stocks: [Stock]) {
        searchResults = stocks.map { stock in
            SearchResult(
                symbol: stock.symbol,
                name: stock.name,
                assetType: .stock,
                currentPrice: stock.currentPrice,
                changePercent: stock.changePercent
            )
        }
        
        updateUI()
    }
    
    private func handleCryptoSearchResults(_ cryptos: [Cryptocurrency]) {
        searchResults = cryptos.map { crypto in
            SearchResult(
                symbol: crypto.symbol,
                name: crypto.name,
                assetType: .cryptocurrency,
                currentPrice: crypto.currentPrice,
                changePercent: crypto.changePercent24h
            )
        }
        
        updateUI()
    }
    
    private func updateUI() {
        loadingIndicator.stopAnimating()
        noResultsLabel.isHidden = !searchResults.isEmpty
        tableView.reloadData()
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Trading Methods
    private func showTradingOptions(for result: SearchResult) {
        let alert = UIAlertController(title: result.symbol, message: "Choose an action", preferredStyle: .actionSheet)
        
        // Add to watchlist
        alert.addAction(UIAlertAction(title: "Add to Watchlist", style: .default) { [weak self] _ in
            self?.addToWatchlist(result)
        })
        
        // Buy
        alert.addAction(UIAlertAction(title: "Buy", style: .default) { [weak self] _ in
            self?.showBuyDialog(for: result)
        })
        
        // Cancel
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func addToWatchlist(_ result: SearchResult) {
        let watchlistItem = WatchlistItem(
            assetType: result.assetType,
            symbol: result.symbol,
            name: result.name,
            currentPrice: result.currentPrice,
            priceChange: 0.0, // We don't have priceChange in the new SearchResult
            priceChangePercent: result.changePercent
        )
        
        portfolioManager.addToWatchlist(watchlistItem)
        
        let alert = UIAlertController(title: "Added to Watchlist", message: "\(result.symbol) has been added to your watchlist", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showBuyDialog(for result: SearchResult) {
        let alert = UIAlertController(title: "Buy \(result.symbol)", message: "Enter quantity to buy", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Quantity"
            textField.keyboardType = .decimalPad
        }
        
        alert.addAction(UIAlertAction(title: "Buy", style: .default) { [weak self] _ in
            guard let quantityText = alert.textFields?.first?.text,
                  let quantity = Double(quantityText),
                  quantity > 0 else {
                self?.showError("Please enter a valid quantity")
                return
            }
            
            self?.buyAsset(result, quantity: quantity)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func buyAsset(_ result: SearchResult, quantity: Double) {
        let success: Bool
        
        if result.assetType == .stock {
            success = portfolioManager.buyStock(
                symbol: result.symbol,
                name: result.name,
                quantity: quantity,
                price: result.currentPrice
            )
        } else {
            success = portfolioManager.buyCrypto(
                symbol: result.symbol,
                name: result.name,
                quantity: quantity,
                price: result.currentPrice
            )
        }
        
        if success {
            let alert = UIAlertController(title: "Purchase Successful", message: "You bought \(quantity) shares of \(result.symbol) at $\(String(format: "%.2f", result.currentPrice))", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            showError("Insufficient funds or invalid transaction")
        }
    }
}

// MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultTableViewCell
        let result = searchResults[indexPath.row]
        cell.configure(with: result)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = searchResults[indexPath.row]
        showTradingOptions(for: result)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - SearchBarViewDelegate
extension SearchViewController: SearchBarViewDelegate {
    func searchBarDidBeginEditing(_ searchBar: SearchBarView) {
        // Optional: Add any additional behavior when search begins
    }
    
    func searchBarDidEndEditing(_ searchBar: SearchBarView) {
        // Optional: Add any additional behavior when search ends
    }
    
    func searchBar(_ searchBar: SearchBarView, textDidChange text: String) {
        // Debounce search
        searchTask?.cancel()
        searchTask = Just(text)
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.performSearch()
            }
    }
}

 