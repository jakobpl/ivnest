//
//  SearchResultTableViewCell.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    private let containerView = UIView()
    private let symbolLabel = UILabel()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let changeLabel = UILabel()
    private let assetTypeIcon = UIImageView()
    
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
        backgroundColor = .clear
        selectionStyle = .none
        
        // Container view
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.8)
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0).cgColor
        
        // Symbol label
        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        symbolLabel.font = .systemFont(ofSize: 18, weight: .bold)
        symbolLabel.textColor = .white
        
        // Name label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 14, weight: .medium)
        nameLabel.textColor = .systemGray
        nameLabel.numberOfLines = 2
        
        // Price label
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        priceLabel.textColor = .white
        priceLabel.textAlignment = .right
        
        // Change label
        changeLabel.translatesAutoresizingMaskIntoConstraints = false
        changeLabel.font = .systemFont(ofSize: 14, weight: .medium)
        changeLabel.textAlignment = .right
        
        // Asset type icon
        assetTypeIcon.translatesAutoresizingMaskIntoConstraints = false
        assetTypeIcon.contentMode = .scaleAspectFit
        assetTypeIcon.tintColor = .systemGray
        
        // Add subviews
        containerView.addSubview(assetTypeIcon)
        containerView.addSubview(symbolLabel)
        containerView.addSubview(nameLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(changeLabel)
        contentView.addSubview(containerView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            // Asset type icon
            assetTypeIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            assetTypeIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            assetTypeIcon.widthAnchor.constraint(equalToConstant: 20),
            assetTypeIcon.heightAnchor.constraint(equalToConstant: 20),
            
            // Symbol label
            symbolLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            symbolLabel.leadingAnchor.constraint(equalTo: assetTypeIcon.trailingAnchor, constant: 12),
            symbolLabel.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor, constant: -12),
            
            // Name label
            nameLabel.topAnchor.constraint(equalTo: symbolLabel.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: symbolLabel.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: changeLabel.leadingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            // Price label
            priceLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            priceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Change label
            changeLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 4),
            changeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            changeLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configuration
    func configure(with result: SearchResult) {
        symbolLabel.text = result.symbol
        nameLabel.text = result.name
        priceLabel.text = FormattingUtils.formatCurrency(result.currentPrice)
        
        // Configure change label
        let changeText = String(format: "%.2f%%", result.changePercent)
        changeLabel.text = changeText
        
        if result.changePercent >= 0 {
            changeLabel.textColor = .systemGreen
        } else {
            changeLabel.textColor = .systemRed
        }
        
        // Configure asset type icon
        switch result.assetType {
        case .stock:
            assetTypeIcon.image = UIImage(systemName: "chart.line.uptrend.xyaxis")
        case .cryptocurrency:
            assetTypeIcon.image = UIImage(systemName: "bitcoinsign.circle")
        }
    }
    
    // MARK: - Selection Animation
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: 0.2) {
            if highlighted {
                self.containerView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
                self.containerView.alpha = 0.8
            } else {
                self.containerView.transform = .identity
                self.containerView.alpha = 1.0
            }
        }
    }
} 