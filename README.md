# ivnest - Investment Simulation App

A comprehensive iOS app for simulating stock and cryptocurrency investments without real financial risk.

## Features

### Core Functionality
- **Virtual Portfolio Management**: Create and manage multiple investment portfolios
- **Stock Trading**: Simulate buying and selling stocks with real-time market data
- **Cryptocurrency Trading**: Trade popular cryptocurrencies like Bitcoin, Ethereum, and more
- **Deposit System**: Add virtual funds to your account to start trading
- **Real-time Market Data**: Get live price updates for stocks and crypto

### Analytics & Statistics
- **Total ROI Tracking**: Monitor your overall return on investment
- **Monthly Performance**: Track average monthly gains/losses
- **Portfolio Analytics**: Detailed breakdown of your investment performance
- **Trade History**: Complete log of all your transactions
- **Performance Charts**: Visual representation of your portfolio growth

### User Experience
- **Intuitive Interface**: Clean, modern UI designed for easy navigation
- **Portfolio Dashboard**: Overview of all your investments at a glance
- **Watchlist**: Track stocks and crypto you're interested in
- **Notifications**: Get alerts for significant price movements
- **Dark Mode Support**: Comfortable viewing in any lighting condition

## Technical Stack

- **Language**: Swift 5.0+
- **Framework**: UIKit
- **Architecture**: MVC (Model-View-Controller) 
- **Data Persistence**: Core Data
- **Networking**: URLSession for API calls
- **Charts**: Core Graphics for custom charting

## Project Structure

```
ivnest/
├── Models/           # Data models for stocks, crypto, portfolios
├── Views/            # Custom UI components and view controllers
├── Controllers/      # Business logic and data management
├── Services/         # API services and data fetching
├── Utils/            # Helper functions and extensions
└── Resources/        # Assets, storyboards, and configuration files
```

## Getting Started

### Prerequisites
- Xcode 14.0 or later
- iOS 15.0+ deployment target
- macOS 12.0 or later (for development)

### Installation
1. Clone the repository
2. Open `ivnest.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run the project

### API Keys Required
- **Alpha Vantage API**: For stock market data
- **CoinGecko API**: For cryptocurrency data

## Development Roadmap

### Phase 1: Core Infrastructure ✅
- [x] Project setup and basic structure
- [ ] Data models for stocks, crypto, and portfolios
- [ ] Core Data setup for local storage
- [ ] Basic UI framework

### Phase 2: Trading Features
- [ ] Stock trading interface
- [ ] Cryptocurrency trading interface
- [ ] Portfolio management
- [ ] Deposit system

### Phase 3: Analytics & Statistics
- [ ] ROI calculations
- [ ] Performance tracking
- [ ] Chart visualizations
- [ ] Trade history

### Phase 4: Enhanced Features
- [ ] Real-time price updates
- [ ] Watchlist functionality
- [ ] Push notifications
- [ ] Advanced analytics

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Disclaimer

This app is for educational and entertainment purposes only. It simulates trading without using real money. Past performance does not guarantee future results. Always do your own research before making real investment decisions.

## Support

For support, email support@ivnest.app or create an issue in this repository. 