//
//  BaseTableViewCell.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    let symbolLabel = UILabel()
    let nameLabel = UILabel()
    let primaryValueLabel = UILabel()
    let secondaryValueLabel = UILabel()
    let tertiaryValueLabel = UILabel()
    
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
        
        // Primary value label (price, current value, etc.)
        primaryValueLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        primaryValueLabel.textColor = .white
        primaryValueLabel.textAlignment = .right
        primaryValueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Secondary value label (change, gain/loss, etc.)
        secondaryValueLabel.font = .systemFont(ofSize: 12, weight: .medium)
        secondaryValueLabel.textAlignment = .right
        secondaryValueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Tertiary value label (change percent, gain/loss percent, etc.)
        tertiaryValueLabel.font = .systemFont(ofSize: 12, weight: .medium)
        tertiaryValueLabel.textAlignment = .right
        tertiaryValueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        contentView.addSubview(symbolLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(primaryValueLabel)
        contentView.addSubview(secondaryValueLabel)
        contentView.addSubview(tertiaryValueLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            symbolLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            symbolLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            symbolLabel.trailingAnchor.constraint(lessThanOrEqualTo: primaryValueLabel.leadingAnchor, constant: -8),
            
            nameLabel.topAnchor.constraint(equalTo: symbolLabel.bottomAnchor, constant: 2),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: secondaryValueLabel.leadingAnchor, constant: -8),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            primaryValueLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            primaryValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            secondaryValueLabel.topAnchor.constraint(equalTo: primaryValueLabel.bottomAnchor, constant: 2),
            secondaryValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            tertiaryValueLabel.topAnchor.constraint(equalTo: secondaryValueLabel.bottomAnchor, constant: 2),
            tertiaryValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tertiaryValueLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configuration Methods
    func configure(symbol: String, name: String, primaryValue: String, secondaryValue: String, tertiaryValue: String, secondaryColor: UIColor = .systemGreen, tertiaryColor: UIColor = .systemGreen) {
        symbolLabel.text = symbol
        nameLabel.text = name
        primaryValueLabel.text = primaryValue
        secondaryValueLabel.text = secondaryValue
        tertiaryValueLabel.text = tertiaryValue
        
        secondaryValueLabel.textColor = secondaryColor
        tertiaryValueLabel.textColor = tertiaryColor
    }
} 