//
//  HoldingDetailViewController.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import UIKit

class HoldingDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let holding: Holding
    private let portfolioManager = PortfolioManager.shared
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let headerView = UIView()
    private let symbolLabel = UILabel()
    private let nameLabel = UILabel()
    private let currentPriceLabel = UILabel()
    private let changeLabel = UILabel()
    private let changePercentLabel = UILabel()
    
    private let detailsStackView = UIStackView()
    private let quantityLabel = UILabel()
    private let averagePriceLabel = UILabel()
    private let totalInvestedLabel = UILabel()
    private let currentValueLabel = UILabel()
    private let gainLossLabel = UILabel()
    private let gainLossPercentLabel = UILabel()
    
    private let actionButton = UIButton()
    
    // MARK: - Initialization
    init(holding: Holding) {
        self.holding = holding
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        configureWithHolding()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .black
        title = holding.symbol
        navigationController?.navigationBar.barStyle = .black
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Setup header view
        setupHeaderView()
        
        // Setup details stack view
        setupDetailsStackView()
        
        // Setup action button
        setupActionButton()
        
        // Add subviews
        contentView.addSubview(headerView)
        contentView.addSubview(detailsStackView)
        contentView.addSubview(actionButton)
    }
    
    private func setupHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
        headerView.layer.cornerRadius = 12
        
        symbolLabel.textColor = .white
        symbolLabel.font = .systemFont(ofSize: 24, weight: .bold)
        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        currentPriceLabel.textColor = .white
        currentPriceLabel.font = .systemFont(ofSize: 32, weight: .bold)
        currentPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        changeLabel.textColor = .white
        changeLabel.font = .systemFont(ofSize: 16, weight: .medium)
        changeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        changePercentLabel.textColor = .white
        changePercentLabel.font = .systemFont(ofSize: 16, weight: .medium)
        changePercentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(symbolLabel)
        headerView.addSubview(nameLabel)
        headerView.addSubview(currentPriceLabel)
        headerView.addSubview(changeLabel)
        headerView.addSubview(changePercentLabel)
        
        NSLayoutConstraint.activate([
            symbolLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            symbolLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            
            nameLabel.topAnchor.constraint(equalTo: symbolLabel.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            
            currentPriceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
            currentPriceLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            currentPriceLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            
            changeLabel.topAnchor.constraint(equalTo: currentPriceLabel.topAnchor),
            changeLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            changePercentLabel.topAnchor.constraint(equalTo: changeLabel.bottomAnchor, constant: 4),
            changePercentLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupDetailsStackView() {
        detailsStackView.translatesAutoresizingMaskIntoConstraints = false
        detailsStackView.axis = .vertical
        detailsStackView.spacing = 16
        detailsStackView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        detailsStackView.layer.cornerRadius = 12
        detailsStackView.layer.borderWidth = 1
        detailsStackView.layer.borderColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0).cgColor
        
        // Create detail rows
        quantityLabel.font = .systemFont(ofSize: 16, weight: .medium)
        quantityLabel.textColor = .white
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        averagePriceLabel.font = .systemFont(ofSize: 16, weight: .medium)
        averagePriceLabel.textColor = .white
        averagePriceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        totalInvestedLabel.font = .systemFont(ofSize: 16, weight: .medium)
        totalInvestedLabel.textColor = .white
        totalInvestedLabel.translatesAutoresizingMaskIntoConstraints = false
        
        currentValueLabel.font = .systemFont(ofSize: 16, weight: .medium)
        currentValueLabel.textColor = .white
        currentValueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        gainLossLabel.font = .systemFont(ofSize: 16, weight: .medium)
        gainLossLabel.translatesAutoresizingMaskIntoConstraints = false
        
        gainLossPercentLabel.font = .systemFont(ofSize: 16, weight: .medium)
        gainLossPercentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to stack view
        detailsStackView.addArrangedSubview(quantityLabel)
        detailsStackView.addArrangedSubview(averagePriceLabel)
        detailsStackView.addArrangedSubview(totalInvestedLabel)
        detailsStackView.addArrangedSubview(currentValueLabel)
        detailsStackView.addArrangedSubview(gainLossLabel)
        detailsStackView.addArrangedSubview(gainLossPercentLabel)
        
        // Add padding
        detailsStackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        detailsStackView.isLayoutMarginsRelativeArrangement = true
    }
    
    private func setupActionButton() {
        actionButton.setTitle("Sell", for: .normal)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        actionButton.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        actionButton.layer.cornerRadius = 12
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            headerView.heightAnchor.constraint(equalToConstant: 120),
            
            detailsStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            detailsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            actionButton.topAnchor.constraint(equalTo: detailsStackView.bottomAnchor, constant: 24),
            actionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            actionButton.heightAnchor.constraint(equalToConstant: 50),
            actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Configuration
    private func configureWithHolding() {
        symbolLabel.text = holding.symbol
        nameLabel.text = holding.name
        currentPriceLabel.text = formatCurrency(holding.currentPrice)
        
        let change = holding.currentPrice - holding.averagePrice
        changeLabel.text = formatCurrency(change)
        changeLabel.textColor = change >= 0 ? .white : .systemRed
        
        let changePercent = (change / holding.averagePrice) * 100
        changePercentLabel.text = String(format: "%.2f%%", changePercent)
        changePercentLabel.textColor = changePercent >= 0 ? .white : .systemRed
        
        quantityLabel.text = "Quantity: \(formatQuantity(holding.quantity))"
        averagePriceLabel.text = "Average Price: \(formatCurrency(holding.averagePrice))"
        totalInvestedLabel.text = "Total Invested: \(formatCurrency(holding.totalInvested))"
        currentValueLabel.text = "Current Value: \(formatCurrency(holding.currentValue))"
        
        gainLossLabel.text = "Gain/Loss: \(formatCurrency(holding.unrealizedGainLoss))"
        gainLossLabel.textColor = holding.unrealizedGainLoss >= 0 ? .systemGreen : .systemRed
        
        gainLossPercentLabel.text = "Gain/Loss %: \(String(format: "%.2f%%", holding.unrealizedGainLossPercent))"
        gainLossPercentLabel.textColor = holding.unrealizedGainLossPercent >= 0 ? .systemGreen : .systemRed
    }
    
    // MARK: - Actions
    @objc private func actionButtonTapped() {
        let alert = UIAlertController(title: "Sell \(holding.symbol)", message: "Enter quantity to sell", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Quantity"
            textField.keyboardType = .decimalPad
            textField.text = String(format: "%.4f", self.holding.quantity)
        }
        
        let sellAction = UIAlertAction(title: "Sell", style: .destructive) { [weak self] _ in
            if let quantityText = alert.textFields?.first?.text,
               let quantity = Double(quantityText),
               quantity > 0 && quantity <= self?.holding.quantity ?? 0 {
                
                let success: Bool
                if self?.holding.assetType == .stock {
                    success = self?.portfolioManager.sellStock(symbol: self?.holding.symbol ?? "", quantity: quantity, price: self?.holding.currentPrice ?? 0) ?? false
                } else {
                    success = self?.portfolioManager.sellCrypto(symbol: self?.holding.symbol ?? "", quantity: quantity, price: self?.holding.currentPrice ?? 0) ?? false
                }
                
                if success {
                    self?.showSuccessAlert()
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    self?.showErrorAlert()
                }
            } else {
                self?.showErrorAlert()
            }
        }
        
        alert.addAction(sellAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - Alerts
    private func showSuccessAlert() {
        let alert = UIAlertController(title: "Success", message: "Sale completed successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Invalid sale quantity or insufficient shares.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Helpers
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    private func formatQuantity(_ quantity: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 4
        return formatter.string(from: NSNumber(value: quantity)) ?? "0"
    }
} 
