//
//  TransactionHistoryViewController.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import UIKit
import Combine

class TransactionHistoryViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView = UITableView()
    private let segmentedControl = UISegmentedControl(items: ["All", "Buys", "Sells", "Deposits"])
    
    // MARK: - Services
    private let portfolioManager = PortfolioManager.shared
    
    // MARK: - State
    private var filteredTransactions: [Transaction] = []
    private var selectedFilter: TransactionFilter = .all
    
    enum TransactionFilter: Int {
        case all = 0
        case buys = 1
        case sells = 2
        case deposits = 3
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupObservers()
        loadTransactions()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .black
        title = "Transaction History"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barStyle = .black
        
        // Setup segmented control
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
        
        // Setup table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TransactionTableViewCell.self, forCellReuseIdentifier: "TransactionCell")
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Data Loading
    private func setupObservers() {
        portfolioManager.$currentPortfolio
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadTransactions()
            }
            .store(in: &cancellables)
    }
    
    private func loadTransactions() {
        let allTransactions = portfolioManager.currentPortfolio.transactions
        filteredTransactions = filterTransactions(allTransactions, by: selectedFilter)
        tableView.reloadData()
    }
    
    private func filterTransactions(_ transactions: [Transaction], by filter: TransactionFilter) -> [Transaction] {
        switch filter {
        case .all:
            return transactions.sorted { $0.timestamp > $1.timestamp }
        case .buys:
            return transactions.filter { $0.type == .buy }.sorted { $0.timestamp > $1.timestamp }
        case .sells:
            return transactions.filter { $0.type == .sell }.sorted { $0.timestamp > $1.timestamp }
        case .deposits:
            return transactions.filter { $0.type == .deposit || $0.type == .withdrawal }.sorted { $0.timestamp > $1.timestamp }
        }
    }
    
    // MARK: - Actions
    @objc private func filterChanged() {
        selectedFilter = TransactionFilter(rawValue: segmentedControl.selectedSegmentIndex) ?? .all
        loadTransactions()
    }
    
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - UITableViewDataSource
extension TransactionHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTransactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionTableViewCell
        let transaction = filteredTransactions[indexPath.row]
        cell.configure(with: transaction)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TransactionHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - Transaction Table View Cell
class TransactionTableViewCell: UITableViewCell {
    
    private let typeLabel = UILabel()
    private let symbolLabel = UILabel()
    private let quantityLabel = UILabel()
    private let priceLabel = UILabel()
    private let totalLabel = UILabel()
    private let dateLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        typeLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        symbolLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        symbolLabel.textColor = .white
        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        
        quantityLabel.font = .systemFont(ofSize: 12, weight: .medium)
        quantityLabel.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        priceLabel.font = .systemFont(ofSize: 12, weight: .medium)
        priceLabel.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        totalLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        totalLabel.textColor = .white
        totalLabel.textAlignment = .right
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabel.font = .systemFont(ofSize: 12, weight: .medium)
        dateLabel.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        dateLabel.textAlignment = .right
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(typeLabel)
        contentView.addSubview(symbolLabel)
        contentView.addSubview(quantityLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(totalLabel)
        contentView.addSubview(dateLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            typeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            typeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            symbolLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 4),
            symbolLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            quantityLabel.topAnchor.constraint(equalTo: symbolLabel.bottomAnchor, constant: 2),
            quantityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            quantityLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            priceLabel.topAnchor.constraint(equalTo: quantityLabel.topAnchor),
            priceLabel.leadingAnchor.constraint(equalTo: quantityLabel.trailingAnchor, constant: 16),
            
            totalLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            totalLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dateLabel.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: 4),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with transaction: Transaction) {
        // Configure type label with color
        typeLabel.text = transaction.type.rawValue.uppercased()
        switch transaction.type {
        case .buy:
            typeLabel.textColor = .systemGreen
        case .sell:
            typeLabel.textColor = .systemRed
        case .deposit:
            typeLabel.textColor = .systemBlue
        case .withdrawal:
            typeLabel.textColor = .systemOrange
        }
        
        symbolLabel.text = transaction.symbol
        quantityLabel.text = "Qty: \(FormattingUtils.formatNumber(transaction.quantity, maximumFractionDigits: 4))"
        priceLabel.text = "Price: \(FormattingUtils.formatCurrency(transaction.price))"
        totalLabel.text = FormattingUtils.formatCurrency(transaction.totalAmount)
        dateLabel.text = FormattingUtils.formatDateTime(transaction.timestamp)
    }
} 