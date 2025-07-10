//
//  PortfolioStatsGridView.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import UIKit

class PortfolioStatsGridView: UIView {
    
    // MARK: - UI Components
    private let stackView = UIStackView()
    
    // Row 1
    private let allTimeReturnTile = StatTile()
    private let ytdReturnTile = StatTile()
    
    // Row 2
    private let maxDrawdownTile = StatTile()
    private let sharpeRatioTile = StatTile()
    
    // Row 3
    private let cashPercentageTile = StatTile()
    private let topHoldingTile = StatTile()
    
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
        backgroundColor = .clear
        
        // Setup stack view
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        
        // Create rows
        let row1 = createRow(tile1: allTimeReturnTile, tile2: ytdReturnTile)
        let row2 = createRow(tile1: maxDrawdownTile, tile2: sharpeRatioTile)
        let row3 = createRow(tile1: cashPercentageTile, tile2: topHoldingTile)
        
        // Add rows to stack view
        stackView.addArrangedSubview(row1)
        stackView.addArrangedSubview(row2)
        stackView.addArrangedSubview(row3)
        
        addSubview(stackView)
        
        // Configure tiles
        allTimeReturnTile.configure(label: "All-Time Return", value: "0.0", unit: "%")
        ytdReturnTile.configure(label: "YTD Return", value: "0.0", unit: "%")
        maxDrawdownTile.configure(label: "Max Drawdown", value: "0.0", unit: "%")
        sharpeRatioTile.configure(label: "Sharpe Ratio", value: "0.0", unit: "")
        cashPercentageTile.configure(label: "Cash %", value: "0.0", unit: "%")
        topHoldingTile.configure(label: "Top Holding", value: "N/A", unit: "")
    }
    
    private func createRow(tile1: StatTile, tile2: StatTile) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 12
        row.distribution = .fillEqually
        
        row.addArrangedSubview(tile1)
        row.addArrangedSubview(tile2)
        
        return row
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Public Methods
    func updateStats(allTimeReturn: Double, ytdReturn: Double, maxDrawdown: Double, sharpeRatio: Double, cashPercentage: Double, topHolding: String) {
        allTimeReturnTile.updateValue(String(format: "%.1f", allTimeReturn))
        ytdReturnTile.updateValue(String(format: "%.1f", ytdReturn))
        maxDrawdownTile.updateValue(String(format: "%.1f", maxDrawdown))
        sharpeRatioTile.updateValue(String(format: "%.2f", sharpeRatio))
        cashPercentageTile.updateValue(String(format: "%.1f", cashPercentage))
        topHoldingTile.updateValue(topHolding)
    }
}

// MARK: - Stat Tile
class StatTile: UIView {
    
    // MARK: - UI Components
    private let label = UILabel()
    private let value = UILabel()
    private let unit = UILabel()
    
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
        
        // Label
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        // Value
        value.font = .systemFont(ofSize: 18, weight: .bold)
        value.textColor = .white
        value.textAlignment = .center
        value.translatesAutoresizingMaskIntoConstraints = false
        addSubview(value)
        
        // Unit
        unit.font = .systemFont(ofSize: 10, weight: .medium)
        unit.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        unit.textAlignment = .center
        unit.translatesAutoresizingMaskIntoConstraints = false
        addSubview(unit)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            value.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            value.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            value.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            unit.topAnchor.constraint(equalTo: value.bottomAnchor, constant: 4),
            unit.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            unit.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            unit.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Public Methods
    func configure(label: String, value: String, unit: String) {
        self.label.text = label
        self.value.text = value
        self.unit.text = unit
    }
    
    func updateValue(_ newValue: String) {
        value.text = newValue
    }
} 