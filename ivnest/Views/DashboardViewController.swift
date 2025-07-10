//
//  DashboardViewController.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import UIKit
import Combine

class DashboardViewController: BaseViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let portfolioChartView = PortfolioChartView()
    private let portfolioStatsGrid = PortfolioStatsGridView()
    private let makeDepositButton = UIButton()
    private let depositOverlayView = DepositOverlayView()
    
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
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Setup portfolio chart
        setupPortfolioChart()
        
        // Setup portfolio stats grid
        setupPortfolioStatsGrid()
        
        // Setup make deposit button
        setupMakeDepositButton()
        
        // Add all views to content view
        contentView.addSubview(portfolioChartView)
        contentView.addSubview(portfolioStatsGrid)
        contentView.addSubview(makeDepositButton)
        
        // Setup deposit overlay
        setupDepositOverlay()
    }
    
    private func setupPortfolioChart() {
        portfolioChartView.translatesAutoresizingMaskIntoConstraints = false
        portfolioChartView.delegate = self
    }
    
    private func setupPortfolioStatsGrid() {
        portfolioStatsGrid.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupMakeDepositButton() {
        makeDepositButton.translatesAutoresizingMaskIntoConstraints = false
        makeDepositButton.setTitle("Make Deposit", for: .normal)
        makeDepositButton.setTitleColor(UIColor(red: 0.1, green: 0.3, blue: 0.8, alpha: 1.0), for: .normal) // Blue text
        makeDepositButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        makeDepositButton.backgroundColor = .clear // Transparent background
        makeDepositButton.layer.cornerRadius = 8
        makeDepositButton.layer.borderWidth = 1
        makeDepositButton.layer.borderColor = UIColor(red: 0.1, green: 0.3, blue: 0.8, alpha: 1.0).cgColor // Blue border matching text
        makeDepositButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16) // Minimum padding
        makeDepositButton.addTarget(self, action: #selector(makeDepositButtonTapped), for: .touchUpInside)
    }
    
    private func setupDepositOverlay() {
        depositOverlayView.translatesAutoresizingMaskIntoConstraints = false
        depositOverlayView.delegate = self
        depositOverlayView.isHidden = true
        view.addSubview(depositOverlayView)
        
        NSLayoutConstraint.activate([
            depositOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            depositOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            depositOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            depositOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
            portfolioChartView.heightAnchor.constraint(equalToConstant: 300),
            
            portfolioStatsGrid.topAnchor.constraint(equalTo: portfolioChartView.bottomAnchor, constant: 16),
            portfolioStatsGrid.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            portfolioStatsGrid.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            makeDepositButton.topAnchor.constraint(equalTo: portfolioStatsGrid.bottomAnchor, constant: 24),
            makeDepositButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            makeDepositButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            makeDepositButton.heightAnchor.constraint(equalToConstant: 50),
            makeDepositButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
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
        
        // Observe portfolio data updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePortfolioDataUpdate),
            name: .portfolioDataUpdated,
            object: nil
        )
    }
    
    @objc private func handlePortfolioDataUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.refreshData()
        }
    }
    
    private func loadData() {
        refreshData()
        marketDataService.startRealTimeUpdates()
    }
    
    private func refreshData() {
        let portfolio = portfolioManager.currentPortfolio
        
        // Update portfolio chart with real data
        if portfolio.historicalData.isEmpty {
            portfolioChartView.updateWithEmptyPortfolio()
        } else {
            portfolioChartView.updateWithPortfolioData(portfolio.historicalData)
        }
        
        // Update current portfolio value
        let totalChange = portfolio.totalValue - portfolio.totalInvested
        let changePercent = portfolio.totalROI
        portfolioChartView.updatePortfolioValue(portfolio.totalValue, change: totalChange, changePercent: changePercent)
        
        // Calculate cash percentage safely
        let cashPercentage = portfolio.totalValue > 0 ? (portfolio.balance / portfolio.totalValue) * 100 : 100.0
        
        // Update portfolio stats grid
        portfolioStatsGrid.updateStats(
            allTimeReturn: portfolio.totalROI,
            ytdReturn: calculateYTDReturn(),
            maxDrawdown: calculateMaxDrawdown(),
            sharpeRatio: calculateSharpeRatio(),
            cashPercentage: cashPercentage,
            topHolding: getTopHolding()
        )
    }
    
    // MARK: - Helpers
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    private func calculateYTDReturn() -> Double {
        let portfolio = portfolioManager.currentPortfolio
        let currentYear = Calendar.current.component(.year, from: Date())
        
        // Filter transactions from current year
        let ytdTransactions = portfolio.transactions.filter { transaction in
            let transactionYear = Calendar.current.component(.year, from: transaction.timestamp)
            return transactionYear == currentYear
        }
        
        // Calculate YTD return based on transactions
        let ytdInvested = ytdTransactions.filter { $0.type == .buy }.reduce(0.0) { $0 + $1.totalAmount }
        let ytdProceeds = ytdTransactions.filter { $0.type == .sell }.reduce(0.0) { $0 + $1.totalAmount }
        
        if ytdInvested > 0 {
            return ((ytdProceeds - ytdInvested) / ytdInvested) * 100
        }
        
        return portfolio.totalROI // Fallback to total ROI
    }
    
    private func calculateMaxDrawdown() -> Double {
        let portfolio = portfolioManager.currentPortfolio
        
        // Calculate max drawdown based on holdings performance
        let maxDrawdown = portfolio.holdings.reduce(0.0) { maxDrawdown, holding in
            let drawdown = min(holding.unrealizedGainLossPercent, 0)
            return min(maxDrawdown, drawdown)
        }
        
        return maxDrawdown
    }
    
    private func calculateSharpeRatio() -> Double {
        let portfolio = portfolioManager.currentPortfolio
        
        // Simple Sharpe ratio calculation based on current holdings
        let returns = portfolio.holdings.map { $0.unrealizedGainLossPercent }
        
        guard !returns.isEmpty else { return 0.0 }
        
        let averageReturn = returns.reduce(0.0, +) / Double(returns.count)
        let variance = returns.reduce(0.0) { sum, returnValue in
            sum + pow(returnValue - averageReturn, 2)
        } / Double(returns.count)
        
        let standardDeviation = sqrt(variance)
        
        // Risk-free rate assumed to be 2%
        let riskFreeRate = 2.0
        
        return standardDeviation > 0 ? (averageReturn - riskFreeRate) / standardDeviation : 0.0
    }
    
    private func getTopHolding() -> String {
        let holdings = portfolioManager.currentPortfolio.holdings
        guard let topHolding = holdings.max(by: { $0.currentValue < $1.currentValue }) else {
            return "N/A"
        }
        return topHolding.symbol
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Actions
    @objc private func makeDepositButtonTapped() {
        depositOverlayView.isHidden = false
        depositOverlayView.show()
    }
}

// MARK: - PortfolioChartViewDelegate
extension DashboardViewController: PortfolioChartViewDelegate {
    func didSelectTimePeriod(_ period: TimePeriod) {
        // Handle time period selection
        // The chart view will automatically update its display
        print("Selected time period: \(period.rawValue)")
    }
}

// MARK: - DepositOverlayViewDelegate
extension DashboardViewController: DepositOverlayViewDelegate {
    func depositOverlayDidCompleteDeposit(amount: Double) {
        // Process the deposit
        portfolioManager.deposit(amount: amount)
        
        // Hide the overlay
        depositOverlayView.hide { [weak self] in
            self?.depositOverlayView.isHidden = true
        }
        
        // Show success message
        let alert = UIAlertController(title: "Success", message: "Deposit of \(formatCurrency(amount)) completed successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func depositOverlayDidCancel() {
        // Hide the overlay
        depositOverlayView.hide { [weak self] in
            self?.depositOverlayView.isHidden = true
        }
    }
}



 