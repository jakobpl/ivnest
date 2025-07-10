//
//  PortfolioStatsView.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import UIKit

class PortfolioStatsView: UIView {
    
    // MARK: - UI Components
    private let totalValueLabel = UILabel()
    private let totalValueAmountLabel = UILabel()
    private let totalInvestedLabel = UILabel()
    private let totalInvestedAmountLabel = UILabel()
    private let roiLabel = UILabel()
    private let roiAmountLabel = UILabel()
    private let balanceLabel = UILabel()
    private let balanceAmountLabel = UILabel()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1.0)
        layer.cornerRadius = 12
        
        // Total Value
        totalValueLabel.text = "Total Value"
        totalValueLabel.font = .systemFont(ofSize: 12, weight: .medium)
        totalValueLabel.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        totalValueLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(totalValueLabel)
        
        totalValueAmountLabel.font = .systemFont(ofSize: 18, weight: .bold)
        totalValueAmountLabel.textColor = .white
        totalValueAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(totalValueAmountLabel)
        
        // Total Invested
        totalInvestedLabel.text = "Total Invested"
        totalInvestedLabel.font = .systemFont(ofSize: 12, weight: .medium)
        totalInvestedLabel.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        totalInvestedLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(totalInvestedLabel)
        
        totalInvestedAmountLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        totalInvestedAmountLabel.textColor = .white
        totalInvestedAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(totalInvestedAmountLabel)
        
        // ROI
        roiLabel.text = "Total ROI"
        roiLabel.font = .systemFont(ofSize: 12, weight: .medium)
        roiLabel.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        roiLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(roiLabel)
        
        roiAmountLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        roiAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(roiAmountLabel)
        
        // Balance
        balanceLabel.text = "Available Balance"
        balanceLabel.font = .systemFont(ofSize: 12, weight: .medium)
        balanceLabel.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(balanceLabel)
        
        balanceAmountLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        balanceAmountLabel.textColor = .white
        balanceAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(balanceAmountLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Total Value
            totalValueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            totalValueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            totalValueAmountLabel.topAnchor.constraint(equalTo: totalValueLabel.bottomAnchor, constant: 4),
            totalValueAmountLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            totalValueAmountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // Total Invested
            totalInvestedLabel.topAnchor.constraint(equalTo: totalValueAmountLabel.bottomAnchor, constant: 12),
            totalInvestedLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            totalInvestedAmountLabel.topAnchor.constraint(equalTo: totalInvestedLabel.bottomAnchor, constant: 4),
            totalInvestedAmountLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            totalInvestedAmountLabel.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -8),
            
            // ROI
            roiLabel.topAnchor.constraint(equalTo: totalValueAmountLabel.bottomAnchor, constant: 12),
            roiLabel.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 8),
            
            roiAmountLabel.topAnchor.constraint(equalTo: roiLabel.bottomAnchor, constant: 4),
            roiAmountLabel.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 8),
            roiAmountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // Balance
            balanceLabel.topAnchor.constraint(equalTo: totalInvestedAmountLabel.bottomAnchor, constant: 12),
            balanceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            balanceAmountLabel.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 4),
            balanceAmountLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            balanceAmountLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Public Methods
    func updateStats(totalValue: Double, totalInvested: Double, totalROI: Double, balance: Double) {
        totalValueAmountLabel.text = FormattingUtils.formatCurrency(totalValue)
        totalInvestedAmountLabel.text = FormattingUtils.formatCurrency(totalInvested)
        
        // Format ROI with color
        let roiText = String(format: "%.2f%%", totalROI)
        roiAmountLabel.text = roiText
        roiAmountLabel.textColor = totalROI >= 0 ? UIColor.systemGreen : UIColor.systemRed
        
        balanceAmountLabel.text = FormattingUtils.formatCurrency(balance)
    }
} 