//
//  TradeViewController.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import UIKit
import Combine

class TradeViewController: UIViewController {
    
    // MARK: - UI Components (Layered Design)
    
    // Layer 1: Trade History (Bottom Layer)
    private let historyContainer = UIView()
    private let historyTitleLabel = UILabel()
    private let openOrdersLabel = UILabel()
    private let closedOrdersLabel = UILabel()
    
    // Layer 2: Blur Overlay (Middle Layer)
    private let blurOverlay = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    // Layer 3: Search Bar (Top Layer - Highest Z-Index)
    private let searchContainer = UIView()
    private let searchTextField = UITextField()
    private let searchShadowView = UIView()
    
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
        loadInitialData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Clean up focused state when leaving the view
        if isSearchFocused {
            searchTextField.resignFirstResponder()
            unfocusSearch()
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .black
        title = ""
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.barStyle = .black
        
        // Setup layers in order (bottom to top)
        setupHistoryLayer()
        setupBlurOverlay()
        setupSearchLayer()
        
        // Add tap gesture to handle tapping outside text field
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupHistoryLayer() {
        // History container
        historyContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // History title
        historyTitleLabel.text = "Trade History"
        historyTitleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        historyTitleLabel.textColor = .white
        historyTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Open orders label
        openOrdersLabel.text = "Open Orders"
        openOrdersLabel.font = .systemFont(ofSize: 16, weight: .medium)
        openOrdersLabel.textColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        openOrdersLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Closed orders label
        closedOrdersLabel.text = "Closed Orders"
        closedOrdersLabel.font = .systemFont(ofSize: 16, weight: .medium)
        closedOrdersLabel.textColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        closedOrdersLabel.translatesAutoresizingMaskIntoConstraints = false
        
        historyContainer.addSubview(historyTitleLabel)
        historyContainer.addSubview(openOrdersLabel)
        historyContainer.addSubview(closedOrdersLabel)
        view.addSubview(historyContainer)
    }
    
    private func setupBlurOverlay() {
        blurOverlay.translatesAutoresizingMaskIntoConstraints = false
        blurOverlay.alpha = 0 // Start hidden
        view.addSubview(blurOverlay)
    }
    
    private func setupSearchLayer() {
        // Search container
        searchContainer.translatesAutoresizingMaskIntoConstraints = false
        searchContainer.backgroundColor = .clear
        searchContainer.layer.borderWidth = 1.0
        searchContainer.layer.borderColor = UIColor.white.cgColor
        searchContainer.layer.cornerRadius = 12
        searchContainer.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        
        // Search shadow view
        searchShadowView.translatesAutoresizingMaskIntoConstraints = false
        searchShadowView.backgroundColor = .clear
        searchShadowView.layer.shadowColor = UIColor.white.cgColor
        searchShadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
        searchShadowView.layer.shadowRadius = 12
        searchShadowView.layer.shadowOpacity = 0
        searchShadowView.layer.cornerRadius = 12
        
        // Search text field
        searchTextField.placeholder = "ex. BTC, TSLA, SWPPX"
        searchTextField.font = .systemFont(ofSize: 16, weight: .medium)
        searchTextField.textColor = .white
        searchTextField.backgroundColor = .clear
        searchTextField.borderStyle = .none
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.delegate = self
        searchTextField.autocapitalizationType = .allCharacters
        searchTextField.autocorrectionType = .no
        searchTextField.spellCheckingType = .no
        
        // Custom placeholder color
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "ex. BTC, TSLA, SWPPX",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)]
        )
        
        // Add subviews to search container
        searchContainer.addSubview(searchShadowView)
        searchContainer.addSubview(searchTextField)
        
        // Add to view (highest z-index)
        view.addSubview(searchContainer)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Layer 3: Search Container (Top - Highest Z-Index)
            searchContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            searchContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchContainer.heightAnchor.constraint(equalToConstant: 50),
            
            // Search shadow view
            searchShadowView.topAnchor.constraint(equalTo: searchContainer.topAnchor),
            searchShadowView.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor),
            searchShadowView.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor),
            searchShadowView.bottomAnchor.constraint(equalTo: searchContainer.bottomAnchor),
            
            // Search text field
            searchTextField.topAnchor.constraint(equalTo: searchContainer.topAnchor, constant: 12),
            searchTextField.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor, constant: -16),
            searchTextField.bottomAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: -12),
            
            // Layer 1: History Container (Bottom) - Now properly spaced below search bar
            historyContainer.topAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: 40),
            historyContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            historyContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            historyContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            // History title
            historyTitleLabel.topAnchor.constraint(equalTo: historyContainer.topAnchor),
            historyTitleLabel.leadingAnchor.constraint(equalTo: historyContainer.leadingAnchor),
            
            // Open orders
            openOrdersLabel.topAnchor.constraint(equalTo: historyTitleLabel.bottomAnchor, constant: 20),
            openOrdersLabel.leadingAnchor.constraint(equalTo: historyContainer.leadingAnchor),
            
            // Closed orders
            closedOrdersLabel.topAnchor.constraint(equalTo: openOrdersLabel.bottomAnchor, constant: 16),
            closedOrdersLabel.leadingAnchor.constraint(equalTo: historyContainer.leadingAnchor),
            
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
        let searchFrame = searchContainer.convert(searchContainer.bounds, to: view)
        
        // If tap is outside the search container, unfocus
        if !searchFrame.contains(location) && isSearchFocused {
            searchTextField.resignFirstResponder()
        }
    }
    
    private func focusSearch() {
        isSearchFocused = true
        
        // Animate scale and effects
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
            self.searchContainer.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            self.searchShadowView.layer.shadowOpacity = 0.3
            self.blurOverlay.alpha = 0.6
        })
    }
    
    private func unfocusSearch() {
        isSearchFocused = false
        
        // Animate back to normal state
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
            self.searchContainer.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.searchShadowView.layer.shadowOpacity = 0
            self.blurOverlay.alpha = 0
        })
    }
    
    // MARK: - Data Loading
    private func setupObservers() {
        // Observe portfolio changes
        portfolioManager.$currentPortfolio
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                // Will be implemented in next steps
            }
            .store(in: &cancellables)
    }
    
    private func loadInitialData() {
        // Will be implemented in next steps
    }
    
    // MARK: - Helpers
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - UITextFieldDelegate
extension TradeViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        focusSearch()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        unfocusSearch()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Convert input to uppercase
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string.uppercased())
        textField.text = newText
        return false // Prevent default behavior since we're manually setting the text
    }
} 