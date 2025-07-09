//
//  AssetTableViewCell.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import UIKit

class AssetTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    private let symbolLabel = UILabel()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let changeLabel = UILabel()
    private let changePercentLabel = UILabel()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        // Symbol label
        symbolLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        symbolLabel.textColor = .white
        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Name label
        nameLabel.font = .systemFont(ofSize: 12, weight: .regular)
        nameLabel.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Price label
        priceLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        priceLabel.textColor = .white
        priceLabel.textAlignment = .right
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Change label
        changeLabel.font = .systemFont(ofSize: 12, weight: .medium)
        changeLabel.textAlignment = .right
        changeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Change percent label
        changePercentLabel.font = .systemFont(ofSize: 12, weight: .medium)
        changePercentLabel.textAlignment = .right
        changePercentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        contentView.addSubview(symbolLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(changeLabel)
        contentView.addSubview(changePercentLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            symbolLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            symbolLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            symbolLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceLabel.leadingAnchor, constant: -8),
            
            nameLabel.topAnchor.constraint(equalTo: symbolLabel.bottomAnchor, constant: 2),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: changeLabel.leadingAnchor, constant: -8),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            priceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            changeLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 2),
            changeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            changePercentLabel.topAnchor.constraint(equalTo: changeLabel.bottomAnchor, constant: 2),
            changePercentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            changePercentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configuration
    func configure(with stock: Stock) {
        symbolLabel.text = stock.symbol
        nameLabel.text = stock.name
        priceLabel.text = formatCurrency(stock.currentPrice)
        
        changeLabel.text = formatCurrency(stock.change)
        changeLabel.textColor = stock.change >= 0 ? .systemGreen : .systemRed
        
        changePercentLabel.text = String(format: "%.2f%%", stock.changePercent)
        changePercentLabel.textColor = stock.changePercent >= 0 ? .systemGreen : .systemRed
    }
    
    func configure(with crypto: Cryptocurrency) {
        symbolLabel.text = crypto.symbol
        nameLabel.text = crypto.name
        priceLabel.text = formatCurrency(crypto.currentPrice)
        
        changeLabel.text = formatCurrency(crypto.change24h)
        changeLabel.textColor = crypto.change24h >= 0 ? .systemGreen : .systemRed
        
        changePercentLabel.text = String(format: "%.2f%%", crypto.changePercent24h)
        changePercentLabel.textColor = crypto.changePercent24h >= 0 ? .systemGreen : .systemRed
    }
    
    // MARK: - Helpers
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
} 