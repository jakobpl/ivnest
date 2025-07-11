//
//  InvestmentModels.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import Foundation

// MARK: - Asset Types
enum AssetType: String, CaseIterable, Codable {
    case stock = "stock"
    case cryptocurrency = "cryptocurrency"
}

// MARK: - Stock Model
struct Stock: Codable, Identifiable {
    let id: UUID
    let symbol: String
    let name: String
    var currentPrice: Double
    var previousClose: Double
    var change: Double
    var changePercent: Double
    let marketCap: Double?
    let volume: Int?
    let high: Double?
    let low: Double?
    let open: Double?
    
    var priceChangeColor: String {
        return change >= 0 ? "green" : "red"
    }
    
    init(symbol: String, name: String, currentPrice: Double, previousClose: Double, change: Double, changePercent: Double, marketCap: Double? = nil, volume: Int? = nil, high: Double? = nil, low: Double? = nil, open: Double? = nil) {
        self.id = UUID()
        self.symbol = symbol
        self.name = name
        self.currentPrice = currentPrice
        self.previousClose = previousClose
        self.change = change
        self.changePercent = changePercent
        self.marketCap = marketCap
        self.volume = volume
        self.high = high
        self.low = low
        self.open = open
    }
}

// MARK: - Cryptocurrency Model
struct Cryptocurrency: Codable, Identifiable {
    let id: UUID
    let symbol: String
    let name: String
    var currentPrice: Double
    var previousPrice: Double
    var change24h: Double
    var changePercent24h: Double
    let marketCap: Double?
    let volume24h: Double?
    let high24h: Double?
    let low24h: Double?
    
    var priceChangeColor: String {
        return change24h >= 0 ? "green" : "red"
    }
    
    init(symbol: String, name: String, currentPrice: Double, previousPrice: Double, change24h: Double, changePercent24h: Double, marketCap: Double? = nil, volume24h: Double? = nil, high24h: Double? = nil, low24h: Double? = nil) {
        self.id = UUID()
        self.symbol = symbol
        self.name = name
        self.currentPrice = currentPrice
        self.previousPrice = previousPrice
        self.change24h = change24h
        self.changePercent24h = changePercent24h
        self.marketCap = marketCap
        self.volume24h = volume24h
        self.high24h = high24h
        self.low24h = low24h
    }
}

// MARK: - Portfolio Model
struct Portfolio: Codable, Identifiable {
    let id: UUID
    var name: String
    var balance: Double
    var totalValue: Double
    var totalInvested: Double
    var totalROI: Double
    var monthlyROI: Double
    var holdings: [Holding]
    var transactions: [Transaction]
    var historicalData: [PortfolioDataPoint]
    var createdAt: Date
    var lastUpdated: Date
    
    init(name: String, initialBalance: Double = 0.0) {
        self.id = UUID()
        self.name = name
        self.balance = initialBalance
        self.totalValue = initialBalance
        self.totalInvested = 0.0
        self.totalROI = 0.0
        self.monthlyROI = 0.0
        self.holdings = []
        self.transactions = []
        self.historicalData = []
        self.createdAt = Date()
        self.lastUpdated = Date()
        
        // Add initial data point
        let initialDataPoint = PortfolioDataPoint(
            date: Date(),
            value: initialBalance,
            change: 0.0,
            changePercent: 0.0
        )
        self.historicalData.append(initialDataPoint)
    }
    
    init(name: String, cash: Double, holdings: [Holding], totalValue: Double, totalReturn: Double, totalReturnPercentage: Double) {
        self.id = UUID()
        self.name = name
        self.balance = cash
        self.totalValue = totalValue
        self.totalInvested = 0.0
        self.totalROI = totalReturnPercentage
        self.monthlyROI = 0.0
        self.holdings = holdings
        self.transactions = []
        self.historicalData = []
        self.createdAt = Date()
        self.lastUpdated = Date()
        
        // Add initial data point
        let initialDataPoint = PortfolioDataPoint(
            date: Date(),
            value: totalValue,
            change: totalReturn,
            changePercent: totalReturnPercentage
        )
        self.historicalData.append(initialDataPoint)
    }
    
    mutating func updatePortfolioValue() {
        let holdingsValue = holdings.reduce(0.0) { $0 + $1.currentValue }
        totalValue = balance + holdingsValue
        totalInvested = holdings.reduce(0.0) { $0 + $1.totalInvested }
        totalROI = totalInvested > 0 ? ((totalValue - totalInvested) / totalInvested) * 100 : 0.0
        lastUpdated = Date()
        
        // Add historical data point
        let dataPoint = PortfolioDataPoint(
            date: Date(),
            value: totalValue,
            change: totalValue - totalInvested,
            changePercent: totalROI
        )
        historicalData.append(dataPoint)
    }
}

// MARK: - Portfolio Data Point
struct PortfolioDataPoint: Codable {
    let date: Date
    let value: Double
    let change: Double
    let changePercent: Double
}


// MARK: - Holding Model
struct Holding: Codable, Identifiable {
    let id: UUID
    let assetType: AssetType
    let symbol: String
    let name: String
    var quantity: Double
    var averagePrice: Double
    var currentPrice: Double
    var totalInvested: Double
    var currentValue: Double
    var unrealizedGainLoss: Double
    var unrealizedGainLossPercent: Double
    var lastUpdated: Date
    
    init(assetType: AssetType, symbol: String, name: String, quantity: Double, price: Double) {
        self.id = UUID()
        self.assetType = assetType
        self.symbol = symbol
        self.name = name
        self.quantity = quantity
        self.averagePrice = price
        self.currentPrice = price
        self.totalInvested = quantity * price
        self.currentValue = quantity * price
        self.unrealizedGainLoss = 0.0
        self.unrealizedGainLossPercent = 0.0
        self.lastUpdated = Date()
    }
    
    mutating func updateCurrentPrice(_ newPrice: Double) {
        currentPrice = newPrice
        currentValue = quantity * currentPrice
        unrealizedGainLoss = currentValue - totalInvested
        unrealizedGainLossPercent = totalInvested > 0 ? (unrealizedGainLoss / totalInvested) * 100 : 0.0
        lastUpdated = Date()
    }
    
    mutating func addShares(_ additionalQuantity: Double, at price: Double) {
        let totalCost = (quantity * averagePrice) + (additionalQuantity * price)
        quantity += additionalQuantity
        averagePrice = totalCost / quantity
        totalInvested = quantity * averagePrice
        updateCurrentPrice(currentPrice)
    }
}

// MARK: - Transaction Model
struct Transaction: Codable, Identifiable {
    let id: UUID
    let type: TransactionType
    let assetType: AssetType
    let symbol: String
    let name: String
    let quantity: Double
    let price: Double
    let totalAmount: Double
    let timestamp: Date
    let portfolioId: UUID
    
    init(type: TransactionType, assetType: AssetType, symbol: String, name: String, quantity: Double, price: Double, totalAmount: Double, timestamp: Date, portfolioId: UUID) {
        self.id = UUID()
        self.type = type
        self.assetType = assetType
        self.symbol = symbol
        self.name = name
        self.quantity = quantity
        self.price = price
        self.totalAmount = totalAmount
        self.timestamp = timestamp
        self.portfolioId = portfolioId
    }
    
    enum TransactionType: String, CaseIterable, Codable {
        case buy = "buy"
        case sell = "sell"
        case deposit = "deposit"
        case withdrawal = "withdrawal"
    }
}

// MARK: - Performance Statistics
struct PerformanceStats: Codable {
    let totalROI: Double
    let monthlyROI: Double
    let yearlyROI: Double
    let bestPerformingAsset: String
    let worstPerformingAsset: String
    let totalTrades: Int
    let winningTrades: Int
    let losingTrades: Int
    let averageTradeReturn: Double
    let portfolioVolatility: Double
    let sharpeRatio: Double
    
    var winRate: Double {
        return totalTrades > 0 ? (Double(winningTrades) / Double(totalTrades)) * 100 : 0.0
    }
}

// MARK: - Market Data
struct MarketData: Codable {
    let timestamp: Date
    let price: Double
    let volume: Double
    let high: Double
    let low: Double
    let open: Double
}

// MARK: - Watchlist Item
struct WatchlistItem: Codable, Identifiable {
    let id: UUID
    let assetType: AssetType
    let symbol: String
    let name: String
    var currentPrice: Double
    var priceChange: Double
    var priceChangePercent: Double
    var addedAt: Date
    
    var priceChangeColor: String {
        return priceChange >= 0 ? "green" : "red"
    }
    
    init(assetType: AssetType, symbol: String, name: String, currentPrice: Double, priceChange: Double, priceChangePercent: Double, addedAt: Date = Date()) {
        self.id = UUID()
        self.assetType = assetType
        self.symbol = symbol
        self.name = name
        self.currentPrice = currentPrice
        self.priceChange = priceChange
        self.priceChangePercent = priceChangePercent
        self.addedAt = addedAt
    }
} 
