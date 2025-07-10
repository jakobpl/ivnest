//
//  PortfolioManager.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import Foundation
import Combine

extension Notification.Name {
    static let portfolioDataUpdated = Notification.Name("portfolioDataUpdated")
}

class PortfolioManager: ObservableObject {
    static let shared = PortfolioManager()
    
    @Published var currentPortfolio: Portfolio
    @Published var portfolios: [Portfolio] = []
    @Published var watchlist: [WatchlistItem] = []
    
    private let userDefaults = UserDefaults.standard
    private let portfolioKey = "savedPortfolios"
    private let watchlistKey = "savedWatchlist"
    
    private init() {
        // Create default portfolio with historical data
        let calendar = Calendar.current
        let now = Date()
        var historicalData: [PortfolioDataPoint] = []
        
        // Add historical data points for the last 30 days with 0 values
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: now) {
                let dataPoint = PortfolioDataPoint(
                    date: date,
                    value: 0.0,
                    change: 0.0,
                    changePercent: 0.0
                )
                historicalData.append(dataPoint)
            }
        }
        
        let defaultPortfolio = Portfolio(
            name: "My Portfolio",
            cash: 0.0,
            holdings: [],
            totalValue: 0.0,
            totalReturn: 0.0,
            totalReturnPercentage: 0.0
        )
        
        // Load saved portfolios or create default with 0 balance
        if let data = userDefaults.data(forKey: portfolioKey),
           let savedPortfolios = try? JSONDecoder().decode([Portfolio].self, from: data) {
            self.portfolios = savedPortfolios
            self.currentPortfolio = savedPortfolios.first ?? defaultPortfolio
        } else {
            self.currentPortfolio = defaultPortfolio
            self.portfolios = [currentPortfolio]
        }
        
        // Load watchlist
        if let data = userDefaults.data(forKey: watchlistKey),
           let savedWatchlist = try? JSONDecoder().decode([WatchlistItem].self, from: data) {
            self.watchlist = savedWatchlist
        }
        
        // Start real-time updates
        startRealTimeUpdates()
    }
    
    // MARK: - Portfolio Management
    

    
    func createPortfolio(name: String, initialBalance: Double = 0.0) {
        let newPortfolio = Portfolio(name: name, initialBalance: initialBalance)
        portfolios.append(newPortfolio)
        savePortfolios()
    }
    
    func resetPortfolio() {
        currentPortfolio.balance = 0.0
        currentPortfolio.holdings = []
        currentPortfolio.transactions = []
        currentPortfolio.updatePortfolioValue()
        updateCurrentPortfolio()
    }
    
    func switchPortfolio(_ portfolio: Portfolio) {
        if let index = portfolios.firstIndex(where: { $0.id == portfolio.id }) {
            currentPortfolio = portfolios[index]
        }
    }
    
    func deletePortfolio(_ portfolio: Portfolio) {
        portfolios.removeAll { $0.id == portfolio.id }
        if currentPortfolio.id == portfolio.id {
            // Create default portfolio inline
            let defaultPortfolio = Portfolio(
                name: "My Portfolio",
                cash: 0.0,
                holdings: [],
                totalValue: 0.0,
                totalReturn: 0.0,
                totalReturnPercentage: 0.0
            )
            currentPortfolio = portfolios.first ?? defaultPortfolio
        }
        savePortfolios()
    }
    
    // MARK: - Balance Management
    
    func deposit(amount: Double) {
        currentPortfolio.balance += amount
        let transaction = Transaction(
            type: .deposit,
            assetType: .stock, // Not relevant for deposits
            symbol: "CASH",
            name: "Cash Deposit",
            quantity: amount,
            price: 1.0,
            totalAmount: amount,
            timestamp: Date(),
            portfolioId: currentPortfolio.id
        )
        currentPortfolio.transactions.append(transaction)
        updateCurrentPortfolio()
    }
    
    func withdraw(amount: Double) -> Bool {
        guard currentPortfolio.balance >= amount else { return false }
        
        currentPortfolio.balance -= amount
        let transaction = Transaction(
            type: .withdrawal,
            assetType: .stock, // Not relevant for withdrawals
            symbol: "CASH",
            name: "Cash Withdrawal",
            quantity: amount,
            price: 1.0,
            totalAmount: amount,
            timestamp: Date(),
            portfolioId: currentPortfolio.id
        )
        currentPortfolio.transactions.append(transaction)
        updateCurrentPortfolio()
        return true
    }
    
    // MARK: - Trading Operations
    
    func buyStock(symbol: String, name: String, quantity: Double, price: Double) -> Bool {
        let totalCost = quantity * price
        guard currentPortfolio.balance >= totalCost else { return false }
        
        currentPortfolio.balance -= totalCost
        
        // Check if we already own this stock
        if let index = currentPortfolio.holdings.firstIndex(where: { $0.symbol == symbol && $0.assetType == .stock }) {
            currentPortfolio.holdings[index].addShares(quantity, at: price)
        } else {
            let holding = Holding(assetType: .stock, symbol: symbol, name: name, quantity: quantity, price: price)
            currentPortfolio.holdings.append(holding)
        }
        
        let transaction = Transaction(
            type: .buy,
            assetType: .stock,
            symbol: symbol,
            name: name,
            quantity: quantity,
            price: price,
            totalAmount: totalCost,
            timestamp: Date(),
            portfolioId: currentPortfolio.id
        )
        currentPortfolio.transactions.append(transaction)
        updateCurrentPortfolio()
        return true
    }
    
    func sellStock(symbol: String, quantity: Double, price: Double) -> Bool {
        guard let index = currentPortfolio.holdings.firstIndex(where: { $0.symbol == symbol && $0.assetType == .stock }),
              currentPortfolio.holdings[index].quantity >= quantity else { return false }
        
        let totalProceeds = quantity * price
        currentPortfolio.balance += totalProceeds
        
        let holding = currentPortfolio.holdings[index]
        let transaction = Transaction(
            type: .sell,
            assetType: .stock,
            symbol: symbol,
            name: holding.name,
            quantity: quantity,
            price: price,
            totalAmount: totalProceeds,
            timestamp: Date(),
            portfolioId: currentPortfolio.id
        )
        currentPortfolio.transactions.append(transaction)
        
        // Update holding
        currentPortfolio.holdings[index].quantity -= quantity
        if currentPortfolio.holdings[index].quantity <= 0 {
            currentPortfolio.holdings.remove(at: index)
        } else {
            currentPortfolio.holdings[index].updateCurrentPrice(price)
        }
        
        updateCurrentPortfolio()
        return true
    }
    
    func buyCrypto(symbol: String, name: String, quantity: Double, price: Double) -> Bool {
        let totalCost = quantity * price
        guard currentPortfolio.balance >= totalCost else { return false }
        
        currentPortfolio.balance -= totalCost
        
        // Check if we already own this crypto
        if let index = currentPortfolio.holdings.firstIndex(where: { $0.symbol == symbol && $0.assetType == .cryptocurrency }) {
            currentPortfolio.holdings[index].addShares(quantity, at: price)
        } else {
            let holding = Holding(assetType: .cryptocurrency, symbol: symbol, name: name, quantity: quantity, price: price)
            currentPortfolio.holdings.append(holding)
        }
        
        let transaction = Transaction(
            type: .buy,
            assetType: .cryptocurrency,
            symbol: symbol,
            name: name,
            quantity: quantity,
            price: price,
            totalAmount: totalCost,
            timestamp: Date(),
            portfolioId: currentPortfolio.id
        )
        currentPortfolio.transactions.append(transaction)
        updateCurrentPortfolio()
        return true
    }
    
    func sellCrypto(symbol: String, quantity: Double, price: Double) -> Bool {
        guard let index = currentPortfolio.holdings.firstIndex(where: { $0.symbol == symbol && $0.assetType == .cryptocurrency }),
              currentPortfolio.holdings[index].quantity >= quantity else { return false }
        
        let totalProceeds = quantity * price
        currentPortfolio.balance += totalProceeds
        
        let holding = currentPortfolio.holdings[index]
        let transaction = Transaction(
            type: .sell,
            assetType: .cryptocurrency,
            symbol: symbol,
            name: holding.name,
            quantity: quantity,
            price: price,
            totalAmount: totalProceeds,
            timestamp: Date(),
            portfolioId: currentPortfolio.id
        )
        currentPortfolio.transactions.append(transaction)
        
        // Update holding
        currentPortfolio.holdings[index].quantity -= quantity
        if currentPortfolio.holdings[index].quantity <= 0 {
            currentPortfolio.holdings.remove(at: index)
        } else {
            currentPortfolio.holdings[index].updateCurrentPrice(price)
        }
        
        updateCurrentPortfolio()
        return true
    }
    
    // MARK: - Price Updates
    
    func updateStockPrice(symbol: String, newPrice: Double) {
        if let index = currentPortfolio.holdings.firstIndex(where: { $0.symbol == symbol && $0.assetType == .stock }) {
            currentPortfolio.holdings[index].updateCurrentPrice(newPrice)
            updateCurrentPortfolio()
        }
    }
    
    func updateCryptoPrice(symbol: String, newPrice: Double) {
        if let index = currentPortfolio.holdings.firstIndex(where: { $0.symbol == symbol && $0.assetType == .cryptocurrency }) {
            currentPortfolio.holdings[index].updateCurrentPrice(newPrice)
            updateCurrentPortfolio()
        }
    }
    
    // MARK: - Watchlist Management
    
    func addToWatchlist(_ item: WatchlistItem) {
        if !watchlist.contains(where: { $0.symbol == item.symbol && $0.assetType == item.assetType }) {
            watchlist.append(item)
            saveWatchlist()
        }
    }
    
    func removeFromWatchlist(symbol: String, assetType: AssetType) {
        watchlist.removeAll { $0.symbol == symbol && $0.assetType == assetType }
        saveWatchlist()
    }
    
    func updateWatchlistPrice(symbol: String, assetType: AssetType, newPrice: Double, priceChange: Double, priceChangePercent: Double) {
        if let index = watchlist.firstIndex(where: { $0.symbol == symbol && $0.assetType == assetType }) {
            watchlist[index].currentPrice = newPrice
            watchlist[index].priceChange = priceChange
            watchlist[index].priceChangePercent = priceChangePercent
            saveWatchlist()
        }
    }
    
    // MARK: - Analytics
    
    func calculatePerformanceStats() -> PerformanceStats {
        let totalTrades = currentPortfolio.transactions.filter { $0.type == .buy || $0.type == .sell }.count
        let winningTrades = currentPortfolio.transactions.filter { transaction in
            if transaction.type == .sell {
                // Find the corresponding buy transaction
                let buyTransactions = currentPortfolio.transactions.filter { 
                    $0.symbol == transaction.symbol && $0.type == .buy && $0.timestamp < transaction.timestamp 
                }
                if let buyTransaction = buyTransactions.last {
                    return transaction.price > buyTransaction.price
                }
            }
            return false
        }.count
        
        let losingTrades = totalTrades - winningTrades
        
        let bestPerformingAsset = currentPortfolio.holdings.max(by: { $0.unrealizedGainLossPercent < $1.unrealizedGainLossPercent })?.symbol ?? "N/A"
        let worstPerformingAsset = currentPortfolio.holdings.min(by: { $0.unrealizedGainLossPercent < $1.unrealizedGainLossPercent })?.symbol ?? "N/A"
        
        return PerformanceStats(
            totalROI: currentPortfolio.totalROI,
            monthlyROI: currentPortfolio.monthlyROI,
            yearlyROI: 0.0, // TODO: Calculate yearly ROI
            bestPerformingAsset: bestPerformingAsset,
            worstPerformingAsset: worstPerformingAsset,
            totalTrades: totalTrades,
            winningTrades: winningTrades,
            losingTrades: losingTrades,
            averageTradeReturn: 0.0, // TODO: Calculate average trade return
            portfolioVolatility: 0.0, // TODO: Calculate volatility
            sharpeRatio: 0.0 // TODO: Calculate Sharpe ratio
        )
    }
    
    // MARK: - Private Methods
    
    private func updateCurrentPortfolio() {
        currentPortfolio.updatePortfolioValue()
        if let index = portfolios.firstIndex(where: { $0.id == currentPortfolio.id }) {
            portfolios[index] = currentPortfolio
        }
        savePortfolios()
        
        // Notify that portfolio data has changed
        NotificationCenter.default.post(name: .portfolioDataUpdated, object: nil)
    }
    
    private func savePortfolios() {
        if let data = try? JSONEncoder().encode(portfolios) {
            userDefaults.set(data, forKey: portfolioKey)
        }
    }
    
    private func saveWatchlist() {
        if let data = try? JSONEncoder().encode(watchlist) {
            userDefaults.set(data, forKey: watchlistKey)
        }
    }
    
    // MARK: - Real-time Updates
    
    private func startRealTimeUpdates() {
        // Listen for price updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleHoldingPriceUpdate),
            name: .holdingPriceUpdated,
            object: nil
        )
        
        // Update portfolio holdings every 30 seconds
        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.updatePortfolioHoldings()
        }
    }
    
    @objc private func handleHoldingPriceUpdate(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let symbol = userInfo["symbol"] as? String,
              let assetType = userInfo["assetType"] as? AssetType,
              let currentPrice = userInfo["currentPrice"] as? Double else {
            return
        }
        
        // Update holding price
        if let index = currentPortfolio.holdings.firstIndex(where: { $0.symbol == symbol && $0.assetType == assetType }) {
            currentPortfolio.holdings[index].updateCurrentPrice(currentPrice)
            updateCurrentPortfolio()
        }
        
        // Update watchlist price
        if let index = watchlist.firstIndex(where: { $0.symbol == symbol && $0.assetType == assetType }) {
            let oldPrice = watchlist[index].currentPrice
            watchlist[index].currentPrice = currentPrice
            watchlist[index].priceChange = currentPrice - oldPrice
            watchlist[index].priceChangePercent = oldPrice > 0 ? ((currentPrice - oldPrice) / oldPrice) * 100 : 0.0
            saveWatchlist()
        }
    }
    
    private func updatePortfolioHoldings() {
        // Update all holdings with current market data
        MarketDataService.shared.updatePortfolioHoldings(currentPortfolio.holdings)
    }
} 