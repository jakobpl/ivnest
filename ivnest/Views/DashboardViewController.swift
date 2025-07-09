//
//  DashboardViewController.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import UIKit
import Combine

class DashboardViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let portfolioChartView = PortfolioChartView()
    
    // MARK: - Services
    private let portfolioManager = PortfolioManager.shared
    private let marketDataService = MarketDataService.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupObservers()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .black
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.barStyle = .black
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Setup portfolio chart
        setupPortfolioChart()
        
        // Add all views to content view
        contentView.addSubview(portfolioChartView)
    }
    
    private func setupPortfolioChart() {
        portfolioChartView.translatesAutoresizingMaskIntoConstraints = false
        portfolioChartView.delegate = self
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            portfolioChartView.topAnchor.constraint(equalTo: contentView.topAnchor),
            portfolioChartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            portfolioChartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            portfolioChartView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    // MARK: - Data Loading
    private func setupObservers() {
        // Observe portfolio changes
        portfolioManager.$currentPortfolio
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshData()
            }
            .store(in: &cancellables)
    }
    
    private func loadData() {
        refreshData()
        marketDataService.startRealTimeUpdates()
    }
    
    private func refreshData() {
        let portfolio = portfolioManager.currentPortfolio
        
        // Update portfolio chart
        let totalChange = portfolio.totalValue - portfolio.totalInvested
        let changePercent = portfolio.totalROI
        portfolioChartView.updatePortfolioValue(portfolio.totalValue, change: totalChange, changePercent: changePercent)
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

// MARK: - PortfolioChartViewDelegate
extension DashboardViewController: PortfolioChartViewDelegate {
    func didSelectTimePeriod(_ period: TimePeriod) {
        // Handle time period selection
        // The chart view will automatically update its display
        print("Selected time period: \(period.rawValue)")
    }
}

 