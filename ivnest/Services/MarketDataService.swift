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
    
    // API Keys - Read from Info.plist
    private var alphaVantageAPIKey: String {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let apiKey = plist["API_KEY"] as? String else {
            fatalError("API_KEY not found in Info.plist")
        }
        return apiKey
    }
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
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(encodedQuery)&apikey=\(alphaVantageAPIKey)"
        
        print("🔍 Searching stocks for query: '\(query)'")
        print("🔗 URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL for stock search")
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .handleEvents(receiveOutput: { data in
                print("📦 Received \(data.count) bytes for stock search")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📄 Response: \(jsonString)")
                    
                    // Check for Alpha Vantage error messages
                    if jsonString.contains("\"Note\":") {
                        print("⚠️ Alpha Vantage API limit reached or error")
                    }
                    if jsonString.contains("\"Error Message\":") {
                        print("⚠️ Alpha Vantage API error")
                    }
                }
            })
            .decode(type: SymbolSearchResponse.self, decoder: JSONDecoder())
            .map { response in
                print("✅ Found \(response.bestMatches.count) stock matches")
                for match in response.bestMatches {
                    print("   📈 \(match.symbol) - \(match.name)")
                }
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
            .catch { error in
                print("❌ Stock search error: \(error)")
                return Fail<[Stock], Error>(error: error).eraseToAnyPublisher()
            }
            .flatMap { (stocks: [Stock]) -> AnyPublisher<[Stock], Error> in
                if stocks.isEmpty {
                    print("🔍 No API results, trying fallback search for: \(query)")
                    return self.fallbackStockSearch(query: query)
                } else {
                    return Just(stocks).setFailureType(to: Error.self).eraseToAnyPublisher()
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
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "\(coinGeckoBaseURL)/search?query=\(encodedQuery)"
        
        print("🔍 Searching crypto for query: '\(query)'")
        print("🔗 URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL for crypto search")
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .handleEvents(receiveOutput: { data in
                print("📦 Received \(data.count) bytes for crypto search")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📄 Response: \(jsonString)")
                }
            })
            .decode(type: CoinGeckoSearchResponse.self, decoder: JSONDecoder())
            .map { response in
                print("✅ Found \(response.coins.count) crypto matches")
                for coin in response.coins.prefix(10) {
                    print("   🪙 \(coin.symbol.uppercased()) - \(coin.name)")
                }
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
            .catch { error in
                print("❌ Crypto search error: \(error)")
                return Fail<[Cryptocurrency], Error>(error: error).eraseToAnyPublisher()
            }
            .flatMap { (cryptos: [Cryptocurrency]) -> AnyPublisher<[Cryptocurrency], Error> in
                if cryptos.isEmpty {
                    print("🔍 No API results, trying fallback crypto search for: \(query)")
                    return self.fallbackCryptoSearch(query: query)
                } else {
                    return Just(cryptos).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Popular Assets
    
    private func loadPopularAssets() {
        // Load popular stocks with real data
        let popularSymbols = ["AAPL", "GOOGL", "MSFT", "TSLA", "AMZN"]
        
        for symbol in popularSymbols {
            fetchStockQuote(symbol: symbol)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] stock in
                        if let stock = stock {
                            DispatchQueue.main.async {
                                if let index = self?.popularStocks.firstIndex(where: { $0.symbol == symbol }) {
                                    self?.popularStocks[index] = stock
                                } else {
                                    self?.popularStocks.append(stock)
                                }
                            }
                        }
                    }
                )
                .store(in: &cancellables)
        }
        
        // Load popular crypto with real data
        let popularCryptoIds = ["bitcoin", "ethereum", "cardano", "solana", "polkadot"]
        
        for cryptoId in popularCryptoIds {
            fetchCryptoPrice(symbol: cryptoId)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] crypto in
                        if let crypto = crypto {
                            DispatchQueue.main.async {
                                if let index = self?.popularCrypto.firstIndex(where: { $0.symbol.lowercased() == cryptoId }) {
                                    self?.popularCrypto[index] = crypto
                                } else {
                                    self?.popularCrypto.append(crypto)
                                }
                            }
                        }
                    }
                )
                .store(in: &cancellables)
        }
    }
    
    // MARK: - Real-time Updates
    
    func startRealTimeUpdates() {
        // Update popular assets every 30 seconds
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updatePopularAssets()
            }
            .store(in: &cancellables)
    }
    
    private func updatePopularAssets() {
        // Update popular stocks
        let popularSymbols = ["AAPL", "GOOGL", "MSFT", "TSLA", "AMZN"]
        
        for symbol in popularSymbols {
            fetchStockQuote(symbol: symbol)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] stock in
                        if let stock = stock {
                            DispatchQueue.main.async {
                                if let index = self?.popularStocks.firstIndex(where: { $0.symbol == symbol }) {
                                    self?.popularStocks[index] = stock
                                }
                            }
                        }
                    }
                )
                .store(in: &cancellables)
        }
        
        // Update popular crypto
        let popularCryptoIds = ["bitcoin", "ethereum", "cardano", "solana", "polkadot"]
        
        for cryptoId in popularCryptoIds {
            fetchCryptoPrice(symbol: cryptoId)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] crypto in
                        if let crypto = crypto {
                            DispatchQueue.main.async {
                                if let index = self?.popularCrypto.firstIndex(where: { $0.symbol.lowercased() == cryptoId }) {
                                    self?.popularCrypto[index] = crypto
                                }
                            }
                        }
                    }
                )
                .store(in: &cancellables)
        }
    }
    
    // MARK: - Portfolio Tracking
    
    func updatePortfolioHoldings(_ holdings: [Holding]) {
        for holding in holdings {
            if holding.assetType == .stock {
                fetchStockQuote(symbol: holding.symbol)
                    .sink(
                        receiveCompletion: { _ in },
                        receiveValue: { stock in
                            if let stock = stock {
                                DispatchQueue.main.async {
                                    // Notify portfolio manager to update holding price
                                    NotificationCenter.default.post(
                                        name: .holdingPriceUpdated,
                                        object: nil,
                                        userInfo: [
                                            "symbol": holding.symbol,
                                            "assetType": AssetType.stock,
                                            "currentPrice": stock.currentPrice
                                        ]
                                    )
                                }
                            }
                        }
                    )
                    .store(in: &cancellables)
            } else if holding.assetType == .cryptocurrency {
                // For crypto, we need to map common symbols to CoinGecko IDs
                let cryptoId = mapCryptoSymbolToId(holding.symbol)
                fetchCryptoPrice(symbol: cryptoId)
                    .sink(
                        receiveCompletion: { _ in },
                        receiveValue: { crypto in
                            if let crypto = crypto {
                                DispatchQueue.main.async {
                                    // Notify portfolio manager to update holding price
                                    NotificationCenter.default.post(
                                        name: .holdingPriceUpdated,
                                        object: nil,
                                        userInfo: [
                                            "symbol": holding.symbol,
                                            "assetType": AssetType.cryptocurrency,
                                            "currentPrice": crypto.currentPrice
                                        ]
                                    )
                                }
                            }
                        }
                    )
                    .store(in: &cancellables)
            }
        }
    }
    
    func mapCryptoSymbolToId(_ symbol: String) -> String {
        // Map common crypto symbols to CoinGecko IDs
        let mapping = [
            "BTC": "bitcoin",
            "ETH": "ethereum",
            "ADA": "cardano",
            "SOL": "solana",
            "DOT": "polkadot",
            "LTC": "litecoin",
            "XRP": "ripple",
            "DOGE": "dogecoin",
            "SHIB": "shiba-inu",
            "MATIC": "matic-network"
        ]
        return mapping[symbol.uppercased()] ?? symbol.lowercased()
    }
    
    // MARK: - Fallback Search Methods
    
    private func fallbackStockSearch(query: String) -> AnyPublisher<[Stock], Error> {
        print("🔄 Using fallback stock search for: \(query)")
        
        let commonStocks = [
            ("AAPL", "Apple Inc."),
            ("TSLA", "Tesla Inc."),
            ("GOOGL", "Alphabet Inc."),
            ("MSFT", "Microsoft Corporation"),
            ("AMZN", "Amazon.com Inc."),
            ("META", "Meta Platforms Inc."),
            ("NVDA", "NVIDIA Corporation"),
            ("NFLX", "Netflix Inc."),
            ("SWPPX", "Schwab S&P 500 Index Fund"),
            ("VOO", "Vanguard S&P 500 ETF"),
            ("SPY", "SPDR S&P 500 ETF Trust"),
            ("QQQ", "Invesco QQQ Trust"),
            ("VTI", "Vanguard Total Stock Market ETF"),
            ("VEA", "Vanguard FTSE Developed Markets ETF"),
            ("VWO", "Vanguard FTSE Emerging Markets ETF")
        ]
        
        let matchingStocks = commonStocks.filter { stock in
            stock.0.uppercased().contains(query.uppercased()) ||
            stock.1.uppercased().contains(query.uppercased())
        }
        
        print("📈 Fallback found \(matchingStocks.count) stocks")
        for stock in matchingStocks {
            print("   📈 \(stock.0) - \(stock.1)")
        }
        
        let stocks = matchingStocks.map { symbol, name in
            Stock(
                symbol: symbol,
                name: name,
                currentPrice: 0.0,
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
        
        return Just(stocks).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    private func fallbackCryptoSearch(query: String) -> AnyPublisher<[Cryptocurrency], Error> {
        print("🔄 Using fallback crypto search for: \(query)")
        
        let commonCryptos = [
            ("BTC", "Bitcoin"),
            ("ETH", "Ethereum"),
            ("ADA", "Cardano"),
            ("SOL", "Solana"),
            ("DOT", "Polkadot"),
            ("LTC", "Litecoin"),
            ("XRP", "Ripple"),
            ("DOGE", "Dogecoin"),
            ("SHIB", "Shiba Inu"),
            ("MATIC", "Polygon"),
            ("LINK", "Chainlink"),
            ("UNI", "Uniswap"),
            ("AVAX", "Avalanche"),
            ("ATOM", "Cosmos"),
            ("FTM", "Fantom")
        ]
        
        let matchingCryptos = commonCryptos.filter { crypto in
            crypto.0.uppercased().contains(query.uppercased()) ||
            crypto.1.uppercased().contains(query.uppercased())
        }
        
        print("🪙 Fallback found \(matchingCryptos.count) cryptos")
        for crypto in matchingCryptos {
            print("   🪙 \(crypto.0) - \(crypto.1)")
        }
        
        let cryptos = matchingCryptos.map { symbol, name in
            Cryptocurrency(
                symbol: symbol,
                name: name,
                currentPrice: 0.0,
                previousPrice: 0.0,
                change24h: 0.0,
                changePercent24h: 0.0,
                marketCap: nil,
                volume24h: nil,
                high24h: nil,
                low24h: nil
            )
        }
        
        return Just(cryptos).setFailureType(to: Error.self).eraseToAnyPublisher()
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
    
    enum CodingKeys: String, CodingKey {
        case bestMatches = "bestMatches"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle case where bestMatches might be empty or missing
        if let matches = try? container.decode([SymbolMatch].self, forKey: .bestMatches) {
            self.bestMatches = matches
        } else {
            print("⚠️ No bestMatches found in response")
            self.bestMatches = []
        }
    }
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

// MARK: - Notification Names
extension Notification.Name {
    static let holdingPriceUpdated = Notification.Name("holdingPriceUpdated")
} 
