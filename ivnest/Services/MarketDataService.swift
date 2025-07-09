//
//  MarketDataService.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import Foundation
import Combine

class MarketDataService: ObservableObject {
    static let shared = MarketDataService()
    
    // API Keys - Replace with your actual API keys
    private let alphaVantageAPIKey = "YOUR_ALPHA_VANTAGE_API_KEY"
    private let coinGeckoBaseURL = "https://api.coingecko.com/api/v3"
    
    @Published var popularStocks: [Stock] = []
    @Published var popularCrypto: [Cryptocurrency] = []
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadPopularAssets()
    }
    
    // MARK: - Stock Data
    
    func fetchStockQuote(symbol: String) -> AnyPublisher<Stock?, Error> {
        let urlString = "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=\(symbol)&apikey=\(alphaVantageAPIKey)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: AlphaVantageResponse.self, decoder: JSONDecoder())
            .map { response in
                guard let quote = response.globalQuote else { return nil }
                return Stock(
                    symbol: quote.symbol,
                    name: quote.symbol, // Alpha Vantage doesn't provide company name in global quote
                    currentPrice: Double(quote.price) ?? 0.0,
                    previousClose: Double(quote.previousClose) ?? 0.0,
                    change: Double(quote.change) ?? 0.0,
                    changePercent: Double(quote.changePercent.replacingOccurrences(of: "%", with: "")) ?? 0.0,
                    marketCap: nil,
                    volume: Int(quote.volume),
                    high: Double(quote.high),
                    low: Double(quote.low),
                    open: Double(quote.open)
                )
            }
            .eraseToAnyPublisher()
    }
    
    func searchStocks(query: String) -> AnyPublisher<[Stock], Error> {
        let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(query)&apikey=\(alphaVantageAPIKey)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: SymbolSearchResponse.self, decoder: JSONDecoder())
            .map { response in
                return response.bestMatches.map { match in
                    Stock(
                        symbol: match.symbol,
                        name: match.name,
                        currentPrice: 0.0, // Will be fetched separately
                        previousClose: 0.0,
                        change: 0.0,
                        changePercent: 0.0,
                        marketCap: nil,
                        volume: nil,
                        high: nil,
                        low: nil,
                        open: nil
                    )
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Cryptocurrency Data
    
    func fetchCryptoPrice(symbol: String) -> AnyPublisher<Cryptocurrency?, Error> {
        let urlString = "\(coinGeckoBaseURL)/simple/price?ids=\(symbol.lowercased())&vs_currencies=usd&include_24hr_change=true&include_market_cap=true&include_24hr_vol=true&include_24hr_high=true&include_24hr_low=true"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [String: CoinGeckoPriceData].self, decoder: JSONDecoder())
            .map { data in
                guard let priceData = data[symbol.lowercased()] else { return nil }
                return Cryptocurrency(
                    symbol: symbol.uppercased(),
                    name: symbol.capitalized,
                    currentPrice: priceData.usd,
                    previousPrice: priceData.usd - priceData.usd_24h_change,
                    change24h: priceData.usd_24h_change,
                    changePercent24h: priceData.usd_24h_change_percentage,
                    marketCap: priceData.usd_market_cap,
                    volume24h: priceData.usd_24h_vol,
                    high24h: priceData.usd_24h_high,
                    low24h: priceData.usd_24h_low
                )
            }
            .eraseToAnyPublisher()
    }
    
    func searchCrypto(query: String) -> AnyPublisher<[Cryptocurrency], Error> {
        let urlString = "\(coinGeckoBaseURL)/search?query=\(query)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: CoinGeckoSearchResponse.self, decoder: JSONDecoder())
            .map { response in
                return response.coins.prefix(10).map { coin in
                    Cryptocurrency(
                        symbol: coin.symbol.uppercased(),
                        name: coin.name,
                        currentPrice: 0.0, // Will be fetched separately
                        previousPrice: 0.0,
                        change24h: 0.0,
                        changePercent24h: 0.0,
                        marketCap: nil,
                        volume24h: nil,
                        high24h: nil,
                        low24h: nil
                    )
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Popular Assets
    
    private func loadPopularAssets() {
        // Load popular stocks (mock data for now)
        popularStocks = [
            Stock(symbol: "AAPL", name: "Apple Inc.", currentPrice: 150.0, previousClose: 148.0, change: 2.0, changePercent: 1.35, marketCap: 2500000000000, volume: 50000000, high: 152.0, low: 147.0, open: 149.0),
            Stock(symbol: "GOOGL", name: "Alphabet Inc.", currentPrice: 2800.0, previousClose: 2750.0, change: 50.0, changePercent: 1.82, marketCap: 1800000000000, volume: 2000000, high: 2820.0, low: 2740.0, open: 2760.0),
            Stock(symbol: "MSFT", name: "Microsoft Corporation", currentPrice: 320.0, previousClose: 315.0, change: 5.0, changePercent: 1.59, marketCap: 2400000000000, volume: 30000000, high: 325.0, low: 314.0, open: 316.0),
            Stock(symbol: "TSLA", name: "Tesla Inc.", currentPrice: 800.0, previousClose: 820.0, change: -20.0, changePercent: -2.44, marketCap: 800000000000, volume: 15000000, high: 825.0, low: 795.0, open: 815.0),
            Stock(symbol: "AMZN", name: "Amazon.com Inc.", currentPrice: 3300.0, previousClose: 3250.0, change: 50.0, changePercent: 1.54, marketCap: 1600000000000, volume: 8000000, high: 3320.0, low: 3240.0, open: 3260.0)
        ]
        
        // Load popular crypto (mock data for now)
        popularCrypto = [
            Cryptocurrency(symbol: "BTC", name: "Bitcoin", currentPrice: 45000.0, previousPrice: 44000.0, change24h: 1000.0, changePercent24h: 2.27, marketCap: 850000000000, volume24h: 30000000000, high24h: 45500.0, low24h: 43800.0),
            Cryptocurrency(symbol: "ETH", name: "Ethereum", currentPrice: 3200.0, previousPrice: 3100.0, change24h: 100.0, changePercent24h: 3.23, marketCap: 380000000000, volume24h: 15000000000, high24h: 3250.0, low24h: 3080.0),
            Cryptocurrency(symbol: "ADA", name: "Cardano", currentPrice: 1.50, previousPrice: 1.45, change24h: 0.05, changePercent24h: 3.45, marketCap: 48000000000, volume24h: 2000000000, high24h: 1.55, low24h: 1.44),
            Cryptocurrency(symbol: "SOL", name: "Solana", currentPrice: 150.0, previousPrice: 145.0, change24h: 5.0, changePercent24h: 3.45, marketCap: 45000000000, volume24h: 3000000000, high24h: 155.0, low24h: 144.0),
            Cryptocurrency(symbol: "DOT", name: "Polkadot", currentPrice: 25.0, previousPrice: 24.0, change24h: 1.0, changePercent24h: 4.17, marketCap: 25000000000, volume24h: 1000000000, high24h: 25.5, low24h: 23.8)
        ]
    }
    
    // MARK: - Real-time Updates
    
    func startRealTimeUpdates() {
        // In a real app, you would use WebSocket connections for real-time updates
        // For now, we'll simulate updates with a timer
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updatePrices()
            }
            .store(in: &cancellables)
    }
    
    private func updatePrices() {
        // Simulate price changes
        for i in 0..<popularStocks.count {
            let randomChange = Double.random(in: -5...5)
            popularStocks[i].currentPrice += randomChange
            popularStocks[i].change += randomChange
            popularStocks[i].changePercent = (popularStocks[i].change / popularStocks[i].previousClose) * 100
        }
        
        for i in 0..<popularCrypto.count {
            let randomChange = Double.random(in: -500...500)
            popularCrypto[i].currentPrice += randomChange
            popularCrypto[i].change24h += randomChange
            popularCrypto[i].changePercent24h = (popularCrypto[i].change24h / popularCrypto[i].previousPrice) * 100
        }
    }
}

// MARK: - Network Models

struct AlphaVantageResponse: Codable {
    let globalQuote: GlobalQuote?
    
    enum CodingKeys: String, CodingKey {
        case globalQuote = "Global Quote"
    }
}

struct GlobalQuote: Codable {
    let symbol: String
    let price: String
    let previousClose: String
    let change: String
    let changePercent: String
    let volume: String
    let high: String
    let low: String
    let open: String
}

struct SymbolSearchResponse: Codable {
    let bestMatches: [SymbolMatch]
}

struct SymbolMatch: Codable {
    let symbol: String
    let name: String
}

struct CoinGeckoPriceData: Codable {
    let usd: Double
    let usd_24h_change: Double
    let usd_24h_change_percentage: Double
    let usd_market_cap: Double?
    let usd_24h_vol: Double?
    let usd_24h_high: Double?
    let usd_24h_low: Double?
}

struct CoinGeckoSearchResponse: Codable {
    let coins: [CoinGeckoCoin]
}

struct CoinGeckoCoin: Codable {
    let id: String
    let name: String
    let symbol: String
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
} 