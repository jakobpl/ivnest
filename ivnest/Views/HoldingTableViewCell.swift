//
//  HoldingTableViewCell.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import UIKit

class HoldingTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    private let symbolLabel = UILabel()
    private let nameLabel = UILabel()
    private let quantityLabel = UILabel()
    private let currentValueLabel = UILabel()
    private let gainLossLabel = UILabel()
    private let gainLossPercentLabel = UILabel()
    
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
        
        // Quantity label
        quantityLabel.font = .systemFont(ofSize: 12, weight: .medium)
        quantityLabel.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Current value label
        currentValueLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        currentValueLabel.textColor = .white
        currentValueLabel.textAlignment = .right
        currentValueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Gain/Loss label
        gainLossLabel.font = .systemFont(ofSize: 12, weight: .medium)
        gainLossLabel.textAlignment = .right
        gainLossLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Gain/Loss percent label
        gainLossPercentLabel.font = .systemFont(ofSize: 12, weight: .medium)
        gainLossPercentLabel.textAlignment = .right
        gainLossPercentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        contentView.addSubview(symbolLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(quantityLabel)
        contentView.addSubview(currentValueLabel)
        contentView.addSubview(gainLossLabel)
        contentView.addSubview(gainLossPercentLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            symbolLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            symbolLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            symbolLabel.trailingAnchor.constraint(lessThanOrEqualTo: currentValueLabel.leadingAnchor, constant: -8),
            
            nameLabel.topAnchor.constraint(equalTo: symbolLabel.bottomAnchor, constant: 2),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: gainLossLabel.leadingAnchor, constant: -8),
            
            quantityLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            quantityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            quantityLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            currentValueLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            currentValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            gainLossLabel.topAnchor.constraint(equalTo: currentValueLabel.bottomAnchor, constant: 2),
            gainLossLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            gainLossPercentLabel.topAnchor.constraint(equalTo: gainLossLabel.bottomAnchor, constant: 2),
            gainLossPercentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            gainLossPercentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configuration
    func configure(with holding: Holding) {
        symbolLabel.text = holding.symbol
        nameLabel.text = holding.name
        quantityLabel.text = "\(formatQuantity(holding.quantity)) shares"
        currentValueLabel.text = formatCurrency(holding.currentValue)
        
        // Configure gain/loss
        gainLossLabel.text = formatCurrency(holding.unrealizedGainLoss)
        gainLossLabel.textColor = holding.unrealizedGainLoss >= 0 ? .systemGreen : .systemRed
        
        gainLossPercentLabel.text = String(format: "%.2f%%", holding.unrealizedGainLossPercent)
        gainLossPercentLabel.textColor = holding.unrealizedGainLossPercent >= 0 ? .systemGreen : .systemRed
    }
    
    // MARK: - Helpers
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    private func formatQuantity(_ quantity: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 4
        return formatter.string(from: NSNumber(value: quantity)) ?? "0"
    }
} 