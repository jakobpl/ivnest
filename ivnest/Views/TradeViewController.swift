//
//  TradeViewController.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import UIKit
import Combine

class TradeViewController: BaseViewController {
    
    // MARK: - UI Components
    
    // Search Bar
    private let searchBarView = SearchBarView()
    
    // Search Results
    private let searchResultsTableView = UITableView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let noResultsLabel = UILabel()
    
    // MARK: - Services
    private let portfolioManager = PortfolioManager.shared
    private let marketDataService = MarketDataService.shared
    
    // MARK: - State
    private var isSearchFocused = false
    private var searchResults: [SearchResult] = []
    private var isLoading = false
    private var searchDebounceTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupObservers()
        loadInitialData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Clean up focused state when leaving the view
        if isSearchFocused {
            searchBarView.searchTextField.resignFirstResponder()
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = ""
        
        // Setup search bar
        setupSearchLayer()
        
        // Setup search results table
        setupSearchResultsTable()
        
        // Setup loading indicator
        setupLoadingIndicator()
        
        // Setup no results label
        setupNoResultsLabel()
        
        // Add tap gesture to handle tapping outside search field
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSearchTapOutside))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupSearchLayer() {
        // Configure search bar
        searchBarView.setPlaceholder("ex. BTC, TSLA, SWPPX")
        searchBarView.delegate = self
        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to view
        view.addSubview(searchBarView)
    }
    
    private func setupSearchResultsTable() {
        searchResultsTableView.translatesAutoresizingMaskIntoConstraints = false
        searchResultsTableView.backgroundColor = .clear
        searchResultsTableView.separatorStyle = .none
        searchResultsTableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: "SearchResultCell")
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        searchResultsTableView.isHidden = true
        
        view.addSubview(searchResultsTableView)
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.color = .white
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.isHidden = true
        
        view.addSubview(loadingIndicator)
    }
    
    private func setupNoResultsLabel() {
        noResultsLabel.translatesAutoresizingMaskIntoConstraints = false
        noResultsLabel.text = "No results found"
        noResultsLabel.textColor = .systemGray
        noResultsLabel.font = .systemFont(ofSize: 16, weight: .medium)
        noResultsLabel.textAlignment = .center
        noResultsLabel.isHidden = true
        
        view.addSubview(noResultsLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Search Bar
            searchBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            searchBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchBarView.heightAnchor.constraint(equalToConstant: 50),
            
            // Search Results Table
            searchResultsTableView.topAnchor.constraint(equalTo: searchBarView.bottomAnchor, constant: 16),
            searchResultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchResultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchResultsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: searchResultsTableView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: searchResultsTableView.centerYAnchor),
            
            // No Results Label
            noResultsLabel.centerXAnchor.constraint(equalTo: searchResultsTableView.centerXAnchor),
            noResultsLabel.centerYAnchor.constraint(equalTo: searchResultsTableView.centerYAnchor)
        ])
    }
    
    // MARK: - Search Focus Handling
    @objc private func handleSearchTapOutside(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        let searchFrame = searchBarView.convert(searchBarView.bounds, to: view)
        
        // If tap is outside the search container, unfocus
        if !searchFrame.contains(location) && isSearchFocused {
            searchBarView.searchTextField.resignFirstResponder()
            searchBarView.unfocusSearch()
        }
    }
    
    // MARK: - Search Implementation
    private func performSearch(query: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            hideSearchResults()
            return
        }
        
        // Cancel previous timer
        searchDebounceTimer?.invalidate()
        
        // Set new timer for debouncing
        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.executeSearch(query: query)
        }
    }
    
    private func executeSearch(query: String) {
        print("🚀 Executing search for query: '\(query)'")
        isLoading = true
        showLoadingIndicator()
        
        // Search stocks and crypto separately to handle errors gracefully
        let stockSearch = marketDataService.searchStocks(query: query)
            .catch { error in 
                print("❌ Stock search failed: \(error)")
                return Just([Stock]()).setFailureType(to: Error.self).eraseToAnyPublisher() 
            }
        
        let cryptoSearch = marketDataService.searchCrypto(query: query)
            .catch { error in 
                print("❌ Crypto search failed: \(error)")
                return Just([Cryptocurrency]()).setFailureType(to: Error.self).eraseToAnyPublisher() 
            }
        
        Publishers.CombineLatest(stockSearch, cryptoSearch)
            .map { (stocks: [Stock], cryptos: [Cryptocurrency]) in
                print("📊 Search results - Stocks: \(stocks.count), Cryptos: \(cryptos.count)")
                var results: [SearchResult] = []
                
                // Add stocks
                for stock in stocks {
                    print("📈 Adding stock: \(stock.symbol) - \(stock.name)")
                    results.append(SearchResult(
                        symbol: stock.symbol,
                        name: stock.name,
                        assetType: .stock,
                        currentPrice: stock.currentPrice,
                        changePercent: stock.changePercent
                    ))
                }
                
                // Add cryptos
                for crypto in cryptos {
                    print("🪙 Adding crypto: \(crypto.symbol) - \(crypto.name)")
                    results.append(SearchResult(
                        symbol: crypto.symbol,
                        name: crypto.name,
                        assetType: .cryptocurrency,
                        currentPrice: crypto.currentPrice,
                        changePercent: crypto.changePercent24h
                    ))
                }
                
                print("🎯 Total search results: \(results.count)")
                return results
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    self?.hideLoadingIndicator()
                    
                    if case .failure(let error) = completion {
                        print("❌ Search completion error: \(error)")
                        self?.showNoResults()
                    } else {
                        print("✅ Search completed successfully")
                    }
                },
                receiveValue: { [weak self] results in
                    print("📱 Updating UI with \(results.count) results")
                    self?.searchResults = results
                    self?.updateSearchResultsDisplay()
                }
            )
            .store(in: &cancellables)
    }
    
    private func showLoadingIndicator() {
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        searchResultsTableView.isHidden = true
        noResultsLabel.isHidden = true
        
        UIView.animate(withDuration: 0.3) {
            self.loadingIndicator.alpha = 1.0
        }
    }
    
    private func hideLoadingIndicator() {
        UIView.animate(withDuration: 0.3) {
            self.loadingIndicator.alpha = 0.0
        } completion: { _ in
            self.loadingIndicator.stopAnimating()
            self.loadingIndicator.isHidden = true
        }
    }
    
    private func updateSearchResultsDisplay() {
        if searchResults.isEmpty {
            showNoResults()
        } else {
            showSearchResults()
        }
    }
    
    private func showSearchResults() {
        noResultsLabel.isHidden = true
        searchResultsTableView.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            self.searchResultsTableView.alpha = 1.0
        }
        
        searchResultsTableView.reloadData()
    }
    
    private func showNoResults() {
        searchResultsTableView.isHidden = true
        noResultsLabel.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            self.noResultsLabel.alpha = 1.0
        }
    }
    
    private func hideSearchResults() {
        searchResults = []
        
        UIView.animate(withDuration: 0.3) {
            self.searchResultsTableView.alpha = 0.0
            self.noResultsLabel.alpha = 0.0
        } completion: { _ in
            self.searchResultsTableView.isHidden = true
            self.noResultsLabel.isHidden = true
        }
    }
    
    // MARK: - Data Loading
    private func setupObservers() {
        // No observers needed for search-only view
    }
    
    private func loadInitialData() {
        // No data to load for search-only view
    }
    
    // MARK: - Helpers
}

// MARK: - SearchBarViewDelegate
extension TradeViewController: SearchBarViewDelegate {
    func searchBarDidBeginEditing(_ searchBar: SearchBarView) {
        isSearchFocused = true
        showBlurOverlay()
    }
    
    func searchBarDidEndEditing(_ searchBar: SearchBarView) {
        isSearchFocused = false
        hideBlurOverlay()
    }
    
    func searchBar(_ searchBar: SearchBarView, textDidChange text: String) {
        performSearch(query: text)
    }
}

// MARK: - UITableViewDataSource
extension TradeViewController: UITableViewDataSource {
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
extension TradeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = searchResults[indexPath.row]
        
        // TODO: Navigate to detail view or trading view
        print("Selected: \(result.symbol) - \(result.name)")
    }
}



 